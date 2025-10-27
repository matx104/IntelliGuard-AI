# Troubleshooting Guide & FAQ

## 🔥 Common Issues

### Issue 1: Docker Compose Fails to Start

**Symptoms:**
- Error: "Cannot connect to Docker daemon"
- Services won't start

**Solutions:**
```bash
# Check if Docker is running
docker ps

# Start Docker service (Linux)
sudo systemctl start docker

# Start Docker Desktop (Mac/Windows)
# Open Docker Desktop application

# Check Docker Compose version
docker-compose --version
# Should be 1.29.0 or higher
```

---

### Issue 2: Port Already in Use

**Symptoms:**
- Error: "port is already allocated"
- Services fail to start

**Solutions:**
```bash
# Find what's using the port (example for port 9200)
sudo lsof -i :9200
# or
sudo netstat -tulpn | grep 9200

# Kill the process
sudo kill -9 <PID>

# Or change port in docker-compose.yml
# Example: Change 9200:9200 to 9201:9200
```

---

### Issue 3: Elasticsearch Won't Start

**Symptoms:**
- Container keeps restarting
- Health check fails

**Solutions:**
```bash
# Check logs
docker-compose logs elasticsearch

# Increase memory limit
# Edit docker-compose.yml:
# ES_JAVA_OPTS: "-Xms1g -Xmx1g"

# Fix max_map_count (Linux)
sudo sysctl -w vm.max_map_count=262144

# Make permanent
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

# Restart
docker-compose restart elasticsearch
```

---

### Issue 4: Out of Memory

**Symptoms:**
- Services crashing
- System slow/unresponsive
- Docker stats shows high memory usage

**Solutions:**
```bash
# Check current usage
docker stats

# Stop some services temporarily
docker-compose stop misp misp-db wazuh

# Or reduce Elasticsearch memory
# Edit docker-compose.yml:
# ES_JAVA_OPTS: "-Xms256m -Xmx256m"

# Restart services
docker-compose down && docker-compose up -d
```

---

### Issue 5: No Events in Elasticsearch

**Symptoms:**
- Queries return 0 results
- Dashboards empty

**Solutions:**
```bash
# Check if data generator is running
docker-compose ps data-generator

# Check logs
docker-compose logs data-generator

# Restart data generator
docker-compose restart data-generator

# Wait 1-2 minutes, then check
curl http://localhost:9200/security-events/_count?pretty

# If still 0, check Elasticsearch connectivity
docker-compose exec data-generator ping elasticsearch
```

---

### Issue 6: Services Stuck in "Starting" State

**Symptoms:**
- Services show "Starting" for >5 minutes
- Never reach "Up" state

**Solutions:**
```bash
# Check detailed logs
docker-compose logs <service-name>

# Check service dependencies
docker-compose ps

# Common issue: Elasticsearch not ready
# Solution: Wait for Elasticsearch first
curl http://localhost:9200/_cluster/health?pretty

# If timeout, restart Elasticsearch
docker-compose restart elasticsearch

# Then restart dependent services
docker-compose restart ml-threat-detector threat-hunter soar-automation
```

---

### Issue 7: Cannot Access Web UIs

**Symptoms:**
- Browser shows "Connection refused"
- Timeout errors

**Solutions:**
```bash
# Verify service is running
docker-compose ps

# Check if port is exposed
docker-compose port grafana 3000

# Test locally
curl http://localhost:3000

# Check firewall (Linux)
sudo ufw status
sudo ufw allow 3000/tcp

# Try 127.0.0.1 instead of localhost
http://127.0.0.1:3000

# Check Docker network
docker network inspect ai-soc-poc_soc-network
```

---

### Issue 8: High CPU Usage

**Symptoms:**
- System lag
- Fan running loud
- Docker using 100% CPU

**Solutions:**
```bash
# Identify culprit
docker stats

# Common causes and fixes:

# 1. Data generator too aggressive
# Edit data-generator/generate_events.py
# Increase sleep time: time.sleep(60)  # Instead of 10

# 2. ML model training too frequent
# Edit ml-service/threat_detector.py
# Increase sleep interval: time.sleep(300)  # Instead of 60

# 3. Too many services
# Stop non-essential services
docker-compose stop cortex misp misp-db

# Restart
docker-compose restart data-generator ml-threat-detector
```

---

### Issue 9: TheHive Won't Start

