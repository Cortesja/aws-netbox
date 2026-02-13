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
# Data Sources
###################

data "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
}

data "aws_iam_role" "netboxTaskRole" {
  name = "netboxTaskRole"
}

data "aws_ecr_image" "netbox_plugins" {
  repository_name    = "netbox-test-environment"
  image_tag           = "latest"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_kms_key" "rds" {
  key_id      = "alias/aws/rds"
}

data "aws_caller_identity" "current" {}

locals {
  # AZs apply exactly 2 different zones to 'azs'
  azs = slice(data.aws_availability_zones.available.names, 0 , 2)
  # RDS postgesql DB credentials 
  db_creds = jsondecode(aws_secretsmanager_secret_version.datab_password.secret_string)
  # Public and private subnet cidrs blocks
  public_cidrs = ["10.253.1.0/24", "10.253.2.0/24"]
  private_cidrs = ["10.253.101.0/24", "10.253.102.0/24"]
}

#################
# VPC
#################

resource "aws_vpc" "netbox_vpc" {
  cidr_block  = "10.253.0.0/16"
  enable_dns_hostnames  = true
  enable_dns_support    = true

  tags = { Name = "netbox-vpc" }
}

################
# Subnets
################

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.netbox_vpc.id
  availability_zone = local.azs[count.index]
  cidr_block        = local.private_cidrs[count.index]

  tags = { Name = "private-${count.index + 1}" }
}

resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.netbox_vpc.id
  availability_zone = local.azs[count.index]
  cidr_block        = local.public_cidrs[count.index]
  
  tags = { Name = "public-${count.index + 1}" }
}

###################
# Internet Gateway
###################

resource "aws_internet_gateway" "igw" {
  vpc_id    = aws_vpc.netbox_vpc.id

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
  subnet_id         = aws_subnet.public[0].id
  connectivity_type = "public"

  tags = { Name = "netbox-ngw" }
}

###################
# S3 Bucket
###################

resource "aws_s3_bucket" "netbox_media" {
  bucket        = "netbox-s3-media-bucketyal6hxjext8l8gh5s5i4ylsoaiqllrm5"
  # Terraform destory will not result in error if this is set to true
  force_destroy = true
}

# SSE settings
resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.netbox_media.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm           = "AES256"
    }
  }
}
