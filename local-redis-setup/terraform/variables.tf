# Variables for temporary Redis setup

variable "redis_password" {
  description = "Password for Redis authentication"
  type        = string
  default     = "MyceLoadTest2025!"
  sensitive   = true
}