**Symptoms:**
- TheHive container exits
- "Database migration failed" error

**Solutions:**
```bash
# Check Cassandra is ready
docker-compose logs cassandra

# TheHive needs Cassandra to be fully initialized
# Wait 2-3 minutes after Cassandra starts

# Check if Elasticsearch is accessible
docker-compose exec thehive ping elasticsearch

# Restart TheHive
docker-compose restart thehive

# If still failing, clean start
docker-compose down -v
docker-compose up -d
```

---

### Issue 10: Disk Space Full

**Symptoms:**
- "No space left on device" error
- Services crashing

**Solutions:**
```bash
# Check disk usage
df -h

# Find large Docker objects
docker system df

# Clean up
docker system prune -a --volumes
# WARNING: This removes all unused data

# Or selectively clean
docker volume prune  # Remove unused volumes
docker image prune -a  # Remove unused images

# Monitor Elasticsearch index size
curl http://localhost:9200/_cat/indices?v

# Delete old indices if needed
curl -X DELETE http://localhost:9200/old-index-name
```

---

## ❓ Frequently Asked Questions

### General Questions

**Q: How long does it take to start?**
A: First startup: 5-10 minutes (downloading images). Subsequent startups: 2-3 minutes.

**Q: Can I run this on Windows?**
A: Yes, using Docker Desktop with WSL2 backend. Requires Windows 10/11 Pro or Enterprise.

**Q: Can I run this on Mac?**
A: Yes, using Docker Desktop for Mac. Works on both Intel and Apple Silicon (M1/M2).

**Q: How much internet data will it use?**
A: First setup downloads ~5-8 GB of Docker images. After that, minimal data usage.

**Q: Can I stop and restart without losing data?**
A: Yes! All data is stored in Docker volumes. Use `docker-compose down` (without -v flag) to preserve data.

---

### Technical Questions

**Q: Why is Elasticsearch health "yellow"?**
A: Yellow status is normal for single-node setup. It means primary shards are allocated but replicas aren't (because there's only one node). This is fine for POC.

**Q: How do I add my own security logs?**
A: You can send logs to Wazuh (port 1514) or directly to Elasticsearch. Configure your log source to send to `http://localhost:9200/security-events`.

**Q: Can I train the ML model on my own data?**
A: Yes! Replace the synthetic training data in `ml-service/threat_detector.py` with your real data. Ensure features match the expected format.

**Q: How do I add more MITRE ATT&CK techniques?**
A: Edit `threat-hunting/automated_hunter.py` and add to the `mitre_techniques` dictionary with corresponding detection queries.

**Q: Can I integrate with my existing SIEM?**
A: Yes! Configure your SIEM to forward events to Elasticsearch index `security-events`. The ML and hunting services will automatically process them.

**Q: How do I export data from Elasticsearch?**
A: Use the Elasticsearch API:
```bash
curl -X GET "http://localhost:9200/security-events/_search?pretty" > events.json
```

**Q: Can I add email notifications?**
A: Yes! Modify `soar-automation/soar_engine.py` to add SMTP email sending in the `send_notification` function.

**Q: How do I backup the data?**
A: Backup Docker volumes:
```bash
docker run --rm -v ai-soc-poc_es-data:/data -v $(pwd):/backup ubuntu tar czf /backup/es-backup.tar.gz /data
```

---

### Performance Questions

**Q: Why is everything so slow?**
A: Check resource allocation:
```bash
docker stats
```
Increase Docker Desktop memory/CPU limits in settings.

**Q: Can I reduce memory usage?**
A: Yes, edit `docker-compose.yml` and reduce ES_JAVA_OPTS values. Also stop non-essential services.

**Q: How many events can this handle?**
A: Current config: ~2000 events/hour. With proper resources: 100K+ events/hour.

**Q: Will this work on a laptop?**
A: Yes, minimum 8GB RAM and 4 CPU cores. Close other applications during demo.

---

### Security Questions

**Q: Is this production-ready?**
A: No, this is a POC/demo. For production, you need:
- Authentication on all services
- TLS/SSL encryption
- Secrets management
- High availability setup
- Regular backups
- Security hardening

**Q: Are the default passwords secure?**
A: No, they're meant for demo only. Change all passwords for any non-local deployment.

**Q: Can this be hacked?**
A: Yes, it's intentionally insecure for ease of demo. Never expose to internet without proper security configuration.

---

