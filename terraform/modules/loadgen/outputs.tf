# Outputs for Load Generator Module

output "instance_id" {
  description = "Load generator instance ID"
  value       = aws_instance.loadgen.id
}

output "instance_private_ip" {
  description = "Private IP address of load generator"
  value       = aws_instance.loadgen.private_ip
}

output "instance_public_ip" {
  description = "Public IP address of load generator"
  value       = aws_instance.loadgen.public_ip
}

output "elastic_ip" {
  description = "Elastic IP address (if created)"
  value       = var.create_eip ? aws_eip.loadgen[0].public_ip : null
}

output "security_group_id" {
  description = "Security group ID for load generator"
  value       = aws_security_group.loadgen.id
}

output "ssh_command" {
  description = "SSH command to connect to load generator"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${var.create_eip ? aws_eip.loadgen[0].public_ip : aws_instance.loadgen.public_ip}"
}

output "k6_metrics_url" {
  description = "URL for k6 metrics (for Prometheus scraping)"
  value       = "http://${aws_instance.loadgen.private_ip}:5656/metrics"
}