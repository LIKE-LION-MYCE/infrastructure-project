# Minimal Backend Environment Variables

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "aws_profile" {
  description = "AWS profile"
  type        = string
  default     = "default"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "myce"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "backend_domain_name" {
  description = "Domain name for the backend API"
  type        = string
  default     = "api.myce.live"
}