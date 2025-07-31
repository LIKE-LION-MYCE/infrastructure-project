#!/bin/bash
# Helper script to get all Terraform outputs and update Ansible configuration

cd ../terraform/environments/dev

# Get all Terraform outputs
echo "🚀 Getting Terraform outputs..."
EC2_IP=$(terraform output -raw public_ip 2>/dev/null)
DB_ENDPOINT=$(terraform output -raw db_endpoint 2>/dev/null)
DB_NAME=$(terraform output -raw db_name 2>/dev/null)
SSH_COMMAND=$(terraform output -raw ssh_command 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$EC2_IP" ]; then
    echo "✅ Found EC2 IP: $EC2_IP"
    echo "✅ Found DB Endpoint: $DB_ENDPOINT"
    echo "✅ Found DB Name: $DB_NAME"
    cd - > /dev/null
    
    # Update inventory file
    sed -i.bak "s/^# Example: .*/# Example: $EC2_IP/" inventory/hosts
    
    # Check if IP already exists in inventory
    if ! grep -q "^$EC2_IP" inventory/hosts; then
        # Add IP after the comment line
        sed -i.bak "/^# Example:/a\\
$EC2_IP" inventory/hosts
    fi
    
    # Create Ansible variables file with RDS info
    cat > group_vars/all.yml << EOF
# Auto-generated from Terraform outputs - $(date)
---
# EC2 Configuration
ec2_public_ip: "$EC2_IP"

# RDS Configuration  
rds_endpoint: "$DB_ENDPOINT"
rds_port: 3306
rds_database: "$DB_NAME"
rds_username: "admin"
rds_password: "myceforever"

# SSH Configuration
ssh_command: "$SSH_COMMAND"
EOF

    echo "✅ Updated inventory/hosts with IP: $EC2_IP"
    echo "✅ Created group_vars/all.yml with RDS connection info"
    
    # Create missing templates directory if needed
    mkdir -p roles/system_config/templates
    
    # Create SSH tunnel script template
    cat > roles/system_config/templates/create_tunnel.sh.j2 << 'EOF'
#!/bin/bash
# SSH Tunnel Script for RDS Access
# Auto-generated from Terraform outputs

echo "🔒 Creating SSH tunnel to RDS database..."
echo "📍 RDS Endpoint: {{ rds_endpoint }}"
echo "🏠 Local Port: 3307 (to avoid conflicts with local MySQL)"

# Create SSH tunnel (run in background)
ssh -f -N -L 3307:{{ rds_endpoint }}:{{ rds_port }} ubuntu@{{ ec2_public_ip }} \
    -i ~/.ssh/aws/likelion-terraform-key \
    -o ServerAliveInterval=60 \
    -o ServerAliveCountMax=3

if [ $? -eq 0 ]; then
    echo "✅ SSH tunnel created successfully!"
    echo ""
    echo "📋 Connection Details:"
    echo "   Host: localhost"
    echo "   Port: 3307"
    echo "   Database: {{ rds_database }}"
    echo "   Username: {{ rds_username }}"
    echo "   Password: {{ rds_password }}"
    echo ""
    echo "🔌 MySQL Command:"
    echo "   mysql -h localhost -P 3307 -u {{ rds_username }} -p{{ rds_password }} {{ rds_database }}"
    echo ""
    echo "🛑 To close tunnel: pkill -f 'ssh.*3307:{{ rds_endpoint }}'"
else
    echo "❌ Failed to create SSH tunnel"
    exit 1
fi
EOF

    # Create authorized_keys template
    cat > roles/system_config/templates/authorized_keys_tunnel.j2 << 'EOF'
# SSH keys for database tunnel access
# Restricted to only allow port forwarding, no shell access

# Add team member SSH public keys here with tunnel restrictions
# Format: command="echo 'Tunnel only'",no-agent-forwarding,no-X11-forwarding,no-pty ssh-rsa AAAAB3... user@host

# Example (replace with actual team member keys):
# command="echo 'DB tunnel only'",no-agent-forwarding,no-X11-forwarding,no-pty ssh-rsa AAAAB3NzaC1yc2EAAAA... team-member@company.com
EOF

    # Create database connection guide
    cat > database-connection-guide.md << EOF
# 🗄️ Database Connection Guide

## 📋 Connection Information
- **RDS Endpoint:** \`$DB_ENDPOINT\`  
- **Database:** \`$DB_NAME\`
- **Username:** \`admin\`
- **Password:** \`myceforever\`
- **Port:** \`3306\`

## 🔒 Secure Connection via SSH Tunnel

### 1. Create SSH Tunnel
\`\`\`bash
# Run the tunnel script (created by Ansible)
/home/ubuntu/scripts/create_tunnel.sh

# Or manually:
ssh -L 3307:$DB_ENDPOINT:3306 ubuntu@$EC2_IP -i ~/.ssh/aws/likelion-terraform-key
\`\`\`

### 2. Connect to Database
\`\`\`bash
mysql -h localhost -P 3307 -u admin -pmyceforever $DB_NAME
\`\`\`

### 3. Close Tunnel
\`\`\`bash
pkill -f 'ssh.*3307:$DB_ENDPOINT'
\`\`\`

## 🛠️ Database Management

### Create Application User
\`\`\`sql
CREATE USER 'app_user'@'%' IDENTIFIED BY 'secure_app_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON $DB_NAME.* TO 'app_user'@'%';
FLUSH PRIVILEGES;
\`\`\`

### Connection String for Applications
\`\`\`
mysql://admin:myceforever@$DB_ENDPOINT:3306/$DB_NAME
\`\`\`

---
*Auto-generated on $(date)*
EOF

    echo "✅ Created SSH tunnel script template"
    echo "✅ Created authorized_keys template"  
    echo "✅ Created database-connection-guide.md"
    echo ""
    echo "🎉 All automation complete! Ansible now has all RDS connection info."
    
else
    echo "❌ Error: Could not get Terraform outputs"
    echo "Make sure you have deployed your infrastructure first:"
    echo "  cd terraform/environments/dev"
    echo "  terraform apply"
    exit 1
fi