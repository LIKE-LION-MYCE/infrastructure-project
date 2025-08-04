# S3 Module for Frontend and Media Hosting

# Frontend S3 Bucket (Public)
resource "aws_s3_bucket" "frontend" {
  bucket = "${var.project_prefix}-frontend-bucket"

  tags = {
    Name        = "${var.project_prefix}-frontend-bucket"
    Environment = var.environment
    Purpose     = "frontend-hosting"
  }
}

# Frontend Bucket Versioning
resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Frontend Bucket Public Access Block (Allow public for CloudFront)
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Frontend Bucket Policy for CloudFront OAC
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = var.frontend_cloudfront_arn
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.frontend]
}

# Media S3 Bucket (Private)
resource "aws_s3_bucket" "media" {
  bucket = "${var.project_prefix}-media-bucket"

  tags = {
    Name        = "${var.project_prefix}-media-bucket"
    Environment = var.environment
    Purpose     = "media-storage"
  }
}

# Media Bucket Versioning
resource "aws_s3_bucket_versioning" "media" {
  bucket = aws_s3_bucket.media.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Media Bucket Public Access Block (Fully private)
resource "aws_s3_bucket_public_access_block" "media" {
  bucket = aws_s3_bucket.media.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Media Bucket Policy for CloudFront OAC
resource "aws_s3_bucket_policy" "media" {
  bucket = aws_s3_bucket.media.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.media.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = var.media_cloudfront_arn
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.media]
}

# S3 Bucket Server-side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Media Bucket CORS Configuration for Direct Frontend Access
resource "aws_s3_bucket_cors_configuration" "media" {
  bucket = aws_s3_bucket.media.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    allowed_origins = [
      "https://www.myce.live",
      "https://myce.live",
      "http://localhost:3000",
      "http://localhost:5173",
      "http://localhost:8080",
      "http://localhost:8081"
    ]
    expose_headers  = ["ETag", "Content-Length", "x-amz-request-id"]
    max_age_seconds = 3600
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "media" {
  bucket = aws_s3_bucket.media.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}