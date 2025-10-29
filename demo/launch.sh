#!/bin/bash

# ============================================================================
#  IntelliGuard AI - Complete SOC Platform Setup Script
# ============================================================================
#  This script deploys the full AI-Driven Security Operations Center with
#  comprehensive monitoring, logging, and threat intelligence capabilities.
#
#  Components:
#    - Core SOC: Elasticsearch, Wazuh, TheHive, MISP, Cortex
#    - Monitoring: Prometheus, Loki, Grafana, cAdvisor, Node Exporter
#    - Management: Portainer, Dockge
#    - AI/ML: Threat detection, automated hunting, SOAR automation
# ============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_header() {
    echo -e "${CYAN}$1${NC}"
}

# Banner
clear
echo ""
echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║                                                                ║${NC}"
echo -e "${MAGENTA}║${NC}          ${CYAN}🛡️  IntelliGuard AI - SOC Platform Setup${NC}          ${MAGENTA}║${NC}"
echo -e "${MAGENTA}║                                                                ║${NC}"
echo -e "${MAGENTA}║${NC}     ${GREEN}AI-Driven Security Operations Center with Full Stack${NC}    ${MAGENTA}║${NC}"
echo -e "${MAGENTA}║${NC}          ${GREEN}Monitoring, Logging & Threat Intelligence${NC}         ${MAGENTA}║${NC}"
echo -e "${MAGENTA}║                                                                ║${NC}"
echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
sleep 1

# ============================================================================
# PREREQUISITE CHECKS
# ============================================================================

print_header "================================================"
print_header "STEP 1: Checking Prerequisites"
print_header "================================================"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_warning "Please don't run this script as root"
    print_info "Run as a regular user with sudo privileges"
    exit 1
fi
print_success "Running as non-root user"

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed"
    echo ""
    echo "Please install Docker first:"
    echo "  curl -fsSL https://get.docker.com -o get-docker.sh"
    echo "  sudo sh get-docker.sh"
    exit 1
fi
print_success "Docker found: $(docker --version | cut -d' ' -f3 | tr -d ',')"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed"
    echo ""
    echo "Please install Docker Compose first:"
    echo "  sudo apt-get install docker-compose"
    exit 1
fi
print_success "Docker Compose found: $(docker-compose --version | cut -d' ' -f3 | tr -d ',')"

# Check if Docker daemon is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker daemon is not running"
    echo ""
    echo "Start Docker with:"
    echo "  sudo systemctl start docker"
    exit 1
fi
print_success "Docker daemon is running"

# Check available disk space
echo ""
print_info "Checking system resources..."
available_space=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$available_space" -lt 30 ]; then
    print_warning "Less than 30GB disk space available (${available_space}GB)"
    print_info "Recommended: 50GB+ for optimal performance"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Setup cancelled. Please free up disk space and try again."
        exit 1
    fi
else
    print_success "Disk space: ${available_space}GB available"
fi

# Check available memory
total_mem=$(free -g | grep Mem | awk '{print $2}')
if [ "$total_mem" -lt 8 ]; then
    print_warning "Less than 8GB RAM available (${total_mem}GB)"
    print_info "Minimum: 8GB | Recommended: 16GB+"
    print_info "Monitoring services will use additional 2-4GB RAM"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Setup cancelled. System needs more RAM."
        exit 1
    fi
else
    print_success "Memory: ${total_mem}GB RAM available"
fi

# ============================================================================
# DIRECTORY STRUCTURE SETUP
# ============================================================================

echo ""
print_header "================================================"
print_header "STEP 2: Creating Directory Structure"
print_header "================================================"
echo ""

directories=(
    "prometheus-config"
    "loki-config"
    "promtail-config"
    "grafana-config/provisioning/datasources"
    "grafana-config/provisioning/dashboards"
    "wazuh-config"
    "thehive-config"
    "cortex-config"
    "ml-service"
    "threat-hunting"
    "soar-automation"
    "data-generator"
    "stacks"
)

for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        print_success "Created: $dir"
    else
        print_info "Already exists: $dir"
    fi
done

# ============================================================================
# CONFIGURATION VALIDATION
# ============================================================================

echo ""
print_header "================================================"
print_header "STEP 3: Validating Configuration Files"
print_header "================================================"
echo ""

