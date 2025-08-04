# S3 Module Variables

variable "project_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "myce"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "frontend_cloudfront_arn" {
  description = "ARN of the CloudFront distribution for frontend bucket"
  type        = string
}

variable "media_cloudfront_arn" {
  description = "ARN of the CloudFront distribution for media bucket"
  type        = string
}