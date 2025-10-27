# Project Structure

```
ai-soc-poc/
├── docker-compose.yml              # Main orchestration file
├── setup.sh                        # Automated setup script
├── README.md                       # Complete documentation
├── QUICK_REFERENCE.md             # Quick command reference
├── PRESENTATION_GUIDE.md          # Oral presentation guide
├── PROJECT_STRUCTURE.md           # This file
│
├── ml-service/                    # Machine Learning Threat Detection
│   ├── Dockerfile
│   └── threat_detector.py         # Anomaly detection with Isolation Forest
│
├── threat-hunting/                # Automated Threat Hunting
│   ├── Dockerfile
│   └── automated_hunter.py        # MITRE ATT&CK-based hunting
│
├── soar-automation/               # SOAR Engine
│   ├── Dockerfile
│   └── soar_engine.py            # Automated playbook execution
│
├── data-generator/                # Sample Data Generator
│   ├── Dockerfile
│   └── generate_events.py        # Generates realistic security events
│
├── thehive-config/                # TheHive Configuration
│   └── application.conf
│
├── cortex-config/                 # Cortex Configuration
│   └── application.conf
│
└── grafana-config/                # Grafana Configuration
    └── provisioning/
        └── datasources/
            └── elasticsearch.yml

```

## 📊 Component Details

### Core Services (From Docker Hub)

1. **Elasticsearch** (docker.elastic.co/elasticsearch/elasticsearch:8.11.0)
   - Purpose: Central data storage and search
   - Ports: 9200
   - Volume: es-data

2. **Wazuh** (wazuh/wazuh:4.7.0)
   - Purpose: SIEM and log collection
   - Ports: 1514, 1515, 514, 55000
   - Volumes: wazuh-data, wazuh-logs

3. **Cassandra** (cassandra:4.1)
   - Purpose: Backend database for TheHive
   - Volume: cassandra-data

4. **TheHive** (strangebee/thehive:5.2)
   - Purpose: Case management and SOAR
   - Ports: 9000
   - Volumes: thehive-data, thehive-files

5. **Cortex** (thehiveproject/cortex:3.1.7)
   - Purpose: Observable analysis engine
   - Ports: 9001
   - Volume: cortex-data

6. **MISP** (coolacid/misp-docker:core-latest)
   - Purpose: Threat intelligence platform
   - Ports: 8080, 8443
   - Volume: misp-data

7. **MISP Database** (mysql:8.0)
   - Purpose: MISP backend database
   - Volume: misp-db-data

8. **Grafana** (grafana/grafana:latest)
   - Purpose: Visualization and dashboards
   - Ports: 3000
   - Volume: grafana-data

### Custom Services (Built from Dockerfiles)

1. **ML Threat Detector**
   - Language: Python 3.11
   - Libraries: scikit-learn, pandas, numpy, elasticsearch
   - Function: Anomaly detection using Isolation Forest
   - Output: threat-alerts, ueba-alerts indices

2. **Automated Threat Hunter**
   - Language: Python 3.11
   - Libraries: elasticsearch, requests, pandas
   - Function: MITRE ATT&CK-based threat hunting
   - Output: threat-hunting-findings, attack-chains indices

3. **SOAR Automation**
   - Language: Python 3.11
   - Libraries: requests, elasticsearch
   - Function: Automated incident response playbooks
   - Output: playbook-executions, soar-actions indices

4. **Data Generator**
   - Language: Python 3.11
   - Libraries: elasticsearch, faker
   - Function: Generate realistic security events
   - Output: security-events index

## 📈 Data Flow

```
┌──────────────────┐
│ Data Generator   │ Generates synthetic security events
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Elasticsearch    │ Stores all events and alerts
└───┬──────────────┘
    │
    ├─────────────────────┬──────────────────┬────────────────┐
    │                     │                  │                │
    ▼                     ▼                  ▼                ▼
┌─────────┐      ┌──────────────┐   ┌──────────┐    ┌─────────┐
│   ML    │      │    Threat    │   │   SOAR   │    │ Grafana │
│Detector │      │    Hunter    │   │  Engine  │    │Dashboard│
└────┬────┘      └──────┬───────┘   └────┬─────┘    └─────────┘
     │                  │                 │
     │ Anomalies        │ Findings        │ Actions
     │                  │                 │
     └──────────────────┴─────────────────┘
                        │
                        ▼
                 ┌─────────────┐
                 │  TheHive    │
                 │    SOAR     │
                 └─────────────┘
```

## 🗄️ Elasticsearch Indices

| Index Name | Purpose | Created By | Documents |
|------------|---------|------------|-----------|
| security-events | Raw security events | Data Generator | ~1000/hour |
| threat-alerts | ML-detected threats | ML Detector | ~300/hour |
| ueba-alerts | User behavior anomalies | ML Detector | ~50/hour |
| threat-hunting-findings | Hunting results | Threat Hunter | ~200/hour |
| attack-chains | Correlated attacks | Threat Hunter | ~15/hour |
| playbook-executions | SOAR playbook runs | SOAR Engine | ~100/hour |
| soar-actions | Individual SOAR actions | SOAR Engine | ~500/hour |

## 🔌 Network Configuration

All services run on the `soc-network` bridge network, allowing:
- Service discovery by container name
- Isolated communication
- Port exposure only where needed

### Exposed Ports

| Port | Service | Purpose |
|------|---------|---------|
| 3000 | Grafana | Dashboard UI |
| 9000 | TheHive | Case management UI |
| 9001 | Cortex | Analysis engine UI |
| 8080 | MISP | Threat intel UI |
| 9200 | Elasticsearch | REST API |
| 55000 | Wazuh | Management API |

## 💾 Persistent Volumes

