#!/bin/bash

echo "=================================="
echo "AI-Driven SOC Platform Destroyer"
echo "=================================="
echo ""
echo "⚠️  WARNING: This will permanently delete:"
echo "   • All containers from this stack"
echo "   • All volumes (including data)"
echo "   • All networks"
echo "   • All images used by this stack"
echo ""
echo "This action CANNOT be undone!"
echo ""

# Ask for confirmation
read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo ""
    echo "❌ Destruction cancelled. Your stack is safe."
    exit 0
fi

echo ""
echo "🛑 Starting destruction sequence..."
echo ""

# Stop and remove containers
echo "📦 Stopping and removing containers..."
docker-compose down

# Remove all containers from this project (even if not running)
echo ""
echo "🔍 Removing any remaining SOC containers..."
docker ps -a | grep 'soc-' | awk '{print $1}' | xargs -r docker rm -f

# Remove volumes
echo ""
echo "💾 Removing volumes..."
docker volume ls | grep 'soc\|es-data\|wazuh\|cassandra\|thehive\|cortex\|misp\|grafana\|ml-models\|portainer\|dockge' | awk '{print $2}' | xargs -r docker volume rm

# You can also use docker-compose down -v to remove volumes defined in compose file
echo ""
echo "🗑️  Removing Docker Compose volumes..."
docker-compose down -v 2>/dev/null

# Remove networks
echo ""
echo "🌐 Removing networks..."
docker network ls | grep 'soc-network' | awk '{print $1}' | xargs -r docker network rm

# Remove images
echo ""
echo "🖼️  Removing images..."
echo "   This may take a moment..."

# List of images used in the compose file
images=(
    "docker.elastic.co/elasticsearch/elasticsearch:8.11.0"
    "wazuh/wazuh:4.2.7"
    "cassandra:4.1"
    "strangebee/thehive:5.2"
    "thehiveproject/cortex:3.1.7"
    "mysql:8.0"
    "coolacid/misp-docker:core-latest"
    "grafana/grafana:latest"
    "portainer/portainer-ce:latest"
    "louislam/dockge:1"
)

for image in "${images[@]}"; do
    if docker images | grep -q "$image"; then
        echo "   Removing $image..."
        docker rmi -f "$image" 2>/dev/null
    fi
done

# Remove custom built images
echo ""
echo "🔨 Removing custom built images..."
docker images | grep 'soc-' | awk '{print $3}' | xargs -r docker rmi -f

# Clean up build cache
echo ""
echo "🧹 Cleaning up Docker build cache..."
docker builder prune -f

# Remove created directories (optional - commented out for safety)
echo ""
echo "📁 Created directories (NOT automatically removed for safety):"
echo "   • ./wazuh-config/"
echo "   • ./stacks/"
echo "   • ./thehive-config/"
echo "   • ./cortex-config/"
echo "   • ./grafana-config/"
echo "   • ./ml-service/"
echo "   • ./threat-hunting/"
echo "   • ./soar-automation/"
echo "   • ./data-generator/"
echo ""
echo "   To remove these manually, run:"
echo "   rm -rf ./wazuh-config ./stacks ./thehive-config ./cortex-config"
echo "   rm -rf ./grafana-config ./ml-service ./threat-hunting"
echo "   rm -rf ./soar-automation ./data-generator"

# Final cleanup
echo ""
echo "🧼 Running final Docker system cleanup..."
docker system prune -f

# Summary
echo ""
echo "=================================="
echo "✅ Destruction Complete!"
echo "=================================="
echo ""
echo "Summary of what was removed:"
echo "  ✓ All SOC containers stopped and removed"
echo "  ✓ All volumes deleted (data is gone)"
echo "  ✓ All networks removed"
echo "  ✓ All Docker images removed"
echo "  ✓ Build cache cleaned"
echo ""
echo "📝 Note: Configuration directories were preserved."
echo "   Delete them manually if needed (see above)."
echo ""
echo "To verify cleanup:"
echo "  docker ps -a | grep soc"
echo "  docker volume ls"
echo "  docker images"
echo ""
echo "=================================="
