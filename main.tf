terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.30"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

###################
# IAM Role declaration
###################

data "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
}

#################
# VPC
#################

resource "aws_vpc" "netbox-vpc" {
  cidr_block  = "10.253.0.0/16"
  enable_dns_hostnames  = true
  enable_dns_support    = true

  tags = { Name = "netbox-vpc" }
}

################
# Subnets
################

resource "aws_subnet" "private-1" {
  vpc_id        = aws_vpc.netbox-vpc.id
  cidr_block    = "10.253.101.0/24"

  tags = { Name = "private-1" }
}

resource "aws_subnet" "private-2" {
  vpc_id      = aws_vpc.netbox-vpc.id
  cidr_block  = "10.253.102.0/24"

  tags = { Name = "private-2" }
}

resource "aws_subnet" "public-1" {
  vpc_id      = aws_vpc.netbox-vpc.id
  cidr_block  = "10.253.1.0/24"

  tags = { Name = "public-1" }
}

resource "aws_subnet" "public-2" {
  vpc_id      = aws_vpc.netbox-vpc.id
  cidr_block  = "10.253.2.0/24"

  tags = { Name = "public-2" }
}

###################
# Internet Gateway
###################

resource "aws_internet_gateway" "igw" {
  vpc_id    = aws_vpc.netbox-vpc.id

  tags = { Name = "netbox-igw" }
}

##################
# AWS EIP for NAT
##################

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = { Name = "netbox-nat-eip" }
}

####################
# NAT Gateway
####################

resource "aws_nat_gateway" "ngw" {
  allocation_id     = aws_eip.nat.id
  subnet_id         = aws_subnet.public-1.id
  connectivity_type = "public"

  tags = { Name = "netbox-ngw" }
}
