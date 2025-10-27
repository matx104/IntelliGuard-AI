# AI-Driven Security Operations Center (SOC) - Proof of Concept

This is a comprehensive yet simplified AI-driven SOC implementation for the EduQual Level 6 AI Operations Diploma project.

## 🎯 Project Overview

This POC demonstrates:
- **AI-Powered Threat Detection** using machine learning (Isolation Forest)
- **Automated Threat Hunting** with MITRE ATT&CK framework mapping
- **SOAR Integration** with automated incident response playbooks
- **Threat Intelligence** platform integration
- **Security Analytics** and visualization
- **Behavioral Analytics** (UEBA)

## 🏗️ Architecture

The platform consists of the following components:

### Core Security Infrastructure
- **Wazuh**: SIEM for log collection and analysis
- **Elasticsearch**: Central data storage and search
- **Grafana**: Security dashboards and visualization

### SOAR Platform
- **TheHive**: Case management and orchestration
- **Cortex**: Analysis engine for observables
- **MISP**: Threat intelligence platform

### Custom AI/ML Services
- **ML Threat Detector**: Anomaly detection using Isolation Forest
- **Automated Threat Hunter**: Proactive threat hunting with MITRE ATT&CK
- **SOAR Automation Engine**: Automated incident response playbooks
- **Data Generator**: Synthetic security event generator for demo

## 📋 Prerequisites

- Docker and Docker Compose installed
- At least 8GB RAM available
- 20GB free disk space
- Linux, macOS, or Windows with WSL2

## 🚀 Quick Start

### 1. Clone or Download This Project

```bash
cd ai-soc-poc
```

### 2. Start the Platform

```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### 3. Wait for Services to Initialize

Services may take 3-5 minutes to fully start. Monitor with:

```bash
# Check if Elasticsearch is ready
curl http://localhost:9200

# Check all containers are running
docker-compose ps
```

## 🔑 Access URLs and Credentials

| Service | URL | Username | Password |
|---------|-----|----------|----------|
| Grafana | http://localhost:3000 | admin | admin |
| TheHive | http://localhost:9000 | admin@thehive.local | secret |
| Cortex | http://localhost:9001 | admin | admin |
| MISP | http://localhost:8080 | admin@misp.local | admin_password |
| Elasticsearch | http://localhost:9200 | - | - |
| Wazuh API | http://localhost:55000 | wazuh | wazuh |

## 📊 Understanding the Data Flow

1. **Data Generator** creates realistic security events (normal + attacks)
2. **Elasticsearch** stores all events
3. **ML Threat Detector** analyzes events for anomalies using machine learning
4. **Threat Hunter** runs hunting queries with MITRE ATT&CK mapping
5. **SOAR Engine** automatically responds to threats with playbooks
6. **Grafana** visualizes all security metrics and alerts

## 🔍 Viewing the Results

### Check Security Events
```bash
# View latest security events
curl "http://localhost:9200/security-events/_search?size=10&pretty"

# Count total events
curl "http://localhost:9200/security-events/_count?pretty"
```

### Check Threat Alerts
```bash
# View ML-detected threats
curl "http://localhost:9200/threat-alerts/_search?size=10&pretty"

# View UEBA alerts
curl "http://localhost:9200/ueba-alerts/_search?size=10&pretty"
```

### Check Threat Hunting Results
```bash
# View hunting findings
curl "http://localhost:9200/threat-hunting-findings/_search?size=10&pretty"

# View attack chains
curl "http://localhost:9200/attack-chains/_search?size=10&pretty"
```

### Check SOAR Automation
```bash
# View playbook executions
curl "http://localhost:9200/playbook-executions/_search?size=10&pretty"

