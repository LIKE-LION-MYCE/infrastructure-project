#!/bin/bash

# Setup script for Option B: ALB Public Monitoring (like jobdams.online)

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Option B: ALB Public Monitoring Setup${NC}"
echo -e "${BLUE}   Replicating your jobdams.online setup${NC}"
echo "==========================================="
echo ""

# Function to print status
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform not installed"
        exit 1
    fi
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI not installed"
        exit 1
    fi
    
    # Check Ansible
    if ! command -v ansible &> /dev/null; then
        print_error "Ansible not installed"
        exit 1
    fi
    
    print_status "All prerequisites met"
}

# Choose routing strategy
choose_routing() {
    echo -e "\n${BLUE}📍 Choose your routing strategy:${NC}"
    echo "1) Path-based: api.myce.live/dashboard/ (like jobdams.online)"
    echo "2) Subdomain: monitoring.myce.live"
    echo ""
    read -p "Enter choice (1 or 2): " ROUTING_CHOICE
    
    case $ROUTING_CHOICE in
        1)
            ROUTING_TYPE="path"
            BASE_URL="https://api.myce.live/dashboard"
            print_status "Selected: Path-based routing"
            ;;
        2)
            ROUTING_TYPE="subdomain"
            BASE_URL="https://monitoring.myce.live"
            print_status "Selected: Subdomain routing"
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
}

# Deploy Terraform changes
deploy_terraform() {
    echo -e "\n${BLUE}🏗️  Deploying ALB configuration...${NC}"
    
    cd terraform
    
    if [ "$ROUTING_TYPE" = "path" ]; then
        cp alb-path-routing.tf.template alb-monitoring.tf
    else
        cp alb-subdomain-routing.tf.template alb-monitoring.tf
    fi
    
    # Initialize and apply
    terraform init
    terraform plan -out=monitoring.plan
    
    echo -e "\n${YELLOW}Review the plan above. Continue?${NC}"
    read -p "Deploy? (y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform apply monitoring.plan
        print_status "ALB configuration deployed"
    else
        print_warning "Deployment cancelled"
        exit 0
    fi
    
    cd ..
}

# Configure Grafana
configure_grafana() {
    echo -e "\n${BLUE}⚙️  Configuring Grafana for public access...${NC}"
    
    # Get EC2 IP
    EC2_IP=$(cd ../../ansible && grep "ec2_public_ip:" group_vars/all.yml | cut -d'"' -f2)
    
    if [ -z "$EC2_IP" ]; then
        print_error "Could not find EC2 IP"
        exit 1
    fi
    
    # Create Grafana config
    cat > ansible/grafana-public-config.yml <<EOF
---
- name: Configure Grafana for public access
  hosts: all
  become: yes
  vars:
    grafana_root_url: "${BASE_URL}"
    routing_type: "${ROUTING_TYPE}"
  tasks:
    - name: Update Grafana configuration
      template:
        src: templates/grafana-public.ini.j2
        dest: /etc/grafana/grafana.ini
        backup: yes
      notify: restart grafana
    
    - name: Create dashboard shortcuts
      template:
        src: templates/dashboard-shortcuts.js.j2
        dest: /usr/share/grafana/public/dashboards/shortcuts.js
      when: routing_type == "path"
    
    - name: Restart Grafana
      systemd:
        name: grafana-server
        state: restarted
  
  handlers:
    - name: restart grafana
      systemd:
        name: grafana-server
        state: restarted
EOF
    
    # Run Ansible playbook
    cd ../../ansible
    ansible-playbook ../monitoring/option_b/ansible/grafana-public-config.yml
    cd ../monitoring/option_b
    
    print_status "Grafana configured for public access"
}

# Create dashboard shortcuts
create_shortcuts() {
    echo -e "\n${BLUE}🔗 Creating dashboard shortcuts...${NC}"
    
    cat > shortcuts.json <<EOF
{
  "shortcuts": [
    {
      "path": "/dashboard/ec2",
      "redirect": "/d/rYdddlPWk/node-exporter-full?orgId=1&from=now-24h&to=now",
      "name": "EC2 System Metrics"
    },
    {
      "path": "/dashboard/app",
      "redirect": "/d/spring-boot-myce/myce-spring-boot-application?from=now-1h&to=now",
      "name": "MYCE Application"
    },
    {
      "path": "/dashboard/jvm",
      "redirect": "/d/4701/jvm-micrometer?from=now-1h&to=now",
      "name": "JVM Metrics"
    }
  ]
}
EOF
    
    print_status "Dashboard shortcuts created"
}

# Display final instructions
show_completion() {
    echo -e "\n${GREEN}🎉 ALB Public Monitoring Setup Complete!${NC}"
    echo "========================================="
    echo ""
    echo -e "${BLUE}📊 Access your monitoring:${NC}"
    
    if [ "$ROUTING_TYPE" = "path" ]; then
        echo "  Main Dashboard:  https://api.myce.live/dashboard/"
        echo "  EC2 Metrics:     https://api.myce.live/dashboard/ec2"
        echo "  App Metrics:     https://api.myce.live/dashboard/app"
        echo "  JVM Metrics:     https://api.myce.live/dashboard/jvm"
    else
        echo "  Main Dashboard:  https://monitoring.myce.live/"
        echo "  Direct Links:"
        echo "    EC2: https://monitoring.myce.live/d/rYdddlPWk/node-exporter-full"
        echo "    App: https://monitoring.myce.live/d/spring-boot-myce/myce-app"
    fi
    
    echo ""
    echo -e "${BLUE}🔐 Default Credentials:${NC}"
    echo "  Username: admin"
    echo "  Password: grafana123"
    echo ""
    echo -e "${YELLOW}⚠️  Security Recommendations:${NC}"
    echo "  1. Change default admin password immediately"
    echo "  2. Configure Grafana authentication (LDAP/OAuth)"
    echo "  3. Set appropriate dashboard permissions"
    echo "  4. Consider IP whitelisting in ALB security group"
    echo ""
    echo -e "${BLUE}📋 Next Steps:${NC}"
    echo "  1. Log into Grafana and change admin password"
    echo "  2. Import recommended dashboards (IDs: 4701, 1860, 11159)"
    echo "  3. Set dashboard permissions for public viewing"
    echo "  4. Test your shortcuts"
    echo ""
    echo -e "${GREEN}✨ Your monitoring is now publicly accessible like jobdams.online!${NC}"
}

# Main execution
main() {
    check_prerequisites
    choose_routing
    
    echo -e "\n${YELLOW}This will:${NC}"
    echo "  1. Configure ALB target groups for Grafana"
    echo "  2. Set up routing rules"
    echo "  3. Configure Grafana for public access"
    echo "  4. Create dashboard shortcuts"
    echo ""
    read -p "Continue? (y/n): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Setup cancelled"
        exit 0
    fi
    
    deploy_terraform
    configure_grafana
    create_shortcuts
    show_completion
}

# Run main function
main