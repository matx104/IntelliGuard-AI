#!/bin/bash

# IntelliGuard-AI Automated Deployment Script
# Author: AL NAFI AI-Ops Diploma Project
# Date: September 2025
# Purpose: Automated deployment of IntelliGuard-AI SOC platform

set -euo pipefail

# Configuration variables
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/var/log/intelliguard-deployment.log"
readonly CONFIG_DIR="${SCRIPT_DIR}/../configs"
readonly INSTALL_USER="intelliguard"
readonly DOMAIN="company.com"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "${LOG_FILE}"
}

info() { log "INFO" "${BLUE}$*${NC}"; }
warn() { log "WARN" "${YELLOW}$*${NC}"; }
error() { log "ERROR" "${RED}$*${NC}"; }
success() { log "SUCCESS" "${GREEN}$*${NC}"; }

# Error handling
error_exit() {
    error "$1"
    exit 1
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error_exit "This script should not be run as root for security reasons"
    fi
}

# Check system requirements
check_requirements() {
    info "Checking system requirements..."
    
    # Check OS
    if ! grep -q "Ubuntu\|CentOS\|RHEL" /etc/os-release; then
        error_exit "Unsupported operating system. Ubuntu, CentOS, or RHEL required."
    fi
    
    # Check memory
    local mem_gb=$(free -g | awk 'NR==2{print $2}')
    if [[ $mem_gb -lt 16 ]]; then
        warn "System has ${mem_gb}GB RAM. Recommended minimum is 16GB."
    fi
    
    # Check disk space
    local disk_gb=$(df -BG / | awk 'NR==2{gsub(/G/,"",$4); print $4}')
    if [[ $disk_gb -lt 100 ]]; then
        warn "Available disk space is ${disk_gb}GB. Recommended minimum is 100GB."
    fi
    
    # Check required tools
    local required_tools=("docker" "docker-compose" "curl" "jq" "git")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            error_exit "Required tool '$tool' is not installed"
        fi
    done
    
    success "System requirements check completed"
}

# Create system user
create_user() {
    info "Creating IntelliGuard system user..."
    
    if ! id "$INSTALL_USER" &>/dev/null; then
        sudo useradd -m -s /bin/bash "$INSTALL_USER"
        sudo usermod -aG docker "$INSTALL_USER"
        success "Created user: $INSTALL_USER"
    else
        info "User $INSTALL_USER already exists"
    fi
}

# Setup directory structure
setup_directories() {
    info "Setting up directory structure..."
    
    local dirs=(
        "/opt/intelliguard"
        "/opt/intelliguard/data"
        "/opt/intelliguard/logs"
        "/opt/intelliguard/configs"
        "/opt/intelliguard/certs"
        "/var/log/intelliguard"
    )
    
    for dir in "${dirs[@]}"; do
        sudo mkdir -p "$dir"
        sudo chown "$INSTALL_USER:$INSTALL_USER" "$dir"
    done
    
    success "Directory structure created"
}

