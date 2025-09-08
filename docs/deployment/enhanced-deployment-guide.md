# Enhanced Deployment Guide - IntelliGuard-AI v2.0
## Complete Installation and Configuration Instructions

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Environment Preparation](#environment-preparation)
3. [Core Platform Deployment](#core-platform-deployment)
4. [Enhanced Monitoring Setup](#enhanced-monitoring-setup)
5. [Alerting Configuration](#alerting-configuration)
6. [Service Mesh Implementation](#service-mesh-implementation)
7. [Security Hardening](#security-hardening)
8. [Validation & Testing](#validation-testing)
9. [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements

#### Minimum Hardware Requirements
```yaml
Master Node (x3 for HA):
  CPU: 8 cores
  RAM: 32 GB
  Storage: 500 GB SSD
  Network: 1 Gbps

Worker Nodes (x5):
  CPU: 16 cores
  RAM: 64 GB
  Storage: 2 TB SSD
  Network: 10 Gbps

Storage Node:
  CPU: 8 cores
  RAM: 32 GB
  Storage: 10 TB (RAID 10)
  Network: 10 Gbps
```

#### Software Requirements
```bash
Operating System: Ubuntu 22.04 LTS / RHEL 8.x
Docker: 24.0.0+
Docker Compose: 2.20.0+
Python: 3.9+
Git: 2.34+
OpenSSL: 1.1.1+
```

### Network Requirements
```yaml
Firewall Rules:
  # Management Access
  - 22/tcp    # SSH
  - 443/tcp   # HTTPS Management
  
  # Wazuh
  - 1514/tcp  # Agent registration
  - 1515/tcp  # Agent communication
  - 55000/tcp # API
  
  # Monitoring
  - 3000/tcp  # Grafana
  - 9090/tcp  # Prometheus
  - 9093/tcp  # Alertmanager
  - 3001/tcp  # Uptime Kuma
  
  # SOAR & IR
  - 9000/tcp  # TheHive
  - 9001/tcp  # Cortex
  - 3001/tcp  # Shuffle
  - 8000/tcp  # DFIR-IRIS
  
  # Elasticsearch
  - 9200/tcp  # REST API
  - 9300/tcp  # Node communication
```

## Environment Preparation

### 1. System Update and Dependencies

```bash
#!/bin/bash
# Update system packages
sudo apt-get update && sudo apt-get upgrade -y

# Install required packages
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    python3-pip \
    jq \
    htop \
    net-tools \
    vim

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installations
docker --version
docker-compose --version
```

### 2. Kernel Tuning for Performance

```bash
# Create sysctl configuration
sudo tee /etc/sysctl.d/99-intelliguard.conf <<EOF
# Network optimizations
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 8192
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_tw_reuse = 1

# File descriptor limits
fs.file-max = 2097152
fs.nr_open = 2097152

# Virtual memory
vm.max_map_count = 262144
vm.swappiness = 1

# Elasticsearch requirements
vm.max_map_count = 262144
EOF

# Apply settings
sudo sysctl -p /etc/sysctl.d/99-intelliguard.conf
```

### 3. Directory Structure Setup

```bash
# Create project structure
sudo mkdir -p /opt/intelliguard/{
    configs,
    data,
    logs,
    backups,
    certs,
    scripts
}

# Set permissions
sudo chown -R $USER:$USER /opt/intelliguard
chmod -R 750 /opt/intelliguard
```

## Core Platform Deployment

### 1. Clone Repository

```bash
cd /opt/intelliguard
git clone https://github.com/matx104/IntelliGuard-AI.git
cd IntelliGuard-AI
```

### 2. Generate SSL Certificates

```bash
#!/bin/bash
# Certificate generation script
cat > /opt/intelliguard/scripts/generate_certs.sh <<'EOF'
#!/bin/bash

CERT_DIR="/opt/intelliguard/certs"
DOMAIN="company.com"

# Generate CA key and certificate
openssl genrsa -out $CERT_DIR/ca-key.pem 4096
openssl req -new -x509 -days 3650 -key $CERT_DIR/ca-key.pem \
    -out $CERT_DIR/ca-cert.pem \
    -subj "/C=US/ST=State/L=City/O=Company/CN=IntelliGuard-CA"

# Generate server certificates for each service
SERVICES=("wazuh" "grafana" "prometheus" "alertmanager" "uptime-kuma" "thehive" "cortex" "shuffle" "dfir-iris")

for SERVICE in "${SERVICES[@]}"; do
    # Generate service key
    openssl genrsa -out $CERT_DIR/${SERVICE}-key.pem 4096
    
    # Generate certificate request
    openssl req -new -key $CERT_DIR/${SERVICE}-key.pem \
        -out $CERT_DIR/${SERVICE}.csr \
        -subj "/C=US/ST=State/L=City/O=Company/CN=${SERVICE}.${DOMAIN}"
    
    # Sign certificate
    openssl x509 -req -days 365 -in $CERT_DIR/${SERVICE}.csr \
        -CA $CERT_DIR/ca-cert.pem -CAkey $CERT_DIR/ca-key.pem \
        -CAcreateserial -out $CERT_DIR/${SERVICE}-cert.pem
done

# Set permissions
chmod 400 $CERT_DIR/*-key.pem
chmod 444 $CERT_DIR/*-cert.pem
EOF

chmod +x /opt/intelliguard/scripts/generate_certs.sh
/opt/intelliguard/scripts/generate_certs.sh
```

### 3. Deploy Wazuh Stack

```yaml
# docker-compose-wazuh.yml
version: '3.8'

services:
  wazuh-manager-master:
    image: wazuh/wazuh-manager:4.7.0
    hostname: wazuh-manager-master
    container_name: wazuh-manager-master
    restart: always
    ports:
      - "1514:1514"
      - "1515:1515"
      - "55000:55000"
    environment:
      - INDEXER_URL=https://elasticsearch:9200
      - INDEXER_USERNAME=admin
      - INDEXER_PASSWORD=${ELASTIC_PASSWORD}
      - FILEBEAT_SSL_VERIFICATION_MODE=full
      - SSL_CERTIFICATE_AUTHORITIES=/etc/ssl/certs/ca-cert.pem
      - SSL_CERTIFICATE=/etc/ssl/certs/wazuh-cert.pem
      - SSL_KEY=/etc/ssl/private/wazuh-key.pem
      - API_USERNAME=wazuh-api
      - API_PASSWORD=${WAZUH_API_PASSWORD}
      - CLUSTER_NODE_TYPE=master
      - CLUSTER_KEY=${CLUSTER_KEY}
      - CLUSTER_NAME=wazuh-cluster
    volumes:
      - wazuh-manager-master-data:/var/ossec/data
      - wazuh-manager-master-logs:/var/ossec/logs
      - wazuh-manager-master-queue:/var/ossec/queue
      - wazuh-manager-master-etc:/var/ossec/etc
      - wazuh-manager-master-integrations:/var/ossec/integrations
      - wazuh-manager-master-active-response:/var/ossec/active-response/bin
      - wazuh-manager-master-agentless:/var/ossec/agentless
      - wazuh-manager-master-wodles:/var/ossec/wodles
      - filebeat-etc:/etc/filebeat
      - filebeat-var:/var/lib/filebeat
      - /opt/intelliguard/certs:/etc/ssl/certs:ro
      - /opt/intelliguard/certs:/etc/ssl/private:ro
      - ./configs/wazuh/ossec.conf:/var/ossec/etc/ossec.conf
    networks:
      - intelliguard

  wazuh-dashboard:
    image: wazuh/wazuh-dashboard:4.7.0
    hostname: wazuh-dashboard
    container_name: wazuh-dashboard
    restart: always
    ports:
      - "443:5601"
    environment:
      - INDEXER_USERNAME=admin
      - INDEXER_PASSWORD=${ELASTIC_PASSWORD}
      - WAZUH_API_URL=https://wazuh-manager-master
      - API_USERNAME=wazuh-api
      - API_PASSWORD=${WAZUH_API_PASSWORD}
      - SERVER_SSL_ENABLED=true
      - SERVER_SSL_CERTIFICATE=/usr/share/wazuh-dashboard/certs/wazuh-cert.pem
      - SERVER_SSL_KEY=/usr/share/wazuh-dashboard/certs/wazuh-key.pem
    volumes:
      - /opt/intelliguard/certs:/usr/share/wazuh-dashboard/certs:ro
    depends_on:
      - wazuh-manager-master
      - elasticsearch
    networks:
      - intelliguard

  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    container_name: elasticsearch
    restart: always
    environment:
      - cluster.name=intelliguard-cluster
      - node.name=es-node-1
      - discovery.type=single-node
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms4g -Xmx4g"
      - xpack.security.enabled=true
      - xpack.security.http.ssl.enabled=true
      - xpack.security.http.ssl.key=/usr/share/elasticsearch/config/certs/elasticsearch-key.pem
      - xpack.security.http.ssl.certificate=/usr/share/elasticsearch/config/certs/elasticsearch-cert.pem
      - xpack.security.http.ssl.certificate_authorities=/usr/share/elasticsearch/config/certs/ca-cert.pem
      - xpack.security.transport.ssl.enabled=true
      - xpack.security.transport.ssl.key=/usr/share/elasticsearch/config/certs/elasticsearch-key.pem
      - xpack.security.transport.ssl.certificate=/usr/share/elasticsearch/config/certs/elasticsearch-cert.pem
      - xpack.security.transport.ssl.certificate_authorities=/usr/share/elasticsearch/config/certs/ca-cert.pem
      - ELASTIC_PASSWORD=${ELASTIC_PASSWORD}
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data
      - /opt/intelliguard/certs:/usr/share/elasticsearch/config/certs:ro
    ports:
      - "9200:9200"
      - "9300:9300"
    networks:
      - intelliguard

volumes:
  wazuh-manager-master-data:
  wazuh-manager-master-logs:
  wazuh-manager-master-queue:
  wazuh-manager-master-etc:
  wazuh-manager-master-integrations:
  wazuh-manager-master-active-response:
  wazuh-manager-master-agentless:
  wazuh-manager-master-wodles:
  filebeat-etc:
  filebeat-var:
  elasticsearch-data:

networks:
  intelliguard:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### 4. Deploy SOAR Components

```yaml
# docker-compose-soar.yml
version: '3.8'

services:
  thehive:
    image: strangebee/thehive:5.2
    container_name: thehive
    restart: always
    depends_on:
      - cassandra
      - elasticsearch
      - cortex
    ports:
      - "9000:9000"
    environment:
      - JVM_OPTS="-Xms2g -Xmx4g"
    volumes:
      - thehive-data:/opt/thehive/data
      - thehive-index:/opt/thehive/index
      - ./configs/thehive/application.conf:/opt/thehive/conf/application.conf
    networks:
      - intelliguard

  cortex:
    image: thehiveproject/cortex:3.1.7
    container_name: cortex
    restart: always
    ports:
      - "9001:9001"
    environment:
      - JVM_OPTS="-Xms1g -Xmx2g"
    volumes:
      - cortex-jobs:/opt/cortex/jobs
      - cortex-data:/opt/cortex/data
      - ./configs/cortex/application.conf:/opt/cortex/conf/application.conf
      - ./configs/cortex/analyzers:/opt/cortex/analyzers
      - ./configs/cortex/responders:/opt/cortex/responders
    depends_on:
      - elasticsearch
    networks:
      - intelliguard

  shuffle:
    image: ghcr.io/shuffle/shuffle:latest
    container_name: shuffle
    hostname: shuffle
    restart: always
    ports:
      - "3001:3001"
      - "3443:3443"
    environment:
      - SHUFFLE_APP_SDK_VERSION=1.2.0
      - SHUFFLE_ORBORUS_EXECUTION_TIMEOUT=600
      - SHUFFLE_ORBORUS_EXECUTION_CONCURRENCY=20
      - SHUFFLE_BACKEND_HOSTNAME=shuffle
      - SHUFFLE_FRONTEND_HOSTNAME=shuffle.company.com
      - SHUFFLE_OPENSEARCH_URL=http://elasticsearch:9200
      - SHUFFLE_OPENSEARCH_USERNAME=admin
      - SHUFFLE_OPENSEARCH_PASSWORD=${ELASTIC_PASSWORD}
      - SHUFFLE_ENCRYPTION_KEY=${SHUFFLE_ENCRYPTION_KEY}
    volumes:
      - shuffle-apps:/shuffle-apps
      - shuffle-files:/shuffle-files
      - ./configs/shuffle/workflows:/shuffle-workflows
    networks:
      - intelliguard

  dfir-iris:
    image: ghcr.io/dfir-iris/iris-web:latest
    container_name: dfir-iris
    restart: always
    ports:
      - "8000:8000"
    environment:
      - POSTGRES_USER=iris
      - POSTGRES_PASSWORD=${IRIS_DB_PASSWORD}
      - POSTGRES_DB=iris_db
      - POSTGRES_HOST=iris-db
      - IRIS_SECRET_KEY=${IRIS_SECRET_KEY}
      - IRIS_SECURITY_PASSWORD_SALT=${IRIS_SALT}
    volumes:
      - iris-data:/home/iris/data
      - ./configs/dfir-iris:/home/iris/config
    depends_on:
      - iris-db
    networks:
      - intelliguard

  