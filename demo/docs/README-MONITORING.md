# 🛡️ SOC Platform - Advanced Monitoring Package

Complete observability and monitoring solution for your AI-Driven Security Operations Center.

## 📦 Package Contents

This package provides comprehensive monitoring capabilities for your SOC infrastructure:

### 🎯 What's Included

- **5 New Monitoring Services** (Prometheus, Loki, cAdvisor, Node Exporter, Promtail)
- **6 Grafana Datasources** (Elasticsearch, Prometheus, Loki, MISP DB)
- **4 Pre-built Dashboards** (Infrastructure, Security, Logs, Threat Intel)
- **Complete Configuration Files**
- **Comprehensive Documentation**

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose installed
- Existing SOC platform (or fresh installation)
- At least 8GB RAM (16GB recommended with monitoring)
- 30GB free disk space

### Installation (3 Steps)

```bash
# 1. Copy configuration files to your SOC directory
cp -r grafana-config prometheus-config loki-config promtail-config /path/to/your/soc/

# 2. Replace docker-compose.yml
cp docker-compose-enhanced.yml /path/to/your/soc/docker-compose.yml

# 3. Start the platform
cd /path/to/your/soc/
./setup.sh
```

### First Access

1. **Open Grafana**: http://localhost:3000
2. **Login**: admin / admin (change on first login)
3. **Navigate**: Dashboards → Browse → "SOC Platform" folder
4. **Enjoy** your 4 new monitoring dashboards! 🎉

## 📊 Dashboards Overview

### 1. Infrastructure Monitoring
Monitor system health and container performance in real-time.

**Key Metrics**:
- CPU, Memory, Disk usage
- Container resource consumption
- Network and Disk I/O
- Container health status

**Refresh**: Every 30 seconds
**Time Range**: Last 6 hours

### 2. Security Monitoring
Track threats, alerts, and security events.

**Key Metrics**:
- Total threats detected
- Critical/High severity alerts
- Threat type distribution
- Wazuh SIEM alerts
- Security event timeline

**Refresh**: Every 30 seconds
**Time Range**: Last 24 hours

### 3. Log Analysis
Centralized log viewing with powerful search and filtering.

**Features**:
- Real-time log streams
- Error/Warning detection
- Per-container log viewing
- Log volume metrics
- Pattern matching

**Refresh**: Every 10 seconds
**Time Range**: Last 1 hour

### 4. Threat Intelligence (MISP)
Visualize threat intelligence data from your MISP platform.

**Key Metrics**:
- Total events and attributes
- Contributing organizations
- Threat level distribution
- Attribute type breakdown
- Event timeline

**Refresh**: Every 1 minute
**Time Range**: Last 30 days

## 🎨 Visual Preview

```
┌─────────────────────────────────────────┐
│      Infrastructure Monitoring          │
├─────────┬─────────┬─────────┬──────────┤
│ CPU 45% │ MEM 62% │ DISK 23%│ 12 Cont. │
├─────────┴─────────┴─────────┴──────────┤
│  📈 Container Memory Usage Over Time    │
│  📈 Container CPU Usage Over Time       │
│  📈 Network I/O by Container            │
│  📈 Disk I/O by Container               │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│       Security Monitoring               │
├─────────┬─────────┬─────────┬──────────┤
│ 234 THR │ 12 CRIT │ 1.2k WZ │ 5.6k EVT │
├─────────┴─────────┴─────────┴──────────┤
│  🥧 Threats by Type                     │
│  🥧 Threats by Severity                 │
│  📈 Threats Timeline                    │
│  📋 Recent Threats Table                │
└─────────────────────────────────────────┘
```

## 🗂️ File Structure

```
soc-platform/
├── docker-compose.yml                 # Enhanced with monitoring services
├── setup.sh                           # Updated setup script
├── destroy.sh                         # Cleanup script
├── prometheus-config/
│   └── prometheus.yml                 # Metrics collection config
├── loki-config/
│   └── loki-config.yml               # Log aggregation config
├── promtail-config/
│   └── promtail-config.yml           # Log shipping config
├── grafana-config/
│   └── provisioning/
│       ├── datasources/
│       │   └── datasources.yml       # 6 datasource definitions
│       └── dashboards/
│           ├── dashboards.yml        # Dashboard provisioning
│           ├── infrastructure-monitoring.json
│           ├── security-monitoring.json
│           ├── log-analysis.json
│           └── threat-intelligence.json
└── docs/
    ├── MONITORING-GUIDE.md           # Comprehensive guide
    ├── MONITORING-SUMMARY.md         # Quick summary
    └── README.md                     # This file
```

