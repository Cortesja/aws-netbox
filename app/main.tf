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

data "aws_ecr_image" "netbox_plugins" {
  repository_name    = "netbox-test-environment"
  image_tag           = "latest"
}

#############
# Variable 
#############

locals {
  # Netbox version
  nb_image = data.aws_ecr_image.netbox_plugins.image_uri
}

#################
# Read "../core/outputs.tf"
#################

data "terraform_remote_state" "core" {
  backend = "local"
  config = {
    path = "../core/terraform.tfstate"
  }
}
