# 🎯 Complete Setup Guide: MISP Fix + Auto-Loading Grafana Dashboard

This guide will fix MISP and set up an awesome Grafana dashboard that loads automatically with your data.

## Part 1: Fix MISP 🔧

### Step 1: Update docker-compose.yml

```bash
cd ~/IntelliGuard-AI/demo
nano docker-compose.yml
```

Find the `misp:` service section and add the `CRON_USER_ID` environment variable:

```yaml
  misp:
    image: coolacid/misp-docker:core-latest
    container_name: soc-misp
    depends_on:
      - misp-db
    ports:
      - "8080:80"
      - "8443:443"
    environment:
      - MYSQL_HOST=misp-db
      - MYSQL_DATABASE=misp
      - MYSQL_USER=misp
      - MYSQL_PASSWORD=misp_password
      - MISP_ADMIN_EMAIL=admin@misp.local
      - MISP_ADMIN_PASSPHRASE=admin_password
      - MISP_BASEURL=http://localhost:8080
      - CRON_USER_ID=1000          # ← ADD THIS LINE
    volumes:
      - misp-data:/var/www/MISP
    networks:
      - soc-network
```

Save with `Ctrl+O`, `Enter`, then exit with `Ctrl+X`.

### Step 2: Restart MISP

```bash
docker-compose up -d misp

# Watch it start (wait for "MISP | Start" messages)
docker-compose logs misp -f
# Press Ctrl+C when you see it's running
```

### Step 3: Verify MISP is Working

```bash
# Check if container is running
docker ps | grep misp

# Should show "Up" status
# Access MISP at: http://YOUR_IP:8080
# Login: admin@misp.local / admin_password
```

## Part 2: Setup Auto-Loading Grafana Dashboard 📊

### Step 1: Create Dashboard Provisioning Directory

```bash
cd ~/IntelliGuard-AI/demo

# Create the dashboards directory
mkdir -p grafana-config/provisioning/dashboards
```

### Step 2: Copy Dashboard Files

```bash
# Copy the dashboard JSON
# (You should have downloaded ai-soc-dashboard.json from Claude)
cp ~/Downloads/ai-soc-dashboard.json grafana-config/provisioning/dashboards/

# Copy the provisioning config
cp ~/Downloads/dashboards.yml grafana-config/provisioning/dashboards/
```

**OR create them directly:**

Create `grafana-config/provisioning/dashboards/dashboards.yml`:
```bash
cat > grafana-config/provisioning/dashboards/dashboards.yml << 'EOF'
apiVersion: 1

providers:
  - name: 'AI-SOC Dashboards'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOF
```

### Step 3: Update docker-compose.yml for Grafana

Update the Grafana service to include the new volume mount:

```bash
nano docker-compose.yml
```

Find the `grafana:` service and update the volumes section:

```yaml
  grafana:
    image: grafana/grafana:latest
    container_name: soc-grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_AUTH_ANONYMOUS_ENABLED=false
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana-config/provisioning:/etc/grafana/provisioning  # ← This line should already exist
    networks:
      - soc-network
    depends_on:
      - elasticsearch
```

### Step 4: Restart Grafana

```bash
# Restart Grafana to load the new dashboard
docker-compose restart grafana

# Wait for it to start
sleep 10

# Check if it's running
docker ps | grep grafana
```

### Step 5: Access Your Dashboard

1. Open browser: `http://YOUR_IP:3000`
2. Login: `admin` / `admin`
3. Look for dashboard: **"AI-Driven SOC - Security Overview"**
4. It should auto-load with your live data!

## 📊 Dashboard Features

Your auto-loaded dashboard includes:

### Top Row Metrics (Stats):
- **Total Security Events** - Live count with color thresholds
- **Threats Detected** - ML-detected anomalies
- **MITRE Techniques Detected** - Unique ATT&CK techniques
- **Average Risk Score** - Overall threat level

### Main Visualizations:
- **Security Events Over Time** - Line chart showing event volume
- **Threat Alerts Over Time** - Multi-series showing different attack types
- **Attack Types Distribution** - Donut chart of threat categories
- **Top 10 Source IPs** - Bar chart of most active sources
- **MITRE ATT&CK Techniques Table** - Detected techniques with counts
- **UEBA High Risk Users** - Count of high-risk user accounts
- **Anomaly Scores Over Time** - ML model confidence scores

### Dashboard Settings:
- **Auto-refresh**: Every 10 seconds
- **Time range**: Last 1 hour (adjustable)
- **Real-time updates**: All panels refresh automatically

## 🎨 Customizing the Dashboard

### Change Refresh Rate:
Top-right corner → Click refresh icon → Select interval (5s, 10s, 30s, 1m, 5m)

