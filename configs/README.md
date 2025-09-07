# IntelliGuard-AI Configuration Templates

This directory contains all configuration templates and examples for the IntelliGuard-AI platform.

## Directory Structure

```
configs/
├── wazuh/
│   ├── ossec.conf              # Main Wazuh configuration
│   ├── rules/
│   │   └── intelliguard_threat_rules.xml  # Custom detection rules
│   └── decoders/               # Custom log decoders
├── grafana/
│   ├── dashboards/
│   │   └── executive-dashboard.json       # Executive security dashboard
│   └── datasources/           # Data source configurations
├── prometheus/
│   └── prometheus.yml         # Monitoring configuration
├── shuffle/
│   └── workflows/
│       └── ransomware-response.json      # Automated response workflow
├── cortex/
│   └── analyzers/             # Custom threat analyzers
├── thehive/
│   └── case-templates/
│       └── security-incident-template.json # Case management template
└── dfir-iris/
    └── playbooks/             # Digital forensics playbooks
```

## Configuration Overview

### 🛡️ Wazuh SIEM/XDR Platform
- **Main Configuration**: Complete Wazuh manager setup with AI-enhanced detection capabilities
- **Custom Rules**: 100+ detection rules covering APT, ransomware, insider threats, and zero-day attacks
- **Rule Categories**:
  - Advanced Persistent Threats (100001-100050)
  - Ransomware Detection (100051-100100)
  - Insider Threats (100101-100150)
  - Lateral Movement (100201-100250)
  - Data Exfiltration (100251-100300)
  - Machine Learning Correlations (100501-100550)
  - Threat Intelligence Integration (100801-100850)

### 📊 Grafana Analytics Platform
- **Executive Dashboard**: Real-time security metrics for C-level visibility
- **Key Metrics**: MTTD, MTTR, detection accuracy, automation coverage
- **Visualizations**: Threat geography, MITRE ATT&CK mapping, ROI tracking
- **Data Sources**: Elasticsearch, Prometheus, custom business metrics

### 📈 Prometheus Monitoring
- **Service Monitoring**: All IntelliGuard-AI components
- **Custom Metrics**: Security-specific KPIs and business impact measurements
- **Alerting**: Integrated with Grafana and Shuffle for automated responses
- **Retention**: 30-day local storage with remote write capability

### 🤖 Shuffle SOAR Workflows
- **Ransomware Response**: 20-step automated containment and response
- **Integrations**: Wazuh, TheHive, Cortex, Active Directory, network security
- **Response Time**: Sub-minute threat containment capabilities
- **Escalation**: Automated escalation for critical incidents

### 🔍 TheHive Case Management
- **Incident Templates**: Comprehensive security incident response procedures
- **Custom Fields**: Incident categorization, MITRE mapping, business impact
- **Automated Tasks**: 8-phase incident response workflow
- **Integrations**: SOAR triggers, Cortex analysis, compliance reporting

### 🧠 Cortex Threat Analysis
- **Analyzers**: VirusTotal, threat intelligence, behavioral analysis
- **Automation**: Automatic observable analysis and enrichment
- **Integration**: Seamless connection with TheHive and Shuffle

## Usage Instructions

### 1. Pre-Deployment Setup
```bash
# Clone the repository
git clone https://github.com/your-org/IntelliGuard-AI.git
cd IntelliGuard-AI

# Review and customize configurations
nano configs/wazuh/ossec.conf
nano configs/grafana/dashboards/executive-dashboard.json
```

### 2. Deployment
```bash
# Run the automated deployment script
cd scripts/deployment
chmod +x deploy-intelliguard.sh
./deploy-intelliguard.sh
```

### 3. Post-Deployment Configuration
```bash
# Follow the configuration guide
cat docs/deployment/configuration-guide.md

# Verify all services are running
docker ps -a
```

## Key Features

### 🎯 Advanced Threat Detection
- **AI-Enhanced Rules**: Machine learning correlation and behavioral analysis
- **MITRE ATT&CK Mapping**: Complete coverage of tactics and techniques
- **Zero-Day Detection**: Behavioral and anomaly-based detection capabilities
- **Threat Intelligence**: Automated IOC correlation and enrichment

### 📊 Business Intelligence
- **Executive Dashboards**: Real-time security posture for leadership
- **ROI Tracking**: Quantified security investment returns
- **Risk Metrics**: Business impact assessment and trending
- **Compliance Reporting**: Automated regulatory compliance documentation

### ⚡ Automated Response
- **Sub-Minute Containment**: Automated threat isolation and neutralization
- **Orchestrated Workflows**: Multi-system coordinated response actions
- **Escalation Procedures**: Intelligent escalation based on threat severity
- **Evidence Preservation**: Automated forensic evidence collection

### 🔗 Integration Capabilities
- **API-First Design**: RESTful APIs for all components
- **Webhook Support**: Real-time event notifications and triggers
- **SIEM Integration**: Native Wazuh integration with custom rule sets
- **Threat Intel Feeds**: Multiple commercial and open source feeds

## Security Considerations

### 🔒 Production Hardening
- **Change Default Passwords**: All services have default credentials that must be changed
- **SSL/TLS Configuration**: Enable encryption for all inter-service communication
- **Network Segmentation**: Implement proper network security controls
- **Access Control**: Configure role-based access control for all services

### 🛡️ Security Best Practices
```bash
# Change default passwords immediately
# Configure firewall rules
sudo ufw enable
sudo ufw allow from 10.0.0.0/8 to any port 443

# Set up SSL certificates
sudo cp certs/intelliguard.crt /etc/ssl/certs/
sudo cp certs/intelliguard.key /etc/ssl/private/

# Configure log retention
sudo nano /etc/logrotate.d/intelliguard
```

