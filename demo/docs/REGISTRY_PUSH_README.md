# Docker Image Registry Push Scripts

These scripts help you push your AI-SOC Docker images to Docker Hub or GitHub Container Registry.

## 📦 Available Scripts

1. **push-images.sh** - Interactive menu (RECOMMENDED)
2. **push-to-dockerhub.sh** - Docker Hub only
3. **push-to-github.sh** - GitHub Container Registry only

## 🚀 Quick Start (Easiest Method)

```bash
# Copy the script to your demo directory
cp push-images.sh ~/IntelliGuard-AI/demo/

# Make it executable
chmod +x ~/IntelliGuard-AI/demo/push-images.sh

# Run it
cd ~/IntelliGuard-AI/demo
./push-images.sh
```

Follow the interactive prompts!

## 📋 Prerequisites

### Before Running Any Script:

1. **Build your images first:**
   ```bash
   cd ~/IntelliGuard-AI/demo
   docker-compose build
   ```

2. **Create accounts:**
   - **Docker Hub**: https://hub.docker.com/signup
   - **GitHub**: Already have one (matx104)

### For Docker Hub:

- Docker Hub account username
- Docker Hub password (you'll enter it during `docker login`)

### For GitHub Container Registry:

1. **Create a Personal Access Token (PAT):**
   - Go to: https://github.com/settings/tokens
   - Click "Generate new token (classic)"
   - Give it a name: "AI-SOC Image Push"
   - Select scopes:
     - ✅ `write:packages`
     - ✅ `read:packages`
     - ✅ `delete:packages` (optional)
   - Click "Generate token"
   - **⚠️ Copy the token immediately** (you won't see it again!)

2. Save your token securely (use it in the script)

## 🎯 Option 1: Interactive Script (RECOMMENDED)

```bash
cd ~/IntelliGuard-AI/demo
./push-images.sh
```

**What it does:**
- Presents a menu with options
- Asks for your username(s)
- Guides you through the process
- Can push to Docker Hub, GitHub, or both

**Example interaction:**
```
Where do you want to push your images?
  1) Docker Hub (hub.docker.com)
  2) GitHub Container Registry (ghcr.io)
  3) Both
  4) Exit

Enter your choice (1-4): 1
Enter your Docker Hub username: matx104
Enter version tag (default: latest): v1.0

[Script proceeds to push images]
```

## 🎯 Option 2: Docker Hub Script

```bash
cd ~/IntelliGuard-AI/demo
./push-to-dockerhub.sh matx104
```

**What it pushes:**
- `matx104/ai-soc-ml-detector:latest`
- `matx104/ai-soc-threat-hunter:latest`
- `matx104/ai-soc-soar:latest`
- `matx104/ai-soc-data-generator:latest`

**View your images:**
https://hub.docker.com/u/matx104

## 🎯 Option 3: GitHub Container Registry Script

```bash
cd ~/IntelliGuard-AI/demo
./push-to-github.sh matx104
```

**What it does:**
- Asks for your GitHub Personal Access Token
- Pushes images to `ghcr.io/matx104/intelliguard-ai/`

**What it pushes:**
- `ghcr.io/matx104/intelliguard-ai/ai-soc-ml-detector:latest`
- `ghcr.io/matx104/intelliguard-ai/ai-soc-threat-hunter:latest`
- `ghcr.io/matx104/intelliguard-ai/ai-soc-soar:latest`
- `ghcr.io/matx104/intelliguard-ai/ai-soc-data-generator:latest`

**View your packages:**
https://github.com/matx104?tab=packages

## 📤 Making GitHub Packages Public

After pushing to GitHub, packages are private by default. To make them public:

1. Go to: https://github.com/matx104?tab=packages
2. Click on a package
3. Click "Package settings" (right side)
4. Scroll to "Danger Zone"
5. Click "Change visibility"
6. Select "Public"
7. Type the package name to confirm
8. Repeat for each package

## 🔄 Using Your Pushed Images

### Update docker-compose.yml to use registry images:

**For Docker Hub:**
```yaml
services:
  ml-threat-detector:
    image: matx104/ai-soc-ml-detector:latest
    # Remove build section
```

**For GitHub:**
```yaml
services:
  ml-threat-detector:
    image: ghcr.io/matx104/intelliguard-ai/ai-soc-ml-detector:latest
    # Remove build section
```

### Pull images on another machine:

**Docker Hub:**
```bash
docker pull matx104/ai-soc-ml-detector:latest
docker pull matx104/ai-soc-threat-hunter:latest
docker pull matx104/ai-soc-soar:latest
docker pull matx104/ai-soc-data-generator:latest
```

**GitHub:**
```bash
# Login first (if private packages)
echo YOUR_TOKEN | docker login ghcr.io -u matx104 --password-stdin

# Pull images
docker pull ghcr.io/matx104/intelliguard-ai/ai-soc-ml-detector:latest
docker pull ghcr.io/matx104/intelliguard-ai/ai-soc-threat-hunter:latest
docker pull ghcr.io/matx104/intelliguard-ai/ai-soc-soar:latest
docker pull ghcr.io/matx104/intelliguard-ai/ai-soc-data-generator:latest
```

## 🏷️ Versioning Your Images

To push with a specific version tag:

```bash
# Docker Hub
./push-to-dockerhub.sh matx104
# When prompted, enter version like: v1.0.0

# Or edit the script and change VERSION variable:
VERSION="v1.0.0"
```

This creates tags like:
- `matx104/ai-soc-ml-detector:v1.0.0`
- `matx104/ai-soc-ml-detector:latest` (also pushed)

## 🔒 Security Best Practices

1. **Never commit tokens to Git:**
   ```bash
   # Add to .gitignore
   echo "*.token" >> .gitignore
   echo ".env" >> .gitignore
   ```

2. **Use environment variables:**
   ```bash
   # Save token securely
   export GITHUB_TOKEN="ghp_your_token_here"
   
   # Use in script
   echo "$GITHUB_TOKEN" | docker login ghcr.io -u matx104 --password-stdin
   ```

3. **Rotate tokens regularly:**
   - Delete old tokens in GitHub settings
   - Generate new ones periodically

## 🐛 Troubleshooting

### "Image not found" error
```bash
# Build images first
cd ~/IntelliGuard-AI/demo
docker-compose build

# Verify images exist
docker images | grep demo
```

### "Permission denied" on Docker Hub
```bash
# Make sure you're logged in
docker login

# Try pushing one image manually
docker tag demo-ml-threat-detector matx104/ai-soc-ml-detector:latest
docker push matx104/ai-soc-ml-detector:latest
```

### "Invalid token" on GitHub
```bash
# Verify token has correct scopes:
# - write:packages
# - read:packages

# Create new token if needed:
# https://github.com/settings/tokens
```

### Rate limit errors
```bash
# Docker Hub free tier: 200 pulls per 6 hours
# Solution: Wait or upgrade to pro account

# Check rate limit
curl "https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull" | jq
```

## 📊 Image Sizes

Approximate sizes after push:
- ML Detector: ~450 MB
- Threat Hunter: ~380 MB
- SOAR Engine: ~250 MB
- Data Generator: ~220 MB

**Total: ~1.3 GB**

## 🎓 For Your Presentation

You can mention in your presentation:

> "The entire AI-SOC platform is containerized and available on Docker Hub/GitHub Container Registry. This means anyone can deploy it with a single command, making it truly portable and reproducible."

Show the Docker Hub/GitHub page during your demo to prove it's production-ready!

## 🔗 Quick Links

- **Your Docker Hub**: https://hub.docker.com/u/matx104
- **Your GitHub Packages**: https://github.com/matx104?tab=packages
- **Docker Hub Docs**: https://docs.docker.com/docker-hub/
- **GHCR Docs**: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry

## 💡 Pro Tips

1. **Tag images with multiple versions:**
   ```bash
   docker tag demo-ml-threat-detector matx104/ai-soc-ml-detector:latest
   docker tag demo-ml-threat-detector matx104/ai-soc-ml-detector:v1.0.0
   docker tag demo-ml-threat-detector matx104/ai-soc-ml-detector:stable
   ```

2. **Create a badge for your README:**
   ```markdown
   ![Docker Pulls](https://img.shields.io/docker/pulls/matx104/ai-soc-ml-detector)
   ```

3. **Automate with GitHub Actions:**
   - Push images automatically on git push
   - See: `.github/workflows/docker-publish.yml`

---

**Questions?** Check the main README.md or TROUBLESHOOTING.md in your demo folder.

**Ready to push?** Run `./push-images.sh` and follow the prompts! 🚀
