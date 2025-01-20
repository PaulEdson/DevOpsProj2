#required providers block pulled from documentation
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    local = {
        source = "hashicorp/local"
        version = "2.5.1"
    }
  }

  required_version = ">= 1.2.0"
}

#aws provider from required providers block
provider "aws" {
  region  = "us-east-1"
}

#------------------VPC-Creation--------------------
#create empty vpc to deploy to
resource "aws_vpc" "proj2-pje" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "proj2-pje"
    BatchID = "DevOps"
  }
}

#creates private subnets using the variablle list created in variables.tf
resource "aws_subnet" "private_subnets"{
    for_each = var.private_subnets
    vpc_id = aws_vpc.proj2-pje.id
    cidr_block = cidrsubnet(var.vpc_cidr, 8, each.value)
    #pulling from data.tf to get current availibility zones
    availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]

    tags = {
        Name = "${each.key}-pje"
        BatchID = "DevOps"
    }
}

#creates public subnets using the variable list created in variables.tf
resource "aws_subnet" "public_subnets"{
    for_each = var.public_subnets
    vpc_id = aws_vpc.proj2-pje.id
    cidr_block = cidrsubnet(var.vpc_cidr, 8, each.value+100)
    #pulling from data.tf to get current availability zones
    availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]

    tags = {
        Name = "${each.key}-pje"
        BatchID = "DevOps"
    }
}

#creates and assigns an internet gateway for us
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.proj2-pje.id

  tags = {
    Name = "internet-gateway-pje"
    BatchID = "DevOps"
  }
}

resource "aws_eip" "nat_gateway_eip" {
    depends_on = [ aws_internet_gateway.internet_gateway ]
    tags = {
        Name = "nat-gateway-eip-pje"
        BatchID = "DevOps"
    }
}

resource "aws_nat_gateway" "nat_gateway" {
    depends_on = [aws_subnet.public_subnets]
    allocation_id = aws_eip.nat_gateway_eip.id
    subnet_id = aws_subnet.public_subnets["public_subnet_1"].id
    tags = {
        Name = "nat-gateway-pje"
        BatchID = "DevOps"
    }
}

#creates public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.proj2-pje.id

  #we are allowing all traffic from the internet right now through the igw
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "public-route-table-pje"
    BatchID = "DevOps"
  }
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.proj2-pje.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat_gateway.id
    }

    tags = {
        Name = "private-route-table-pje"
        BatchID = "DevOps"
    }
}

#creates association between public route table and public subnets
resource "aws_route_table_association" "public_routes" {
    depends_on = [ aws_subnet.public_subnets ]
    route_table_id = aws_route_table.public_route_table.id
    for_each = aws_subnet.public_subnets
    subnet_id = each.value.id
}

#private asociations
resource "aws_route_table_association" "private_routes" {
    depends_on = [ aws_subnet.private_subnets ]
    route_table_id = aws_route_table.private_route_table.id
    for_each = aws_subnet.private_subnets
    subnet_id = each.value.id
}

#Security Groups example
resource "aws_security_group" "terraform_sg" {
  name        = "terraform_sg"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = aws_vpc.proj2-pje.id

  tags = {
    Name = "terraform-sg-pje"
  }
}

#-----------------VPC-Security_group-----------------------------
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.terraform_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.terraform_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.terraform_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.terraform_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#------------------------------EC2-instance----------------------------
#creating key pair
resource "tls_private_key" "rsa4096" {
    algorithm = "RSA"
    rsa_bits = 4096
}

#local pem file use for ssh
resource "local_file" "private_key_pem" {
    content = tls_private_key.rsa4096.private_key_pem
    filename = "terraform_pje.pem"
}

#creating key on aws
resource "aws_key_pair" "public_key" {
    key_name = "public-key-pje"
    public_key = tls_private_key.rsa4096.public_key_openssh
    lifecycle {
      ignore_changes = [ key_name ]
    }
}

resource "aws_instance" "app_server" {
  ami           = "ami-05576a079321f21f8"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnets["public_subnet_1"].id
  vpc_security_group_ids = [aws_security_group.terraform_sg.id]
  associate_public_ip_address = "true"
  key_name = aws_key_pair.public_key.key_name
  connection {
    user = "ec2-user"
    private_key = tls_private_key.rsa4096.private_key_pem
    host = self.public_ip
  }
  provisioner "local-exec" {
    #commands to give permisions to private key for windows
    command = "chmod 600 ${local_file.private_key_pem.filename}"
    # inline = [
    #     "icacls ${local_file.private_key_pem.filename} /grant %username%:rw",
    #     "icacls ${local_file.private_key_pem.filename} /grant %username%:rw",
    #     "icacls ${local_file.private_key_pem.filename} /remove *S-1-5-11 *S-1-5-18 *S-1-5-32-544 *S-1-5-32-545"
    # ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -m777 paul",
      "cd paul",
      "sudo mkdir -m777 edson"
        # "sudo rm -rf /tmp",
        # "sudo git clone https://github.com/hashicorp/demo-terraform-101 /tmp",
        # "sudo sh /tmp/assets/setup-web.sh"
    ]
}
  tags = {
    Name = "app-server-pje"
    BatchID = "DevOps"
  }
}


#----------------S3---------------
resource "aws_s3_bucket" "s3-bucket" {
  bucket = "angular-frontend-pje"
  tags = {
    Name = "angular-frontend-pje"
    BatchID = "DevOps"
  }
}

resource "aws_s3_bucket_ownership_controls" "ownership_controls" {
  bucket = aws_s3_bucket.s3-bucket.id
  rule{
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.s3-bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}