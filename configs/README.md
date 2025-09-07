# IntelliGuard-AI Enhanced Configuration Templates v2.0

🚀 **NEW IN VERSION 2.0**: Alertmanager & Uptime Kuma Integration

This directory contains all configuration templates and examples for the IntelliGuard-AI platform, now enhanced with enterprise-grade alerting and service monitoring capabilities.

## Enhanced Directory Structure

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
│   ├── prometheus.yml         # Enhanced monitoring configuration
│   └── intelliguard_alerting_rules.yml   # 🆕 Custom alerting rules
├── shuffle/
│   └── workflows/
│       └── ransomware-response.json      # Automated response workflow
├── cortex/
│   ├── analyzers/
│   │   ├── intelliguard-analyzers-config.json  # Analyzer configurations
│   │   └── intelliguard-responders.py          # Custom responders
│   └── requirements.txt       # Python dependencies
├── thehive/
│   └── case-templates/
│       └── security-incident-template.json # Case management template
├── dfir-iris/
│   └── playbooks/
│       └── incident-response-playbook.json     # Digital forensics playbook
├── alertmanager/ 🆕
│   ├── alertmanager.yml       # Enterprise alerting configuration
│   └── templates/             # Alert notification templates
└── uptime-kuma/ 🆕
    └── kuma-config.json       # Service monitoring configuration
```

## 🆕 New Components Added

### 📢 Alertmanager - Enterprise Alerting Management
**Professional-grade alerting and notification orchestration**

**Key Features:**
- **Multi-channel notifications**: Slack, Email, PagerDuty, SMS, Webhooks
- **Intelligent alert routing**: Business hours vs after-hours escalation
- **Alert grouping & suppression**: Reduces noise and prevents alert fatigue
- **Escalation policies**: Critical → High → Medium priority workflows
- **Inhibition rules**: Smart correlation to prevent duplicate alerts

**Alert Categories:**
- 🚨 **Emergency Response**: Ransomware, APT, Data Breach (Immediate)
- 🔴 **Critical Security**: Platform outages, Security failures (1-5 min)
- 🟠 **High Priority**: Service degradation, Performance issues (15-30 min)
- 🟡 **Medium Priority**: Resource warnings, Maintenance alerts (1-2 hours)

### 📊 Uptime Kuma - Modern Service Monitoring
**Beautiful, real-time service availability monitoring with stakeholder transparency**

**Key Features:**
- **Real-time monitoring**: HTTP, TCP, Ping, DNS, and custom protocols
- **Public status pages**: Transparent service availability for stakeholders
- **SLA monitoring**: Track availability targets and breach notifications
- **Incident management**: Automated incident creation and status updates
- **Multi-protocol support**: Comprehensive endpoint monitoring

**Monitoring Groups:**
- 🛡️ **Core Security Services**: Wazuh, TheHive, Cortex, Shuffle
- 📊 **Monitoring & Analytics**: Grafana, Prometheus, Alertmanager
- 🤖 **Automation & Orchestration**: SOAR workflows, DFIR-IRIS
- 🌐 **Network & Infrastructure**: Firewall, DNS, Internet connectivity
- 💼 **Business Applications**: Company website, Customer portal, APIs

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

### 📈 Prometheus Monitoring (Enhanced)
- **Service Monitoring**: All IntelliGuard-AI components + new alerting rules
- **Custom Metrics**: Security-specific KPIs and business impact measurements
- **Enhanced Alerting**: Integrated with Alertmanager for intelligent notifications
- **Business Logic**: ROI tracking, SLA monitoring, cost-benefit analysis
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

### 🧠 Cortex Threat Analysis (Enhanced)
- **20+ Analyzers**: VirusTotal, ThreatCrowd, Abuse.ch, custom intelligence
- **Custom Responders**: Automated threat hunting, IOC blocking, host isolation
- **ML Integration**: Behavioral analysis and unknown threat detection
- **MITRE Mapping**: Automatic ATT&CK technique and tactic assignment
- **Automation**: Seamless integration with TheHive and Shuffle workflows

### 🕵️ DFIR-IRIS Digital Forensics (Enhanced)
- **6-Phase Playbook**: Complete incident response methodology
- **Evidence Management**: Chain of custody and forensic artifact collection
- **Timeline Analysis**: Automated event correlation and reconstruction
- **Legal Compliance**: GDPR, HIPAA, SOX regulatory requirements
- **Integration**: Automated case creation from security alerts

## 🎯 Business Value Enhancement

### Executive Benefits
- **Real-time status visibility** for leadership and stakeholders
- **SLA compliance reporting** with automated breach notifications
- **Proactive incident communication** through public status pages
- **ROI tracking** with quantified security investment returns

### Operational Benefits
- **Reduced MTTR** through intelligent alert routing and escalation
- **Decreased alert fatigue** via smart grouping and suppression
- **Improved accountability** with comprehensive SLA monitoring
- **Enhanced transparency** through stakeholder-facing status pages

### Technical Benefits
- **Comprehensive monitoring coverage** across all platform components
- **Automated escalation procedures** based on severity and time of day
- **Deep integration** with existing SOAR and case management workflows
- **Performance baseline establishment** for capacity planning

## 🚨 Enhanced Alerting Strategy

### Critical Security Alerts (Immediate Response: 0-1 minutes)
```yaml
# Ransomware Detection → Emergency Response Team
- Automated host isolation
- Emergency team notification (Slack + Email + PagerDuty)
- Incident case auto-creation
- Executive notification

