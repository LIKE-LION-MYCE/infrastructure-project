# EIP Module Variables

variable "instance_id" {
  description = "EC2 instance ID to associate with EIP"
  type        = string
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "likelion-terraform"
}

variable "domain" {
  description = "Domain for EIP (vpc or standard)"
  type        = string
  default     = "vpc"
}