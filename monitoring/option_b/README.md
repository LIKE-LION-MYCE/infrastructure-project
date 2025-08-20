# Option B: ALB Public Monitoring Setup (Like jobdams.online)

## Overview
This setup replicates your previous jobdams.online monitoring configuration using ALB instead of nginx.

## Features
- ✅ Public Grafana access at `https://api.myce.live/dashboard/`
- ✅ Dashboard shortcuts (e.g., `/dashboard/ec2`, `/dashboard/app`)
- ✅ Team access with Grafana authentication
- ✅ Public dashboard sharing capability
- ✅ SSL/HTTPS via ACM certificates

## Architecture
```
Internet → CloudFront → ALB → EC2:3000 (Grafana)
                         ↓
                    EC2:9090 (Prometheus - internal only)
```

## Setup Instructions

### 1. Choose Your URL Strategy

#### Option B1: Path-based (like jobdams.online)
```
https://api.myce.live/dashboard/        # Grafana main
https://api.myce.live/dashboard/ec2     # EC2 dashboard shortcut
https://api.myce.live/dashboard/app     # App dashboard shortcut
```

#### Option B2: Subdomain-based
```
https://monitoring.myce.live/           # Grafana main
https://grafana.myce.live/              # Alternative
```

### 2. Run Setup Script
```bash
./setup-alb-monitoring.sh

# Choose option when prompted:
# 1) Path-based routing (/dashboard)
# 2) Subdomain routing (monitoring.myce.live)
```

### 3. Configure Grafana for Public Access
The script will automatically:
- Set up ALB target groups
- Configure listener rules
- Update Grafana root_url
- Set up authentication
- Create dashboard shortcuts

## Dashboard Shortcuts (Like Your Previous Setup)

### EC2 Monitoring
- URL: `https://api.myce.live/dashboard/ec2`
- Redirects to: Node Exporter dashboard with 24h view

### Application Monitoring  
- URL: `https://api.myce.live/dashboard/app`
- Redirects to: Spring Boot dashboard with 1h view

### Custom Shortcuts
Edit `grafana-shortcuts.conf` to add more shortcuts

## Security Configuration

### Basic Authentication (Recommended)
```ini
# grafana.ini
[auth.basic]
enabled = true

[auth.anonymous]
enabled = true
org_role = Viewer  # Public can view dashboards
```

### Advanced: AWS Cognito Integration
For enterprise-grade authentication via ALB

## Files Structure
```
option_b/
├── terraform/
│   ├── alb-monitoring.tf       # ALB target groups and rules
│   └── route53-monitoring.tf   # DNS records (if subdomain)
├── ansible/
│   ├── grafana-public.yml      # Grafana public config
│   └── templates/
│       ├── grafana.ini.j2      # Grafana config template
│       └── shortcuts.conf.j2    # Dashboard shortcuts
└── setup-alb-monitoring.sh     # Automated setup script
```

## Comparison with Your Previous nginx Setup

| Your nginx Config | Our ALB Equivalent |
|-------------------|-------------------|
| `location /dashboard/` | ALB path pattern `/dashboard/*` |
| `proxy_pass http://127.0.0.1:3000` | ALB target group port 3000 |
| SSL via Certbot | SSL via ACM (AWS managed) |
| nginx redirect shortcuts | ALB listener rules or Grafana config |

## Cost Considerations
- ALB: ~$0.025/hour + data transfer
- Total: ~$20-30/month
- Alternative: Use existing ALB (no extra cost)

## Making Dashboards Public

### 1. Make Specific Dashboard Public
```bash
# In Grafana UI
Dashboard Settings → Permissions → Add Permission
Role: Viewer
Permission: View
```

### 2. Get Public URL
```
https://api.myce.live/dashboard/d/dashboard-id/dashboard-name
```

### 3. Share Snapshot (Alternative)
Dashboard → Share → Snapshot → Publish to snapshot.raintank.io