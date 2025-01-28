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
#-----------------VPC-Security_groups-----------------------------
#private security group
resource "aws_security_group" "terraform_sg" {
  name        = "terraform_sg"
  description = "Allow all needed traffic within security group"
  vpc_id      = aws_vpc.proj2-pje.id

  tags = {
    Name = "terraform-sg-pje"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_custom_port" {
  security_group_id = aws_security_group.terraform_sg.id
  referenced_security_group_id = aws_security_group.terraform_sg.id
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.terraform_sg.id
  referenced_security_group_id = aws_security_group.terraform_sg.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.terraform_sg.id
  #cidr_ipv4         = "0.0.0.0/0"
  referenced_security_group_id = aws_security_group.terraform_sg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_sg_traffic" {
  security_group_id = aws_security_group.terraform_sg.id
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
  referenced_security_group_id = aws_security_group.terraform_sg.id
}

#allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.terraform_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#security group open to the public
#assigned to load balancer to allow communication with public internet
resource "aws_security_group" "public_access_sg" {
  name        = "public_access_sg"
  description = "Allow http traffic from internet"
  vpc_id      = aws_vpc.proj2-pje.id

  tags = {
    Name = "terraform-sg-pje"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_public" {
  security_group_id = aws_security_group.public_access_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

#allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_public_sg" {
  security_group_id = aws_security_group.public_access_sg.id
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

#creating a EC2 instance and cloning our Nest API onto it so that it can run our backend
#Running a script through user data
#adding a boot script through user data as well so that when the instance is stopped and started it still works
resource "aws_instance" "app_server" {
  depends_on = [aws_db_instance.default]
  ami           = "ami-05576a079321f21f8"
  instance_type = "t3.small"
  #EC2 instances are kept in private subnets, communicate through nat gateway and load balancer
  subnet_id = aws_subnet.private_subnets["private_subnet_1"].id
  vpc_security_group_ids = [aws_security_group.terraform_sg.id]
  associate_public_ip_address = "false"
  key_name = aws_key_pair.public_key.key_name
  #user data is executed when instance is initialized
  user_data = <<-EOL
  #!/bin/bash -xe

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  node -e "console.log('Running Node.js ' + process.version)"
  sudo yum install git -y
  git clone --no-checkout https://github.com/PaulEdson/DevOpsProj2
  cd ./DevOpsProj2
  git sparse-checkout init
  git sparse-checkout set backend
  git checkout master
  cd backend
  npm install

  cd /var/lib/cloud/scripts/per-boot/
  cat >> script.sh << EOF
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  cd /DevOpsProj2/backend
  git pull
  npm install
  npm run start
  EOF
  chmod +x script.sh

  cd /DevOpsProj2/backend
  touch .env
  cat >> .env << EOF
  DB_HOST = "${aws_db_instance.default.address}"
  DB_PORT = 5432
  DB_USER = "postgres"
  DB_PASSWORD = "y1ew1Fx3W0QwwGSD8EyQ"
  DB_NAME = "private_db_pje"
  SSL_BOOL = 0
  EOF
  npm run start

  EOL
  
#commented out provisioner block. Using user data for now.
#   connection {
#     user = "ec2-user"
#     private_key = tls_private_key.rsa4096.private_key_pem
#     host = self.public_ip
#   }
#   provisioner "local-exec" {
#     #commands to give permisions to private key for windows
#     command = "chmod 600 ${local_file.private_key_pem.filename}"
#     # inline = [
#     #     "icacls ${local_file.private_key_pem.filename} /grant %username%:rw",
#     #     "icacls ${local_file.private_key_pem.filename} /grant %username%:rw",
#     #     "icacls ${local_file.private_key_pem.filename} /remove *S-1-5-11 *S-1-5-18 *S-1-5-32-544 *S-1-5-32-545"
#     # ]
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo mkdir -m777 paul",
#       "cd paul",
#       "sudo mkdir -m777 edson"
#         # "sudo rm -rf /tmp",
#         # "sudo git clone https://github.com/hashicorp/demo-terraform-101 /tmp",
#         # "sudo sh /tmp/assets/setup-web.sh"
#     ]
# }
  tags = {
    Name = "app-server-pje"
    BatchID = "DevOps"
  }
}


# user data could be put into its own file to not repeat the script file for each EC2 instance
#inserting terraform variables made this difficult, so for now two instances we can just repeat the 
#user input script
resource "aws_instance" "app_server2" {
  depends_on = [aws_db_instance.default]
  ami           = "ami-05576a079321f21f8"
  instance_type = "t3.small"
  subnet_id = aws_subnet.private_subnets["private_subnet_2"].id
  vpc_security_group_ids = [aws_security_group.terraform_sg.id]
  associate_public_ip_address = "false"
  key_name = aws_key_pair.public_key.key_name
  user_data = <<-EOL
  #!/bin/bash -xe

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  node -e "console.log('Running Node.js ' + process.version)"
  sudo yum install git -y
  git clone --no-checkout https://github.com/PaulEdson/DevOpsProj2
  cd ./DevOpsProj2
  git sparse-checkout init
  git sparse-checkout set backend
  git checkout master
  cd backend
  npm install

  cd /var/lib/cloud/scripts/per-boot/
  cat >> script.sh << EOF
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  cd /DevOpsProj2/backend
  git pull
  npm install
  npm run start
  EOF
  chmod +x script.sh

  cd /DevOpsProj2/backend
  touch .env
  cat >> .env << EOF
  DB_HOST = "${aws_db_instance.default.address}"
  DB_PORT = 5432
  DB_USER = "postgres"
  DB_PASSWORD = "y1ew1Fx3W0QwwGSD8EyQ"
  DB_NAME = "private_db_pje"
  SSL_BOOL = 0
  EOF
  npm run start

  EOL
tags = {
    Name = "app-server2-pje"
    BatchID = "DevOps"
  }
}

#--------------------Load-Balancer------------------------------
#static frontend will be pointed to load balancer dns to communicate with any
#number of EC2 instances hosting backend
resource "aws_lb" "server_lb" {
  name               = "proj2-lb-pje"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.terraform_sg.id, aws_security_group.public_access_sg.id]
  subnets            = [for subnet in aws_subnet.public_subnets : subnet.id]

  enable_deletion_protection = false

  tags = {
    BatchID = "DevOps"
  }
}

#target group that the ec2 servers will be assigned to
resource "aws_lb_target_group" "server_lb_tg" {
  name     = "proj2-lb-tg-pje"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.proj2-pje.id

  tags = {
    BatchID = "DevOps"
  }
}

#target group attachment is required to point the created target group to specific instances
resource "aws_lb_target_group_attachment" "server_1" {
  target_group_arn = aws_lb_target_group.server_lb_tg.arn
  target_id        = aws_instance.app_server.id 
  port             = 3000
}

resource "aws_lb_target_group_attachment" "server_2" {
  target_group_arn = aws_lb_target_group.server_lb_tg.arn
  target_id        = aws_instance.app_server2.id 
  port             = 3000
}

#takes http traffic and forwards to the server target group
resource "aws_lb_listener" "server_1_listener" {
  load_balancer_arn = aws_lb.server_lb.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.server_lb_tg.arn
  }
}

#creates local file with balance dns to be uploaded to the s3 bucket and read by frontend app
#needed for app to find newly created api and access backend data
resource "local_file" "load_balancer_dns" {
    content  = aws_lb.server_lb.dns_name
    filename = "public_lb_dns.txt"
}


#----------------S3-Bucket----------------------------------------
#frontend will be served through this public s3 bucket
resource "aws_s3_bucket" "s3-bucket" {
  bucket = "frontend-pje"
  tags = {
    Name = "1519948-pje"
    BatchID = "DevOps"
  }
}

resource "aws_s3_bucket_ownership_controls" "ownership_controls" {
  bucket = aws_s3_bucket.s3-bucket.id
  rule{
    object_ownership = "BucketOwnerEnforced"
  }
}

#points to index of website to be served
resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.s3-bucket.id

  index_document {
    suffix = "index.html"
  }
  
  #currently no error.html file, but might add later
  error_document {
    key = "error.html"
  }

  #routes can go here, these are just an example
  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}

