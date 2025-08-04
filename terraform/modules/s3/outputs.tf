# S3 Module Outputs

output "frontend_bucket_id" {
  description = "ID of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend.id
}

output "frontend_bucket_arn" {
  description = "ARN of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend.arn
}

output "frontend_bucket_domain_name" {
  description = "Bucket domain name of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend.bucket_domain_name
}

output "media_bucket_id" {
  description = "ID of the media S3 bucket"
  value       = aws_s3_bucket.media.id
}

output "media_bucket_arn" {
  description = "ARN of the media S3 bucket"
  value       = aws_s3_bucket.media.arn
}

output "media_bucket_domain_name" {
  description = "Bucket domain name of the media S3 bucket"
  value       = aws_s3_bucket.media.bucket_domain_name
}