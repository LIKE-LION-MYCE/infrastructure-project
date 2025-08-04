# CloudFront Module for CDN

# SSL Certificate for CloudFront (must be in us-east-1)
provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = var.aws_profile
}

# ACM Certificate for Custom Domains
resource "aws_acm_certificate" "frontend_cert" {
  provider          = aws.us_east_1
  domain_name       = var.frontend_domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    var.media_domain_name,
    replace(var.frontend_domain_name, "www.", "")  # Add root domain (myce.live)
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.project_prefix}-ssl-cert"
    Environment = var.environment
  }
}

# Certificate validation
resource "aws_acm_certificate_validation" "frontend_cert" {
  provider        = aws.us_east_1
  certificate_arn = aws_acm_certificate.frontend_cert.arn
  validation_record_fqdns = [
    for record in aws_acm_certificate.frontend_cert.domain_validation_options : record.resource_record_name
  ]

  timeouts {
    create = "10m"
  }
}

# CloudFront Origin Access Control for Frontend Bucket
resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "${var.project_prefix}-frontend-oac"
  description                      = "OAC for frontend S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                 = "always"
  signing_protocol                 = "sigv4"
}

# CloudFront Origin Access Control for Media Bucket
resource "aws_cloudfront_origin_access_control" "media" {
  name                              = "${var.project_prefix}-media-oac"
  description                      = "OAC for media S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                 = "always"
  signing_protocol                 = "sigv4"
}

# CloudFront Distribution for Frontend
resource "aws_cloudfront_distribution" "frontend" {
  origin {
    domain_name              = var.frontend_bucket_domain_name
    origin_id                = "S3-${var.project_prefix}-frontend"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.project_prefix} Frontend Distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.project_prefix}-frontend"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Custom error page for SPA routing
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "${var.project_prefix}-frontend-distribution"
    Environment = var.environment
    Purpose     = "frontend-cdn"
  }

  # Custom domain configuration
  aliases = var.frontend_domain_name != "" ? [
    var.frontend_domain_name,                              # www.myce.live
    replace(var.frontend_domain_name, "www.", "")          # myce.live
  ] : []

  viewer_certificate {
    cloudfront_default_certificate = var.frontend_domain_name == ""
    acm_certificate_arn           = var.frontend_domain_name != "" ? aws_acm_certificate_validation.frontend_cert.certificate_arn : null
    ssl_support_method            = var.frontend_domain_name != "" ? "sni-only" : null
    minimum_protocol_version      = var.frontend_domain_name != "" ? "TLSv1.2_2021" : null
  }
}

# CloudFront Distribution for Media
resource "aws_cloudfront_distribution" "media" {
  origin {
    domain_name              = var.media_bucket_domain_name
    origin_id                = "S3-${var.project_prefix}-media"
    origin_access_control_id = aws_cloudfront_origin_access_control.media.id
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.project_prefix} Media Distribution"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.project_prefix}-media"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "${var.project_prefix}-media-distribution"
    Environment = var.environment
    Purpose     = "media-cdn"
  }

  # Custom domain configuration
  aliases = var.media_domain_name != "" ? [var.media_domain_name] : []

  viewer_certificate {
    cloudfront_default_certificate = var.media_domain_name == ""
    acm_certificate_arn           = var.media_domain_name != "" ? aws_acm_certificate_validation.frontend_cert.certificate_arn : null
    ssl_support_method            = var.media_domain_name != "" ? "sni-only" : null
    minimum_protocol_version      = var.media_domain_name != "" ? "TLSv1.2_2021" : null
  }
}