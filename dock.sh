#!/bin/bash

# Define the username
USER_NAME="dockeruser"

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