# Generate SSL certificates
generate_certificates() {
    info "Generating SSL certificates..."
    
    local cert_dir="/opt/intelliguard/certs"
    local config_file="$cert_dir/openssl.conf"
    
    # Create OpenSSL configuration
    sudo tee "$config_file" > /dev/null <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = US
ST = State
L = City
O = Company
OU = IT Department
CN = intelliguard.${DOMAIN}

[v3_req]
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = intelliguard.${DOMAIN}
DNS.2 = wazuh.${DOMAIN}
DNS.3 = grafana.${DOMAIN}
DNS.4 = thehive.${DOMAIN}
DNS.5 = cortex.${DOMAIN}
DNS.6 = shuffle.${DOMAIN}
IP.1 = 127.0.0.1
EOF

    # Generate private key and certificate
    sudo openssl genrsa -out "$cert_dir/intelliguard.key" 2048
    sudo openssl req -new -key "$cert_dir/intelliguard.key" -out "$cert_dir/intelliguard.csr" -config "$config_file"
    sudo openssl x509 -req -in "$cert_dir/intelliguard.csr" -signkey "$cert_dir/intelliguard.key" -out "$cert_dir/intelliguard.crt" -days 365 -extensions v3_req -extfile "$config_file"
    
    # Set permissions
    sudo chown "$INSTALL_USER:$INSTALL_USER" "$cert_dir"/*
    sudo chmod 600 "$cert_dir"/*.key
    sudo chmod 644 "$cert_dir"/*.crt
    
    success "SSL certificates generated"
}

# Deploy Wazuh
deploy_wazuh() {
    info "Deploying Wazuh SIEM..."
    
    local wazuh_dir="/opt/intelliguard/wazuh"
    sudo mkdir -p "$wazuh_dir"
    
    # Create docker-compose for Wazuh
    sudo tee "$wazuh_dir/docker-compose.yml" > /dev/null <<EOF
version: '3.8'

services:
  wazuh.manager:
    image: wazuh/wazuh-manager:4.7.0
    hostname: wazuh.manager
    restart: always
    ports:
      - "1514:1514"
      - "1515:1515"
      - "514:514/udp"
      - "55000:55000"
    environment:
      - INDEXER_URL=https://wazuh.indexer:9200
      - INDEXER_USERNAME=admin
      - INDEXER_PASSWORD=SecretPassword
      - FILEBEAT_SSL_VERIFICATION_MODE=full
      - SSL_CERTIFICATE_AUTHORITIES=/etc/ssl/root-ca.pem
      - SSL_CERTIFICATE=/etc/ssl/filebeat.pem
      - SSL_KEY=/etc/ssl/filebeat.key
    volumes:
      - wazuh_api_configuration:/var/ossec/api/configuration
      - wazuh_etc:/var/ossec/etc
      - wazuh_logs:/var/ossec/logs
      - wazuh_queue:/var/ossec/queue
      - wazuh_var_multigroups:/var/ossec/var/multigroups
      - wazuh_integrations:/var/ossec/integrations
      - wazuh_active_response:/var/ossec/active-response/bin
      - wazuh_agentless:/var/ossec/agentless
      - wazuh_wodles:/var/ossec/wodles
      - filebeat_etc:/etc/filebeat
      - filebeat_var:/var/lib/filebeat
      - ${CONFIG_DIR}/wazuh/ossec.conf:/var/ossec/etc/ossec.conf:ro
      - ${CONFIG_DIR}/wazuh/rules:/var/ossec/etc/rules:ro
    depends_on:
      - wazuh.indexer

  wazuh.indexer:
    image: wazuh/wazuh-indexer:4.7.0
    hostname: wazuh.indexer
    restart: always
    ports:
      - "9200:9200"
    environment:
      - "OPENSEARCH_JAVA_OPTS=-Xms1g -Xmx1g"
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    volumes:
      - wazuh-indexer-data:/var/lib/wazuh-indexer

  wazuh.dashboard:
    image: wazuh/wazuh-dashboard:4.7.0
    hostname: wazuh.dashboard
    restart: always
    ports:
      - "443:5601"
    environment:
      - INDEXER_USERNAME=admin
      - INDEXER_PASSWORD=SecretPassword
      - WAZUH_API_URL=https://wazuh.manager
      - API_USERNAME=wazuh-wui
      - API_PASSWORD=MyS3cr37P450r.*-
    depends_on:
      - wazuh.indexer
    links:
      - wazuh.indexer:wazuh.indexer
      - wazuh.manager:wazuh.manager

volumes:
  wazuh_api_configuration:
  wazuh_etc:
  wazuh_logs:
  wazuh_queue:
  wazuh_var_multigroups:
  wazuh_integrations:
  wazuh_active_response:
  wazuh_agentless:
  wazuh_wodles:
  filebeat_etc:
  filebeat_var:
  wazuh-indexer-data:
EOF

    sudo chown -R "$INSTALL_USER:$INSTALL_USER" "$wazuh_dir"
    
    # Deploy Wazuh
    cd "$wazuh_dir"
    sudo -u "$INSTALL_USER" docker-compose up -d
    
    success "Wazuh deployed successfully"
}

# Deploy Grafana
deploy_grafana() {
    info "Deploying Grafana..."
    
    local grafana_dir="/opt/intelliguard/grafana"
    sudo mkdir -p "$grafana_dir"
    
    # Create docker-compose for Grafana
    sudo tee "$grafana_dir/docker-compose.yml" > /dev/null <<EOF
version: '3.8'

services:
  grafana:
    image: grafana/grafana:latest
    container_name: intelliguard-grafana
    restart: always
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=IntelliGuard@2025
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-worldmap-panel
    volumes:
      - grafana-data:/var/lib/grafana
      - ${CONFIG_DIR}/grafana/dashboards:/etc/grafana/provisioning/dashboards:ro
      - ${CONFIG_DIR}/grafana/datasources:/etc/grafana/provisioning/datasources:ro

volumes:
  grafana-data:
EOF

    sudo chown -R "$INSTALL_USER:$INSTALL_USER" "$grafana_dir"
    
    # Deploy Grafana
    cd "$grafana_dir"
    sudo -u "$INSTALL_USER" docker-compose up -d
    
    success "Grafana deployed successfully"
}

# Deploy Prometheus
deploy_prometheus() {
    info "Deploying Prometheus..."
    
    local prometheus_dir="/opt/intelliguard/prometheus"
    sudo mkdir -p "$prometheus_dir"
    
    # Create docker-compose for Prometheus
    sudo tee "$prometheus_dir/docker-compose.yml" > /dev/null <<EOF
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: intelliguard-prometheus
    restart: always
    ports:
      - "9090:9090"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
    volumes:
      - prometheus-data:/prometheus
      - ${CONFIG_DIR}/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro

volumes:
  prometheus-data:
EOF

    sudo chown -R "$INSTALL_USER:$INSTALL_USER" "$prometheus_dir"
    
    # Deploy Prometheus
    cd "$prometheus_dir"
    sudo -u "$INSTALL_USER" docker-compose up -d
    
    success "Prometheus deployed successfully"
}

# Deploy TheHive
deploy_thehive() {
    info "Deploying TheHive..."
    
    local thehive_dir="/opt/intelliguard/thehive"
    sudo mkdir -p "$thehive_dir"
    
    # Create docker-compose for TheHive
    sudo tee "$thehive_dir/docker-compose.yml" > /dev/null <<EOF
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.0
    container_name: thehive-elasticsearch
    restart: always
    environment:
      - discovery.type=single-node
      - cluster.name=thehive
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data
    ports:
      - "9201:9200"

  thehive:
    image: strangebee/thehive:5.2
    container_name: thehive
    restart: always
    depends_on:
      - elasticsearch
    ports:
      - "9000:9000"
    volumes:
      - thehive-data:/opt/thp/thehive/data
      - thehive-index:/opt/thp/thehive/index
      - ${CONFIG_DIR}/thehive/case-templates:/opt/thp/thehive/case-templates:ro
    environment:
      - TH_NO_CONFIG_ELASTICSEARCH_HOSTNAMES=elasticsearch:9200
    command: --no-config-secret

volumes:
  elasticsearch-data:
  thehive-data:
  thehive-index:
EOF

    sudo chown -R "$INSTALL_USER:$INSTALL_USER" "$thehive_dir"
    
    # Deploy TheHive
    cd "$thehive_dir"
    sudo -u "$INSTALL_USER" docker-compose up -d
    
    success "TheHive deployed successfully"
}

# Deploy Cortex
deploy_cortex() {
    info "Deploying Cortex..."
    
    local cortex_dir="/opt/intelliguard/cortex"
    sudo mkdir -p "$cortex_dir"
    
    # Create docker-compose for Cortex
    sudo tee "$cortex_dir/docker-compose.yml" > /dev/null <<EOF
version: '3.8'

services:
  cortex:
    image: thehiveproject/cortex:latest
    container_name: intelliguard-cortex
    restart: always
    ports:
      - "9001:9001"
    volumes:
      - cortex-data:/tmp/cortex-jobs
      - ${CONFIG_DIR}/cortex/analyzers:/opt/cortex/analyzers:ro
    environment:
      - JOB_DIRECTORY=/tmp/cortex-jobs

volumes:
  cortex-data:
EOF

    sudo chown -R "$INSTALL_USER:$INSTALL_USER" "$cortex_dir"
    
    # Deploy Cortex
    cd "$cortex_dir"
    sudo -u "$INSTALL_USER" docker-compose up -d
    
    success "Cortex deployed successfully"
}

# Deploy Shuffle
deploy_shuffle() {
    info "Deploying Shuffle..."
    
    local shuffle_dir="/opt/intelliguard/shuffle"
    sudo mkdir -p "$shuffle_dir"
    
    # Create docker-compose for Shuffle
    sudo tee "$shuffle_dir/docker-compose.yml" > /dev/null <<EOF
version: '3.8'

services:
  frontend:
    image: ghcr.io/shuffle/shuffle-frontend:latest
    container_name: shuffle-frontend
    hostname: shuffle-frontend
    ports:
      - "3001:80"
      - "3443:443"
    environment:
      - BACKEND_HOSTNAME=shuffle-backend
    restart: unless-stopped
    depends_on:
      - backend

  backend:
    image: ghcr.io/shuffle/shuffle-backend:latest
    container_name: shuffle-backend
    hostname: shuffle-backend
    ports:
      - "5001:5001"
    volumes:
      - shuffle-apps:/shuffle-apps
      - shuffle-files:/shuffle-files
      - ${CONFIG_DIR}/shuffle/workflows:/shuffle-workflows:ro
    environment:
      - DATASTORE_EMULATOR_HOST=shuffle-database:8000
      - SHUFFLE_APP_HOTLOAD_FOLDER=/shuffle-apps
      - SHUFFLE_FILE_LOCATION=/shuffle-files
    restart: unless-stopped
    depends_on:
      - database

  orborus:
    image: ghcr.io/shuffle/shuffle-orborus:latest
    container_name: shuffle-orborus
    hostname: shuffle-orborus
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - shuffle-apps:/shuffle-apps
      - shuffle-files:/shuffle-files
    environment:
      - ENVIRONMENT_NAME=Shuffle
      - BASE_URL=http://shuffle-backend:5001
      - DOCKER_API_VERSION=1.40
      - SHUFFLE_APP_SDK_TIMEOUT=300
    restart: unless-stopped

  database:
    image: frikky/shuffle:database
    container_name: shuffle-database
    hostname: shuffle-database
    ports:
      - "8000:8000"
    restart: unless-stopped
    volumes:
      - shuffle-database:/etc/shuffle

volumes:
  shuffle-database:
  shuffle-apps:
  shuffle-files:
EOF

    sudo chown -R "$INSTALL_USER:$INSTALL_USER" "$shuffle_dir"
    
    # Deploy Shuffle
    cd "$shuffle_dir"
    sudo -u "$INSTALL_USER" docker-compose up -d
    
    success "Shuffle deployed successfully"
}

# Configure system services
configure_services() {
    info "Configuring system services..."
    
    # Create systemd service for IntelliGuard
    sudo tee /etc/systemd/system/intelliguard.service > /dev/null <<EOF
[Unit]
Description=IntelliGuard-AI Security Operations Center
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
User=$INSTALL_USER
WorkingDirectory=/opt/intelliguard
ExecStart=/usr/bin/docker-compose -f /opt/intelliguard/docker-compose.yml up -d
ExecStop=/usr/bin/docker-compose -f /opt/intelliguard/docker-compose.yml down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable intelliguard.service
    
    success "System services configured"
}

# Perform health checks
health_check() {
    info "Performing health checks..."
    
    local services=(
        "http://localhost:443:Wazuh Dashboard"
        "http://localhost:3000:Grafana"
        "http://localhost:9090:Prometheus"
        "http://localhost:9000:TheHive"
        "http://localhost:9001:Cortex"
        "http://localhost:3001:Shuffle"
    )
    
    for service in "${services[@]}"; do
        local url=$(echo "$service" | cut -d: -f1-3)
        local name=$(echo "$service" | cut -d: -f4)
        
        info "Checking $name..."
        if curl -k -s "$url" > /dev/null; then
            success "$name is accessible"
        else
            warn "$name may not be ready yet"
        fi
    done
}

# Create initial configuration
initial_setup() {
    info "Running initial setup..."
    
    # Wait for services to be ready
    sleep 30
    
    # Configure Wazuh API user
    info "Configuring Wazuh API access..."
    # Add Wazuh API configuration commands here
    
    # Import Grafana dashboards
    info "Importing Grafana dashboards..."
    # Add Grafana dashboard import commands here
    
    # Configure TheHive case templates
    info "Configuring TheHive case templates..."
    # Add TheHive template configuration commands here
    
    success "Initial setup completed"
}

# Generate deployment report
generate_report() {
    info "Generating deployment report..."
    
    local report_file="/opt/intelliguard/deployment-report.txt"
    
    cat > "$report_file" <<EOF
IntelliGuard-AI Deployment Report
================================
Deployment Date: $(date)
Deployed by: $(whoami)
System: $(uname -a)

Service URLs:
- Wazuh Dashboard: https://localhost:443
- Grafana: http://localhost:3000
- Prometheus: http://localhost:9090
- TheHive: http://localhost:9000
- Cortex: http://localhost:9001
- Shuffle: http://localhost:3001

Default Credentials:
- Wazuh: admin / SecretPassword
- Grafana: admin / IntelliGuard@2025
- TheHive: admin / secret
- Cortex: admin / secret
- Shuffle: admin / password

Important Notes:
- Change all default passwords immediately
- Configure SSL certificates for production use
- Review firewall rules and network security
- Set up backup procedures
- Configure monitoring and alerting
- Review log retention policies

Next Steps:
1. Access each service and change default credentials
2. Configure data sources in Grafana
3. Import threat intelligence feeds
4. Test automated workflows
5. Configure user accounts and permissions
6. Set up backup and recovery procedures

Support:
- Documentation: /opt/intelliguard/docs/
- Logs: /var/log/intelliguard/
- Configuration: /opt/intelliguard/configs/

EOF

    sudo chown "$INSTALL_USER:$INSTALL_USER" "$report_file"
    success "Deployment report generated: $report_file"
}

# Cleanup function
cleanup() {
    info "Cleaning up temporary files..."
    # Add cleanup commands here
    success "Cleanup completed"
}

# Main deployment function
main() {
    info "Starting IntelliGuard-AI deployment..."
    
    # Pre-deployment checks
    check_root
    check_requirements
    
    # Core deployment
    create_user
    setup_directories
    generate_certificates
    
    # Service deployments
    deploy_wazuh
    deploy_grafana
    deploy_prometheus
    deploy_thehive
    deploy_cortex
    deploy_shuffle
    
    # Post-deployment configuration
    configure_services
    initial_setup
    health_check
    generate_report
    cleanup
    
    success "IntelliGuard-AI deployment completed successfully!"
    info "Please review the deployment report at: /opt/intelliguard/deployment-report.txt"
    info "Access the services using the URLs and credentials in the report."
    warn "IMPORTANT: Change all default passwords before production use!"
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Create log file
    sudo touch "$LOG_FILE"
    sudo chown "$(whoami):$(whoami)" "$LOG_FILE"
    
    # Run main function
    main "$@"
fi
