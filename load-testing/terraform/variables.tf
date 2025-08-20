# Variables for Load Testing Environment

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "myce-loadtest"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "test"
}

variable "instance_type" {
  description = "EC2 instance type for k6 load generator"
  type        = string
  default     = "t3.large"  # 4 vCPUs, 8GB RAM for high load generation
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 10  # 10GB for 4-day testing
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = "likelion-terraform-key"  # Same as Redis setup
}

variable "create_eip" {
  description = "Whether to create an Elastic IP for the instance"
  type        = bool
  default     = true  # For consistent SSH access during testing
}