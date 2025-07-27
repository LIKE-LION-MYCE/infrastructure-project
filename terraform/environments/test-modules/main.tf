# Test Environment for All Modules
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

  project_name      = "likelion-terraform-test-modules"
  vpc_cidr         = "10.2.0.0/16"
  subnet_cidr      = "10.2.1.0/24"
  availability_zone = "ap-northeast-2a"
}

# EC2 Module
module "ec2" {
  source = "../../modules/ec2"

  project_name    = "likelion-terraform-test-modules"
  instance_type   = "t3.micro"
  key_name        = "likelion-terraform-key"
  vpc_id          = module.vpc.vpc_id
  subnet_id       = module.vpc.public_subnet_id
  root_volume_size = 16
}

# EIP Module
module "eip" {
  source = "../../modules/eip"

  project_name = "likelion-terraform-test-modules"
  instance_id  = module.ec2.instance_id
}

# Test Outputs
output "test_results" {
  value = {
    vpc_id       = module.vpc.vpc_id
    subnet_id    = module.vpc.public_subnet_id
    instance_id  = module.ec2.instance_id
    public_ip    = module.eip.public_ip
    ssh_command  = "ssh -i ~/.ssh/aws/likelion-terraform-key ubuntu@${module.eip.public_ip}"
  }
}

output "test_message" {
  value = "All modules test successful! Infrastructure ready."
}