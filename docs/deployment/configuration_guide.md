# IntelliGuard-AI Configuration Guide

## Overview

This comprehensive guide provides step-by-step instructions for configuring the IntelliGuard-AI platform after successful deployment. Follow these procedures to ensure optimal security operations.

## 🚀 Quick Start Checklist

- [ ] Change all default passwords
- [ ] Configure SSL certificates
- [ ] Set up data sources
- [ ] Import threat intelligence feeds
- [ ] Test automated workflows
- [ ] Configure user accounts
- [ ] Set up monitoring and alerting

## 📋 Detailed Configuration Steps

### 1. Wazuh Configuration

#### 1.1 Access Wazuh Dashboard
```bash
# Open browser and navigate to:
https://localhost:443

# Default credentials:
Username: admin
Password: SecretPassword
```

#### 1.2 Change Default Password
1. Navigate to **Security** → **Users**
2. Select **admin** user
3. Click **Change Password**
4. Enter strong password (minimum 12 characters)

#### 1.3 Configure Custom Rules
```bash
# Custom rules are already deployed at:
/var/ossec/etc/rules/intelliguard_threat_rules.xml

# To add new rules:
sudo nano /var/ossec/etc/rules/custom_rules.xml

# Restart Wazuh manager:
sudo systemctl restart wazuh-manager
```

#### 1.4 Agent Deployment
```bash
# Install agent on endpoints:
curl -s https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.7.0-1_amd64.deb -o wazuh-agent.deb
sudo dpkg -i wazuh-agent.deb

# Configure agent:
sudo nano /var/ossec/etc/ossec.conf

# Add manager IP:
<client>
  <server>
    <address>MANAGER_IP</address>
    <port>1514</port>
    <protocol>tcp</protocol>
  </server>
</client>

# Start agent:
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
```

### 2. Grafana Configuration

#### 2.1 Initial Setup
```bash
# Access Grafana:
http://localhost:3000

# Default credentials:
Username: admin
Password: IntelliGuard@2025
```

#### 2.2 Configure Data Sources
1. Navigate to **Configuration** → **Data Sources**
2. Add **Elasticsearch** data source:
   - **URL**: `http://elasticsearch:9200`
   - **Index**: `wazuh-alerts-*`
   - **Time field**: `@timestamp`
3. Add **Prometheus** data source:
   - **URL**: `http://prometheus:9090`

#### 2.3 Import Dashboards
```bash
# Executive dashboard is already configured
# Import additional dashboards:
1. Navigate to **+** → **Import**
2. Upload dashboard JSON files from configs/grafana/dashboards/
3. Select appropriate data sources
```

#### 2.4 Configure Alerting
```bash
# Set up notification channels:
1. Navigate to **Alerting** → **Notification channels**
2. Add Slack integration:
   - **Type**: Slack
   - **Webhook URL**: Your Slack webhook
   - **Channel**: #security-alerts
3. Add Email notifications:
   - **Type**: Email
   - **Addresses**: security-team@company.com
```

### 3. Prometheus Configuration

#### 3.1 Verify Configuration
```bash
# Check Prometheus targets:
http://localhost:9090/targets

# Ensure all targets are "UP"
# If targets are down, check network connectivity and firewall rules
```

#### 3.2 Configure Custom Metrics
```bash
# Add custom metrics endpoint:
sudo nano /opt/intelliguard/prometheus/prometheus.yml

# Add new job:
- job_name: 'custom-app'
  static_configs:
    - targets: ['app-server:8080']
  scrape_interval: 30s

# Reload configuration:
curl -X POST http://localhost:9090/-/reload
```

### 4. TheHive Configuration

#### 4.1 Initial Setup
```bash
# Access TheHive:
http://localhost:9000

# Create initial admin user during first login
Username: admin@company.com
Password: [Strong Password]
```

#### 4.2 Configure Organizations
1. Navigate to **Admin** → **Organizations**
2. Create organization: **Company Security**
3. Add users and assign roles

#### 4.3 Import Case Templates
```bash
# Case templates are automatically imported
# To add custom templates:
1. Navigate to **Admin** → **Case Templates**
2. Click **+** to create new template
3. Configure custom fields and tasks
```

