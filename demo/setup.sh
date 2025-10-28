#!/bin/bash

echo "=================================="
echo "AI-Driven SOC POC Setup Script"
echo "=================================="
echo ""

# Define the username
USER_NAME="ubuntu"

# Update package index
echo "Updating package index..."
sudo apt-get update -y

# Install dependencies
echo "Installing required dependencies..."
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y

# Add Docker's official GPG key
echo "Adding Docker's official GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Set up the stable repository
echo "Setting up the Docker stable repository..."
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update package index again
echo "Updating package index again..."
sudo apt-get update -y

# Install Docker CE (Community Edition)
echo "Installing Docker CE..."
sudo apt-get install docker-ce -y

# Start Docker service and enable it to start on boot
echo "Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Verify Docker installation
echo "Verifying Docker installation..."
sudo docker --version

# Install Docker Compose
echo "Installing Docker Compose..."
DOCKER_COMPOSE_VERSION="1.29.2"
sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Set executable permission for Docker Compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify Docker Compose installation
echo "Verifying Docker Compose installation..."
docker-compose --version

# Create a new user (if doesn't already exist)
if id "$USER_NAME" &>/dev/null; then
    echo "User $USER_NAME already exists."
else
    echo "Creating user $USER_NAME..."
    sudo useradd -m $USER_NAME
    sudo passwd $USER_NAME
fi

# Add user to the Docker group to run Docker without sudo
echo "Adding $USER_NAME to the Docker group..."
sudo usermod -aG docker $USER_NAME

# Restart Docker service to apply changes
echo "Restarting Docker service..."
sudo systemctl restart docker

groups $USER
sudo usermod -aG docker $USER
newgrp docker

# Final message
echo "Docker and Docker Compose have been installed successfully, and $USER_NAME has been added to the Docker group!"
echo "You may need to log out and log back in for group changes to take effect."

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
echo "Access URLs:"
echo "  Grafana:        http://localhost:3000 (admin/admin)"
echo "  TheHive:        http://localhost:9000 (admin@thehive.local/secret)"
echo "  MISP:           http://localhost:8080 (admin@misp.local/admin_password)"
echo "  Elasticsearch:  http://localhost:9200"
echo ""
echo "Check status:"
echo "  docker-compose ps"
echo ""
echo "View logs:"
echo "  docker-compose logs -f"
echo ""
echo "Check for threats detected:"
echo "  curl http://localhost:9200/threat-alerts/_count?pretty"
echo ""
echo "Stop the platform:"
echo "  docker-compose down"
echo ""
echo "📖 See README.md for detailed usage instructions"
echo "=================================="
