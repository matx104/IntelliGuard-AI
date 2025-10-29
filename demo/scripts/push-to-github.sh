#!/bin/bash

# Script to tag and push AI-SOC images to GitHub Container Registry
# Usage: ./push-to-github.sh <your-github-username>

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if username provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: GitHub username required${NC}"
    echo "Usage: ./push-to-github.sh <your-github-username>"
    echo "Example: ./push-to-github.sh matx104"
    exit 1
fi

GITHUB_USERNAME="$1"
VERSION="latest"  # Change this if you want specific version tags

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  GitHub Container Registry Push${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "GitHub Username: ${YELLOW}${GITHUB_USERNAME}${NC}"
echo -e "Version Tag: ${YELLOW}${VERSION}${NC}"
echo ""

# Check if GitHub token is available
echo -e "${YELLOW}Step 1: Authenticating with GitHub Container Registry...${NC}"
echo ""
echo -e "${BLUE}You need a GitHub Personal Access Token (PAT) with 'write:packages' scope${NC}"
echo -e "${BLUE}To create one:${NC}"
echo -e "  1. Go to: ${YELLOW}https://github.com/settings/tokens${NC}"
echo -e "  2. Click 'Generate new token (classic)'"
echo -e "  3. Select scope: ${YELLOW}write:packages${NC} and ${YELLOW}read:packages${NC}"
echo -e "  4. Copy the token"
echo ""
read -p "Enter your GitHub Personal Access Token: " -s GITHUB_TOKEN
echo ""

if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}Error: Token cannot be empty${NC}"
    exit 1
fi

# Login to GitHub Container Registry
echo -e "${YELLOW}Logging in to ghcr.io...${NC}"
echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_USERNAME" --password-stdin

echo ""
echo -e "${GREEN}✓ Login successful${NC}"
echo ""

# Define images
declare -A IMAGES=(
    ["demo-ml-threat-detector"]="intelliguard-ai/ml-detector"
    ["demo-threat-hunter"]="intelliguard-ai/threat-hunter"
    ["demo-soar-automation"]="intelliguard-ai/soar-engine"
    ["demo-data-generator"]="intelliguard-ai/data-generator"
)

# Tag and push each image
for LOCAL_IMAGE in "${!IMAGES[@]}"; do
    REMOTE_IMAGE="${IMAGES[$LOCAL_IMAGE]}"
    FULL_REMOTE="ghcr.io/${GITHUB_USERNAME}/${REMOTE_IMAGE}:${VERSION}"
    
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
echo -e "${YELLOW}https://github.com/${GITHUB_USERNAME}?tab=packages${NC}"
echo ""
echo -e "${BLUE}Note: Make sure to set packages to 'Public' in GitHub settings if you want others to pull them${NC}"
echo -e "Go to each package → Package settings → Change visibility → Public"
echo ""
echo -e "To pull these images on another machine:"
for LOCAL_IMAGE in "${!IMAGES[@]}"; do
    REMOTE_IMAGE="${IMAGES[$LOCAL_IMAGE]}"
    echo "  docker pull ghcr.io/${GITHUB_USERNAME}/${REMOTE_IMAGE}:${VERSION}"
done
echo ""
