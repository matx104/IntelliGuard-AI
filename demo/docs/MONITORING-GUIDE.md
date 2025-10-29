# Advanced Monitoring Setup Guide

## Overview

This enhanced setup includes comprehensive monitoring and observability for your SOC platform:

### New Services Added

1. **Prometheus** (Port 9090) - Metrics collection and storage
2. **Node Exporter** (Port 9100) - System-level metrics
3. **cAdvisor** (Port 8081) - Container metrics
4. **Loki** (Port 3100) - Log aggregation
5. **Promtail** - Log shipping to Loki

### New Grafana Datasources

1. **Elasticsearch** - Security events and logs
2. **Elasticsearch-Threats** - Threat alerts
3. **Elasticsearch-Wazuh** - Wazuh security alerts
4. **Prometheus** - System and container metrics
5. **Loki** - Centralized logs
6. **MISP-Database** - Threat intelligence data

### New Dashboards

1. **Infrastructure Monitoring** - System resources, container health
2. **Security Monitoring** - Threats, alerts, security events
3. **Log Analysis** - Centralized log viewing and analysis
4. **Threat Intelligence** - MISP data visualization

## Installation

### Step 1: Organize Configuration Files

Create the necessary directory structure:

```bash
mkdir -p prometheus-config
mkdir -p loki-config
mkdir -p promtail-config
mkdir -p grafana-config/provisioning/datasources
mkdir -p grafana-config/provisioning/dashboards
```

### Step 2: Copy Configuration Files

Copy all the provided configuration files to their respective directories:

```bash
# Copy Prometheus config
cp prometheus-config/prometheus.yml ./prometheus-config/

# Copy Loki config
cp loki-config/loki-config.yml ./loki-config/

# Copy Promtail config
cp promtail-config/promtail-config.yml ./promtail-config/

# Copy Grafana datasources and dashboards
cp grafana-config/provisioning/datasources/datasources.yml ./grafana-config/provisioning/datasources/
cp grafana-config/provisioning/dashboards/dashboards.yml ./grafana-config/provisioning/dashboards/
cp grafana-config/provisioning/dashboards/*.json ./grafana-config/provisioning/dashboards/
```

### Step 3: Update Docker Compose

Replace your existing `docker-compose.yml` with the enhanced version that includes:
- Prometheus
- Node Exporter
- cAdvisor
- Loki
- Promtail

### Step 4: Start the Platform

```bash
# Make setup script executable
chmod +x setup.sh

# Run setup
./setup.sh
```

## Accessing Dashboards

### Grafana Access

1. Open Grafana: http://localhost:3000
2. Login: admin / admin
3. Navigate to Dashboards → Browse
4. You'll find all dashboards in the "SOC Platform" folder:
   - Infrastructure Monitoring
   - Security Monitoring
   - Log Analysis
   - Threat Intelligence (MISP)

### Direct Service Access

- **Prometheus**: http://localhost:9090
- **Loki**: http://localhost:3100
- **cAdvisor**: http://localhost:8081
- **Node Exporter**: http://localhost:9100

## Dashboard Details

### 1. Infrastructure Monitoring Dashboard

**Purpose**: Monitor system and container health

**Key Panels**:
- CPU Usage (gauge)
- Memory Usage (gauge)
- Disk Usage (gauge)
- Running Container Count
- Container Memory Usage (time series)
- Container CPU Usage (time series)
- Network I/O by container
- Disk I/O by container

**Metrics Source**: Prometheus, Node Exporter, cAdvisor

**Refresh Rate**: 30 seconds

**Use Cases**:
- Identify resource-constrained containers
- Monitor system health
- Capacity planning
- Performance optimization

### 2. Security Monitoring Dashboard

**Purpose**: Track security threats and incidents

**Key Panels**:
- Total Threats Detected
- Critical Threats Count
- Wazuh Alerts Count
- Total Security Events
- Threats by Type (donut chart)
- Threats by Severity (donut chart)
- Threats Timeline (time series)
- Recent Threats (table)
- Wazuh Alerts Over Time

**Metrics Source**: Elasticsearch (threat-alerts, wazuh-alerts indices)

**Refresh Rate**: 30 seconds

**Use Cases**:
- Real-time threat monitoring
- Security incident tracking
- Threat type analysis
- Alert prioritization

### 3. Log Analysis Dashboard

**Purpose**: Centralized log viewing and analysis

**Key Panels**:
- Log Volume (all containers)
- Log Rate by Container
- Error Log Count (5-minute window)
- Warning Log Count (5-minute window)
- Error Logs viewer (filtered)
- Elasticsearch Logs
- Wazuh Logs

**Metrics Source**: Loki

**Refresh Rate**: 10 seconds

**Use Cases**:
- Troubleshooting container issues
- Error tracking
- Log correlation
- System debugging

### 4. Threat Intelligence Dashboard

**Purpose**: Visualize MISP threat intelligence data

**Key Panels**:
- Total Events (30 days)
- Attributes (7 days)
- Contributing Organizations
- Total Tags
- Top Attribute Types (donut chart)
- Events by Threat Level (donut chart)
- Events Timeline (30 days)
- Recent Events (table)

**Metrics Source**: MISP MySQL Database

**Refresh Rate**: 1 minute

**Use Cases**:
- Threat intelligence tracking
- IOC monitoring
- Organization contribution analysis
- Threat trend analysis

## Customization Guide

### Adding New Metrics to Prometheus

1. Edit `prometheus-config/prometheus.yml`
2. Add a new scrape config:

```yaml
- job_name: 'my-service'
  static_configs:
    - targets: ['my-service:8000']
      labels:
        service: 'my-service'
```

3. Restart Prometheus:
```bash
docker-compose restart prometheus
```

