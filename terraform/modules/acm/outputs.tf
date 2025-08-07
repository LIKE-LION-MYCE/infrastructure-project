# Outputs for ACM module

output "certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = aws_acm_certificate.backend.arn
}

output "certificate_domain_name" {
  description = "Domain name of the certificate"
  value       = aws_acm_certificate.backend.domain_name
}

output "certificate_status" {
  description = "Status of the certificate"
  value       = aws_acm_certificate.backend.status
}

output "domain_validation_options" {
  description = "Domain validation options for manual DNS setup"
  value       = aws_acm_certificate.backend.domain_validation_options
  sensitive   = false
}

# This output is particularly important for GoDaddy DNS setup
output "validation_records" {
  description = "DNS validation records to add to GoDaddy"
  value = [
    for option in aws_acm_certificate.backend.domain_validation_options : {
      name   = option.resource_record_name
      type   = option.resource_record_type
      value  = option.resource_record_value
    }
  ]
}