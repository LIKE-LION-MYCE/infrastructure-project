#!/bin/bash

# Database Setup Script for Infrastructure Project
# This script sets up MySQL database users through SSH tunnel

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$SCRIPT_DIR/ansible"
RDS_ENDPOINT="likelion-terraform-dev-mysql.cb06282489sk.ap-northeast-2.rds.amazonaws.com"
EC2_IP="43.203.98.133"
TUNNEL_PORT="3307"
DB_TUNNEL_KEY=~/.ssh/aws/db_tunnel_key

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if SSH tunnel is running
check_tunnel() {
    if nc -z localhost $TUNNEL_PORT 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to start SSH tunnel
start_tunnel() {
    print_status "Starting SSH tunnel to RDS..."
    
    if [ ! -f "$DB_TUNNEL_KEY" ]; then
        print_error "SSH key not found: $DB_TUNNEL_KEY"
        print_status "Please copy the private key from EC2 server:"
        echo "  scp -i ~/.ssh/aws/likelion-terraform-key ubuntu@$EC2_IP:/home/dbtunnel/.ssh/db_tunnel_key ./dbtunnel_private_key"
        echo "  chmod 600 ./dbtunnel_private_key"
        exit 1
    fi
    
    # Start tunnel in background
    ssh -f -N -L $TUNNEL_PORT:$RDS_ENDPOINT:3306 dbtunnel@$EC2_IP -i "$DB_TUNNEL_KEY" \
        -o ServerAliveInterval=60 \
        -o ServerAliveCountMax=3 \
        -o StrictHostKeyChecking=no
    
    # Wait for tunnel to establish
    print_status "Waiting for tunnel to establish..."
    sleep 3
    
    if check_tunnel; then
        print_success "SSH tunnel established on localhost:$TUNNEL_PORT"
    else
        print_error "Failed to establish SSH tunnel"
        exit 1
    fi
}

# Function to stop SSH tunnel
stop_tunnel() {
    print_status "Stopping SSH tunnel..."
    pkill -f "ssh.*$TUNNEL_PORT:$RDS_ENDPOINT" || true
    print_success "SSH tunnel stopped"
}

# Function to run database setup
setup_database() {
    print_status "Running database user setup..."
    
    cd "$ANSIBLE_DIR"
    
    if [ -n "$MYCE_PASSWORD" ] && [ -n "$JOBDAM_PASSWORD" ]; then
        ansible-playbook -i inventory/hosts playbooks/database.yml \
            -e "myce_user_password=$MYCE_PASSWORD" \
            -e "jobdam_user_password=$JOBDAM_PASSWORD"
    else
        print_warning "Using default passwords (change for production!)"
        ansible-playbook -i inventory/hosts playbooks/database.yml
    fi
}

# Main script
main() {
    echo
    print_status "🗄️  Database Setup Script"
    echo "========================================"
    
    case "${1:-setup}" in
        "setup")
            # Check if tunnel is already running
            if check_tunnel; then
                print_success "SSH tunnel already running"
            else
                start_tunnel
            fi
            
            setup_database
            print_success "Database setup completed!"
            
            echo
            print_status "📋 Connection Information:"
            echo "  Host: localhost"
            echo "  Port: $TUNNEL_PORT"
            echo "  Database: myce_database"
            echo "  Example: mysql -h localhost -P $TUNNEL_PORT -u myce_choi -p myce_database"
            echo
            ;;
            
        "tunnel-start")
            if check_tunnel; then
                print_warning "SSH tunnel already running"
            else
                start_tunnel
            fi
            ;;
            
        "tunnel-stop")
            stop_tunnel
            ;;
            
        "tunnel-status")
            if check_tunnel; then
                print_success "SSH tunnel is running on port $TUNNEL_PORT"
            else
                print_warning "SSH tunnel is not running"
            fi
            ;;
            
        "help"|"-h"|"--help")
            echo "Usage: $0 [COMMAND]"
            echo
            echo "Commands:"
            echo "  setup         (default) Start tunnel and setup database users"
            echo "  tunnel-start  Start SSH tunnel only"
            echo "  tunnel-stop   Stop SSH tunnel"
            echo "  tunnel-status Check tunnel status"
            echo "  help          Show this help message"
            echo
            echo "Environment Variables:"
            echo "  MYCE_PASSWORD    Password for myce_* users"
            echo "  JOBDAM_PASSWORD  Password for jobdam_* users"
            echo
            echo "Examples:"
            echo "  $0                                    # Setup with default passwords"
            echo "  MYCE_PASSWORD=secure123 $0           # Setup with custom passwords"
            echo "  $0 tunnel-start                      # Start tunnel only"
            echo
            ;;
            
        *)
            print_error "Unknown command: $1"
            print_status "Run '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
