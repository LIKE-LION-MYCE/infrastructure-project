# IAM Role and Policy for EC2 to access SSM Parameters
# This allows EC2 instances to read Myce application secrets from Systems Manager

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data source to get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# IAM Policy for SSM Parameter and S3 Media Bucket access
resource "aws_iam_policy" "myce_app_access" {
  name        = "${var.project_name}-app-access"
  description = "Allow EC2 instances to read Myce SSM parameters and access S3 media bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SSMParameterAccess"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/myce/*"
        ]
      },
      {
        Sid    = "S3MediaBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:PutObjectAcl",
          "s3:GetObjectVersion"
        ]
        Resource = [
          "arn:aws:s3:::myce-media-bucket/*"
        ]
      },
      {
        Sid    = "S3MediaBucketList"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::myce-media-bucket"
        ]
      },
      {
        Sid    = "KMSDecryption"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "ssm.${data.aws_region.current.name}.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-ssm-access"
    Project     = var.project_name
    Environment = var.environment
    Component   = "IAM"
  }
}

# Trust policy document for EC2 service
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM Role for EC2 instances
resource "aws_iam_role" "myce_ec2_role" {
  name               = "${var.project_name}-ec2-role"
  description        = "IAM role for Myce EC2 instances to access SSM parameters"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name        = "${var.project_name}-ec2-role"
    Project     = var.project_name
    Environment = var.environment
    Component   = "IAM"
  }
}

# Attach the application access policy to the role
resource "aws_iam_role_policy_attachment" "myce_app_policy_attachment" {
  role       = aws_iam_role.myce_ec2_role.name
  policy_arn = aws_iam_policy.myce_app_access.arn
}

# Optional: Attach AWS managed policy for CloudWatch if needed for monitoring
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  count      = var.enable_cloudwatch ? 1 : 0
  role       = aws_iam_role.myce_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Instance Profile (required to attach IAM role to EC2)
resource "aws_iam_instance_profile" "myce_ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.myce_ec2_role.name

  tags = {
    Name        = "${var.project_name}-ec2-profile"
    Project     = var.project_name
    Environment = var.environment
    Component   = "IAM"
  }
}