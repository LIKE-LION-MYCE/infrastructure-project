# Ansible Configuration for EC2 Servers

This Ansible setup configures EC2 instances with development and deployment tools.

## Quick Start

1. **Get EC2 IP from Terraform:**
   ```bash
   cd inventory
   ./get_ec2_ip.sh
   ```

2. **Test connection:**
   ```bash
   ansible all -m ping
   ```

3. **Run full configuration:**
   ```bash
   ansible-playbook playbooks/site.yml
   ```

## What Gets Installed

### System Configuration
- Swap memory (2GB)
- SSH tunnel setup for RDS access
- Folder structure under `/home/ubuntu/`

### CLI Tools
- **zsh** + oh-my-zsh with plugins
- **fzf** (fuzzy finder with Ctrl+R, Ctrl+T)
- **neofetch** (system info)
- **bat** (better cat)
- **btop** (better top)
- **rsync**, **tmux**, **vim**

### Programming Environment
- **Python3** + pip
- **Git**
- **Docker** + Docker Compose

### Infrastructure
- **nginx** (reverse proxy)
- **certbot** (SSL certificates)
- **fail2ban** (SSH protection)  
- **logrotate** (log management)

### Folder Structure Created
```
/home/ubuntu/
├── apps/
│   ├── backend/     # Backend Docker scripts, configs, .env
│   ├── frontend/    # Frontend static builds
│   └── monitoring/  # Prometheus, Grafana
├── logs/            # Centralized logs
├── scripts/         # Deployment scripts
├── docker/          # Docker Compose files
└── config/          # Configuration files

/etc/nginx/          # Nginx configs
/etc/letsencrypt/    # SSL certificates
/opt/monitoring/     # External monitoring tools
```

## Selective Installation

Run specific parts only:

```bash
# System setup only
ansible-playbook playbooks/site.yml --tags "system,folders"

# CLI tools only  
ansible-playbook playbooks/site.yml --tags "tools,shell"

# Programming environment only
ansible-playbook playbooks/site.yml --tags "programming,docker"

# Infrastructure only
ansible-playbook playbooks/site.yml --tags "infrastructure,nginx"
```

## Variables

Key variables in `group_vars/all.yml`:
- `swap_size`: Swap file size (default: 2G)
- `dockerhub_username`: Docker Hub username (optional)
- `dockerhub_password`: Docker Hub password (optional)

## Inventory

- Static: Edit `inventory/hosts` 
- Dynamic: Use `inventory/get_ec2_ip.sh` to auto-populate from Terraform

## Next Steps

After running the playbook:
1. SSH into your server: `ssh -i ~/.ssh/aws/likelion-terraform-key ubuntu@<IP>`
2. Your shell will be zsh with oh-my-zsh
3. All folders are ready under `/home/ubuntu/`
4. Docker is ready for your applications
5. nginx is ready for reverse proxy configuration