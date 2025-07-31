#!/bin/bash
# 🚀 Infrastructure Deployment Script
# Automates Terraform + Ansible deployment pipeline

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform/environments/dev"
ANSIBLE_DIR="$SCRIPT_DIR/ansible"

echo -e "${BLUE}🚀 Infrastructure Deployment Pipeline${NC}"
echo "======================================="

# Function to print status
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
echo -e "${BLUE}🔍 Checking prerequisites...${NC}"

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed or not in PATH"
    exit 1
fi

# Check if ansible is installed
if ! command -v ansible &> /dev/null; then
    print_error "Ansible is not installed or not in PATH"
    exit 1
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity --profile likelion-terraform &> /dev/null; then
    print_error "AWS CLI not configured with 'likelion-terraform' profile"
    exit 1
fi

# Check if SSH key exists
if [ ! -f ~/.ssh/aws/likelion-terraform-key ]; then
    print_error "SSH key not found at ~/.ssh/aws/likelion-terraform-key"
    exit 1
fi

print_status "All prerequisites met"

# Parse command line arguments
SKIP_TERRAFORM=false
SKIP_ANSIBLE=false
ANSIBLE_TAGS="system,folders,tools,infrastructure"
ENABLE_MONITORING=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-terraform)
            SKIP_TERRAFORM=true
            shift
            ;;
        --skip-ansible)
            SKIP_ANSIBLE=true
            shift
            ;;
        --tags)
            ANSIBLE_TAGS="$2"
            shift 2
            ;;
        --enable-monitoring)
            ENABLE_MONITORING=true
            ANSIBLE_TAGS="$ANSIBLE_TAGS,monitoring"
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-terraform     Skip Terraform deployment"
            echo "  --skip-ansible       Skip Ansible configuration"
            echo "  --tags TAGS          Ansible tags to run (default: system,folders,tools,infrastructure)"
            echo "  --enable-monitoring  Include monitoring stack (Prometheus, Grafana)"
            echo "  --help              Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Full deployment"
            echo "  $0 --enable-monitoring               # Full deployment with monitoring"
            echo "  $0 --skip-terraform                  # Only run Ansible"
            echo "  $0 --tags system,folders             # Only run specific Ansible tags"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Step 1: Terraform Deployment
if [ "$SKIP_TERRAFORM" = false ]; then
    echo -e "\n${BLUE}📋 Step 1: Terraform Infrastructure Deployment${NC}"
    echo "=============================================="
    
    cd "$TERRAFORM_DIR"
    
    echo "🔧 Initializing Terraform (downloading modules and providers)..."
    terraform init
    print_status "Terraform initialized successfully"
    
    echo "🔍 Checking Terraform configuration..."
    terraform validate
    print_status "Terraform configuration is valid"
    
    echo "📋 Planning infrastructure changes..."
    terraform plan
    
    echo ""
    read -p "🤔 Do you want to apply these changes? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Deployment cancelled by user"
        exit 0
    fi
    
    echo "🚀 Applying Terraform configuration..."
    terraform apply -auto-approve
    print_status "Infrastructure deployed successfully"
    
    echo "📊 Infrastructure outputs:"
    terraform output
    
    cd - > /dev/null
else
    print_warning "Skipping Terraform deployment"
fi

# Step 2: Link Terraform outputs to Ansible
echo -e "\n${BLUE}🔗 Step 2: Linking Terraform Outputs to Ansible${NC}"
echo "============================================="

cd "$ANSIBLE_DIR"

echo "📥 Extracting Terraform outputs..."
./inventory/get_ec2_ip.sh

if [ $? -eq 0 ]; then
    print_status "Terraform outputs linked to Ansible successfully"
else
    print_error "Failed to link Terraform outputs"
    exit 1
fi

# Step 3: Ansible Configuration
if [ "$SKIP_ANSIBLE" = false ]; then
    echo -e "\n${BLUE}⚙️  Step 3: Ansible Server Configuration${NC}"
    echo "======================================"
    
    echo "🔍 Testing connection to EC2 instance..."
    if ansible all -m ping; then
        print_status "Connection to EC2 instance successful"
    else
        print_error "Cannot connect to EC2 instance"
        echo "Please check:"
        echo "  - EC2 instance is running"
        echo "  - Security group allows SSH (port 22)"
        echo "  - SSH key is correct"
        exit 1
    fi
    
    echo "🔧 Running Ansible playbook with tags: $ANSIBLE_TAGS"
    
    if [ "$ENABLE_MONITORING" = true ]; then
        echo "📊 Monitoring stack will be installed (Prometheus + Grafana)"
        ansible-playbook playbooks/site.yml --tags "$ANSIBLE_TAGS" -e "enable_monitoring=true"
    else
        ansible-playbook playbooks/site.yml --tags "$ANSIBLE_TAGS"
    fi
    
    if [ $? -eq 0 ]; then
        print_status "Server configuration completed successfully"
    else
        print_error "Ansible configuration failed"
        exit 1
    fi
else
    print_warning "Skipping Ansible configuration"
fi

# Step 4: Display final information
echo -e "\n${GREEN}🎉 Deployment Completed Successfully!${NC}"
echo "=================================="

# Get server IP for display
if [ -f group_vars/all.yml ]; then
    SERVER_IP=$(grep "ec2_public_ip:" group_vars/all.yml | cut -d'"' -f2)
    
    echo -e "\n${BLUE}📋 Access Information:${NC}"
    echo "SSH Access:       ssh -i ~/.ssh/aws/likelion-terraform-key ubuntu@$SERVER_IP"
    echo "HTTP:            http://$SERVER_IP"
    echo "HTTPS:           https://$SERVER_IP"
    
    if [[ "$ANSIBLE_TAGS" == *"monitoring"* ]]; then
        echo "Prometheus:      http://$SERVER_IP:9090"
        echo "Grafana:         http://$SERVER_IP:3000 (admin/grafana123)"
    fi
    
    echo -e "\n${BLUE}📚 Documentation:${NC}"
    echo "Database Guide:   $(pwd)/database-connection-guide.md"
    echo "Project README:   $SCRIPT_DIR/README.md"
    
    echo -e "\n${BLUE}🛠️  Next Steps:${NC}"
    echo "1. Configure your domain/SSL certificates"
    echo "2. Deploy your applications to /home/ubuntu/apps/"
    echo "3. Set up database users and permissions"
    echo "4. Configure monitoring alerts (if enabled)"
fi

cd - > /dev/null

echo -e "\n${GREEN}✨ Happy coding! 🚀${NC}"