# 📦 SOC Platform Monitoring Package - File Manifest

Complete list of all files included in this monitoring enhancement package.

## 📋 Quick Overview

- **13 Configuration Files**
- **3 Documentation Files**
- **3 Setup/Management Scripts**
- **4 Grafana Dashboards**
- **1 Enhanced Docker Compose**

**Total**: 24 files organized across 5 directories

---

## 📂 Directory Structure

```
monitoring-package/
├── 📄 docker-compose-enhanced.yml           [Main deployment file]
├── 📄 setup-monitoring.sh                   [Automated setup script]
├── 📄 setup.sh                              [Updated setup script]
├── 📄 destroy.sh                            [Cleanup script]
│
├── 📘 README-MONITORING.md                  [Main documentation]
├── 📘 MONITORING-GUIDE.md                   [Detailed guide]
├── 📘 MONITORING-SUMMARY.md                 [Quick reference]
│
├── 📁 prometheus-config/
│   └── 📄 prometheus.yml                    [Prometheus configuration]
│
├── 📁 loki-config/
│   └── 📄 loki-config.yml                   [Loki configuration]
│
├── 📁 promtail-config/
│   └── 📄 promtail-config.yml              [Promtail configuration]
│
└── 📁 grafana-config/
    └── provisioning/
        ├── 📁 datasources/
        │   └── 📄 datasources.yml           [6 datasource definitions]
        └── 📁 dashboards/
            ├── 📄 dashboards.yml            [Dashboard provisioning]
            ├── 📄 infrastructure-monitoring.json
            ├── 📄 security-monitoring.json
            ├── 📄 log-analysis.json
            └── 📄 threat-intelligence.json
```

---

## 📄 File Descriptions

### 🚀 Deployment Files

#### `docker-compose-enhanced.yml`
**Purpose**: Complete Docker Compose configuration with all monitoring services  
**Size**: ~8.8 KB  
**What it includes**:
- All original SOC services (Elasticsearch, Wazuh, TheHive, MISP, etc.)
- New monitoring services (Prometheus, Loki, cAdvisor, Node Exporter)
- Portainer and Dockge for container management
- Proper networking and volume configurations

**Usage**: 
```bash
cp docker-compose-enhanced.yml docker-compose.yml
docker-compose up -d
```

---

### 🛠️ Setup & Management Scripts

#### `setup-monitoring.sh`
**Purpose**: Automated setup and installation script  
**Size**: ~13 KB  
**Features**:
- Prerequisites checking (Docker, disk space, memory)
- Directory structure creation
- Configuration file validation
- System configuration (vm.max_map_count)
- Service deployment and health checks
- Comprehensive status reporting
- Interactive verification

**Usage**:
```bash
chmod +x setup-monitoring.sh
./setup-monitoring.sh
```

#### `setup.sh`
**Purpose**: Updated original setup script with monitoring info  
**Size**: ~3.2 KB  
**Enhancements**:
- Includes Portainer and Dockge URLs
- Shows monitoring service access points
- Pro tips for management tools

**Usage**:
```bash
chmod +x setup.sh
./setup.sh
```

#### `destroy.sh`
**Purpose**: Complete cleanup and removal script  
**Size**: ~3.8 KB  
**What it removes**:
- All containers
- All volumes (data deletion)
- All networks
- All Docker images
- Build cache

**Usage**:
```bash
chmod +x destroy.sh
./destroy.sh
# Type 'yes' to confirm
```

---

### 📘 Documentation Files

#### `README-MONITORING.md`
**Purpose**: Main documentation and package overview  
**Size**: ~14 KB  
**Contents**:
- Package overview
- Quick start guide
- Dashboard descriptions
- Service & port reference
- Common use cases
- Customization guide
- Troubleshooting
- Verification checklist

**Best for**: First-time users, general overview

