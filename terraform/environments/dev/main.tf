# Dev Environment using Modular Terraform
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
  profile = "likelion-terraform"
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  project_name         = "likelion-terraform-dev"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]
  availability_zones   = ["ap-northeast-2a", "ap-northeast-2b"]
}

# EC2 Module
module "ec2" {
  source = "../../modules/ec2"

  project_name    = "likelion-terraform-dev"
  instance_type   = "t3.micro"
  key_name        = "likelion-terraform-key"
  vpc_id          = module.vpc.vpc_id
  subnet_id       = module.vpc.public_subnet_id
  root_volume_size = 16
}

# EIP Module
module "eip" {
  source = "../../modules/eip"

  project_name = "likelion-terraform-dev"
  instance_id  = module.ec2.instance_id
}

# RDS Module
module "rds" {
  source = "../../modules/rds"

  project_name           = "likelion-terraform-dev"
  db_password           = var.db_password
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ec2_security_group_id = module.ec2.security_group_id
}

# Variable for DB password
variable "db_password" {
  description = "Password for RDS MySQL database"
  type        = string
  sensitive   = true
}

# Outputs
output "instance_id" {
  value = module.ec2.instance_id
}

output "public_ip" {
  value = module.eip.public_ip
}

output "public_dns" {
  value = module.eip.public_dns
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_id" {
  value = module.vpc.public_subnet_id
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/aws/likelion-terraform-key ubuntu@${module.eip.public_ip}"
}

output "db_endpoint" {
  value = module.rds.db_endpoint
}

output "db_name" {
  value = module.rds.db_name
}