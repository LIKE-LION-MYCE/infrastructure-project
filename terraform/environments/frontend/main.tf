# Frontend Environment - S3 + CloudFront CDN

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

# S3 Module
module "s3" {
  source = "../../modules/s3"

  project_prefix             = var.project_prefix
  environment               = var.environment
  frontend_cloudfront_arn   = module.cloudfront.frontend_distribution_arn
  media_cloudfront_arn      = module.cloudfront.media_distribution_arn
}

# CloudFront Module
module "cloudfront" {
  source = "../../modules/cloudfront"

  project_prefix                = var.project_prefix
  environment                  = var.environment
  frontend_bucket_domain_name  = module.s3.frontend_bucket_domain_name
  media_bucket_domain_name     = module.s3.media_bucket_domain_name
  frontend_domain_name         = var.frontend_domain_name
  media_domain_name           = var.media_domain_name
  aws_profile                  = var.aws_profile
}