# APT Activity → Threat Hunting Team  
- Advanced threat hunting initiation
- Forensic evidence collection
- Threat intelligence correlation
- Attribution analysis

# Data Breach → Legal & Compliance Team
- DLP policy activation
- Legal team immediate notification  
- Compliance assessment initiation
- Regulatory notification preparation
```

### High Priority Alerts (Response: 15-30 minutes)
- Platform service outages → Infrastructure team
- Security detection failures → SOC analysts  
- Performance degradation → Operations team
- Authentication failures → Security team

### Medium Priority Alerts (Response: 1-2 hours)
- Resource utilization warnings
- Non-critical service issues
- Performance trending notifications
- Maintenance reminders

## 📈 SLA Monitoring & Targets

### Service Level Objectives
- **Core Security Services**: 99.9% availability (Wazuh, TheHive, Cortex)
- **Monitoring Stack**: 99.5% availability (Grafana, Prometheus, Alertmanager)
- **Business Applications**: 99.95% availability (Customer-facing services)
- **Response Time Targets**: 
  - Critical alerts: < 5 minutes
  - High priority: < 30 minutes
  - Medium priority: < 2 hours

### Automated SLA Reporting
- Monthly availability reports
- SLA breach notifications
- Performance trend analysis
- Capacity planning insights

## Usage Instructions

### 1. Pre-Deployment Setup
```bash
# Clone the repository
git clone https://github.com/your-org/IntelliGuard-AI.git
cd IntelliGuard-AI

# Review and customize configurations
nano configs/wazuh/ossec.conf
nano configs/alertmanager/alertmanager.yml
nano configs/uptime-kuma/kuma-config.json
```

### 2. Enhanced Deployment
```bash
# Run the enhanced deployment script (v2.0)
cd scripts/deployment
chmod +x deploy-intelliguard-enhanced.sh
./deploy-intelliguard-enhanced.sh
```

### 3. Post-Deployment Configuration
```bash
# Follow the configuration guide
cat docs/deployment/configuration-guide.md

# Verify all services are running (including new services)
docker ps -a

