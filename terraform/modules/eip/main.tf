# EIP Module - Main Configuration

# Elastic IP (Static public IP)
resource "aws_eip" "main" {
  instance = var.instance_id
  domain   = var.domain

  tags = {
    Name = "${var.project_name}-eip"
  }
}