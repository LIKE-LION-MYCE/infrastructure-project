# EC2 Module Variables

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "AWS Key Pair name for SSH access"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security group will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where EC2 instance will be launched"
  type        = string
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "likelion-terraform"
}

variable "associate_public_ip_address" {
  description = "Associate public IP address with instance"
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Size of root EBS volume in GiB"
  type        = number
  default     = 16
}

variable "root_volume_type" {
  description = "Type of root EBS volume"
  type        = string
  default     = "gp2"
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "iam_instance_profile" {
  description = "IAM instance profile name for EC2"
  type        = string
  default     = null
}