# Outputs for ALB module

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "target_group_arn" {
  description = "ARN of the backend target group"
  value       = aws_lb_target_group.backend.arn
}

# Monitoring outputs (when enabled)
output "grafana_target_group_arn" {
  description = "ARN of the Grafana target group (if monitoring enabled)"
  value       = var.enable_monitoring ? aws_lb_target_group.grafana[0].arn : null
}

output "monitoring_urls" {
  description = "Public monitoring URLs (like jobdams.online setup)"
  value = var.enable_monitoring ? {
    main_dashboard = "https://api.myce.live/dashboard/"
    ec2_metrics    = "https://api.myce.live/dashboard/ec2"
    app_metrics    = "https://api.myce.live/dashboard/app"
    jvm_metrics    = "https://api.myce.live/dashboard/jvm"
  } : null
}