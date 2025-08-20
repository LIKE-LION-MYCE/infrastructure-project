# Option A: SSH Tunnel Monitoring Setup

## Overview
This is the secure, private monitoring setup using SSH tunnels. No public exposure of monitoring services.

## Files Included
- `prometheus.yml` - Prometheus configuration for Spring Boot
- `grafana.ini` - Grafana configuration  
- `monitoring-tunnel.sh` - SSH tunnel access script
- `dashboards/` - Pre-configured Grafana dashboards

## Setup Instructions

### 1. Deploy Monitoring Stack
```bash
cd ../../
./deploy.sh --enable-monitoring
```

### 2. Access Monitoring
```bash
cd ../../myce-server
./scripts/monitoring-tunnel.sh
```

### 3. Access URLs
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/grafana123)

## Features
- ✅ Spring Boot metrics collection
- ✅ System metrics (CPU, Memory, Disk)
- ✅ JVM monitoring
- ✅ Database connection pool monitoring
- ✅ WebSocket connections tracking
- ✅ Custom MYCE dashboards

## Security
- All access via SSH tunnel only
- No public ports exposed
- Requires SSH key for access

## Dashboards Included
1. **MYCE Spring Boot Application** - Custom metrics for your app
2. **Node Exporter Full** - System metrics
3. **JVM Micrometer** - Java application metrics

## Troubleshooting

### Can't connect via tunnel
```bash
# Check if EC2 is running
aws ec2 describe-instances --instance-ids <your-instance-id>

# Test SSH connection
ssh -i ~/.ssh/aws/likelion-terraform-key ubuntu@<EC2-IP>
```

### Prometheus not scraping Spring Boot
```bash
# On EC2, check if app is running
curl http://localhost:8080/actuator/prometheus

# Check Prometheus targets
http://localhost:9090/targets
```