#### `MONITORING-GUIDE.md`
**Purpose**: Comprehensive technical guide  
**Size**: ~11 KB  
**Contents**:
- Detailed installation steps
- Dashboard technical details
- Performance optimization
- Security best practices
- Advanced customization
- Query examples
- Troubleshooting guide
- Backup procedures

**Best for**: Advanced users, system administrators

#### `MONITORING-SUMMARY.md`
**Purpose**: Quick reference and summary  
**Size**: ~8.5 KB  
**Contents**:
- Feature list
- Quick setup steps
- Port reference table
- Common issues & solutions
- Next steps

**Best for**: Quick reference, troubleshooting

---

### ⚙️ Configuration Files

#### `prometheus-config/prometheus.yml`
**Purpose**: Prometheus metrics collection configuration  
**Size**: ~1.5 KB  
**Configures**:
- Scrape intervals (15s)
- Retention period (30d)
- Target endpoints:
  - Prometheus itself (9090)
  - Node Exporter (9100)
  - cAdvisor (8080)
  - Elasticsearch (9200)
  - Grafana (3000)

**Key Settings**:
```yaml
global:
  scrape_interval: 15s      # How often to collect metrics
  evaluation_interval: 15s   # How often to evaluate rules

scrape_configs:
  - job_name: 'prometheus'   # Self-monitoring
  - job_name: 'node-exporter' # System metrics
  - job_name: 'cadvisor'     # Container metrics
```

**Customization**: Add new services to scrape_configs section

#### `loki-config/loki-config.yml`
**Purpose**: Loki log aggregation configuration  
**Size**: ~1.8 KB  
**Configures**:
- Log retention (31 days)
- Storage backend (filesystem)
- Ingestion rate limits
- Query settings
- Compaction rules

**Key Settings**:
```yaml
retention_period: 744h  # 31 days
ingestion_rate_mb: 10   # Max ingestion rate
max_query_length: 721h  # Max query time range
```

**Customization**: Adjust retention and rate limits based on volume

#### `promtail-config/promtail-config.yml`
**Purpose**: Promtail log shipping configuration  
**Size**: ~1.3 KB  
**Configures**:
- Log collection paths
- Label extraction
- Log parsing rules
- Shipping to Loki

