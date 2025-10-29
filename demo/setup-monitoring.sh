#!/bin/bash

echo "================================================"
echo "    SOC Platform - Monitoring Enhancement      "
echo "        Setup and Installation Script          "
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    print_warning "Please don't run this script as root"
    exit 1
fi

# Check if Docker is installed
echo "Checking prerequisites..."
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi
print_success "Docker found"

if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi
print_success "Docker Compose found"

# Check available disk space
available_space=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$available_space" -lt 30 ]; then
    print_warning "Less than 30GB disk space available (${available_space}GB)"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    print_success "Sufficient disk space available (${available_space}GB)"
fi

# Check available memory
total_mem=$(free -g | grep Mem | awk '{print $2}')
if [ "$total_mem" -lt 8 ]; then
    print_warning "Less than 8GB RAM available (${total_mem}GB)"
    print_info "Monitoring services may use 2-4GB additional RAM"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    print_success "Sufficient RAM available (${total_mem}GB)"
fi

echo ""
echo "================================================"
echo "Creating directory structure..."
echo "================================================"

# Create directories
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

echo ""
echo "================================================"
echo "Checking for configuration files..."
echo "================================================"

# Check if configs exist
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
    print_info "Please copy the provided configuration files to the correct locations"
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

echo ""
echo "================================================"
echo "Docker Compose Configuration"
echo "================================================"

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    print_error "docker-compose.yml not found"
    print_info "Please ensure docker-compose-enhanced.yml is renamed to docker-compose.yml"
    exit 1
fi

# Check if docker-compose has monitoring services
if grep -q "prometheus:" docker-compose.yml && \
   grep -q "loki:" docker-compose.yml && \
   grep -q "node-exporter:" docker-compose.yml; then
    print_success "Docker Compose includes monitoring services"
else
    print_error "Docker Compose appears to be missing monitoring services"
    print_info "Please use the enhanced docker-compose.yml file"
    exit 1
fi

echo ""
echo "================================================"
echo "System Configuration"
echo "================================================"

# Check and set vm.max_map_count for Elasticsearch
current_max_map_count=$(sysctl vm.max_map_count | awk '{print $3}')
if [ "$current_max_map_count" -lt 262144 ]; then
    print_warning "vm.max_map_count is too low ($current_max_map_count)"
    print_info "Elasticsearch requires vm.max_map_count >= 262144"
    
    read -p "Set vm.max_map_count=262144 now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo sysctl -w vm.max_map_count=262144
        print_success "vm.max_map_count set to 262144"
        
        # Make it persistent
        if ! grep -q "vm.max_map_count" /etc/sysctl.conf; then
            echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
            print_success "Made vm.max_map_count persistent"
        fi
    fi
else
    print_success "vm.max_map_count is properly configured ($current_max_map_count)"
fi

echo ""
echo "================================================"
echo "Pulling Docker Images"
echo "================================================"
echo "This may take several minutes depending on your connection..."
echo ""

# Pull images
if docker-compose pull; then
    print_success "All images pulled successfully"
else
    print_error "Failed to pull some images"
    exit 1
fi

echo ""
echo "================================================"
echo "Starting Services"
echo "================================================"
echo ""

# Start services
print_info "Starting all services..."
if docker-compose up -d; then
    print_success "Services started successfully"
else
    print_error "Failed to start services"
    print_info "Check logs with: docker-compose logs"
    exit 1
fi

echo ""
print_info "Waiting for services to initialize (this may take 3-5 minutes)..."
sleep 30

echo ""
echo "================================================"
echo "Health Checks"
echo "================================================"
echo ""

# Check Elasticsearch
print_info "Checking Elasticsearch..."
for i in {1..12}; do
    if curl -s http://localhost:9200/_cluster/health > /dev/null 2>&1; then
        print_success "Elasticsearch is ready"
        break
    fi
    if [ $i -eq 12 ]; then
        print_error "Elasticsearch failed to start"
    else
        echo "   Waiting... ($i/12)"
        sleep 10
    fi
done

# Check Prometheus
print_info "Checking Prometheus..."
if curl -s http://localhost:9090/-/healthy > /dev/null 2>&1; then
    print_success "Prometheus is ready"
else
    print_warning "Prometheus may not be fully ready yet"
fi

# Check Loki
print_info "Checking Loki..."
if curl -s http://localhost:3100/ready > /dev/null 2>&1; then
    print_success "Loki is ready"
else
    print_warning "Loki may not be fully ready yet"
fi

# Check Grafana
print_info "Checking Grafana..."
if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
    print_success "Grafana is ready"
else
    print_warning "Grafana may not be fully ready yet"
