# EIP Module Outputs

output "eip_id" {
  description = "ID of the Elastic IP"
  value       = aws_eip.main.id
}

output "public_ip" {
  description = "The Elastic IP address"
  value       = aws_eip.main.public_ip
}

output "allocation_id" {
  description = "The allocation ID of the Elastic IP"
  value       = aws_eip.main.allocation_id
}

output "association_id" {
  description = "The association ID of the Elastic IP"
  value       = aws_eip.main.association_id
}

output "public_dns" {
  description = "Public DNS name associated with the Elastic IP"
  value       = aws_eip.main.public_dns
}