### 🔐 Authentication & Authorization
- **Multi-Factor Authentication**: Enable MFA for all administrative accounts
- **Service Accounts**: Use dedicated service accounts for integrations
- **API Key Management**: Rotate API keys regularly and store securely
- **Audit Logging**: Enable comprehensive audit logging for all actions

## Performance Optimization

### 💾 Resource Requirements
- **Minimum**: 16GB RAM, 4 CPU cores, 100GB storage
- **Recommended**: 32GB RAM, 8 CPU cores, 500GB SSD storage
- **Production**: 64GB RAM, 16 CPU cores, 1TB NVMe storage

### ⚡ Performance Tuning
```bash
# Elasticsearch optimization
ES_JAVA_OPTS="-Xms4g -Xmx4g"

# Wazuh manager tuning
<global>
  <agents_disconnection_time>600</agents_disconnection_time>
  <agents_disconnection_alert_time>0</agents_disconnection_alert_time>
</global>

# Prometheus retention
storage:
  tsdb:
    retention.time: 30d
    retention.size: 100GB
```

## Backup and Recovery

### 💾 Backup Strategy
```bash
# Automated daily backups
0 2 * * * /opt/intelliguard/scripts/backup.sh

# Backup components:
# - Configuration files
# - Docker volumes
# - SSL certificates
# - Custom rules and dashboards
```

### 🔄 Recovery Procedures
```bash
# Restore from backup
cd /opt/backups/intelliguard
tar xzf intelliguard_backup_YYYYMMDD_HHMMSS.tar.gz

# Restore Docker volumes
docker run --rm -v wazuh_etc:/data -v /backup:/backup alpine tar xzf /backup/wazuh_etc.tar.gz -C /data
```

## Monitoring and Alerting

### 📊 Health Monitoring
- **Service Health**: Automated health checks every 5 minutes
- **Performance Metrics**: Resource utilization and response times
- **Alert Fatigue Prevention**: Intelligent alert correlation and suppression
- **Business Impact**: Automated calculation of security incident costs

### 🚨 Alert Configuration
```bash
# Critical alerts sent via multiple channels:
# - Slack: #security-emergency
# - Email: security-team@company.com
# - SMS: On-call security team
# - PagerDuty: Escalation procedures
```

## Troubleshooting

### 🔧 Common Issues
```bash
# Service not starting
docker logs <container_name>
docker-compose logs <service_name>

# Network connectivity
telnet localhost <port>
docker network inspect intelliguard_default

# Resource issues
docker stats
free -h
df -h
```

### 📋 Log Locations
- **Wazuh**: `/var/ossec/logs/`
- **Grafana**: `/var/log/grafana/`
- **TheHive**: `/opt/thp/thehive/logs/`
- **Shuffle**: `/opt/shuffle/logs/`
- **System**: `/var/log/intelliguard/`

## Development and Customization

### 🛠️ Custom Rules Development
```xml
<!-- Add custom rules to: -->
<!-- configs/wazuh/rules/custom_rules.xml -->
<group name="custom_threats">
  <rule id="200001" level="8">
    <if_sid>5716</if_sid>
    <description>Custom threat detection rule</description>
    <group>custom,threat_hunting</group>
  </rule>
</group>
```

### 📊 Custom Dashboard Creation
```json
// Add custom panels to Grafana dashboards
// Follow the executive dashboard template structure
// Located in: configs/grafana/dashboards/
```

### 🔄 Workflow Customization
```json
// Modify SOAR workflows in:
// configs/shuffle/workflows/
// Add custom actions and integrations as needed
```

## Compliance and Audit

### 📋 Regulatory Support
- **GDPR**: Data protection and breach notification
- **HIPAA**: Healthcare data security controls
- **PCI DSS**: Payment card industry compliance
- **SOX**: Financial reporting controls
- **ISO 27001**: Information security management

### 📊 Audit Trail
- **Complete Activity Logging**: All user actions and system events
- **Immutable Logs**: Cryptographically signed log entries
- **Retention Policies**: Configurable log retention based on requirements
- **Export Capabilities**: Audit reports in multiple formats

## Support and Documentation

### 📚 Additional Resources
- **Configuration Guide**: `docs/deployment/configuration-guide.md`
- **API Documentation**: `docs/api/`
- **User Manual**: `docs/user-guide/`
- **Troubleshooting**: `docs/troubleshooting/`

### 🆘 Getting Help
- **Internal Documentation**: `/opt/intelliguard/docs/`
- **Log Analysis**: `/var/log/intelliguard/`
- **Community Support**: GitHub Issues
- **Professional Support**: Contact security team

### 🔄 Updates and Maintenance
```bash
# Check for updates
cd /opt/intelliguard
git pull origin main

# Update Docker images
docker-compose pull
docker-compose up -d

# Backup before updates
./scripts/backup.sh
```

## Project Information

- **Project**: AL NAFI EduQual Level 6 Diploma Exam Project
- **Title**: AI-Driven Security Operations Center Implementation
- **Author**: AL NAFI AI-Ops Diploma Candidate
- **Version**: 1.0.0
- **License**: MIT License

---

**🚀 Ready to deploy IntelliGuard-AI and transform your security operations!**

For deployment instructions, see: `scripts/deployment/deploy-intelliguard.sh`  
For configuration details, see: `docs/deployment/configuration-guide.md`
