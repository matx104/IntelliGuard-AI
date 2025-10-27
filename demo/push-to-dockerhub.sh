#!/bin/bash

# Script to tag and push AI-SOC images to Docker Hub
# Usage: ./push-to-dockerhub.sh <your-dockerhub-username>

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if username provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Docker Hub username required${NC}"
    echo "Usage: ./push-to-dockerhub.sh <your-dockerhub-username>"
    echo "Example: ./push-to-dockerhub.sh matx104"
    exit 1
fi

DOCKERHUB_USERNAME="$1"
VERSION="latest"  # Change this if you want specific version tags

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Docker Hub Image Push Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Docker Hub Username: ${YELLOW}${DOCKERHUB_USERNAME}${NC}"
echo -e "Version Tag: ${YELLOW}${VERSION}${NC}"
echo ""

# Login to Docker Hub
echo -e "${YELLOW}Step 1: Logging in to Docker Hub...${NC}"
docker login

echo ""
echo -e "${GREEN}✓ Login successful${NC}"
echo ""

# Define images
declare -A IMAGES=(
    ["demo-ml-threat-detector"]="ai-soc-ml-detector"
    ["demo-threat-hunter"]="ai-soc-threat-hunter"
    ["demo-soar-automation"]="ai-soc-soar"
    ["demo-data-generator"]="ai-soc-data-generator"
)

# Tag and push each image
for LOCAL_IMAGE in "${!IMAGES[@]}"; do
    REMOTE_IMAGE="${IMAGES[$LOCAL_IMAGE]}"
    FULL_REMOTE="${DOCKERHUB_USERNAME}/${REMOTE_IMAGE}:${VERSION}"
    
    echo -e "${YELLOW}Processing: ${LOCAL_IMAGE}${NC}"
    
    # Check if local image exists
    if ! docker image inspect "${LOCAL_IMAGE}" >/dev/null 2>&1; then
        echo -e "${RED}  ✗ Local image '${LOCAL_IMAGE}' not found. Build it first!${NC}"
        continue
    fi
    
    # Tag the image
    echo -e "  Tagging: ${LOCAL_IMAGE} → ${FULL_REMOTE}"
    docker tag "${LOCAL_IMAGE}" "${FULL_REMOTE}"
    
    # Push the image
    echo -e "  Pushing: ${FULL_REMOTE}"
    docker push "${FULL_REMOTE}"
    
    echo -e "${GREEN}  ✓ Successfully pushed ${FULL_REMOTE}${NC}"
    echo ""
done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  All images pushed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Your images are now available at:"
echo -e "${YELLOW}https://hub.docker.com/u/${DOCKERHUB_USERNAME}${NC}"
echo ""
echo -e "To pull these images on another machine:"
for LOCAL_IMAGE in "${!IMAGES[@]}"; do
    REMOTE_IMAGE="${IMAGES[$LOCAL_IMAGE]}"
    echo "  docker pull ${DOCKERHUB_USERNAME}/${REMOTE_IMAGE}:${VERSION}"
done
echo ""