#### 4.4 Configure Integrations
```bash
# Wazuh integration:
1. Navigate to **Admin** → **Connectors**
2. Add Wazuh connector:
   - **Name**: Wazuh-IntelliGuard
   - **URL**: https://wazuh.company.com:55000
   - **API Key**: [Generated from Wazuh]
```

### 5. Cortex Configuration

#### 5.1 Initial Setup
```bash
# Access Cortex:
http://localhost:9001

# Create admin user:
Username: admin
Password: [Strong Password]
```

#### 5.2 Configure Analyzers
```bash
# Enable analyzers:
1. Navigate to **Organization** → **Analyzers**
2. Enable required analyzers:
   - VirusTotal_GetReport_3_0
   - Abuse_Finder_3_0
   - MaxMind_GeoIP_3_0
   - ThreatCrowd_1_0
3. Configure API keys for each analyzer
```

#### 5.3 API Key Configuration
```bash
# Generate API keys for integration:
1. Navigate to **Organization** → **Users**
2. Create service account: **thehive-integration**
3. Generate API key
4. Configure in TheHive connector settings
```

### 6. Shuffle SOAR Configuration

#### 6.1 Initial Setup
```bash
# Access Shuffle:
http://localhost:3001

# Register admin account:
Email: admin@company.com
Password: [Strong Password]
```

#### 6.2 Import Workflows
```bash
# Import IntelliGuard workflows:
1. Navigate to **Workflows**
2. Click **Import**
3. Upload workflow files from configs/shuffle/workflows/
4. Configure workflow triggers and actions
```

#### 6.3 Configure Integrations
```bash
# Configure app integrations:
1. Navigate to **Apps**
2. Configure authentication for:
   - Wazuh (API key)
   - TheHive (API key)
   - Cortex (API key)
   - Slack (Webhook URL)
   - Email (SMTP settings)
```

### 7. Security Hardening

#### 7.1 SSL/TLS Configuration
```bash
# Configure SSL certificates:
sudo cp /opt/intelliguard/certs/* /etc/ssl/certs/

# Update service configurations to use SSL:
# Wazuh:
sudo nano /var/ossec/etc/ossec.conf
# Add SSL configuration

# Grafana:
sudo nano /etc/grafana/grafana.ini
[server]
protocol = https
cert_file = /etc/ssl/certs/intelliguard.crt
cert_key = /etc/ssl/certs/intelliguard.key
```

#### 7.2 Firewall Configuration
```bash
# Configure firewall rules:
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 443/tcp  # Wazuh Dashboard
sudo ufw allow 3000/tcp # Grafana
sudo ufw allow 9090/tcp # Prometheus
sudo ufw allow 9000/tcp # TheHive
sudo ufw allow 9001/tcp # Cortex
sudo ufw allow 3001/tcp # Shuffle

# Restrict access to specific networks:
sudo ufw allow from 10.0.0.0/8 to any port 443
```

#### 7.3 User Access Control
```bash
# Configure role-based access:
# Create user groups:
sudo groupadd soc-analysts
sudo groupadd soc-managers
sudo groupadd security-admins

# Add users to groups:
sudo usermod -a -G soc-analysts analyst1
sudo usermod -a -G soc-managers manager1
sudo usermod -a -G security-admins admin1
```

### 8. Monitoring and Alerting

#### 8.1 Health Monitoring
```bash
# Create health check script:
cat > /opt/intelliguard/scripts/health-check.sh << 'EOF'
#!/bin/bash

services=(
    "wazuh-manager:1514"
    "grafana:3000"
    "prometheus:9090"
    "thehive:9000"
    "cortex:9001"
    "shuffle:3001"
)

for service in "${services[@]}"; do
    host=$(echo $service | cut -d: -f1)
    port=$(echo $service | cut -d: -f2)
    
    if nc -z localhost $port; then
        echo "$host: OK"
    else
        echo "$host: FAILED"
        # Send alert
    fi
done
EOF

chmod +x /opt/intelliguard/scripts/health-check.sh

# Add to crontab:
echo "*/5 * * * * /opt/intelliguard/scripts/health-check.sh" | crontab -
```

#### 8.2 Log Monitoring
```bash
# Configure log rotation:
sudo tee /etc/logrotate.d/intelliguard << 'EOF'
/var/log/intelliguard/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 0644 intelliguard intelliguard
}
EOF
```

### 9. Backup Configuration

