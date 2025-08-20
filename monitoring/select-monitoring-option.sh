#!/bin/bash

# Monitoring Option Selection Script

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 MYCE Monitoring Setup${NC}"
echo "========================="
echo ""
echo "Choose your monitoring setup:"
echo ""

echo -e "${GREEN}Option A: SSH Tunnel (Secure & Private)${NC}"
echo "  ✅ Most secure - no public exposure"
echo "  ✅ Zero additional cost"
echo "  ✅ Quick setup"
echo "  ❌ Requires SSH key for access"
echo "  ❌ No team sharing"
echo ""
echo "  Access: SSH tunnel → http://localhost:3000"
echo ""

echo -e "${GREEN}Option B: ALB Public Access (Like jobdams.online)${NC}"
echo "  ✅ Team access via web browser"
echo "  ✅ Public dashboard sharing"
echo "  ✅ Professional URLs (api.myce.live/dashboard)"
echo "  ✅ Custom shortcuts (/dashboard/ec2, /dashboard/app)"
echo "  ❌ More complex setup"
echo "  ❌ Additional AWS costs (~$20/month)"
echo ""
echo "  Access: https://api.myce.live/dashboard/"
echo ""

read -p "Enter your choice (A or B): " CHOICE

case $CHOICE in
    [Aa])
        echo -e "\n${GREEN}✅ Option A Selected: SSH Tunnel${NC}"
        echo ""
        echo "Setting up secure SSH tunnel monitoring..."
        echo ""
        echo "Steps to complete:"
        echo "1. Deploy monitoring stack: ./deploy.sh --enable-monitoring"
        echo "2. Access via tunnel: ../myce-server/scripts/monitoring-tunnel.sh"
        echo ""
        read -p "Deploy now? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ./deploy.sh --enable-monitoring
            echo ""
            echo -e "${GREEN}✨ Option A setup complete!${NC}"
            echo ""
            echo "To access monitoring:"
            echo "  cd ../myce-server"
            echo "  ./scripts/monitoring-tunnel.sh"
            echo ""
            echo "Then open:"
            echo "  Prometheus: http://localhost:9090"
            echo "  Grafana: http://localhost:3000 (admin/grafana123)"
        fi
        ;;
    [Bb])
        echo -e "\n${GREEN}✅ Option B Selected: ALB Public Access${NC}"
        echo ""
        echo "Setting up public monitoring like jobdams.online..."
        echo ""
        echo "This will replicate your previous setup:"
        echo "  https://api.myce.live/dashboard/     (main Grafana)"
        echo "  https://api.myce.live/dashboard/ec2  (system metrics)"
        echo "  https://api.myce.live/dashboard/app  (app metrics)"
        echo ""
        read -p "Continue with Option B setup? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cd option_b
            chmod +x setup-alb-monitoring.sh
            ./setup-alb-monitoring.sh
        fi
        ;;
    *)
        echo -e "\n${RED}❌ Invalid choice. Please run again and select A or B.${NC}"
        exit 1
        ;;
esac