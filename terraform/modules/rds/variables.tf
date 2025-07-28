# RDS Module Variables

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "likelion-terraform"
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "myce_database"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
  # No default - must be provided via TF_VAR_db_password or terraform.tfvars
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "vpc_id" {
  description = "VPC ID where RDS will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for DB subnet group"
  type        = list(string)
}

variable "ec2_security_group_id" {
  description = "Security group ID of EC2 instance for MySQL access"
  type        = string
}

variable "backup_retention_period" {
  description = "Backup retention period in days (0 = disabled)"
  type        = number
  default     = 0
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying"
  type        = bool
  default     = true
}