#### 9.1 Data Backup
```bash
# Create backup script:
cat > /opt/intelliguard/scripts/backup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/opt/backups/intelliguard"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR/$DATE

# Backup configurations
cp -r /opt/intelliguard/configs $BACKUP_DIR/$DATE/

# Backup Docker volumes
docker run --rm -v wazuh_etc:/data -v $BACKUP_DIR/$DATE:/backup alpine tar czf /backup/wazuh_etc.tar.gz -C /data .
docker run --rm -v grafana-data:/data -v $BACKUP_DIR/$DATE:/backup alpine tar czf /backup/grafana-data.tar.gz -C /data .
docker run --rm -v prometheus-data:/data -v $BACKUP_DIR/$DATE:/backup alpine tar czf /backup/prometheus-data.tar.gz -C /data .

# Compress backup
cd $BACKUP_DIR
tar czf intelliguard_backup_$DATE.tar.gz $DATE/
rm -rf $DATE/

echo "Backup completed: intelliguard_backup_$DATE.tar.gz"
EOF

chmod +x /opt/intelliguard/scripts/backup.sh

# Schedule daily backups:
echo "0 2 * * * /opt/intelliguard/scripts/backup.sh" | crontab -
```

### 10. Testing and Validation

#### 10.1 Alert Testing
```bash
# Test Wazuh rules:
# Generate test alert:
echo "Test suspicious activity" | logger -p local0.warn

# Check if alert appears in Wazuh dashboard
# Verify Grafana receives the data
# Confirm automated workflow triggers
```

#### 10.2 Workflow Testing
```bash
# Test SOAR workflows:
1. Navigate to Shuffle workflows
2. Select "IntelliGuard Ransomware Response"
3. Click "Test" with sample data
4. Verify all actions execute successfully
```

#### 10.3 Integration Testing
```bash
# Test TheHive-Cortex integration:
1. Create test case in TheHive
2. Add observables (IP, domain, hash)
3. Run analyzers from Cortex
4. Verify results appear in case
```

## 🔧 Troubleshooting

### Common Issues

#### Service Not Starting
```bash
# Check service status:
docker ps -a

# Check logs:
docker logs <container_name>

# Check resource usage:
docker stats
```

#### Network Connectivity Issues
```bash
# Test network connectivity:
docker network ls
docker network inspect <network_name>

# Test port connectivity:
telnet localhost <port>
```

#### Performance Issues
```bash
# Monitor system resources:
htop
iotop
free -h
df -h

# Optimize Docker:
docker system prune -f
docker volume prune -f
```

## 📊 Performance Tuning

### Elasticsearch Optimization
```bash
# Adjust JVM heap size:
# In docker-compose.yml:
environment:
  - "ES_JAVA_OPTS=-Xms4g -Xmx4g"
```

### Wazuh Performance
```bash
# Increase log analysis threads:
# In ossec.conf:
<global>
  <logall_json>yes</logall_json>
  <jsonout_output>yes</jsonout_output>
  <agents_disconnection_time>600</agents_disconnection_time>
</global>
```

## 🚀 Advanced Configuration

### Custom Integrations
```bash
# Create custom webhook endpoint:
# Add to Wazuh configuration:
<integration>
  <name>custom-webhook</name>
  <hook_url>https://custom-endpoint.company.com/webhook</hook_url>
  <api_key>your-api-key</api_key>
  <alert_format>json</alert_format>
  <rule_id>100001,100002</rule_id>
  <level>7</level>
</integration>
```

### Machine Learning Integration
```bash
# Configure ML-based anomaly detection:
# Add custom analyzer to Cortex for behavioral analysis
# Integrate with existing ML platforms via API
```

## 📚 Additional Resources

- [Wazuh Documentation](https://documentation.wazuh.com/)
- [Grafana Documentation](https://grafana.com/docs/)
- [TheHive Documentation](https://docs.thehive-project.org/)
- [Shuffle Documentation](https://shuffler.io/docs)
- [MITRE ATT&CK Framework](https://attack.mitre.org/)

## 🆘 Support

For technical support:
- Internal Documentation: `/opt/intelliguard/docs/`
- Log Files: `/var/log/intelliguard/`
- Configuration Files: `/opt/intelliguard/configs/`
- Community Support: IntelliGuard-AI GitHub Repository

---

**Next Steps**: After completing this configuration, proceed to user training and operational procedures documentation.