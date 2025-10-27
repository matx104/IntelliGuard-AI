#!/bin/bash

# AI-SOC Image Registry Push Script
# Supports both Docker Hub and GitHub Container Registry

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════╗
║   AI-SOC Image Registry Push Tool        ║
║   Push your Docker images to registry    ║
╚═══════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Menu
echo -e "${YELLOW}Where do you want to push your images?${NC}"
echo ""
echo "  1) Docker Hub (hub.docker.com)"
echo "  2) GitHub Container Registry (ghcr.io)"
echo "  3) Both"
echo "  4) Exit"
echo ""
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        REGISTRY="dockerhub"
        ;;
    2)
        REGISTRY="github"
        ;;
    3)
        REGISTRY="both"
        ;;
    4)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

# Get username
echo ""
if [ "$REGISTRY" = "dockerhub" ] || [ "$REGISTRY" = "both" ]; then
    read -p "Enter your Docker Hub username: " DOCKERHUB_USERNAME
fi

if [ "$REGISTRY" = "github" ] || [ "$REGISTRY" = "both" ]; then
    read -p "Enter your GitHub username: " GITHUB_USERNAME
fi

echo ""

# Version tag
read -p "Enter version tag (default: latest): " VERSION
VERSION=${VERSION:-latest}

echo ""
echo -e "${GREEN}Configuration:${NC}"
[ ! -z "$DOCKERHUB_USERNAME" ] && echo -e "  Docker Hub: ${YELLOW}${DOCKERHUB_USERNAME}${NC}"
[ ! -z "$GITHUB_USERNAME" ] && echo -e "  GitHub: ${YELLOW}${GITHUB_USERNAME}${NC}"
echo -e "  Version: ${YELLOW}${VERSION}${NC}"
echo ""

# Define images
declare -A IMAGES=(
    ["demo-ml-threat-detector"]="ai-soc-ml-detector"
    ["demo-threat-hunter"]="ai-soc-threat-hunter"
    ["demo-soar-automation"]="ai-soc-soar"
    ["demo-data-generator"]="ai-soc-data-generator"
)

# Function to push to Docker Hub
push_to_dockerhub() {
    echo -e "${BLUE}══════════════════════════════════════${NC}"
    echo -e "${BLUE}  Pushing to Docker Hub${NC}"
    echo -e "${BLUE}══════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${YELLOW}Logging in to Docker Hub...${NC}"
    docker login
    echo ""
    
    for LOCAL_IMAGE in "${!IMAGES[@]}"; do
        REMOTE_IMAGE="${IMAGES[$LOCAL_IMAGE]}"
        FULL_REMOTE="${DOCKERHUB_USERNAME}/${REMOTE_IMAGE}:${VERSION}"
        
        if ! docker image inspect "${LOCAL_IMAGE}" >/dev/null 2>&1; then
            echo -e "${RED}✗ ${LOCAL_IMAGE} not found locally${NC}"
            continue
        fi
        
        echo -e "${CYAN}Pushing ${LOCAL_IMAGE}...${NC}"
        docker tag "${LOCAL_IMAGE}" "${FULL_REMOTE}"
        docker push "${FULL_REMOTE}"
        echo -e "${GREEN}✓ Pushed ${FULL_REMOTE}${NC}"
        echo ""
    done
}

# Function to push to GitHub
push_to_github() {
    echo -e "${BLUE}══════════════════════════════════════${NC}"
    echo -e "${BLUE}  Pushing to GitHub Container Registry${NC}"
    echo -e "${BLUE}══════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${YELLOW}Enter your GitHub Personal Access Token:${NC}"
    echo -e "${BLUE}(Create at: https://github.com/settings/tokens)${NC}"
    echo -e "${BLUE}Required scopes: write:packages, read:packages${NC}"
    echo ""
    read -p "Token: " -s GITHUB_TOKEN
    echo ""
    
    if [ -z "$GITHUB_TOKEN" ]; then
        echo -e "${RED}Error: Token cannot be empty${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Logging in to ghcr.io...${NC}"
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_USERNAME" --password-stdin
    echo ""
    
    for LOCAL_IMAGE in "${!IMAGES[@]}"; do
        REMOTE_IMAGE="${IMAGES[$LOCAL_IMAGE]}"
        FULL_REMOTE="ghcr.io/${GITHUB_USERNAME}/intelliguard-ai/${REMOTE_IMAGE}:${VERSION}"
        
        if ! docker image inspect "${LOCAL_IMAGE}" >/dev/null 2>&1; then
            echo -e "${RED}✗ ${LOCAL_IMAGE} not found locally${NC}"
            continue
        fi
        
        echo -e "${CYAN}Pushing ${LOCAL_IMAGE}...${NC}"
        docker tag "${LOCAL_IMAGE}" "${FULL_REMOTE}"
        docker push "${FULL_REMOTE}"
        echo -e "${GREEN}✓ Pushed ${FULL_REMOTE}${NC}"
        echo ""
    done
}

# Execute based on choice
case $REGISTRY in
    dockerhub)
        push_to_dockerhub
        ;;
    github)
        push_to_github
        ;;
    both)
        push_to_dockerhub
        echo ""
        push_to_github
        ;;
esac

echo ""
echo -e "${GREEN}══════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ All images pushed successfully!${NC}"
echo -e "${GREEN}══════════════════════════════════════${NC}"
echo ""

# Show pull commands
if [ "$REGISTRY" = "dockerhub" ] || [ "$REGISTRY" = "both" ]; then
    echo -e "${YELLOW}Docker Hub images:${NC}"
    echo -e "  View at: https://hub.docker.com/u/${DOCKERHUB_USERNAME}"
    echo ""
    echo -e "  Pull commands:"
    for LOCAL_IMAGE in "${!IMAGES[@]}"; do
        REMOTE_IMAGE="${IMAGES[$LOCAL_IMAGE]}"
        echo "    docker pull ${DOCKERHUB_USERNAME}/${REMOTE_IMAGE}:${VERSION}"
    done
    echo ""
fi

if [ "$REGISTRY" = "github" ] || [ "$REGISTRY" = "both" ]; then
    echo -e "${YELLOW}GitHub Container Registry images:${NC}"
    echo -e "  View at: https://github.com/${GITHUB_USERNAME}?tab=packages"
    echo ""
    echo -e "  ${BLUE}Remember to make packages public in GitHub settings!${NC}"
    echo ""
    echo -e "  Pull commands:"
    for LOCAL_IMAGE in "${!IMAGES[@]}"; do
        REMOTE_IMAGE="${IMAGES[$LOCAL_IMAGE]}"
        echo "    docker pull ghcr.io/${GITHUB_USERNAME}/intelliguard-ai/${REMOTE_IMAGE}:${VERSION}"
    done
    echo ""
fi

echo -e "${GREEN}Done!${NC}"