config_files=(
    "prometheus-config/prometheus.yml"
    "loki-config/loki-config.yml"
    "promtail-config/promtail-config.yml"
    "grafana-config/provisioning/datasources/datasources.yml"
    "grafana-config/provisioning/dashboards/dashboards.yml"
)

missing_configs=0
for config in "${config_files[@]}"; do
    if [ ! -f "$config" ]; then
        print_error "Missing: $config"
        missing_configs=$((missing_configs + 1))
    else
        print_success "Found: $config"
    fi
done

if [ $missing_configs -gt 0 ]; then
    print_error "Missing $missing_configs configuration file(s)"
    echo ""
    print_info "Please ensure all configuration files are in place:"
    for config in "${config_files[@]}"; do
        echo "  - $config"
    done
    exit 1
fi

# Check for dashboard files
dashboard_count=$(ls -1 grafana-config/provisioning/dashboards/*.json 2>/dev/null | wc -l)
if [ $dashboard_count -lt 4 ]; then
    print_warning "Found only $dashboard_count dashboard(s), expected 4"
    print_info "Expected dashboards:"
    print_info "  - infrastructure-monitoring.json"
    print_info "  - security-monitoring.json"
    print_info "  - log-analysis.json"
    print_info "  - threat-intelligence.json"
else
    print_success "Found $dashboard_count Grafana dashboards"
fi

# Check docker-compose.yml
echo ""
if [ ! -f "docker-compose.yml" ]; then
    print_error "docker-compose.yml not found"
    print_info "Please ensure docker-compose.yml is in the current directory"
    exit 1
fi

# Validate docker-compose has monitoring services
if grep -q "prometheus:" docker-compose.yml && \
   grep -q "loki:" docker-compose.yml && \
   grep -q "node-exporter:" docker-compose.yml; then
    print_success "Docker Compose configuration validated"
    print_success "Includes: Core SOC + Monitoring Stack"
else
    print_warning "Docker Compose may be missing monitoring services"
    print_info "Continuing with available configuration..."
fi

# ============================================================================
# SYSTEM CONFIGURATION
# ============================================================================

echo ""
print_header "================================================"
print_header "STEP 4: System Configuration"
print_header "================================================"
echo ""

# Configure vm.max_map_count for Elasticsearch
current_max_map_count=$(sysctl vm.max_map_count 2>/dev/null | awk '{print $3}')
if [ -z "$current_max_map_count" ] || [ "$current_max_map_count" -lt 262144 ]; then
    print_warning "vm.max_map_count needs adjustment"
    print_info "Elasticsearch requires vm.max_map_count >= 262144"
    print_info "Current value: ${current_max_map_count:-not set}"
    echo ""
    read -p "Configure vm.max_map_count now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo sysctl -w vm.max_map_count=262144
        print_success "vm.max_map_count set to 262144"
        
        # Make it persistent
        if ! grep -q "vm.max_map_count" /etc/sysctl.conf 2>/dev/null; then
            echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf > /dev/null
            print_success "Configuration persisted to /etc/sysctl.conf"
        fi
    else
        print_warning "Skipping vm.max_map_count configuration"
        print_info "Elasticsearch may not start properly"
    fi
else
    print_success "vm.max_map_count properly configured: $current_max_map_count"
fi

# ============================================================================
# DOCKER IMAGE DOWNLOAD
# ============================================================================

echo ""
print_header "================================================"
print_header "STEP 5: Downloading Docker Images"
print_header "================================================"
echo ""
print_info "This may take 5-15 minutes depending on your connection..."
print_info "Downloading ~5GB of images for all services"
echo ""

if docker-compose pull; then
    print_success "All images downloaded successfully"
else
    print_error "Failed to download some images"
    print_info "Check your internet connection and try again"
    print_info "Or run: docker-compose pull"
    exit 1
fi

# ============================================================================
# SERVICE DEPLOYMENT
# ============================================================================

echo ""
print_header "================================================"
print_header "STEP 6: Starting All Services"
print_header "================================================"
echo ""
print_info "Deploying complete SOC platform..."
echo ""

# Start services
if docker-compose up -d; then
    print_success "All services started successfully"
else
    print_error "Failed to start services"
    echo ""
    print_info "Troubleshooting tips:"
    echo "  1. Check logs: docker-compose logs"
    echo "  2. Verify ports not in use: netstat -tulpn"
    echo "  3. Check Docker status: docker ps"
    exit 1
fi

# Wait for initialization
echo ""
print_info "Waiting for services to initialize..."
print_info "This may take 3-5 minutes for all services to be ready"
echo ""

# Progress indicator
for i in {1..30}; do
    echo -n "."
    sleep 1
done
echo ""

# ============================================================================
# HEALTH CHECKS
# ============================================================================

echo ""
print_header "================================================"
print_header "STEP 7: Performing Health Checks"
print_header "================================================"
echo ""

# Check Elasticsearch
print_info "Checking Elasticsearch..."
elasticsearch_ready=false
for i in {1..12}; do
    if curl -s http://localhost:9200/_cluster/health > /dev/null 2>&1; then
        print_success "Elasticsearch is ready"
        elasticsearch_ready=true
        break
    fi
    if [ $i -eq 12 ]; then
        print_error "Elasticsearch failed to start"
        print_info "Check logs: docker-compose logs elasticsearch"
    else
        echo "   Attempt $i/12..."
        sleep 10
    fi
done

# Check Prometheus
print_info "Checking Prometheus..."
if curl -s http://localhost:9090/-/healthy > /dev/null 2>&1; then
    print_success "Prometheus is ready"
else
    print_warning "Prometheus may not be fully ready yet"
    print_info "It may take a few more minutes to initialize"
fi

# Check Loki
print_info "Checking Loki..."
if curl -s http://localhost:3100/ready > /dev/null 2>&1; then
    print_success "Loki is ready"
else
    print_warning "Loki may not be fully ready yet"
    print_info "Logs will be available shortly"
fi

# Check Grafana
print_info "Checking Grafana..."
if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
    print_success "Grafana is ready"
else
    print_warning "Grafana may not be fully ready yet"
    print_info "Try accessing it in a few minutes"
fi

# Count running containers
echo ""
running_containers=$(docker ps --filter "name=soc-" --format "{{.Names}}" | wc -l)
total_containers=$(docker-compose ps -q | wc -l)
print_success "Running containers: $running_containers/$total_containers"

# ============================================================================
# DEPLOYMENT COMPLETE
# ============================================================================

echo ""
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                                ║${NC}"
echo -e "${GREEN}║${NC}                   ${CYAN}🎉 DEPLOYMENT COMPLETE! 🎉${NC}                   ${GREEN}║${NC}"
echo -e "${GREEN}║                                                                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# ACCESS INFORMATION
# ============================================================================

print_header "╔════════════════════════════════════════════════════════════════╗"
print_header "║                     ACCESS INFORMATION                         ║"
print_header "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📊 MONITORING & DASHBOARDS${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${GREEN}Grafana Dashboards:${NC}"
echo -e "    URL:      ${BLUE}http://localhost:3000${NC}"
echo -e "    Login:    ${YELLOW}admin${NC} / ${YELLOW}admin${NC}"
echo -e "    Location: ${CYAN}Dashboards → Browse → SOC Platform${NC}"
echo ""
echo -e "    Available Dashboards:"
echo -e "      ${GREEN}1.${NC} Infrastructure Monitoring (System & Container Metrics)"
echo -e "      ${GREEN}2.${NC} Security Monitoring (Threats & Alerts)"
echo -e "      ${GREEN}3.${NC} Log Analysis (Centralized Logging)"
echo -e "      ${GREEN}4.${NC} Threat Intelligence (MISP Data)"
echo ""
echo -e "  ${GREEN}Prometheus:${NC}     ${BLUE}http://localhost:9090${NC}"
echo -e "  ${GREEN}cAdvisor:${NC}       ${BLUE}http://localhost:8081${NC}"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}🛡️  SOC PLATFORM TOOLS${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${GREEN}TheHive (SOAR):${NC}"
echo -e "    URL:   ${BLUE}http://localhost:9000${NC}"
echo -e "    Login: ${YELLOW}admin@thehive.local${NC} / ${YELLOW}secret${NC}"
echo ""
echo -e "  ${GREEN}MISP (Threat Intel):${NC}"
echo -e "    URL:   ${BLUE}http://localhost:8080${NC}"
echo -e "    Login: ${YELLOW}admin@misp.local${NC} / ${YELLOW}admin_password${NC}"
echo ""
echo -e "  ${GREEN}Cortex (Analysis):${NC}       ${BLUE}http://localhost:9001${NC}"
echo -e "  ${GREEN}Elasticsearch:${NC}           ${BLUE}http://localhost:9200${NC}"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}🔧 CONTAINER MANAGEMENT${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${GREEN}Portainer:${NC}"
echo -e "    URL:  ${BLUE}https://localhost:9443${NC}"
echo -e "    Note: ${CYAN}Create admin account on first login${NC}"
echo ""
echo -e "  ${GREEN}Dockge:${NC}"
echo -e "    URL:  ${BLUE}http://localhost:5001${NC}"
echo -e "    Note: ${CYAN}Visual docker-compose management${NC}"
echo ""

# ============================================================================
# MANAGEMENT COMMANDS
# ============================================================================

echo ""
print_header "╔════════════════════════════════════════════════════════════════╗"
print_header "║                   MANAGEMENT COMMANDS                          ║"
print_header "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo -e "${YELLOW}Container Management:${NC}"
echo -e "  ${GREEN}View status:${NC}        docker-compose ps"
echo -e "  ${GREEN}View all logs:${NC}      docker-compose logs -f"
echo -e "  ${GREEN}View service logs:${NC}  docker-compose logs -f ${CYAN}[service-name]${NC}"
echo -e "  ${GREEN}Restart service:${NC}    docker-compose restart ${CYAN}[service-name]${NC}"
echo -e "  ${GREEN}Stop platform:${NC}      docker-compose down"
echo -e "  ${GREEN}Stop + remove data:${NC} docker-compose down -v"
echo ""

echo -e "${YELLOW}Quick Health Checks:${NC}"
echo -e "  ${GREEN}ES Cluster:${NC}         curl http://localhost:9200/_cluster/health?pretty"
echo -e "  ${GREEN}Threat Alerts:${NC}      curl http://localhost:9200/threat-alerts/_count?pretty"
echo -e "  ${GREEN}Prometheus:${NC}         curl http://localhost:9090/-/healthy"
echo -e "  ${GREEN}Loki:${NC}               curl http://localhost:3100/ready"
echo ""

# ============================================================================
# IMPORTANT NOTES
# ============================================================================

echo ""
print_header "╔════════════════════════════════════════════════════════════════╗"
print_header "║                      IMPORTANT NOTES                           ║"
print_header "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo -e "${YELLOW}🔐 Security:${NC}"
echo "  • Change all default passwords immediately"
echo "  • This setup is for POC/testing - harden for production"
echo "  • Review docs/MONITORING-GUIDE.md for security best practices"
echo ""

echo -e "${YELLOW}📊 Monitoring:${NC}"
echo "  • Dashboards auto-refresh (10-30 second intervals)"
echo "  • Default data retention: 30 days (configurable)"
echo "  • Use time picker in Grafana to adjust time ranges"
echo ""

echo -e "${YELLOW}💾 Data Persistence:${NC}"
echo "  • All data stored in Docker volumes"
echo "  • Regular backups recommended"
echo "  • Use 'docker-compose down' to stop (keeps data)"
echo "  • Use 'docker-compose down -v' to remove all data"
echo ""

echo -e "${YELLOW}📚 Documentation:${NC}"
echo "  • Start Here:        docs/START-HERE.md"
echo "  • Main Guide:        docs/README-MONITORING.md"
echo "  • Detailed Setup:    docs/MONITORING-GUIDE.md"
echo "  • Quick Reference:   docs/MONITORING-SUMMARY.md"
echo "  • File Manifest:     docs/FILE-MANIFEST.md"
echo ""

# ============================================================================
# VERIFICATION CHECKLIST
# ============================================================================

echo ""
print_header "╔════════════════════════════════════════════════════════════════╗"
print_header "║                  VERIFICATION CHECKLIST                        ║"
print_header "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo -e "${YELLOW}Please verify the following:${NC}"
echo ""

# Interactive verification
read -p "$(echo -e ${CYAN}1. Can you access Grafana at http://localhost:3000? \(y/n\): ${NC})" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_success "Grafana accessible"
else
    print_warning "Check Grafana logs: docker-compose logs grafana"
fi

read -p "$(echo -e ${CYAN}2. Are all 4 dashboards visible in Grafana? \(y/n\): ${NC})" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_success "Dashboards verified"
else
    print_warning "Check dashboard files in grafana-config/provisioning/dashboards/"
fi

read -p "$(echo -e ${CYAN}3. Are all datasources connected \(green\) in Grafana? \(y/n\): ${NC})" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_success "Datasources verified"
else
    print_warning "Check datasource configuration and service status"
fi

read -p "$(echo -e ${CYAN}4. Are metrics appearing in Infrastructure dashboard? \(y/n\): ${NC})" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_success "Metrics verified"
else
    print_warning "Wait a few minutes for metrics to populate"
fi

# ============================================================================
# NEXT STEPS
# ============================================================================

echo ""
echo ""
print_header "╔════════════════════════════════════════════════════════════════╗"
print_header "║                         NEXT STEPS                             ║"
print_header "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo -e "${GREEN}Immediate (Right Now):${NC}"
echo "  1. Open Grafana: http://localhost:3000"
echo "  2. Login with admin/admin and change password"
echo "  3. Explore all 4 dashboards in 'SOC Platform' folder"
echo "  4. Set up Portainer admin account: https://localhost:9443"
echo ""

echo -e "${GREEN}Today:${NC}"
echo "  1. Read docs/START-HERE.md"
echo "  2. Familiarize yourself with each dashboard"
echo "  3. Check all services are running: docker-compose ps"
echo "  4. Review access credentials above"
echo ""

echo -e "${GREEN}This Week:${NC}"
echo "  1. Read docs/MONITORING-GUIDE.md"
echo "  2. Configure alert rules in Prometheus"
echo "  3. Customize dashboards for your needs"
echo "  4. Set up backup procedures"
echo "  5. Review security hardening steps"
echo ""

# ============================================================================
# TROUBLESHOOTING
# ============================================================================

echo ""
print_header "╔════════════════════════════════════════════════════════════════╗"
print_header "║                      TROUBLESHOOTING                           ║"
print_header "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo -e "${YELLOW}Common Issues & Solutions:${NC}"
echo ""
echo -e "${CYAN}No data in dashboards?${NC}"
echo "  • Wait 2-3 minutes for services to fully initialize"
echo "  • Check datasources in Grafana → Configuration → Data Sources"
echo "  • Verify services: docker-compose ps"
echo "  • Check Prometheus targets: http://localhost:9090/targets"
echo ""

echo -e "${CYAN}Services won't start?${NC}"
echo "  • Check logs: docker-compose logs [service-name]"
echo "  • Verify ports not in use: netstat -tulpn | grep [port]"
echo "  • Check system resources: free -h && df -h"
echo "  • Try: docker-compose down && docker-compose up -d"
echo ""

echo -e "${CYAN}High resource usage?${NC}"
echo "  • Normal for full stack: expect 6-8GB RAM usage"
echo "  • Reduce retention: edit prometheus-config/prometheus.yml"
echo "  • Reduce log retention: edit loki-config/loki-config.yml"
echo "  • Add resource limits: edit docker-compose.yml"
echo ""

echo -e "${CYAN}Elasticsearch won't start?${NC}"
echo "  • Check vm.max_map_count: sysctl vm.max_map_count"
echo "  • Should be: 262144 or higher"
echo "  • Set with: sudo sysctl -w vm.max_map_count=262144"
echo ""

# ============================================================================
# FINAL MESSAGE
# ============================================================================

echo ""
echo ""
echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║                                                                ║${NC}"
echo -e "${MAGENTA}║${NC}                    ${GREEN}🎉 SETUP COMPLETE! 🎉${NC}                    ${MAGENTA}║${NC}"
echo -e "${MAGENTA}║                                                                ║${NC}"
echo -e "${MAGENTA}║${NC}        ${CYAN}Your IntelliGuard AI SOC Platform is Ready!${NC}        ${MAGENTA}║${NC}"
echo -e "${MAGENTA}║                                                                ║${NC}"
echo -e "${MAGENTA}║${NC}              ${YELLOW}Start exploring your dashboards:${NC}             ${MAGENTA}║${NC}"
echo -e "${MAGENTA}║${NC}                ${BLUE}http://localhost:3000${NC}                      ${MAGENTA}║${NC}"
echo -e "${MAGENTA}║                                                                ║${NC}"
echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Happy Monitoring! 🛡️📊📈${NC}"
echo ""

# Log completion
echo "$(date): IntelliGuard AI SOC Platform setup completed successfully" >> setup.log
