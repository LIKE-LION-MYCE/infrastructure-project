# Temporary Redis EC2 for Load Testing
# Use for 1 week then terraform destroy

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
  profile = "likelion-terraform-current"
}

# Get existing VPC and subnet (same as main EC2)
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name" 
    values = ["likelion-terraform-dev-vpc"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

# Security Group for Redis
resource "aws_security_group" "redis" {
  name        = "myce-redis-temp-sg"
  description = "Temporary Redis security group for load testing"
  vpc_id      = data.aws_vpc.main.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Redis port - open to world for dev access (temporary setup)
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open for dev access - secure with password
  }

  # All outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "myce-redis-temp-sg"
    Purpose     = "temporary-load-testing" 
    Environment = "test"
  }
}

# Redis EC2 Instance
resource "aws_instance" "redis" {
  ami           = "ami-00bbf0eabfaee75db"  # Latest Ubuntu 22.04 LTS
  instance_type = "t3.nano"
  key_name      = "likelion-terraform-key"  # Same key as main EC2
  
  vpc_security_group_ids = [aws_security_group.redis.id]
  subnet_id              = data.aws_subnets.public.ids[0]  # Same subnet as main
  
  # Root volume
  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  # User data for basic setup
  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y redis-server
    
    # Configure Redis for external access
    sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf
    sed -i 's/# requirepass foobared/requirepass ${var.redis_password}/' /etc/redis/redis.conf
    
    # Restart Redis
    systemctl restart redis-server
    systemctl enable redis-server
  EOF
  )

  tags = {
    Name        = "myce-redis-temp"
    Purpose     = "temporary-load-testing"
    Environment = "test"
  }
}

# Elastic IP for consistent access
resource "aws_eip" "redis" {
  instance = aws_instance.redis.id
  domain   = "vpc"

  tags = {
    Name        = "myce-redis-temp-eip"
    Purpose     = "temporary-load-testing"
    Environment = "test"
  }
}