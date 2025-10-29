#!/bin/bash
echo "=================================="
echo "AI-Driven SOC POC Setup Script"
echo "=================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Docker and Docker Compose found"
echo ""

# Check available disk space
available_space=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$available_space" -lt 20 ]; then
    echo "⚠️  Warning: Less than 20GB disk space available"
    echo "   Available: ${available_space}GB"
    echo ""
fi

# Check available memory
total_mem=$(free -g | grep Mem | awk '{print $2}')
if [ "$total_mem" -lt 8 ]; then
    echo "⚠️  Warning: Less than 8GB RAM available"
    echo "   Available: ${total_mem}GB"
    echo ""
fi

echo "Starting AI-Driven SOC Platform..."
echo ""

# Create necessary directories
mkdir -p wazuh-config
mkdir -p stacks

# Pull images (optional, will happen anyway during up)
echo "📥 Pulling Docker images (this may take a few minutes)..."
docker-compose pull

# Start services
echo ""
echo "🚀 Starting services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to initialize (this may take 3-5 minutes)..."
sleep 30

# Check Elasticsearch
echo ""
echo "Checking Elasticsearch..."
for i in {1..12}; do
    if curl -s http://localhost:9200/_cluster/health > /dev/null 2>&1; then
        echo "✅ Elasticsearch is ready"
        break
    fi
    echo "   Waiting for Elasticsearch... ($i/12)"
    sleep 10
done

echo ""
echo "=================================="
echo "Setup Complete! 🎉"
echo "=================================="
echo ""
echo "🔐 Security & Management Tools:"
echo "  Portainer:      https://localhost:9443 (Create admin on first login)"
echo "  Dockge:         http://localhost:5001 (Compose stack manager)"
echo ""
echo "📊 SOC Platform Access:"
echo "  Grafana:        http://localhost:3000 (admin/admin)"
echo "  TheHive:        http://localhost:9000 (admin@thehive.local/secret)"
echo "  MISP:           http://localhost:8080 (admin@misp.local/admin_password)"
echo "  Cortex:         http://localhost:9001"
echo "  Elasticsearch:  http://localhost:9200"
echo ""
echo "🔧 Management Commands:"
echo "  Check status:   docker-compose ps"
echo "  View logs:      docker-compose logs -f [service_name]"
echo "  Stop platform:  docker-compose down"
echo "  Restart:        docker-compose restart [service_name]"
echo ""
echo "🔍 Quick Checks:"
echo "  Threat alerts:  curl http://localhost:9200/threat-alerts/_count?pretty"
echo "  ES health:      curl http://localhost:9200/_cluster/health?pretty"
echo ""
echo "💡 Pro Tips:"
echo "  • Use Portainer for easy container management and monitoring"
echo "  • Use Dockge to view and edit docker-compose stacks visually"
echo "  • Check container logs via Portainer or 'docker-compose logs'"
echo "  • Monitor resource usage in Portainer's dashboard"
echo ""
echo "📖 See README.md for detailed usage instructions"
echo "=================================="
