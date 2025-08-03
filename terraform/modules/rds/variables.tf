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

# Enhanced Monitoring Variables
variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0 = disabled, 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 0
  
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Monitoring interval must be one of: 0, 1, 5, 10, 15, 30, 60."
  }
}

# Performance Insights Variables
variable "performance_insights_enabled" {
  description = "Enable Performance Insights for the RDS instance"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days (7 or 731 for free tier)"
  type        = number
  default     = 7
  
  validation {
    condition     = contains([7, 731], var.performance_insights_retention_period)
    error_message = "Performance Insights retention period must be 7 or 731 days."
  }
}