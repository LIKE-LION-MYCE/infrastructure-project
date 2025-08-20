# Outputs for Redis setup

output "redis_public_ip" {
  description = "Public IP of Redis server"
  value       = aws_eip.redis.public_ip
}

output "redis_private_ip" {
  description = "Private IP of Redis server"
  value       = aws_instance.redis.private_ip
}

output "redis_url" {
  description = "Redis connection URL for application"
  value       = "redis://:${var.redis_password}@${aws_eip.redis.public_ip}:6379"
  sensitive   = true
}

output "ssh_command" {
  description = "SSH command to connect to Redis server"
  value       = "ssh -i ~/.ssh/aws/likelion-terraform-key ubuntu@${aws_eip.redis.public_ip}"
}

output "ssm_update_command" {
  description = "Command to update SSM parameter"
  value       = "aws ssm put-parameter --name '/myce/redis-url' --type 'SecureString' --value 'redis://:${var.redis_password}@${aws_eip.redis.public_ip}:6379' --overwrite --profile likelion-terraform-current"
  sensitive   = true
}