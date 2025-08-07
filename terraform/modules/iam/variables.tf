# Variables for IAM module

variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
  default     = "myce"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "enable_cloudwatch" {
  description = "Enable CloudWatch monitoring policies"
  type        = bool
  default     = false
}