# Variables for Load Generator Module

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "myce-loadtest"
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "test"
}

variable "vpc_id" {
  description = "VPC ID where load generator will be deployed"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block for security group rules"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for load generator instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the load generator instance"
  type        = string
  default     = "ami-00bbf0eabfaee75db"  # Ubuntu 22.04 LTS (same as Redis)
}

variable "instance_type" {
  description = "EC2 instance type for load generator"
  type        = string
  default     = "t3.large"
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 10
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = "likelion-terraform-key"
}

variable "create_eip" {
  description = "Whether to create an Elastic IP for the instance"
  type        = bool
  default     = true
}

# Prometheus server configuration moved to Ansible variables