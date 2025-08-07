# Variables for ALB module

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener"
  type        = string
}

variable "ec2_instance_id" {
  description = "ID of the EC2 instance to attach to the target group"
  type        = string
}

variable "ec2_security_group_id" {
  description = "ID of the EC2 security group to update"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB (optional, will auto-discover if not provided)"
  type        = list(string)
  default     = null
}