All data is stored in Docker volumes for persistence:
- `es-data`: Elasticsearch indices
- `wazuh-data`: Wazuh configurations
- `wazuh-logs`: Wazuh log files
- `cassandra-data`: TheHive database
- `thehive-data`: TheHive application data
- `thehive-files`: TheHive file attachments
- `cortex-data`: Cortex application data
- `misp-db-data`: MISP MySQL database
- `misp-data`: MISP application data
- `grafana-data`: Grafana dashboards
- `ml-models`: Trained ML models

## 🔄 Service Dependencies

Start order (managed by Docker Compose):
1. Elasticsearch (required by many services)
2. Cassandra (required by TheHive)
3. MISP DB (required by MISP)
4. Core services (Wazuh, TheHive, Cortex, MISP, Grafana)
5. Custom services (ML Detector, Threat Hunter, SOAR, Data Generator)

## 📦 Resource Requirements

### Minimum (Development/POC)
- CPU: 4 cores
- RAM: 8 GB
- Disk: 20 GB
- Network: 10 Mbps

### Recommended (Demo/Testing)
- CPU: 8 cores
- RAM: 16 GB
- Disk: 50 GB
- Network: 100 Mbps

### Production (Estimated)
- CPU: 16+ cores
- RAM: 32+ GB
- Disk: 500+ GB SSD
- Network: 1 Gbps

## 🔒 Security Considerations

### For POC (Current State)
- No authentication on Elasticsearch
- Default passwords used
- No TLS/SSL encryption
- Single-node setup

### For Production (Recommended)
- Enable Elasticsearch security
- Strong, unique passwords
- TLS certificates for all services
- Multi-node clustering
- Network segmentation
- Regular backups
- Secrets management (Vault)
- Role-based access control

## 🧪 Testing the Setup

### Verify All Services Running
```bash
docker-compose ps
# All services should show "Up" status
```

### Check Elasticsearch Health
```bash
curl http://localhost:9200/_cluster/health?pretty
# Should return status: green or yellow
```

### Verify Data Generation
```bash
curl http://localhost:9200/security-events/_count?pretty
# Should return increasing count
```

### Check ML Detection
```bash
curl http://localhost:9200/threat-alerts/_count?pretty
# Should show detected threats
```

### Verify Threat Hunting
```bash
curl http://localhost:9200/threat-hunting-findings/_count?pretty
# Should show hunting results
```

### Check SOAR Automation
```bash
curl http://localhost:9200/playbook-executions/_count?pretty
# Should show executed playbooks
```

## 📚 Key Files Explained

### docker-compose.yml
- Defines all services and their configurations
- Sets up networking and volumes
- Configures service dependencies
- Exposes necessary ports

### setup.sh
- Automated deployment script
- Checks prerequisites
- Starts services in correct order
- Provides status updates

### threat_detector.py
- Implements Isolation Forest ML model
- Extracts features from security events
- Calculates anomaly scores
- Implements UEBA analytics
- Stores alerts in Elasticsearch

### automated_hunter.py
- Defines hunting queries
- Maps findings to MITRE ATT&CK
- Correlates events into attack chains
- Identifies multi-stage attacks
- Continuous hunting loop

### soar_engine.py
- Defines incident response playbooks
- Matches alerts to appropriate playbooks
- Executes automated actions
- Tracks action history
- Integrates with TheHive

### generate_events.py
- Creates realistic security events
- Simulates various attack scenarios
- Generates normal user behavior
- Provides consistent data for testing
- Configurable attack frequency

## 🎯 Extending the Platform

### Add New Detection Rules
Edit `threat-hunting/automated_hunter.py`:
- Add new hunting queries
- Map to MITRE ATT&CK techniques
- Define severity levels

### Add New SOAR Playbooks
Edit `soar-automation/soar_engine.py`:
- Define new playbook actions
- Create action implementations
- Add to playbook catalog

### Integrate New Data Sources
1. Add service to docker-compose.yml
2. Configure to send logs to Elasticsearch
3. Update ML model features if needed
4. Add parsing logic for new event types

### Create Custom Dashboards
1. Log into Grafana (localhost:3000)
2. Create new dashboard
3. Add panels with Elasticsearch queries
4. Save and export JSON
5. Add to grafana-config/provisioning/dashboards/

## 🐛 Common Issues and Solutions

### Services Won't Start
```bash
# Check Docker resources
docker stats

# View logs
docker-compose logs <service-name>

# Restart specific service
docker-compose restart <service-name>
```

### Elasticsearch Yellow/Red Health
```bash
# Check cluster health
curl http://localhost:9200/_cluster/health?pretty

# Solution: Normal for single-node setup
# Yellow is acceptable for POC
```

### No Events Generated
```bash
# Check data generator
docker-compose logs data-generator

# Restart if needed
docker-compose restart data-generator
```

### High Memory Usage
```bash
# Reduce Elasticsearch memory
# Edit docker-compose.yml:
# ES_JAVA_OPTS: "-Xms512m -Xmx512m"

# Restart services
docker-compose down && docker-compose up -d
```

## 📖 Additional Resources

### Documentation
- Elasticsearch: https://www.elastic.co/guide/
- Wazuh: https://documentation.wazuh.com/
- TheHive: https://docs.strangebee.com/thehive/
- MISP: https://www.misp-project.org/documentation/
- MITRE ATT&CK: https://attack.mitre.org/

### Learning Resources
- Docker Compose: https://docs.docker.com/compose/
- scikit-learn: https://scikit-learn.org/
- Isolation Forest: https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.IsolationForest.html

---

**Project**: AI-Driven SOC POC  
**Created for**: EduQual Level 6 Diploma  
**Student**: Muhammad Abdullah Tariq  
**Last Updated**: 2025