**Collects from**:
- System logs (/var/log/*.log)
- Docker container logs
- Elasticsearch logs

**Key Features**:
- Automatic container ID extraction
- JSON log parsing
- Timestamp normalization

**Customization**: Add new log sources in scrape_configs

---

### 📊 Grafana Configuration Files

#### `grafana-config/provisioning/datasources/datasources.yml`
**Purpose**: Grafana datasource definitions  
**Size**: ~2.5 KB  
**Defines 6 datasources**:

1. **Elasticsearch** - Security events
   - URL: http://elasticsearch:9200
   - Index pattern: [security-events-]YYYY.MM.DD

2. **Elasticsearch-Threats** - Threat alerts
   - URL: http://elasticsearch:9200
   - Index: threat-alerts

3. **Elasticsearch-Wazuh** - Wazuh alerts
   - URL: http://elasticsearch:9200
   - Index pattern: [wazuh-alerts-]YYYY.MM.DD

4. **Prometheus** - System metrics
   - URL: http://prometheus:9090
   - Query timeout: 60s

5. **Loki** - Log aggregation
   - URL: http://loki:3100
   - Max lines: 1000

6. **MISP-Database** - Threat intelligence
   - URL: misp-db:3306
   - Database: misp
   - User: misp

**Auto-loaded**: On Grafana startup, no manual configuration needed

#### `grafana-config/provisioning/dashboards/dashboards.yml`
**Purpose**: Dashboard provisioning configuration  
**Size**: ~0.5 KB  
**Configures**:
- Dashboard folder: "SOC Platform"
- Auto-reload interval: 10s
- Allow UI updates: true

**Note**: This file tells Grafana where to find dashboard JSON files

---

### 📈 Grafana Dashboards

#### `infrastructure-monitoring.json`
**Purpose**: System and container monitoring  
**Size**: ~8 KB  
**Panels (9)**:
- CPU Usage (gauge)
- Memory Usage (gauge)
- Disk Usage (gauge)
- SOC Containers Status
- Container Memory Usage (time series)
- Container CPU Usage (time series)
- Network I/O (time series)
- Disk I/O (time series)

**Datasource**: Prometheus  
**Refresh**: 30 seconds  
**Time range**: Last 6 hours

**Key metrics**:
- `node_cpu_seconds_total` - CPU usage
- `node_memory_MemAvailable_bytes` - Memory usage
- `container_memory_usage_bytes` - Container memory
- `container_cpu_usage_seconds_total` - Container CPU

#### `security-monitoring.json`
**Purpose**: Security threats and alerts  
**Size**: ~12 KB  
**Panels (10)**:
- Total Threats Detected (stat)
- Critical Threats (stat)
- Wazuh Alerts Count (stat)
- Total Security Events (stat)
- Threats by Type (pie chart)
- Threats by Severity (pie chart)
- Threats Timeline (time series)
- Recent Threats (table)
- Wazuh Alerts Over Time (time series)

**Datasources**: Elasticsearch-Threats, Elasticsearch-Wazuh  
**Refresh**: 30 seconds  
**Time range**: Last 24 hours

**Shows**:
- Real-time threat counts
- Severity distribution
- Threat type breakdown
- Historical trends

#### `log-analysis.json`
**Purpose**: Centralized log viewing and analysis  
**Size**: ~10 KB  
**Panels (8)**:
- Log Volume (all containers)
- Log Rate by Container
- Error Log Count (5-minute window)
- Warning Log Count (5-minute window)
- Error Logs (log viewer)
- Elasticsearch Logs (log viewer)
- Wazuh Logs (log viewer)

**Datasource**: Loki  
**Refresh**: 10 seconds  
**Time range**: Last 1 hour

**Features**:
- Real-time log streaming
- Error/warning filtering
- Per-container log views
- Pattern matching

**Query examples**:
```logql
{job="docker"} |= "error"                          # All errors
{job="docker", container_id=~".*elasticsearch.*"} # ES logs
{job="docker"} |~ "(?i)error|fail|exception"      # Error patterns
```

#### `threat-intelligence.json`
**Purpose**: MISP threat intelligence visualization  
**Size**: ~11 KB  
**Panels (9)**:
- Total Events (30 days)
- Attributes (7 days)
- Contributing Organizations
- Total Tags
- Top Attribute Types (pie chart)
- Events by Threat Level (pie chart)
- Events Timeline (time series)
- Recent Events (table)

**Datasource**: MISP-Database (MySQL)  
**Refresh**: 1 minute  
**Time range**: Last 30 days

**SQL Queries**:
```sql
-- Event count
SELECT COUNT(*) FROM events WHERE date >= DATE_SUB(NOW(), INTERVAL 30 DAY)

-- Attribute types
SELECT type, COUNT(*) as count FROM attributes GROUP BY type

-- Timeline
SELECT DATE(date) as time, COUNT(*) as value FROM events GROUP BY DATE(date)
```

---

## 📦 Installation Order

Follow this order for successful setup:

1. **Create directories**
   ```bash
   mkdir -p {prometheus,loki,promtail,grafana}-config/
   mkdir -p grafana-config/provisioning/{datasources,dashboards}
   ```

2. **Copy configuration files**
   - prometheus-config/prometheus.yml
   - loki-config/loki-config.yml
   - promtail-config/promtail-config.yml
   - grafana-config/provisioning/datasources/datasources.yml
   - grafana-config/provisioning/dashboards/*.json
   - grafana-config/provisioning/dashboards/dashboards.yml

3. **Copy docker-compose file**
   ```bash
   cp docker-compose-enhanced.yml docker-compose.yml
   ```

4. **Run setup**
   ```bash
   chmod +x setup-monitoring.sh
   ./setup-monitoring.sh
   ```

---

## 🎯 Quick Reference

### File Usage by Role

**For Initial Setup**:
- `setup-monitoring.sh` - Run first
- `docker-compose-enhanced.yml` - Deployment config
- All config files in */config directories

**For Daily Operations**:
- Grafana dashboards (*.json files)
- `docker-compose.yml` - Service management

**For Troubleshooting**:
- `MONITORING-GUIDE.md` - Detailed help
- `MONITORING-SUMMARY.md` - Quick answers
- Container logs: `docker-compose logs`

**For Customization**:
- `prometheus.yml` - Add metrics sources
- `datasources.yml` - Add new datasources
- Dashboard JSON files - Modify panels
- `docker-compose-enhanced.yml` - Adjust services

**For Cleanup**:
- `destroy.sh` - Complete removal

---

## 💾 File Sizes Summary

| Category | Files | Total Size |
|----------|-------|------------|
| Documentation | 3 | ~33.5 KB |
| Docker Compose | 1 | ~8.8 KB |
| Scripts | 3 | ~20 KB |
| Config Files | 4 | ~6.1 KB |
| Datasources | 1 | ~2.5 KB |
| Dashboards | 5 | ~41 KB |
| **Total** | **17** | **~111.9 KB** |

*Plus directory structures*

---

## ✅ File Checklist

Before starting setup, verify you have all files:

**Core Files**:
- [ ] docker-compose-enhanced.yml
- [ ] setup-monitoring.sh
- [ ] setup.sh
- [ ] destroy.sh

**Documentation**:
- [ ] README-MONITORING.md
- [ ] MONITORING-GUIDE.md
- [ ] MONITORING-SUMMARY.md

**Prometheus**:
- [ ] prometheus-config/prometheus.yml

**Loki**:
- [ ] loki-config/loki-config.yml

**Promtail**:
- [ ] promtail-config/promtail-config.yml

**Grafana Datasources**:
- [ ] grafana-config/provisioning/datasources/datasources.yml

**Grafana Dashboards Config**:
- [ ] grafana-config/provisioning/dashboards/dashboards.yml

**Grafana Dashboards**:
- [ ] grafana-config/provisioning/dashboards/infrastructure-monitoring.json
- [ ] grafana-config/provisioning/dashboards/security-monitoring.json
- [ ] grafana-config/provisioning/dashboards/log-analysis.json
- [ ] grafana-config/provisioning/dashboards/threat-intelligence.json

---

## 🔄 Update/Modification Guide

### To update configurations:

1. **Prometheus** (`prometheus.yml`)
   - Modify, then restart: `docker-compose restart prometheus`

2. **Loki** (`loki-config.yml`)
   - Modify, then restart: `docker-compose restart loki`

3. **Datasources** (`datasources.yml`)
   - Modify, Grafana auto-reloads in ~10s
   - Or restart: `docker-compose restart grafana`

4. **Dashboards** (`*.json`)
   - Modify JSON file
   - Grafana auto-reloads in ~10s
   - Or export from UI and replace file

### To add new components:

1. Add service to `docker-compose-enhanced.yml`
2. Add scrape config to `prometheus.yml` (if metrics)
3. Add datasource to `datasources.yml` (if needed)
4. Create dashboard JSON (optional)
5. Restart affected services

---

## 🆘 Help & Support

**Quick Help**:
- Start with README-MONITORING.md
- Check MONITORING-SUMMARY.md for common issues

**Detailed Help**:
- MONITORING-GUIDE.md has comprehensive troubleshooting

**Still stuck?**
- Check container logs: `docker-compose logs [service]`
- Verify file permissions
- Ensure Docker network connectivity

---

**Package Version**: 1.0  
**Created**: 2024  
**Compatible with**: Docker Compose 3.8+

