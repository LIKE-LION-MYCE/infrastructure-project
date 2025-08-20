# Application Load Balancer Module for Backend
# Creates ALB with SSL termination and health checks

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data source for existing VPC and subnets
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

# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = data.aws_vpc.main.id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-alb-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids != null ? var.subnet_ids : data.aws_subnets.public.ids

  enable_deletion_protection = false

  tags = {
    Name        = "${var.project_name}-backend-alb"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Target Group for backend instances
resource "aws_lb_target_group" "backend" {
  name     = "${var.project_name}-backend-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/actuator/health/liveness"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = {
    Name        = "${var.project_name}-backend-tg"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Attach EC2 instance to target group
resource "aws_lb_target_group_attachment" "backend" {
  target_group_arn = aws_lb_target_group.backend.arn
  target_id        = var.ec2_instance_id
  port             = 8080
}

# HTTP Listener (redirect to HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name        = "${var.project_name}-http-listener"
    Project     = var.project_name
    Environment = var.environment
  }
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  tags = {
    Name        = "${var.project_name}-https-listener"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Update EC2 security group to allow traffic from ALB
resource "aws_security_group_rule" "allow_alb_to_ec2" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = var.ec2_security_group_id
  source_security_group_id = aws_security_group.alb.id
  description              = "Allow ALB to reach backend on port 8080"
}

# Allow ALB to reach Grafana monitoring port
resource "aws_security_group_rule" "allow_alb_to_grafana" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = var.ec2_security_group_id
  source_security_group_id = aws_security_group.alb.id
  description              = "Allow ALB to reach Grafana on port 3000"
}

# ============================================================================
# MONITORING CONFIGURATION (Option B: Public Access like jobdams.online)
# ============================================================================

# Grafana Target Group (like jobdams.online/dashboard/)
resource "aws_lb_target_group" "grafana" {
  count    = var.enable_monitoring ? 1 : 0
  name     = "${var.project_name}-grafana-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/api/health"
    matcher             = "200"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400  # 1 day sticky sessions for Grafana
    enabled         = true
  }

  tags = {
    Name        = "${var.project_name}-grafana-tg"
    Project     = var.project_name
    Environment = var.environment
    Type        = "monitoring"
  }
}

# Attach EC2 to Grafana target group
resource "aws_lb_target_group_attachment" "grafana" {
  count            = var.enable_monitoring ? 1 : 0
  target_group_arn = aws_lb_target_group.grafana[0].arn
  target_id        = var.ec2_instance_id
  port             = 3000
}

# ALB Listener Rule for /dashboard/* path (like jobdams.online setup)
resource "aws_lb_listener_rule" "grafana_dashboard" {
  count        = var.enable_monitoring ? 1 : 0
  listener_arn = aws_lb_listener.https.arn
  priority     = 90  # High priority for monitoring

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana[0].arn
  }

  condition {
    path_pattern {
      values = ["/dashboard/*", "/dashboard"]
    }
  }

  tags = {
    Name        = "${var.project_name}-grafana-dashboard-rule"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Dashboard shortcuts (like jobdams.online/dashboard/ec2)
resource "aws_lb_listener_rule" "dashboard_ec2_shortcut" {
  count        = var.enable_monitoring ? 1 : 0
  listener_arn = aws_lb_listener.https.arn
  priority     = 91

  action {
    type = "redirect"
    redirect {
      path        = "/dashboard/d/rYdddlPWk/node-exporter-full"
      query       = "orgId=1&from=now-24h&to=now"
      status_code = "HTTP_302"
    }
  }

  condition {
    path_pattern {
      values = ["/dashboard/ec2"]
    }
  }

  tags = {
    Name        = "${var.project_name}-dashboard-ec2-shortcut"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_lb_listener_rule" "dashboard_app_shortcut" {
  count        = var.enable_monitoring ? 1 : 0
  listener_arn = aws_lb_listener.https.arn
  priority     = 92

  action {
    type = "redirect"
    redirect {
      path        = "/dashboard/d/spring-boot-myce/myce-spring-boot-application"
      query       = "from=now-1h&to=now"
      status_code = "HTTP_302"
    }
  }

  condition {
    path_pattern {
      values = ["/dashboard/app", "/dashboard/myce"]
    }
  }

  tags = {
    Name        = "${var.project_name}-dashboard-app-shortcut"
    Project     = var.project_name
    Environment = var.environment
  }
}

# k6 Load Testing Performance Dashboard (kiosk mode)
resource "aws_lb_listener_rule" "dashboard_performance_shortcut" {
  count        = var.enable_monitoring ? 1 : 0
  listener_arn = aws_lb_listener.https.arn
  priority     = 93

  action {
    type = "redirect"
    redirect {
      path        = "/dashboard/d/ccbb2351-2ae2-462f-ae0e-f2c893ad1028/k6-prometheus"
      query       = "orgId=1&from=now-5m&to=now&kiosk"
      status_code = "HTTP_302"
    }
  }

  condition {
    path_pattern {
      values = ["/dashboard/performance"]
    }
  }

  tags = {
    Name        = "${var.project_name}-dashboard-performance-shortcut"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Combined Demo Dashboard (kiosk mode) - will be created next
resource "aws_lb_listener_rule" "dashboard_demo_shortcut" {
  count        = var.enable_monitoring ? 1 : 0
  listener_arn = aws_lb_listener.https.arn
  priority     = 94

  action {
    type = "redirect"
    redirect {
      path        = "/dashboard/d/demo-combined-v2/myce-demo-dashboard"
      query       = "orgId=1&from=now-15m&to=now&kiosk&refresh=5s"
      status_code = "HTTP_302"
    }
  }

  condition {
    path_pattern {
      values = ["/dashboard/demo"]
    }
  }

  tags = {
    Name        = "${var.project_name}-dashboard-demo-shortcut"
    Project     = var.project_name
    Environment = var.environment
  }
}