### Adjust Time Range:
Top-right corner → Select time range or use "Last X hours"

### Edit Panels:
1. Click panel title → Edit
2. Modify queries, colors, thresholds
3. Click "Apply" to save

### Add New Panels:
1. Click "Add panel" (top right)
2. Select visualization type
3. Configure data source: **Elasticsearch**
4. Write query
5. Save dashboard

## 🔍 Troubleshooting

### Dashboard Not Loading?

```bash
# Check Grafana logs
docker-compose logs grafana | tail -50

# Verify files exist
ls -la grafana-config/provisioning/dashboards/

# Should show:
# dashboards.yml
# ai-soc-dashboard.json
```

### No Data in Panels?

```bash
# Verify Elasticsearch has data
curl http://localhost:9200/security-events/_count
curl http://localhost:9200/threat-alerts/_count

# Check Elasticsearch datasource in Grafana
# Go to: Configuration → Data Sources → Elasticsearch
# Click "Test" - should be green
```

### Panels Show "No Data"?

Wait 2-3 minutes for data generator to create more events, then:
1. In Grafana, change time range to "Last 6 hours"
2. Click refresh icon
3. Data should appear

### MISP Still Not Starting?

```bash
# Check logs for errors
docker-compose logs misp --tail 100 | grep -i error

# Try complete restart
docker-compose down
docker-compose up -d

# Wait 2-3 minutes for MISP to initialize
```

## ✅ Verification Checklist

After setup, verify:

- [ ] MISP container is "Up" (not "Exited")
- [ ] Can access MISP at http://YOUR_IP:8080
- [ ] Grafana container is running
- [ ] Can access Grafana at http://YOUR_IP:3000
- [ ] Dashboard "AI-Driven SOC - Security Overview" exists
- [ ] All dashboard panels show data
- [ ] Dashboard auto-refreshes every 10 seconds
- [ ] Can see live threat detection happening

## 🎯 For Your Presentation

### Opening the Dashboard:
1. Have Grafana open: `http://YOUR_IP:3000`
2. Show the "AI-Driven SOC - Security Overview" dashboard
3. Point out the real-time data updating

### Talking Points:
> "This is our live security dashboard showing real-time threat detection. As you can see, we've processed over [X] events and detected [Y] threats using machine learning. The dashboard updates every 10 seconds with new detections."

> "The system has identified [Z] different MITRE ATT&CK techniques, including brute force attacks, port scanning, and data exfiltration attempts."

> "You can see the anomaly scores from our ML model here - higher scores indicate greater confidence in threat detection."

### Demo Flow:
1. **Show top metrics** - "Here are our key security metrics"
2. **Point to time series** - "This shows threat detection over time"
3. **Highlight MITRE table** - "We map all findings to ATT&CK framework"
4. **Show auto-refresh** - "Notice it updates automatically"

## 🎨 Dashboard Color Scheme

- **Green**: Normal/safe (0-50)
- **Yellow**: Warning/elevated (50-75)
- **Red**: Critical/dangerous (75-100)
- **Blue**: Information/neutral

## 📈 Sample Queries You Can Show

During demo, you can also run these in terminal:

```bash
# Show live threat count
watch -n 2 'echo "Threats: $(curl -s http://localhost:9200/threat-alerts/_count | jq .count)"'

# Show latest threat
curl -s "http://localhost:9200/threat-alerts/_search?size=1&sort=@timestamp:desc" | jq '.hits.hits[0]._source'

# Count by attack type
curl -s "http://localhost:9200/threat-alerts/_search?size=0" -H 'Content-Type: application/json' -d '{
  "aggs": {
    "attack_types": {
      "terms": {"field": "alert_type.keyword"}
    }
  }
}' | jq '.aggregations.attack_types.buckets'
```

## 🚀 Next Steps

After setup is complete:

1. Let the system run for 30 minutes to accumulate data
2. Practice navigating the dashboard
3. Try different time ranges
4. Create additional panels if desired
5. Take screenshots for backup

## 💾 Backup Your Dashboard

To save your dashboard configuration:

```bash
# Export from Grafana UI
# Dashboard → Settings → JSON Model → Copy to clipboard

# Or backup the file
cp grafana-config/provisioning/dashboards/ai-soc-dashboard.json \
   grafana-config/provisioning/dashboards/ai-soc-dashboard.json.backup
```

## 🎉 Success!

You now have:
- ✅ MISP working and accessible
- ✅ Beautiful Grafana dashboard
- ✅ Auto-loading on boot
- ✅ Real-time data visualization
- ✅ Professional security monitoring interface

**Your AI-SOC demo is complete and production-ready!** 🚀

---

**Need help?** Check the troubleshooting section or examine the logs:
```bash
docker-compose logs grafana
docker-compose logs misp
```