## 🔧 Services & Ports

| Service | Port | Purpose | UI Access |
|---------|------|---------|-----------|
| **Grafana** | 3000 | Dashboards & Visualization | ✅ http://localhost:3000 |
| **Prometheus** | 9090 | Metrics Collection | ✅ http://localhost:9090 |
| **Loki** | 3100 | Log Aggregation | 🔧 API Only |
| **cAdvisor** | 8081 | Container Metrics | ✅ http://localhost:8081 |
| **Node Exporter** | 9100 | System Metrics | 🔧 Metrics Only |
| Promtail | - | Log Shipping | 🔧 Background Service |
| **Elasticsearch** | 9200 | Search & Analytics | ✅ http://localhost:9200 |
| **Portainer** | 9443 | Container Management | ✅ https://localhost:9443 |
| **Dockge** | 5001 | Stack Management | ✅ http://localhost:5001 |

✅ = Has Web UI | 🔧 = Backend Service

## 📈 What You Can Monitor

### System Level
- [x] CPU usage and load
- [x] Memory utilization
- [x] Disk space and I/O
- [x] Network traffic
- [x] System processes

### Container Level
- [x] Per-container resource usage
- [x] Container health status
- [x] Network traffic by container
- [x] Filesystem I/O by container
- [x] Container restart counts

### Security Level
- [x] Threat detections in real-time
- [x] Alert severity distribution
- [x] Wazuh SIEM alerts
- [x] Security event patterns
- [x] Attack timeline visualization

### Application Level
- [x] Service logs (all containers)
- [x] Error and warning rates
- [x] Application metrics
- [x] Debug information
- [x] Performance indicators

### Threat Intelligence
- [x] MISP events and attributes
- [x] Threat actor tracking
- [x] IOC (Indicator of Compromise) data
- [x] Organization contributions
- [x] Intelligence trends

## 💪 Key Features

### Real-Time Monitoring
- Live metrics with 10-30 second refresh rates
- Auto-refreshing dashboards
- Instant alert visibility

### Multi-Source Integration
- Prometheus for metrics
- Elasticsearch for security data
- Loki for logs
- MySQL for threat intelligence

### Advanced Analytics
- Time-series visualization
- Log pattern matching
- Metric aggregation and correlation
- Historical trend analysis

### Powerful Query Languages
- **PromQL** for Prometheus metrics
- **LogQL** for Loki logs
- **Lucene** for Elasticsearch
- **SQL** for MISP database

### Built-in Best Practices
- Optimal retention policies
- Efficient query patterns
- Resource-conscious configurations
- Production-ready settings

## 🎓 Documentation

Comprehensive guides included:

1. **MONITORING-GUIDE.md** (Detailed)
   - Complete setup instructions
   - Dashboard details
   - Customization guide
   - Troubleshooting
   - Performance optimization
   - Security best practices

2. **MONITORING-SUMMARY.md** (Quick Reference)
   - Feature overview
   - Quick setup steps
   - Port reference
   - Common issues
   - Next steps

3. **README.md** (This file)
   - Package overview
   - Quick start
   - File structure

## 🔍 Common Use Cases

### Scenario 1: Investigating Performance Issues
1. Open **Infrastructure Monitoring** dashboard
2. Check container CPU/Memory usage
3. Identify resource-constrained services
4. Review logs in **Log Analysis** for errors
5. Take action to optimize or scale

### Scenario 2: Analyzing Security Incidents
1. Open **Security Monitoring** dashboard
2. Check threat count and severity
3. Review threat timeline for patterns
4. Examine **Recent Threats** table for details
5. Cross-reference with **Threat Intelligence** dashboard
6. Check **Log Analysis** for related log entries

### Scenario 3: Debugging Application Errors
1. Open **Log Analysis** dashboard
2. Filter logs by container
3. Search for error patterns
4. Correlate with **Infrastructure** metrics
5. Check resource constraints
6. Review security events if needed

### Scenario 4: Capacity Planning
1. Review **Infrastructure Monitoring** over 7-30 days
2. Identify usage trends
3. Check peak resource consumption
4. Plan for scaling or upgrades
5. Monitor after changes

## 🛠️ Customization

### Adding Custom Metrics

**From Python Services**:
```python
from prometheus_client import Counter, Histogram, start_http_server

# Define metrics
request_count = Counter('requests_total', 'Total requests')
request_duration = Histogram('request_duration_seconds', 'Request duration')

# Expose metrics endpoint
start_http_server(8000)
```

**Update Prometheus Config**:
```yaml
scrape_configs:
  - job_name: 'my-service'
    static_configs:
      - targets: ['my-service:8000']
```