# Check enhanced monitoring
curl http://localhost:9093  # Alertmanager
curl http://localhost:3001  # Uptime Kuma
```

## 🌐 Service URLs (Updated)

### Core Security Platform
- **Wazuh Dashboard**: https://wazuh.company.com:443
- **TheHive**: http://thehive.company.com:9000
- **Cortex**: http://cortex.company.com:9001
- **Shuffle SOAR**: http://shuffle.company.com:3001
- **DFIR-IRIS**: http://dfir-iris.company.com:8000

### Monitoring & Alerting (Enhanced)
- **Grafana**: http://grafana.company.com:3000
- **Prometheus**: http://prometheus.company.com:9090
- **Alertmanager**: http://alertmanager.company.com:9093 🆕
- **Uptime Kuma**: http://status.company.com:3001 🆕
- **Public Status Page**: http://status.company.com 🆕

### Infrastructure Management
- **Traefik Dashboard**: http://traefik.company.com:8080
- **Consul Service Discovery**: http://consul.company.com:8500

## Key Features

### 🎯 Advanced Threat Detection
- **AI-Enhanced Rules**: Machine learning correlation and behavioral analysis
- **MITRE ATT&CK Mapping**: Complete coverage of tactics and techniques
- **Zero-Day Detection**: Behavioral and anomaly-based detection capabilities
- **Threat Intelligence**: Automated IOC correlation and enrichment

### 📊 Business Intelligence (Enhanced)
- **Executive Dashboards**: Real-time security posture for leadership
- **ROI Tracking**: Quantified security investment returns with automated calculation
- **Risk Metrics**: Business impact assessment and trending analysis
- **Compliance Reporting**: Automated regulatory compliance documentation
- **SLA Monitoring**: Service availability and performance tracking

### ⚡ Automated Response (Enhanced)
- **Sub-Minute Containment**: Automated threat isolation and neutralization
- **Orchestrated Workflows**: Multi-system coordinated response actions
- **Intelligent Escalation**: Smart routing based on severity, time, and personnel
- **Evidence Preservation**: Automated forensic evidence collection and chain of custody
- **Stakeholder Communication**: Automated incident updates and status reporting

### 🔗 Integration Capabilities (Expanded)
- **API-First Design**: RESTful APIs for all components
- **Webhook Support**: Real-time event notifications and triggers
- **SIEM Integration**: Native Wazuh integration with custom rule sets
- **Threat Intel Feeds**: Multiple commercial and open source feeds
- **Status Page Integration**: Public transparency and stakeholder communication
- **Multi-Channel Alerting**: Slack, Email, PagerDuty, SMS, Custom webhooks

## Security Considerations

### 🔒 Production Hardening
- **Change Default Passwords**: All services have default credentials that must be changed
- **SSL/TLS Configuration**: Enable encryption for all inter-service communication
- **Network Segmentation**: Implement proper network security controls with Docker networks
- **Access Control**: Configure role-based access control for all services
- **API Security**: Secure all API endpoints with authentication and rate limiting

### 🛡️ Security Best Practices
```bash
# Change default passwords immediately
# Configure firewall rules
sudo ufw enable
sudo ufw allow from 10.0.0.0/8 to any port 443
sudo ufw allow from 10.0.0.0/8 to any port 9093  # Alertmanager
sudo ufw allow from 10.0.0.0/8 to any port 3001  # Uptime Kuma

# Set up SSL certificates
sudo cp certs/intelliguard.crt /etc/ssl/certs/
sudo cp certs/intelliguard.key /etc/ssl/private/

# Configure log retention
sudo nano /etc/logrotate.d/intelliguard
```

### 🔐 Authentication & Authorization (Enhanced)
- **Multi-Factor Authentication**: Enable MFA for all administrative accounts
- **Service Accounts**: Use dedicated service accounts for integrations
- **API Key Management**: Rotate API keys regularly and store securely
- **Audit Logging**: Enable comprehensive audit logging for all actions
- **Status Page Security**: Configure appropriate access controls for internal vs public pages

## Performance Optimization

### 💾 Resource Requirements (Updated)
- **Minimum**: 20GB RAM, 6 CPU cores, 150GB storage (increased for new services)
- **Recommended**: 40GB RAM, 12 CPU cores, 750GB SSD storage
- **Production**: 80GB RAM, 24 CPU cores, 2TB NVMe storage

### ⚡ Performance Tuning
```bash
# Elasticsearch optimization
ES_JAVA_OPTS="-Xms4g -Xmx4g"

