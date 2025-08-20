# Load Testing Environment - k6 EC2 Setup
# Temporary setup for 4-day load testing demo
# Use terraform destroy when done

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
  profile = "likelion-terraform-current"
}

# Get existing VPC and subnet (same as main EC2 and Redis)
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name" 
    values = ["likelion-terraform-dev-vpc"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

# Use the loadgen module
module "k6_loadgen" {
  source = "../../terraform/modules/loadgen"
  
  # Basic Configuration
  name_prefix  = var.name_prefix
  environment  = var.environment
  
  # Network Configuration (same as Redis setup)
  vpc_id       = data.aws_vpc.main.id
  vpc_cidr     = data.aws_vpc.main.cidr_block
  subnet_id    = data.aws_subnets.public.ids[0]
  
  # Instance Configuration
  instance_type = var.instance_type
  volume_size   = var.volume_size
  key_name      = var.key_name
  create_eip    = var.create_eip
}

# Output important information
output "k6_instance_info" {
  description = "k6 Load Generator Instance Information"
  value = {
    instance_id     = module.k6_loadgen.instance_id
    public_ip      = module.k6_loadgen.elastic_ip != null ? module.k6_loadgen.elastic_ip : module.k6_loadgen.instance_public_ip
    private_ip     = module.k6_loadgen.instance_private_ip
    ssh_command    = module.k6_loadgen.ssh_command
    metrics_url    = module.k6_loadgen.k6_metrics_url
  }
}