### Customization Questions

**Q: How do I change attack frequency?**
A: Edit `data-generator/generate_events.py`, modify the `attack_scenarios` dictionary percentages.

**Q: Can I add more playbooks?**
A: Yes, edit `soar-automation/soar_engine.py` and add to the `playbooks` dictionary.

**Q: How do I modify ML model parameters?**
A: Edit `ml-service/threat_detector.py`, change IsolationForest parameters (contamination, n_estimators, etc.).

**Q: Can I use different ML algorithms?**
A: Yes, replace Isolation Forest with any scikit-learn anomaly detection algorithm (One-Class SVM, LOF, etc.).

---

## 🔬 Advanced Troubleshooting

### Enable Debug Logging

Edit individual service Python files to increase logging:
```python
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
```

### Inspect Container Internals

```bash
# Enter container shell
docker-compose exec <service-name> /bin/bash

# Example: Check ML service
docker-compose exec ml-threat-detector /bin/bash
python -c "import sklearn; print(sklearn.__version__)"
```

### Network Debugging

```bash
# Test connectivity between containers
docker-compose exec ml-threat-detector ping elasticsearch

# Check DNS resolution
docker-compose exec ml-threat-detector nslookup elasticsearch

# Inspect network
docker network inspect ai-soc-poc_soc-network
```

### Elasticsearch Debugging

```bash
# Cluster info
curl http://localhost:9200/

# Node stats
curl http://localhost:9200/_nodes/stats?pretty

# Indices stats
curl http://localhost:9200/_cat/indices?v

# Specific index info
curl http://localhost:9200/security-events?pretty

# Force refresh
curl -X POST http://localhost:9200/_refresh

# Clear cache
curl -X POST http://localhost:9200/_cache/clear
```

### Service Health Checks

```bash
# Check all services
docker-compose ps

# Detailed service info
docker inspect ai-soc-poc_elasticsearch

# Resource usage
docker stats --no-stream

# Logs with timestamps
docker-compose logs --timestamps --tail=100 elasticsearch
```

---

## 📞 Getting Help

If you can't resolve an issue:

1. **Check logs first:**
   ```bash
   docker-compose logs <service-name>
   ```

2. **Search for error messages:**
   - Google the exact error message
   - Check Stack Overflow
   - Search GitHub issues for the specific tool

3. **Collect diagnostic info:**
   ```bash
   docker version
   docker-compose version
   docker-compose ps
   docker stats --no-stream
   df -h
   free -h
   ```

4. **Try clean restart:**
   ```bash
   docker-compose down -v
   docker-compose up -d
   ```

5. **Community resources:**
   - Wazuh Forum: https://groups.google.com/g/wazuh
   - TheHive Forum: https://chat.thehive-project.org/
   - Elasticsearch Forum: https://discuss.elastic.co/

---

## 🎯 Pro Tips

1. **Monitor resources during demo:**
   ```bash
   watch -n 2 docker stats
   ```

2. **Pre-pull images before presentation:**
   ```bash
   docker-compose pull
   ```

3. **Have a backup plan:**
   - Take screenshots of working system
   - Record a video of successful demo
   - Keep detailed slides as fallback

4. **Test everything beforehand:**
   - Run full demo at least twice
   - Note timing for each section
   - Identify potential failure points

5. **Keep it simple:**
   - Don't try to show everything
   - Focus on key features
   - Have a clear narrative

---

## ✅ Pre-Presentation Checklist

- [ ] All services running (`docker-compose ps`)
- [ ] Elasticsearch healthy (`curl localhost:9200/_cluster/health`)
- [ ] Events being generated (`curl localhost:9200/security-events/_count`)
- [ ] Threats detected (`curl localhost:9200/threat-alerts/_count`)
- [ ] Playbooks executed (`curl localhost:9200/playbook-executions/_count`)
- [ ] Grafana accessible (http://localhost:3000)
- [ ] TheHive accessible (http://localhost:9000)
- [ ] Terminal commands prepared in text file
- [ ] Screenshots taken as backup
- [ ] System resources adequate (memory, CPU, disk)
- [ ] No other resource-intensive apps running
- [ ] Internet connection stable (if needed)
- [ ] Presentation slides ready
- [ ] Time allocation practiced

---

**Remember:** Technical issues happen to everyone. How you handle them shows your problem-solving skills. Stay calm, explain what you're doing, and have backup options ready!
