# Monitoring Setup Options for MYCE

You have two monitoring setup options to choose from:

## Option A: SSH Tunnel (Secure, Private)
**Best for:** Development, staging, or when security is top priority

### Architecture
```
Your Computer → SSH Tunnel → EC2:9090 (Prometheus)
Your Computer → SSH Tunnel → EC2:3000 (Grafana)
```

### Pros
- ✅ **Most Secure** - No public exposure
- ✅ **Simple Setup** - No ALB/DNS configuration needed
- ✅ **No SSL Certificates** - Works immediately
- ✅ **Zero Cost** - No additional AWS resources
- ✅ **Full Control** - Direct access to all features

### Cons
- ❌ Requires SSH key to access
- ❌ Not accessible by team members without SSH access
- ❌ No public dashboards for stakeholders
- ❌ Need to run tunnel script each time

### How to Use
```bash
# Start monitoring access
./scripts/monitoring-tunnel.sh

# Access locally
http://localhost:9090  # Prometheus
http://localhost:3000  # Grafana
```

---

## Option B: ALB Public Access (Like jobdams.online)
**Best for:** Production, team access, public dashboards

### Architecture
```
Internet → ALB → EC2:3000 (Grafana)
         ↓
   SSL Termination
   Authentication
   Path/Subdomain Routing
```

### Pros
- ✅ **Team Access** - Anyone with credentials can access
- ✅ **Public Dashboards** - Share specific dashboards publicly
- ✅ **Professional URLs** - `monitoring.myce.live` or `api.myce.live/dashboard`
- ✅ **SSL/HTTPS** - Secure with ACM certificates
- ✅ **Direct Links** - Bookmark specific dashboards

### Cons
- ❌ More complex setup (ALB, Route53, Terraform)
- ❌ Security considerations (must configure authentication)
- ❌ Additional AWS costs (ALB hours)
- ❌ Requires domain configuration

### How to Use
```bash
# Access via domain (after setup)
https://api.myce.live/dashboard/        # Main Grafana
https://api.myce.live/dashboard/ec2     # EC2 metrics shortcut
https://api.myce.live/dashboard/app     # App metrics shortcut

# OR with subdomain
https://monitoring.myce.live/           # Grafana main
```

---

## Quick Comparison

| Feature | Option A (SSH Tunnel) | Option B (ALB Public) |
|---------|----------------------|----------------------|
| Security | ⭐⭐⭐⭐⭐ Most Secure | ⭐⭐⭐ Secure with Auth |
| Setup Complexity | ⭐ Simple | ⭐⭐⭐ Moderate |
| Team Access | ❌ SSH Key Required | ✅ Web Browser |
| Public Dashboards | ❌ Not Possible | ✅ Supported |
| Cost | Free | ~$20/month (ALB) |
| Professional Look | ⭐⭐ Local Only | ⭐⭐⭐⭐⭐ Custom Domain |
| Best For | Dev/Staging | Production |

---

## How to Choose

Choose **Option A** if:
- You're the only one accessing monitoring
- This is for development/staging
- Security is paramount
- You want to start immediately

Choose **Option B** if:
- Multiple team members need access
- You want to share dashboards with stakeholders
- This is for production
- You want professional URLs like your previous project

---

## Implementation Status

### Option A ✅ Ready to Use
All files are created and ready:
- `/scripts/monitoring-tunnel.sh` - Access script
- Prometheus config updated for Spring Boot
- Grafana dashboards prepared

### Option B 🔧 Ready to Implement
Template files prepared:
- `/monitoring/option_b/terraform/` - ALB configuration
- `/monitoring/option_b/grafana/` - Public access config
- `/monitoring/option_b/shortcuts/` - Dashboard shortcuts

---

## Quick Start

### To use Option A:
```bash
cd infrastructure-project
./deploy.sh --enable-monitoring
cd ../myce-server
./scripts/monitoring-tunnel.sh
```

### To use Option B:
```bash
cd infrastructure-project/monitoring/option_b
./setup-alb-monitoring.sh
```