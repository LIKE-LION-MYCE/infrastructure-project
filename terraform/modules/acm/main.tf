# AWS Certificate Manager Module
# Creates SSL certificate with DNS validation for backend domain

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Request SSL certificate from ACM
resource "aws_acm_certificate" "backend" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  # Optional: Add subject alternative names if needed
  subject_alternative_names = var.subject_alternative_names

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.project_name}-backend-cert"
    Project     = var.project_name
    Environment = var.environment
    Domain      = var.domain_name
  }
}

# Note: Certificate validation is manual via GoDaddy DNS
# The certificate will be validated once DNS records are added manually
# Commenting out automatic validation to avoid blocking ALB creation

# resource "aws_acm_certificate_validation" "backend" {
#   certificate_arn = aws_acm_certificate.backend.arn
#   
#   timeouts {
#     create = "10m"
#   }
# 
#   depends_on = [aws_acm_certificate.backend]
# }