# Wazuh manager tuning
<global>
  <agents_disconnection_time>600</agents_disconnection_time>
  <agents_disconnection_alert_time>0</agents_disconnection_alert_time>
</global>

# Prometheus retention (enhanced)
storage:
  tsdb:
    retention.time: 30d
    retention.size: 200GB  # Increased for additional metrics

# Alertmanager optimization
route:
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
```

## Backup and Recovery (Enhanced)

### 💾 Backup Strategy
```bash
# Enhanced automated daily backups
0 2 * * * /opt/intelliguard/scripts/backup-enhanced.sh

# Backup components:
# - Configuration files (all services)
# - Docker volumes (including new services)
# - SSL certificates
# - Custom rules and dashboards
# - Alertmanager configurations
# - Uptime Kuma monitoring configs
# - Status page settings
```

### 🔄 Recovery Procedures
```bash
# Restore from enhanced backup
cd /opt/backups/intelliguard
tar xzf intelliguard_backup_enhanced_YYYYMMDD_HHMMSS.tar.gz

# Restore Docker volumes (including new services)
docker run --rm -v alertmanager-data:/data -v /backup:/backup alpine tar xzf /backup/alertmanager-data.tar.gz -C /data
docker run --rm -v uptime-kuma-data:/data -v /backup:/backup alpine tar xzf /backup/uptime-kuma-data.tar.gz -C /data
```

## Monitoring and Alerting (Comprehensive)

### 📊 Health Monitoring (Enhanced)
- **Service Health**: Automated health checks every 30 seconds for critical services
- **Performance Metrics**: Resource utilization, response times, and throughput
- **Alert Fatigue Prevention**: Intelligent correlation, grouping, and suppression
- **Business Impact**: Automated calculation of security incident costs and ROI
- **SLA Tracking**: Real-time availability and performance against targets

### 🚨 Alert Configuration (Multi-Channel)
```yaml
# Critical alerts sent via ALL channels:
emergency-response-team:
  slack_configs:
    - channel: '#security-emergency'
  email_configs:
    - to: 'ciso@company.com'
  pagerduty_configs:
    - routing_key: 'critical-security-key'
  
# Business hours routing
business-hours-team:
  slack_configs:
    - channel: '#security-alerts'
  email_configs:
    - to: 'security-team@company.com'

# After hours escalation
on-call-team:
  pagerduty_configs:
    - routing_key: 'on-call-security-key'
```

## Troubleshooting (Enhanced)

### 🔧 Common Issues
```bash
# Service not starting
docker logs <container_name>
docker-compose logs <service_name>

# Network connectivity (enhanced network)
telnet localhost <port>
docker network inspect intelliguard-network

# New services troubleshooting
docker logs intelliguard-alertmanager
docker logs intelliguard-uptime-kuma

# Resource issues (increased monitoring)
docker stats
free -h
df -h
```

### 📋 Log Locations (Updated)
- **Wazuh**: `/var/ossec/logs/`
- **Grafana**: `/var/log/grafana/`
- **TheHive**: `/opt/thp/thehive/logs/`
- **Shuffle**: `/opt/shuffle/logs/`
- **Alertmanager**: `/var/log/alertmanager/` 🆕
- **Uptime Kuma**: `/app/data/logs/` 🆕
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

### 🚨 Custom Alert Rules (New)
```yaml
# Add custom alerting rules to:
# configs/prometheus/intelliguard_alerting_rules.yml
- alert: CustomSecurityAlert
  expr: custom_metric > threshold
  for: 5m
  labels:
    severity: high
  annotations:
    summary: "Custom security condition detected"