fi

# Count running containers
running_containers=$(docker ps --filter "name=soc-" --format "{{.Names}}" | wc -l)
print_info "Running containers: $running_containers"

echo ""
echo "================================================"
echo "✅ Setup Complete!"
echo "================================================"
echo ""
echo -e "${GREEN}🎉 Your SOC Platform with Advanced Monitoring is ready!${NC}"
echo ""
echo "================================================"
echo "📊 ACCESS URLS"
echo "================================================"
echo ""
echo -e "${BLUE}Monitoring & Dashboards:${NC}"
echo "  Grafana:        http://localhost:3000"
echo "                  Login: admin / admin"
echo "                  Dashboards: Browse → SOC Platform folder"
echo ""
echo -e "${BLUE}Monitoring Services:${NC}"
echo "  Prometheus:     http://localhost:9090"
echo "  cAdvisor:       http://localhost:8081"
echo ""
echo -e "${BLUE}Container Management:${NC}"
echo "  Portainer:      https://localhost:9443"
echo "  Dockge:         http://localhost:5001"
echo ""
echo -e "${BLUE}SOC Platform:${NC}"
echo "  TheHive:        http://localhost:9000"
echo "  MISP:           http://localhost:8080"
echo "  Elasticsearch:  http://localhost:9200"
echo ""
echo "================================================"
echo "🔧 MANAGEMENT COMMANDS"
echo "================================================"
echo ""
echo "Check status:       docker-compose ps"
echo "View all logs:      docker-compose logs -f"
echo "View service logs:  docker-compose logs -f [service-name]"
echo "Restart service:    docker-compose restart [service-name]"
echo "Stop platform:      docker-compose down"
echo "Stop & remove data: docker-compose down -v"
echo ""
echo "================================================"
echo "📊 MONITORING DASHBOARDS"
echo "================================================"
echo ""
echo "After logging into Grafana, you'll find these dashboards:"
echo ""
echo "1. Infrastructure Monitoring"
echo "   - System resources (CPU, Memory, Disk)"
echo "   - Container metrics and health"
echo "   - Network and Disk I/O"
echo ""
echo "2. Security Monitoring"
echo "   - Threat detections and alerts"
echo "   - Wazuh SIEM events"
echo "   - Security event timeline"
echo ""
echo "3. Log Analysis"
echo "   - Centralized log viewing"
echo "   - Error and warning tracking"
echo "   - Per-container logs"
echo ""
echo "4. Threat Intelligence (MISP)"
echo "   - MISP events and attributes"
echo "   - Threat level distribution"
echo "   - Intelligence trends"
echo ""
echo "================================================"
echo "💡 QUICK TIPS"
echo "================================================"
echo ""
echo "• All dashboards auto-refresh (10s - 30s intervals)"
echo "• Use time picker (top-right) to change time ranges"
echo "• Click panel titles for more options"
echo "• Export dashboards for backup via Share → Export"
echo "• Check Prometheus targets: http://localhost:9090/targets"
echo ""
echo "================================================"
echo "📚 DOCUMENTATION"
echo "================================================"
echo ""
echo "README-MONITORING.md    - Complete overview"
echo "MONITORING-GUIDE.md     - Detailed setup and usage"
echo "MONITORING-SUMMARY.md   - Quick reference"
echo ""
echo "================================================"
echo "🔍 TROUBLESHOOTING"
echo "================================================"
echo ""
echo "No data in dashboards?"
echo "  1. Check datasources in Grafana UI"
echo "  2. Verify services: docker-compose ps"
echo "  3. Check logs: docker-compose logs [service]"
echo ""
echo "High resource usage?"
echo "  1. Reduce retention periods in configs"
echo "  2. Increase scrape intervals"
echo "  3. Add resource limits to docker-compose.yml"
echo ""
echo "================================================"
echo "✅ VERIFICATION CHECKLIST"
echo "================================================"
echo ""
read -p "Open Grafana and verify all 4 dashboards are visible? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_success "Dashboards verified"
fi

read -p "Check that all datasources are connected (green)? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_success "Datasources verified"
fi

read -p "Verify metrics are appearing in Infrastructure dashboard? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_success "Metrics verified"
fi

echo ""
echo "================================================"
echo ""
echo -e "${GREEN}🎉 Congratulations!${NC}"
echo ""
echo "Your SOC Platform with Advanced Monitoring is"
echo "fully operational and ready to use!"
echo ""
echo "Start exploring your dashboards at:"
echo -e "${BLUE}http://localhost:3000${NC}"
echo ""
echo "================================================"
echo ""
echo "Happy Monitoring! 🛡️📊📈"
echo ""
