# SSM Parameters Module for Myce Backend Secrets
# This module creates secure parameters for sensitive configuration values

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# MySQL Database URL (constructed from components)
resource "aws_ssm_parameter" "db_url" {
  name        = "/myce/db-url"
  description = "MySQL database connection URL"
  type        = "SecureString"
  value       = "jdbc:mysql://${var.db_host}/${var.db_name}"

  tags = {
    Project     = "Myce"
    Environment = "Production"
    Component   = "Database"
  }
}

# MySQL Database Password
resource "aws_ssm_parameter" "db_password" {
  name        = "/myce/db-password"
  description = "MySQL database password"
  type        = "SecureString"
  value       = var.db_password

  tags = {
    Project     = "Myce"
    Environment = "Production"
    Component   = "Database"
  }
}

# MySQL Database Username
resource "aws_ssm_parameter" "db_username" {
  name        = "/myce/db-username"
  description = "MySQL database username"
  type        = "String"
  value       = var.db_username

  tags = {
    Project     = "Myce"
    Environment = "Production"
    Component   = "Database"
  }
}

# MongoDB URI (reconstructed with secure password)
resource "aws_ssm_parameter" "mongodb_uri" {
  name        = "/myce/mongodb-uri"
  description = "MongoDB Atlas connection URI"
  type        = "SecureString"
  value       = "mongodb+srv://myce:${var.mongodb_password}@${var.mongodb_cluster}/myce_nosql?retryWrites=true&w=majority&appName=Juan-Cluster0"

  tags = {
    Project     = "Myce"
    Environment = "Production"
    Component   = "Database"
  }
}

# Redis URL (reconstructed with secure password)
resource "aws_ssm_parameter" "redis_url" {
  name        = "/myce/redis-url"
  description = "Redis/Upstash connection URL"
  type        = "SecureString"
  value       = "rediss://default:${var.redis_password}@${var.redis_host}:6379"

  tags = {
    Project     = "Myce"
    Environment = "Production"
    Component   = "Database"
  }
}

# JWT Secret
resource "aws_ssm_parameter" "jwt_secret" {
  name        = "/myce/jwt-secret"
  description = "JWT signing secret key"
  type        = "SecureString"
  value       = var.jwt_secret

  tags = {
    Project     = "Myce"
    Environment = "Production"
    Component   = "Authentication"
  }
}

# AWS Credentials for S3
resource "aws_ssm_parameter" "aws_access_key_id" {
  name        = "/myce/aws-access-key-id"
  description = "AWS access key ID for S3 operations"
  type        = "SecureString"
  value       = var.aws_access_key_id

  tags = {
    Project     = "Myce"
    Environment = "Production"
    Component   = "AWS"
  }
}

resource "aws_ssm_parameter" "aws_secret_access_key" {
  name        = "/myce/aws-secret-access-key"
  description = "AWS secret access key for S3 operations"
  type        = "SecureString"
  value       = var.aws_secret_access_key

  tags = {
    Project     = "Myce"
    Environment = "Production"
    Component   = "AWS"
  }
}

# S3 Bucket Name (not sensitive)
resource "aws_ssm_parameter" "s3_bucket_name" {
  name        = "/myce/s3-bucket-name"
  description = "S3 media bucket name"
  type        = "String"
  value       = var.s3_bucket_name

  tags = {
    Project     = "Myce"
    Environment = "Production"
    Component   = "AWS"
  }
}

# CloudFront Domain (not sensitive)
resource "aws_ssm_parameter" "cloudfront_domain" {
  name        = "/myce/cloudfront-domain"
  description = "CloudFront distribution domain"
  type        = "String"
  value       = var.cloudfront_domain

  tags = {
    Project     = "Myce"
    Environment = "Production"
    Component   = "AWS"
  }
}

# AWS Region (not sensitive)
resource "aws_ssm_parameter" "aws_region" {
  name        = "/myce/aws-region"
  description = "AWS region"
  type        = "String"
  value       = var.aws_region

  tags = {
    Project     = "Myce"
    Environment = "Production"
    Component   = "AWS"
  }
}