```

## Compliance and Audit (Enhanced)

### 📋 Regulatory Support
- **GDPR**: Data protection and breach notification with automated reporting
- **HIPAA**: Healthcare data security controls with audit trails
- **PCI DSS**: Payment card industry compliance with continuous monitoring
- **SOX**: Financial reporting controls with automated documentation
- **ISO 27001**: Information security management with metrics tracking

### 📊 Audit Trail (Comprehensive)
- **Complete Activity Logging**: All user actions and system events across all services
- **Immutable Logs**: Cryptographically signed log entries with tamper detection
- **Retention Policies**: Configurable log retention based on regulatory requirements
- **Export Capabilities**: Audit reports in multiple formats (PDF, CSV, JSON)
- **SLA Compliance**: Automated compliance reporting with breach notifications

## Support and Documentation

### 📚 Additional Resources
- **Configuration Guide**: `docs/deployment/configuration-guide.md`
- **Enhanced Deployment Guide**: `docs/deployment/enhanced-deployment-guide.md` 🆕
- **Alerting Runbooks**: `docs/runbooks/alerting-procedures.md` 🆕
- **Status Page Management**: `docs/operations/status-page-guide.md` 🆕
- **API Documentation**: `docs/api/`
- **User Manual**: `docs/user-guide/`
- **Troubleshooting**: `docs/troubleshooting/`

### 🆘 Getting Help
- **Internal Documentation**: `/opt/intelliguard/docs/`
- **Log Analysis**: `/var/log/intelliguard/`
- **Community Support**: GitHub Issues
- **Professional Support**: Contact security team
- **Status Page**: Check service status at http://status.company.com 🆕

### 🔄 Updates and Maintenance (Enhanced)
```bash
# Check for updates (all services)
cd /opt/intelliguard
git pull origin main

# Update Docker images (including new services)
docker-compose pull
docker-compose up -d

# Backup before updates (enhanced backup)
./scripts/backup-enhanced.sh

# Update alerting rules
kubectl apply -f configs/prometheus/intelliguard_alerting_rules.yml
```

## Project Information

- **Project**: AL NAFI EduQual Level 6 Diploma Exam Project
- **Title**: AI-Driven Security Operations Center Implementation
- **Author**: AL NAFI AI-Ops Diploma Candidate
- **Version**: 2.0.0 (Enhanced with Alertmanager & Uptime Kuma)
- **License**: MIT License

---

## 🚀 Quick Start (Enhanced)

### Immediate Deployment
```bash
# Enhanced deployment with all new features
cd scripts/deployment
./deploy-intelliguard-enhanced.sh
```

### Verify New Services
```bash
# Check Alertmanager
curl http://localhost:9093/-/healthy

# Check Uptime Kuma  
curl http://localhost:3001/api/status-page/heartbeat

# View status page
open http://status.company.com
```

### Configure Notifications
1. **Slack Integration**: Add webhook URL to Alertmanager config
2. **Email Setup**: Configure SMTP settings for notifications
3. **PagerDuty**: Add integration keys for escalation
4. **Status Page**: Configure public status page for stakeholders

---

**🚀 Ready to deploy IntelliGuard-AI v2.0 and transform your security operations with enhanced monitoring and alerting!**

**New in v2.0:**
- 📢 **Enterprise Alerting** with Alertmanager
- 📊 **Service Monitoring** with Uptime Kuma  
- 🎯 **SLA Tracking** and compliance reporting
- 🚨 **Multi-Channel Notifications** (Slack, Email, PagerDuty)
- 📈 **Public Status Pages** for stakeholder transparency

For deployment instructions, see: `scripts/deployment/deploy-intelliguard-enhanced.sh`  
For configuration details, see: `docs/deployment/configuration-guide.md`  
For alerting setup, see: `docs/runbooks/alerting-procedures.md` 🆕