### Creating Custom Dashboards

1. Login to Grafana
2. Create dashboard via UI
3. Export as JSON: Dashboard → Share → Export
4. Save to `grafana-config/provisioning/dashboards/my-dashboard.json`
5. Restart Grafana or wait for auto-reload

### Adding New Datasources

Edit `grafana-config/provisioning/datasources/datasources.yml`:

```yaml
- name: MyNewDataSource
  type: prometheus  # or mysql, elasticsearch, etc.
  access: proxy
  url: http://my-service:9090
  editable: true
```

## 🔒 Security Considerations

### Default Setup (POC/Testing)
- Default credentials are used
- No TLS/SSL encryption
- Limited access control

### Production Hardening
- [ ] Change all default passwords
- [ ] Enable authentication in all services
- [ ] Configure TLS/SSL certificates
- [ ] Implement network segmentation
- [ ] Use secrets management (Docker secrets, Vault)
- [ ] Enable audit logging
- [ ] Configure firewall rules
- [ ] Regular security updates

## 📊 Performance Impact

### Resource Requirements

**Additional Resources Needed**:
- **CPU**: +1-2 cores
- **Memory**: +2-4 GB RAM
- **Disk**: +10-20 GB (for metrics/logs storage)
- **Network**: Minimal impact

**Optimization Tips**:
- Adjust scrape intervals (default: 15s)
- Reduce retention periods (default: 30d)
- Limit log collection scope
- Use downsampling for long-term storage

## 🐛 Troubleshooting

### No Data in Dashboards

**Check**:
```bash
# Verify services are running
docker-compose ps

# Check datasource connectivity
curl http://localhost:9090/-/healthy  # Prometheus
curl http://localhost:3100/ready      # Loki
curl http://localhost:9200/_cluster/health  # Elasticsearch

# View service logs
docker-compose logs prometheus
docker-compose logs loki
docker-compose logs grafana
```

### High Resource Usage

**Solutions**:
1. Reduce Prometheus retention: Edit `prometheus-config/prometheus.yml`
2. Reduce Loki retention: Edit `loki-config/loki-config.yml`
3. Increase scrape intervals
4. Add resource limits in docker-compose.yml

### Logs Not Appearing

**Check**:
```bash
# Promtail logs
docker-compose logs promtail

# Loki health
curl http://localhost:3100/ready

# Test log ingestion
docker logs soc-elasticsearch 2>&1 | head
```

## 📞 Support

### Getting Help

1. **Check Documentation**
   - MONITORING-GUIDE.md for detailed help
   - MONITORING-SUMMARY.md for quick answers

2. **Review Logs**
   ```bash
   docker-compose logs -f [service-name]
   ```

3. **Test Components**
   - Datasources in Grafana UI
   - Prometheus targets: http://localhost:9090/targets
   - Service health endpoints

4. **Common Issues**
   - Verify file permissions
   - Check Docker network connectivity
   - Ensure adequate resources

## 🎯 Next Steps

After setup:

1. **Explore Dashboards** - Get familiar with each dashboard
2. **Customize** - Add your own panels and metrics
3. **Set Up Alerts** - Configure alerting for critical metrics
4. **Optimize** - Tune based on your environment
5. **Backup** - Export and version control your dashboards

## 📚 Additional Resources

### Official Documentation
- [Prometheus Docs](https://prometheus.io/docs/)
- [Grafana Docs](https://grafana.com/docs/)
- [Loki Docs](https://grafana.com/docs/loki/)
- [PromQL Guide](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [LogQL Guide](https://grafana.com/docs/loki/latest/logql/)

### Tutorials
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [Grafana Dashboards](https://grafana.com/docs/grafana/latest/dashboards/)
- [Loki Configuration](https://grafana.com/docs/loki/latest/configuration/)

## ✅ Verification Checklist

After installation, verify:

- [ ] All containers running: `docker-compose ps`
- [ ] Grafana accessible: http://localhost:3000
- [ ] All datasources connected (Grafana → Configuration → Data Sources)
- [ ] All 4 dashboards visible (Grafana → Dashboards → Browse)
- [ ] Prometheus targets UP: http://localhost:9090/targets
- [ ] Metrics appearing in dashboards
- [ ] Logs appearing in Log Analysis dashboard
- [ ] No error messages in container logs

## 🎉 Congratulations!

You now have enterprise-grade monitoring for your SOC platform!

**Start Monitoring**: http://localhost:3000

---

**Questions?** Check MONITORING-GUIDE.md for detailed information.

**Need Help?** Review container logs: `docker-compose logs [service]`

**Happy Monitoring! 🛡️📊📈**
