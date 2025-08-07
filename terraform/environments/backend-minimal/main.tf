# Minimal Backend Environment - Uses existing resources where possible
# This approach prevents non-idempotent changes to existing infrastructure

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Reference existing resources
data "aws_instance" "existing_backend" {
  filter {
    name   = "tag:Name"
    values = ["likelion-terraform-dev-server"]
  }
  
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

data "aws_lb" "existing_alb" {
  name = "myce-backend-alb"
}

data "aws_lb_target_group" "existing_tg" {
  name = "myce-backend-tg"
}

# Only manage the ACM certificate (new resource that we created)
module "acm" {
  source = "../../modules/acm"
  
  project_name = var.project_name
  environment  = var.environment
  domain_name  = var.backend_domain_name
  
  subject_alternative_names = []
}

# Output existing resource information
output "alb_dns_name" {
  description = "DNS name of the existing Application Load Balancer"
  value       = data.aws_lb.existing_alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the existing Application Load Balancer"
  value       = data.aws_lb.existing_alb.zone_id
}

output "ec2_instance_id" {
  description = "ID of the existing EC2 instance"
  value       = data.aws_instance.existing_backend.id
}

output "ec2_public_ip" {
  description = "Public IP of the existing EC2 instance"
  value       = data.aws_instance.existing_backend.public_ip
}

output "certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = module.acm.certificate_arn
}

output "certificate_status" {
  description = "Status of the SSL certificate"
  value       = module.acm.certificate_status
}

output "dns_validation_records" {
  description = "DNS validation records for SSL certificate"
  value       = module.acm.validation_records
}