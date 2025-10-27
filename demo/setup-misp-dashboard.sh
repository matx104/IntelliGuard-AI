#!/bin/bash

# Automated Setup Script for MISP Fix + Grafana Dashboard
# Run this from ~/IntelliGuard-AI/demo directory

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}"
cat << "EOF"
╔════════════════════════════════════════════╗
║  AI-SOC Setup: MISP Fix + Dashboard       ║
╔════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}Error: docker-compose.yml not found${NC}"
    echo "Please run this script from ~/IntelliGuard-AI/demo directory"
    exit 1
fi

echo -e "${YELLOW}Step 1: Fixing MISP configuration...${NC}"

# Check if CRON_USER_ID already exists
if grep -q "CRON_USER_ID" docker-compose.yml; then
    echo -e "${GREEN}✓ MISP already has CRON_USER_ID configured${NC}"
else
    echo "Adding CRON_USER_ID to MISP configuration..."
    
    # Backup docker-compose.yml
    cp docker-compose.yml docker-compose.yml.backup
    
    # Add CRON_USER_ID after MISP_BASEURL
    sed -i '/MISP_BASEURL=/a\      - CRON_USER_ID=1000' docker-compose.yml
    
    echo -e "${GREEN}✓ MISP configuration updated${NC}"
fi

echo ""
echo -e "${YELLOW}Step 2: Setting up Grafana dashboard...${NC}"

# Create dashboard directories
mkdir -p grafana-config/provisioning/dashboards

# Create dashboards.yml if it doesn't exist
if [ ! -f "grafana-config/provisioning/dashboards/dashboards.yml" ]; then
    cat > grafana-config/provisioning/dashboards/dashboards.yml << 'EOFYML'
apiVersion: 1

providers:
  - name: 'AI-SOC Dashboards'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOFYML
    echo -e "${GREEN}✓ Created dashboards.yml${NC}"
else
    echo -e "${GREEN}✓ dashboards.yml already exists${NC}"
fi

# Check if dashboard JSON exists
if [ ! -f "grafana-config/provisioning/dashboards/ai-soc-dashboard.json" ]; then
    echo -e "${YELLOW}⚠ Dashboard JSON not found${NC}"
    echo "Please copy ai-soc-dashboard.json to:"
    echo "  grafana-config/provisioning/dashboards/"
    echo ""
    echo "Then run this script again."
    DASHBOARD_MISSING=1
else
    echo -e "${GREEN}✓ Dashboard JSON found${NC}"
    DASHBOARD_MISSING=0
fi

echo ""
echo -e "${YELLOW}Step 3: Restarting services...${NC}"

# Stop problematic services
docker-compose stop misp grafana 2>/dev/null || true

# Wait a bit
sleep 2

# Start services
echo "Starting MISP..."
docker-compose up -d misp

echo "Starting Grafana..."
docker-compose up -d grafana

echo ""
echo -e "${GREEN}✓ Services restarted${NC}"

echo ""
echo -e "${YELLOW}Step 4: Verifying setup...${NC}"
sleep 5

# Check MISP
MISP_STATUS=$(docker ps --filter "name=soc-misp" --format "{{.Status}}" | grep -c "Up" || echo "0")
if [ "$MISP_STATUS" = "1" ]; then
    echo -e "${GREEN}✓ MISP is running${NC}"
else
    echo -e "${RED}✗ MISP is not running - check logs with: docker-compose logs misp${NC}"
fi

# Check Grafana
GRAFANA_STATUS=$(docker ps --filter "name=soc-grafana" --format "{{.Status}}" | grep -c "Up" || echo "0")
if [ "$GRAFANA_STATUS" = "1" ]; then
    echo -e "${GREEN}✓ Grafana is running${NC}"
else
    echo -e "${RED}✗ Grafana is not running - check logs with: docker-compose logs grafana${NC}"
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  Setup Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

if [ "$MISP_STATUS" = "1" ]; then
    echo -e "${YELLOW}MISP Access:${NC}"
    echo "  URL: http://${SERVER_IP}:8080"
    echo "  Login: admin@misp.local / admin_password"
    echo ""
fi

if [ "$GRAFANA_STATUS" = "1" ]; then
    echo -e "${YELLOW}Grafana Access:${NC}"
    echo "  URL: http://${SERVER_IP}:3000"
    echo "  Login: admin / admin"
    
    if [ "$DASHBOARD_MISSING" = "0" ]; then
        echo -e "${GREEN}  Dashboard: AI-Driven SOC - Security Overview${NC}"
    else
        echo -e "${YELLOW}  Note: Dashboard JSON needs to be added${NC}"
    fi
    echo ""
fi

echo -e "${YELLOW}Useful Commands:${NC}"
echo "  View MISP logs:    docker-compose logs misp -f"
echo "  View Grafana logs: docker-compose logs grafana -f"
echo "  Check all status:  docker-compose ps"
echo ""

if [ "$DASHBOARD_MISSING" = "1" ]; then
    echo -e "${YELLOW}⚠ Action Required:${NC}"
    echo "  Copy ai-soc-dashboard.json to grafana-config/provisioning/dashboards/"
    echo "  Then run: docker-compose restart grafana"
    echo ""
fi

echo -e "${GREEN}🎉 Your AI-SOC is ready for demo!${NC}"
echo ""
