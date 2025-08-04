# CloudFront Module Outputs

output "frontend_distribution_id" {
  description = "ID of the frontend CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.id
}

output "frontend_distribution_arn" {
  description = "ARN of the frontend CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.arn
}

output "frontend_distribution_domain_name" {
  description = "Domain name of the frontend CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "media_distribution_id" {
  description = "ID of the media CloudFront distribution"
  value       = aws_cloudfront_distribution.media.id
}

output "media_distribution_arn" {
  description = "ARN of the media CloudFront distribution"
  value       = aws_cloudfront_distribution.media.arn
}

output "media_distribution_domain_name" {
  description = "Domain name of the media CloudFront distribution"
  value       = aws_cloudfront_distribution.media.domain_name
}

# SSL Certificate outputs
output "ssl_certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = var.frontend_domain_name != "" ? aws_acm_certificate.frontend_cert.arn : null
}

output "ssl_certificate_validation_records" {
  description = "DNS records for SSL certificate validation"
  value       = var.frontend_domain_name != "" ? aws_acm_certificate.frontend_cert.domain_validation_options : []
}