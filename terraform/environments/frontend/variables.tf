# Frontend Environment Variables

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-northeast-2"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "likelion-terraform-current"
}

variable "project_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "myce"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "frontend"
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