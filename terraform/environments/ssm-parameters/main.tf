# SSM Parameters Environment
# This is a separate Terraform layer for managing application secrets
# Can be updated independently from core infrastructure (VPC, EC2, RDS)

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
  profile = "likelion-terraform-current"
}

# Data source to get RDS endpoint from your existing dev infrastructure
data "terraform_remote_state" "dev" {
  backend = "local"
  config = {
    path = "../dev/terraform.tfstate"
  }
}

# SSM Parameters Module
module "ssm_parameters" {
  source = "../../modules/ssm-parameters"

  # Database configuration (from existing RDS)
  db_host     = data.terraform_remote_state.dev.outputs.db_endpoint
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  # MongoDB configuration
  mongodb_cluster  = var.mongodb_cluster
  mongodb_password = var.mongodb_password

  # Redis configuration
  redis_host     = var.redis_host
  redis_password = var.redis_password

  # JWT secret
  jwt_secret = var.jwt_secret

  # AWS configuration
  aws_region              = var.aws_region
  aws_access_key_id       = var.aws_access_key_id
  aws_secret_access_key   = var.aws_secret_access_key

  # S3 configuration
  s3_bucket_name    = var.s3_bucket_name
  cloudfront_domain = var.cloudfront_domain
}

# Output the created parameters
output "ssm_parameters_created" {
  description = "List of SSM parameters created"
  value       = module.ssm_parameters.ssm_parameters_created
}

output "parameter_count" {
  description = "Total SSM parameters created"
  value       = module.ssm_parameters.ssm_parameter_count
}

output "deployment_info" {
  description = "Deployment summary"
  value = {
    environment = "production"
    timestamp   = timestamp()
    parameters  = length(module.ssm_parameters.ssm_parameters_created)
    region      = var.aws_region
  }
}