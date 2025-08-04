# CloudFront Module Variables

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

variable "frontend_bucket_domain_name" {
  description = "Domain name of the frontend S3 bucket"
  type        = string
}

variable "media_bucket_domain_name" {
  description = "Domain name of the media S3 bucket"
  type        = string
}

variable "frontend_domain_name" {
  description = "Custom domain name for frontend (e.g., app.myce.live)"
  type        = string
  default     = ""
}

variable "media_domain_name" {
  description = "Custom domain name for media (e.g., media.myce.live)"
  type        = string
  default     = ""
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}