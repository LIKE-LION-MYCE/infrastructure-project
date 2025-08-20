# Load Generator EC2 Module
# Reusable k6 load testing infrastructure following Redis pattern

# Security Group for k6 load generator
resource "aws_security_group" "loadgen" {
  name        = "${var.name_prefix}-loadgen-sg"
  description = "Security group for k6 load generator"
  vpc_id      = var.vpc_id

  # SSH access (same as Redis pattern - open to world)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # k6 metrics port for Prometheus scraping (VPC only)
  ingress {
    from_port   = 5656
    to_port     = 5656
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # All outbound traffic (same as Redis pattern)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name_prefix}-loadgen-sg"
    Purpose     = "load-testing"
    Environment = var.environment
  }
}

# k6 Load Generator EC2 Instance
resource "aws_instance" "loadgen" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  
  vpc_security_group_ids = [aws_security_group.loadgen.id]
  subnet_id              = var.subnet_id
  
  # Root volume
  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
    encrypted   = true
  }

  # No user_data - Ansible will handle k6 installation

  tags = {
    Name        = "${var.name_prefix}-loadgen"
    Purpose     = "load-testing"
    Environment = var.environment
    AutoShutdown = "true"  # For cost tracking (manual shutdown)
  }
}

# Elastic IP for consistent access (optional, following Redis pattern)
resource "aws_eip" "loadgen" {
  count    = var.create_eip ? 1 : 0
  instance = aws_instance.loadgen.id
  domain   = "vpc"

  tags = {
    Name        = "${var.name_prefix}-loadgen-eip"
    Purpose     = "load-testing"
    Environment = var.environment
  }
}