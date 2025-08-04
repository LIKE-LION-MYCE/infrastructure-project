# Frontend Environment Outputs

# S3 Outputs
output "frontend_bucket_id" {
  description = "ID of the frontend S3 bucket"
  value       = module.s3.frontend_bucket_id
}

output "media_bucket_id" {
  description = "ID of the media S3 bucket"
  value       = module.s3.media_bucket_id
}

# CloudFront Outputs
output "frontend_distribution_id" {
  description = "ID of the frontend CloudFront distribution"
  value       = module.cloudfront.frontend_distribution_id
}

output "frontend_distribution_domain_name" {
  description = "Domain name of the frontend CloudFront distribution"
  value       = module.cloudfront.frontend_distribution_domain_name
}

output "media_distribution_id" {
  description = "ID of the media CloudFront distribution"
  value       = module.cloudfront.media_distribution_id
}

output "media_distribution_domain_name" {
  description = "Domain name of the media CloudFront distribution"
  value       = module.cloudfront.media_distribution_domain_name
}

# URLs for easy access
output "frontend_url" {
  description = "Frontend application URL"
  value       = "https://${module.cloudfront.frontend_distribution_domain_name}"
}

output "media_url" {
  description = "Media CDN URL"
  value       = "https://${module.cloudfront.media_distribution_domain_name}"
}

# SSL Certificate outputs
output "ssl_certificate_validation_records" {
  description = "DNS records needed for SSL certificate validation"
  value       = module.cloudfront.ssl_certificate_validation_records
}

# Custom domain URLs
output "custom_frontend_url" {
  description = "Custom frontend URL (if domain configured)"
  value       = var.frontend_domain_name != "" ? "https://${var.frontend_domain_name}" : "Not configured"
}

output "custom_media_url" {
  description = "Custom media URL (if domain configured)"
  value       = var.media_domain_name != "" ? "https://${var.media_domain_name}" : "Not configured"
}