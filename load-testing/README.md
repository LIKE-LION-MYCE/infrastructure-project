# k6 Load Testing Setup

This module creates a dedicated EC2 instance for running k6 load tests against your MYCE application.

## 🚀 Quick Start

### 1. Deploy Infrastructure
```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

### 2. Get EC2 IP Address
```bash
terraform output k6_instance_info
```

### 3. Update Ansible Inventory
```bash
cd ../ansible/
cp inventory.template inventory
# Replace <K6_PUBLIC_IP> with the IP from terraform output
```

### 4. Install k6 on EC2
```bash
ansible-playbook -i inventory playbook.yml
```

### 5. Run Load Tests
```bash
# SSH into k6 server
ssh -i ~/.ssh/likelion-terraform-key.pem ubuntu@<K6_PUBLIC_IP>

# Run tests
k6-run smoke-test.js    # Light test (1 user, 30s)
k6-run load-test.js     # Load test (100→200 users, 16 minutes)  
k6-run stress-test.js   # Stress test (spike to 1000 users)
k6-run spike-test.js    # Spike test (sudden 2000 users - great for demos!)
```

## 📊 Monitoring

- **Grafana Dashboard**: https://api.myce.live/dashboard/
- **k6 Metrics**: http://k6-server-ip:5656/metrics
- **Prometheus**: Automatically scrapes k6 metrics every 5 seconds

## 🧪 Test Scripts

| Script | Duration | Max Users | Purpose |
|--------|----------|-----------|---------|
| `smoke-test.js` | 30s | 1 | Quick validation |
| `load-test.js` | 16m | 200 | Sustained load testing |
| `stress-test.js` | 8m | 1000 | Breaking point testing |
| `spike-test.js` | 5m | 2000 | Sudden traffic surge (demo) |

## 🔧 Advanced Usage

### Run with custom Prometheus server
```bash
k6-run smoke-test.js http://your-prometheus:9090
```

### View real-time metrics
```bash
# On k6 server
tail -f /opt/k6/logs/k6.log
```

### Create custom test
```bash
# Edit test scripts
vim /opt/k6/scripts/my-test.js

# Run custom test
k6-run my-test.js
```

## 🧹 Cleanup

After your 4-day testing period:
```bash
cd terraform/
terraform destroy
```

## 🏗️ Architecture

```
┌─────────────┐    HTTP Load    ┌──────────────┐
│   k6 EC2    │ ────────────▶   │ MYCE Backend │
│ (t3.large)  │                 │   (EKS)      │
└─────┬───────┘                 └──────────────┘
      │
      │ Metrics (5656)
      ▼
┌─────────────┐    Scrape       ┌──────────────┐
│ Prometheus  │ ◀─────────────  │   k6 server  │
└─────┬───────┘                 └──────────────┘
      │
      │ Query
      ▼
┌─────────────┐    
│   Grafana   │    
│ Dashboard   │    
└─────────────┘    
```

## 💰 Cost Estimation

- **t3.large**: ~$0.084/hour × 96 hours (4 days) = ~$8.06
- **10GB Storage**: ~$0.10/month ÷ 30 × 4 days = ~$0.01  
- **Elastic IP**: ~$0.005/hour × 96 hours = ~$0.48

**Total**: ~$8.55 for 4 days of testing