### Creating Custom Dashboards

1. **Via Grafana UI**:
   - Login to Grafana
   - Click "+" → "Dashboard"
   - Add panels with your queries
   - Save dashboard

2. **Via JSON** (Recommended for version control):
   - Create dashboard in Grafana UI
   - Click "Share" → "Export" → "Save to file"
   - Copy JSON to `grafana-config/provisioning/dashboards/`
   - Restart Grafana or wait for auto-reload

### Adding New Datasources

Edit `grafana-config/provisioning/datasources/datasources.yml`:

```yaml
- name: MyDataSource
  type: prometheus  # or elasticsearch, mysql, etc.
  access: proxy
  url: http://my-service:9090
  editable: true
```

## Troubleshooting

### Prometheus Not Collecting Metrics

**Check**:
1. Target health: http://localhost:9090/targets
2. Container logs: `docker-compose logs prometheus`
3. Network connectivity: `docker exec soc-prometheus ping node-exporter`

**Fix**:
- Ensure all targets are in the same Docker network
- Verify port mappings in docker-compose.yml
- Check firewall rules

### Loki Not Receiving Logs

**Check**:
1. Promtail status: `docker-compose logs promtail`
2. Loki API: `curl http://localhost:3100/ready`
3. Log file permissions

**Fix**:
- Verify volume mounts in docker-compose.yml
- Check Promtail configuration file syntax
- Ensure Docker log driver is json-file

### Grafana Dashboards Not Loading

**Check**:
1. Datasource configuration: Grafana → Configuration → Data Sources
2. Grafana logs: `docker-compose logs grafana`
3. Dashboard provisioning: Check `/etc/grafana/provisioning/dashboards`

**Fix**:
- Test datasource connection in Grafana
- Verify JSON syntax in dashboard files
- Restart Grafana: `docker-compose restart grafana`

### High Resource Usage

**Symptoms**:
- Containers restarting
- Slow dashboard loading
- OOM errors

**Solutions**:

1. **Adjust Prometheus retention**:
```yaml
# In docker-compose.yml
command:
  - '--storage.tsdb.retention.time=15d'  # Reduce from 30d
```

2. **Limit Loki retention**:
```yaml
# In loki-config.yml
limits_config:
  retention_period: 168h  # 7 days instead of 31
```

3. **Reduce scrape intervals**:
```yaml
# In prometheus-config/prometheus.yml
global:
  scrape_interval: 30s  # Increase from 15s
```

4. **Limit container resources**:
```yaml
# In docker-compose.yml
services:
  prometheus:
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '1'
```

## Performance Optimization

### For Large Deployments

1. **Use Remote Storage**:
   - Configure Prometheus remote write to external storage
   - Use object storage for Loki chunks

2. **Enable Compression**:
   - Loki compression enabled by default
   - Use gzip for Prometheus metrics

3. **Implement Sharding**:
   - Shard Prometheus by service or namespace
   - Use multiple Loki instances

4. **Query Optimization**:
   - Use recording rules in Prometheus
   - Limit time ranges in queries
   - Use proper label filtering

## Security Best Practices

1. **Enable Authentication**:
```yaml
# In loki-config.yml
auth_enabled: true
```

2. **Use TLS**:
   - Configure HTTPS for Grafana
   - Enable TLS for Prometheus

3. **Restrict Access**:
   - Use firewall rules
   - Implement network policies
   - Use authentication proxies

4. **Secure Credentials**:
   - Use Docker secrets
   - Avoid hardcoded passwords
   - Rotate credentials regularly

## Monitoring Checklist

### Daily
- [ ] Check critical alerts in Security Monitoring dashboard
- [ ] Review error logs in Log Analysis dashboard
- [ ] Verify all containers running (Infrastructure dashboard)

### Weekly
- [ ] Review threat trends (Security Monitoring)
- [ ] Check resource utilization trends (Infrastructure)
- [ ] Analyze MISP intelligence updates (Threat Intelligence)
- [ ] Review and tune alert thresholds

### Monthly
- [ ] Capacity planning review
- [ ] Performance optimization
- [ ] Update threat detection rules
- [ ] Backup Grafana dashboards and configurations

## Backup and Recovery

### Backing Up Grafana Dashboards

```bash
# Export all dashboards
docker exec soc-grafana grafana-cli admin export-dashboard > dashboards-backup.json

# Or copy provisioning directory
cp -r grafana-config/provisioning grafana-config-backup/
```

### Backing Up Prometheus Data

```bash
# Snapshot Prometheus data
docker exec soc-prometheus promtool tsdb snapshot /prometheus
```

### Backing Up Loki Data

```bash
# Backup Loki chunks
docker run --rm -v loki-data:/data -v $(pwd):/backup alpine \
  tar czf /backup/loki-backup.tar.gz /data
```

## Support and Resources

### Documentation Links
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/latest/)

### Query Examples

**Prometheus Queries**:
```promql
# CPU usage by container
rate(container_cpu_usage_seconds_total[5m]) * 100

# Memory usage percentage
(container_memory_usage_bytes / container_memory_limit_bytes) * 100

# Network traffic
rate(container_network_receive_bytes_total[5m])
```

**Loki Queries**:
```logql
# All errors
{job="docker"} |= "error"

# Container-specific logs
{job="docker",container_id=~".*elasticsearch.*"}

# Error rate
rate({job="docker"} |= "error" [5m])
```

**Elasticsearch Queries**:
```json
{
  "query": {
    "range": {
      "@timestamp": {
        "gte": "now-1h"
      }
    }
  }
}
```

---

**Need Help?** Check the troubleshooting section or review container logs with:
```bash
docker-compose logs -f [service-name]
```
