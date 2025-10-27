# Getting Started - One Page Guide

## 🎯 What This Is
A complete AI-driven Security Operations Center (SOC) that:
- Detects threats using machine learning
- Hunts for attacks using MITRE ATT&CK
- Automatically responds to incidents with SOAR playbooks
- Visualizes security metrics in real-time

## 📋 Requirements
- Docker & Docker Compose
- 8GB+ RAM, 20GB+ disk space
- Linux, macOS, or Windows (WSL2)

## 🚀 Quick Start (3 Steps)

### Step 1: Setup
```bash
cd ai-soc-poc
chmod +x setup.sh
./setup.sh
```

### Step 2: Wait (3-5 minutes)
Services are initializing. Check status:
```bash
docker-compose ps
curl http://localhost:9200/_cluster/health?pretty
```

### Step 3: Access & Explore
- **Dashboards**: http://localhost:3000 (admin/admin)
- **Cases**: http://localhost:9000 (admin@thehive.local/secret)
- **Threat Intel**: http://localhost:8080 (admin@misp.local/admin_password)

## 🔍 Verify It's Working

### Check Events
```bash
curl http://localhost:9200/security-events/_count?pretty
```

### Check Threats
```bash
curl http://localhost:9200/threat-alerts/_search?size=3&pretty
```

### Check Responses
```bash
curl http://localhost:9200/playbook-executions/_search?size=3&pretty
```

## 📊 What's Happening

1. **Data Generator** creates ~100 events/hour (70% normal, 30% attacks)
2. **ML Detector** analyzes events for anomalies every minute
3. **Threat Hunter** runs hunting queries every 5 minutes
4. **SOAR Engine** automatically responds to detected threats
5. **Grafana** shows everything in real-time dashboards

## 🛑 Stop the System
```bash
docker-compose down
```

## 📚 Full Documentation
- **README.md** - Complete documentation
- **QUICK_REFERENCE.md** - Command reference
- **PRESENTATION_GUIDE.md** - Presentation tips
- **TROUBLESHOOTING.md** - Problem solutions

## 🎯 For Presentation

### Show These 3 Things:

1. **Real-time Detection** (Grafana dashboard)
   - Open http://localhost:3000
   - Show event counts and threat detection

2. **MITRE ATT&CK Mapping** (Terminal)
   ```bash
   curl http://localhost:9200/threat-hunting-findings/_search?size=2&pretty | grep technique
   ```

3. **Automated Response** (Terminal)
   ```bash
   curl http://localhost:9200/playbook-executions/_search?size=2&pretty
   ```

### Explain These Concepts:
- **Why ML?** - Detects unknown/zero-day threats
- **Why SOAR?** - Instant response, no human delay
- **Why MITRE?** - Standard threat taxonomy

## 🆘 Quick Fixes

**Nothing working?**
```bash
docker-compose restart
```

**Out of memory?**
```bash
docker-compose stop misp misp-db wazuh
```

**No events?**
```bash
docker-compose restart data-generator
```

**Port conflict?**
```bash
# Edit docker-compose.yml
# Change port number (e.g., 3000:3000 → 3001:3000)
docker-compose up -d
```

## 🎓 Learning Outcomes Demonstrated
✅ AI-powered threat detection  
✅ Automated threat hunting  
✅ SOAR integration  
✅ Security analytics  
✅ Threat intelligence  
✅ Compliance automation  

---

**That's it!** You now have a fully functional AI-driven SOC running locally.

For detailed information, see README.md
For presentation help, see PRESENTATION_GUIDE.md
For problems, see TROUBLESHOOTING.md

**Good luck with your presentation! 🚀**
