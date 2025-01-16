#required providers block pulled from documentation
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

#aws provider from required providers block
provider "aws" {
  region  = "us-east-1"
}

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
        Name = each.key
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
        Name = each.key
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

#creates public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.proj2-pje.id

  #we are allowing all traffic from the internet right now through the igw
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "public-route-table"
    BatchID = "DevOps"
  }
}

#creates association between public route table and public subnets
resource "aws_route_table_association" "public_1" {
    depends_on = [ aws_subnet.public_subnets ]#test to see if this is necessary
    route_table_id = aws_route_table.public_route_table.id
    for_each = aws_subnet.public_subnets
    subnet_id = each.value.id
}