# View automated actions
curl "http://localhost:9200/soar-actions/_search?size=10&pretty"
```

## 📈 Creating Grafana Dashboards

1. Open Grafana at http://localhost:3000
2. Login with admin/admin
3. Create new dashboard
4. Add panels with Elasticsearch queries:

### Example Queries:

**Threat Detection Over Time:**
```
Index: threat-alerts
Metric: Count
Time field: @timestamp
Group by: Terms on alert_type.keyword
```

**Attack Types Distribution:**
```
Index: security-events
Metric: Count
Group by: Terms on alert_type.keyword
```

**Risk Score Timeline:**
```
Index: security-events
Metric: Average of risk_score
Time field: @timestamp
```

## 🎭 Attack Scenarios Generated

The data generator creates these attack patterns:

1. **Normal Activity (70%)**: Legitimate user behavior
2. **Brute Force Attacks (10%)**: Multiple failed login attempts
3. **Port Scanning (8%)**: Network reconnaissance
4. **Malware Detection (5%)**: Malicious file execution
5. **Data Exfiltration (4%)**: Unusual outbound data transfers
6. **Privilege Escalation (3%)**: Unauthorized privilege requests

## 🤖 ML Model Details

### Anomaly Detection
- **Algorithm**: Isolation Forest
- **Features**: Failed logins, packet count, byte count, connection duration, port scan score
- **Contamination**: 10% (expects 10% anomalies)
- **Training**: Initial training on synthetic normal behavior

### UEBA (User and Entity Behavior Analytics)
- **Metrics**: Average failed logins, unusual hours, unique locations
- **Risk Levels**: LOW, MEDIUM, HIGH, CRITICAL
- **Behavioral Scoring**: Weighted combination of risk indicators

## 🎯 MITRE ATT&CK Techniques Covered

| Technique ID | Name | Tactic |
|--------------|------|--------|
| T1110 | Brute Force | Credential Access |
| T1078 | Valid Accounts | Defense Evasion |
| T1046 | Network Service Scanning | Discovery |
| T1071 | Application Layer Protocol | Command and Control |
| T1486 | Data Encrypted for Impact | Impact |

## 🔧 SOAR Playbooks

### 1. Brute Force Response
- Block source IP
- Notify SOC team
- Reset user password
- Enable MFA
- Create incident ticket

### 2. Malware Detection Response
- Isolate endpoint
- Kill malicious process
- Collect forensic artifacts
- Scan network for spread
- Notify IR team

### 3. Data Exfiltration Response
- Block outbound connection
- Suspend user account
- Analyze transferred data
- Notify security leadership
- Initiate forensic investigation

### 4. Port Scan Response
- Log scanning activity
- Rate limit source
- Add to watchlist
- Alert network team

### 5. Privilege Escalation Response
- Revoke elevated privileges
- Suspend account
- Audit access logs
- Check lateral movement
- Escalate to IR

## 📊 Key Metrics and KPIs

Monitor these in Grafana:
- **Total Security Events**: Overall volume
- **Threats Detected**: ML anomalies + manual hunts
- **Mean Time to Detect (MTTD)**: Alert generation time
- **Mean Time to Respond (MTTR)**: Playbook execution time
- **False Positive Rate**: Normal events flagged as threats
- **Automated Response Rate**: Incidents handled by SOAR
- **MITRE Technique Coverage**: Techniques detected

## 🐛 Troubleshooting

### Services Won't Start
```bash
# Check Docker resources
docker stats

# Restart specific service
docker-compose restart <service-name>

# View detailed logs
docker-compose logs <service-name>
```

### Elasticsearch Issues
```bash
# Check Elasticsearch health
curl http://localhost:9200/_cluster/health?pretty

# Increase memory if needed (edit docker-compose.yml)
# Change ES_JAVA_OPTS to -Xms1g -Xmx1g
```

### No Events Being Generated
```bash
# Check data generator logs
docker-compose logs data-generator

# Restart data generator
docker-compose restart data-generator
```

### ML Model Not Detecting Threats
```bash
# Check ML service logs
docker-compose logs ml-threat-detector

# Verify events exist
curl "http://localhost:9200/security-events/_count"
```

## 🛑 Stopping the Platform

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (clean slate)
docker-compose down -v
```

## 📝 Customization

### Adjust Attack Frequency
Edit `data-generator/generate_events.py`:
```python
self.attack_scenarios = {
    'normal_activity': 0.50,  # Increase attacks
    'brute_force': 0.20,
    # ...
}
```

### Add Custom Playbooks
Edit `soar-automation/soar_engine.py`:
```python
'custom_playbook': {
    'name': 'Custom Response',
    'trigger': 'custom_alert',
    'actions': [
        {'action': 'custom_action', 'priority': 1}
    ]
}
```

### Modify ML Model
Edit `ml-service/threat_detector.py`:
```python
self.model = IsolationForest(
    contamination=0.15,  # Adjust sensitivity
    n_estimators=200     # More trees
)
```

## 📚 Presentation Tips

For your oral presentation:

1. **Demo the Dashboard**: Show Grafana with live metrics
2. **Show Attack Detection**: Point out ML-detected threats
3. **Demonstrate SOAR**: Show automated playbook execution
4. **Explain MITRE Mapping**: Display threat hunting findings
5. **Discuss ML Model**: Explain anomaly detection approach
6. **Show Data Flow**: Trace event from generation to response

## 🎓 Learning Outcomes Demonstrated

- ✅ AI-powered threat detection with ML
- ✅ Automated threat hunting with MITRE ATT&CK
- ✅ SOAR integration with automated playbooks
- ✅ Security analytics and predictive modeling
- ✅ Threat intelligence integration
- ✅ Compliance reporting automation
- ✅ Open-source tool integration
- ✅ Cloud-native architecture

## 📞 Support

For issues with this POC:
- Check Docker logs: `docker-compose logs`
- Verify system resources: `docker stats`
- Ensure ports are not in use: `netstat -tuln`

## 📄 License

This is an educational POC for demonstration purposes.

---

**Created for**: EduQual Level 6 Diploma in AI Operations  
**Student**: Muhammad Abdullah Tariq  
**Topic**: AI-Driven Security Operations Center Implementation
