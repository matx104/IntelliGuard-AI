# AI-Driven SOC Platform - Quick Start Guide

## What's New in This Update

✨ **Container Management Tools Added:**
- **Portainer** - Web-based container management UI (https://localhost:9443)
- **Dockge** - Docker Compose stack manager (http://localhost:5001)

## Files Included

1. **docker-compose.yml** - Complete stack configuration with all services
2. **setup.sh** - Automated setup script
3. **destroy.sh** - Complete cleanup and removal script

## Quick Start

### 1. Make Scripts Executable
```bash
chmod +x setup.sh destroy.sh
```

### 2. Start the Platform
```bash
./setup.sh
```

This will:
- Check system requirements
- Pull all Docker images
- Start all services
- Wait for initialization
- Display access URLs

### 3. Access the Platform

**Container Management:**
- Portainer: https://localhost:9443 (Create admin on first visit)
- Dockge: http://localhost:5001

**SOC Tools:**
- Grafana: http://localhost:3000 (admin/admin)
- TheHive: http://localhost:9000 (admin@thehive.local/secret)
- MISP: http://localhost:8080 (admin@misp.local/admin_password)
- Cortex: http://localhost:9001
- Elasticsearch: http://localhost:9200

## Portainer First-Time Setup

1. Navigate to https://localhost:9443
2. Accept the self-signed certificate warning
3. Create your admin username and password
4. Select "Docker" as your environment
5. Connect to the local Docker environment
6. You'll see all your SOC containers!

## Dockge Features

- View and manage your docker-compose stack visually
- Edit compose files through the UI
- Start/stop/restart services
- View real-time logs
- Monitor resource usage

## Management Commands

```bash
# View all containers
docker-compose ps

# View logs for all services
docker-compose logs -f

# View logs for specific service
docker-compose logs -f portainer

# Restart a service
docker-compose restart grafana

# Stop the platform (keeps data)
docker-compose down

# Stop and remove volumes (deletes data)
docker-compose down -v
```

## Complete Removal

### ⚠️ WARNING: This deletes EVERYTHING permanently!

```bash
./destroy.sh
```

This script will:
1. Stop all containers
2. Remove all containers
3. Delete all volumes (including data)
4. Remove all networks
5. Delete all Docker images
6. Clean up build cache

**Type 'yes' when prompted to confirm destruction.**

## System Requirements

- **Minimum:**
  - 8GB RAM
  - 20GB free disk space
  - Docker & Docker Compose installed

- **Recommended:**
  - 16GB RAM
  - 50GB free disk space
  - SSD storage

## Port Usage

| Service | Port(s) | Protocol |
|---------|---------|----------|
| Elasticsearch | 9200 | HTTP |
| Wazuh | 1514, 1515, 514, 55000 | UDP/TCP |
| TheHive | 9000 | HTTP |
| Cortex | 9001 | HTTP |
| MISP | 8080, 8443 | HTTP/HTTPS |
| Grafana | 3000 | HTTP |
| Portainer | 9443, 8000 | HTTPS/HTTP |
| Dockge | 5001 | HTTP |

## Troubleshooting

### Services not starting?
```bash
# Check logs
docker-compose logs [service-name]

# Check resource usage
docker stats
```

### Elasticsearch fails to start?
```bash
# Increase virtual memory
sudo sysctl -w vm.max_map_count=262144

# Make it permanent
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
```

### Port conflicts?
Edit the port mappings in `docker-compose.yml` before running setup.

### Need to reset everything?
```bash
./destroy.sh
./setup.sh
```

## Useful Portainer Features

- **Dashboard**: Overview of all containers, images, volumes
- **Containers**: Start, stop, restart, view logs, exec into containers
- **Images**: Manage Docker images
- **Volumes**: Browse and manage data volumes
- **Networks**: View network topology
- **Events**: Real-time Docker events
- **Stacks**: Manage docker-compose stacks

## Useful Dockge Features

- **Visual Editing**: Edit docker-compose files with syntax highlighting
- **Service Control**: One-click start/stop/restart for services
- **Log Viewer**: Real-time logs with search and filter
- **Terminal Access**: Execute commands inside containers
- **Health Monitoring**: See container health status at a glance

## Support

For issues or questions:
1. Check logs: `docker-compose logs -f`
2. Check container status: `docker-compose ps`
3. Use Portainer to inspect containers and logs
4. Verify system resources: `docker stats`

## Security Notes

🔒 **Important:** 
- Change default passwords immediately
- This setup is for POC/testing only
- Not recommended for production without proper security hardening
- Portainer admin credentials should be strong
- Consider using secrets management for production

---

**Happy SOC Building! 🛡️**
