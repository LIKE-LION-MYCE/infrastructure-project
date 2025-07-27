# Terraform Configuration
terraform {
  required_version = ">= 1.0" # Require Terraform version 1.0 or later
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Use the official AWS provider
      version = "~> 5.0"        # Use any 5.x version (not 6.x)
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = "ap-northeast-2" # Region: Asia Pacific (Seoul)
  profile = "likelion-terraform"
}

# VPC (Virtual Private Cloud)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"   # Main CIDR block for the VPC
  enable_dns_support   = true            # Allow DNS resolution in VPC
  enable_dns_hostnames = true            # Required for public IP DNS entries

  tags = {
    Name = "likelion-terraform-vpc"
  }
}

# Subnet (Public)
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"       # Subnet range
  availability_zone       = "ap-northeast-2a"   # Fixed AZ for simplicity
  map_public_ip_on_launch = true                # Required to auto-assign public IPs

  tags = {
    Name = "likelion-terraform-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "likelion-terraform-igw"
  }
}

# Route Table (for internet access)
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                   # Default route (anywhere)
    gateway_id = aws_internet_gateway.main.id # Use the internet gateway
  }

  tags = {
    Name = "likelion-terraform-rt"
  }
}

# Associate subnet with route table
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# Security Group (Allow SSH only)
resource "aws_security_group" "main" {
  name        = "likelion-terraform-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ Opens SSH to everyone – lock down to your IP for production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "likelion-terraform-sg"
  }
}

# EC2 Instance
resource "aws_instance" "likelion-terraform" {
  ami                    = "ami-0e98e26aee1c6f590" # Ubuntu 22.04.5 LTS x86_64 in ap-northeast-2
  instance_type          = "t3.micro"              # Free-tier eligible small instance
  subnet_id              = aws_subnet.main.id
  key_name               = "likelion-terraform-key"         # 🔑 Replace with the name of your uploaded .pem key
  associate_public_ip_address = true               # Ensure instance gets a public IP
  security_groups        = [aws_security_group.main.name]

  tags = {
    Name = "likelion-terraform-server"
  }

  root_block_device {
    volume_size = 16        # EBS volume size in GiB
    volume_type = "gp2"     # General Purpose SSD
  }
}

# Elastic IP (Static public IP)
resource "aws_eip" "main" {
  instance = aws_instance.likelion-terraform.id

  tags = {
    Name = "likelion-terraform-eip"
  }
}

# Output: EC2 Instance ID
output "instance_id" {
  value = aws_instance.likelion-terraform.id
}

# Output: EC2 Public IP (via EIP)
output "public_ip" {
  value = aws_eip.main.public_ip
}

# Output: EC2 Public DNS
output "public_dns" {
  value = aws_instance.likelion-terraform.public_dns
}

# Output: VPC ID
output "vpc_id" {
  value = aws_vpc.main.id
}

# Output: Subnet ID
output "subnet_id" {
  value = aws_subnet.main.id
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/aws/likelion-terraform-key ubuntu@${aws_eip.main.public_ip}"
  description = "Use this command to SSH into the instance (ensure your key path is correct)"
}
