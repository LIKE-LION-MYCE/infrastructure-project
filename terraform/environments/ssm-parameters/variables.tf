# Variables for SSM Parameters Environment
# These variables will be provided via terraform.tfvars (gitignored)

# Database Configuration
variable "db_name" {
  description = "MySQL database name"
  type        = string
  default     = "myce_database"
}

variable "db_username" {
  description = "MySQL database username"
  type        = string
  default     = "myce_juan"
}

variable "db_password" {
  description = "MySQL database password"
  type        = string
  sensitive   = true
}

# MongoDB Configuration
variable "mongodb_cluster" {
  description = "MongoDB Atlas cluster endpoint"
  type        = string
  default     = "juan-cluster0.z2wjce3.mongodb.net"
}

variable "mongodb_password" {
  description = "MongoDB Atlas password"
  type        = string
  sensitive   = true
}

# Redis Configuration
variable "redis_host" {
  description = "Redis/Upstash host endpoint"
  type        = string
  default     = "smooth-gnu-29395.upstash.io"
}

variable "redis_password" {
  description = "Redis/Upstash password"
  type        = string
  sensitive   = true
}

# JWT Configuration
variable "jwt_secret" {
  description = "JWT signing secret key"
  type        = string
  sensitive   = true
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-northeast-2"
}

variable "aws_access_key_id" {
  description = "AWS access key ID for S3 operations"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret access key for S3 operations"
  type        = string
  sensitive   = true
}

# S3 Configuration
variable "s3_bucket_name" {
  description = "S3 media bucket name"
  type        = string
  default     = "myce-media-bucket"
}

variable "cloudfront_domain" {
  description = "CloudFront distribution domain for media"
  type        = string
  default     = "https://media.myce.live"
}