#bucket access policy is allowing all public access 
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.s3-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

#assigning access block to our s3 bucket
resource "aws_s3_bucket_policy" "allow_public_access" {
  depends_on = [ aws_s3_bucket_public_access_block.example ]
  bucket = aws_s3_bucket.s3-bucket.id
  #pulling 
  policy = data.aws_iam_policy_document.allow_public_access.json
}


#--------------------------project frontend files-----------------------
#retrieves files from created dist folder in frontend files
#as of now needs to be manually changed every time ng build changes file names
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.s3-bucket.id
  key    = "index.html"
  source = "./frontend/dist/frontend/browser/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "main" {
  bucket = aws_s3_bucket.s3-bucket.id
  key    = "main-LHFWLPVM.js"
  source = "./frontend/dist/frontend/browser/main-LHFWLPVM.js"
  content_type = "application/javascript"
}

resource "aws_s3_object" "polyfills" {
  bucket = aws_s3_bucket.s3-bucket.id
  key    = "polyfills-FFHMD2TL.js"
  source = "./frontend/dist/frontend/browser/polyfills-FFHMD2TL.js"
  content_type = "application/javascript"
}

resource "aws_s3_object" "styles" {
  bucket = aws_s3_bucket.s3-bucket.id
  key    = "styles-5INURTSO.css"
  source = "./frontend/dist/frontend/browser/styles-5INURTSO.css"
  content_type = "text/html"
}

resource "aws_s3_object" "icon" {
  bucket = aws_s3_bucket.s3-bucket.id
  key    = "favicon.ico"
  source = "./frontend/dist/frontend/browser/favicon.ico"
  content_type = "image/x-icon"
}

#pushes txt file with generated load balancer DNS into the s3 folder to be read by the app
resource "aws_s3_object" "url" {
  depends_on = [local_file.load_balancer_dns]
  bucket = aws_s3_bucket.s3-bucket.id
  key    = "url.txt"
  source = "./public_lb_dns.txt"
  content_type = "text/html"
}

#-------------Database------------------------------
resource "aws_db_subnet_group" "default" {
  
  name       = "db-subnet-pje" 
  subnet_ids = values(aws_subnet.private_subnets)[*].id

  tags = {
    Name = "db-subnet-pje"
    BatchID = "DevOps"
  }
}

#db is kept on private subnets and is set to not be publicly accessible
resource "aws_db_instance" "default" {
  depends_on = [ aws_db_subnet_group.default ]
  allocated_storage    = 10
  db_name              = "private_db_pje"
  engine               = "postgres"
  engine_version       = "16.3"
  instance_class       = "db.t3.micro"
  username             = "postgres"
  password             = "y1ew1Fx3W0QwwGSD8EyQ"
  //identifier = "terraform-db-pje"
  vpc_security_group_ids = [aws_security_group.terraform_sg.id]
  db_subnet_group_name = aws_db_subnet_group.default.id
  skip_final_snapshot  = true
  publicly_accessible = false
  tags = {
    BatchID = "DevOps"
  }
}

# resource "local_file" "database_adress" {
#     content  = aws_db_instance.default.address
#     filename = "public_lb_dns.txt"
# }
