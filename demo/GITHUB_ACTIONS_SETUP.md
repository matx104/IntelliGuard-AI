# GitHub Actions Automatic Image Building

This workflow automatically builds and pushes your Docker images to GitHub Container Registry whenever you push code to the `main` branch.

## 🎯 Setup Instructions

### 1. Create Workflows Directory

```bash
cd ~/IntelliGuard-AI
mkdir -p .github/workflows
```

### 2. Copy the Workflow File

```bash
cp docker-publish.yml .github/workflows/
```

### 3. Commit and Push

```bash
git add .github/workflows/docker-publish.yml
git commit -m "Add automated Docker image building workflow"
git push origin main
```

### 4. Watch It Work! 🎉

1. Go to your GitHub repository: https://github.com/matx104/IntelliGuard-AI
2. Click on the "Actions" tab
3. You should see "Build and Push Docker Images" workflow running
4. Wait for it to complete (~5-10 minutes)

## ✅ What This Does

**Automatically triggers when:**
- You push to the `main` branch
- You modify files in the `demo/` directory
- You manually trigger it (via Actions tab)

**Builds and pushes:**
- `ghcr.io/matx104/intelliguard-ai/ai-soc-ml-detector:latest`
- `ghcr.io/matx104/intelliguard-ai/ai-soc-threat-hunter:latest`
- `ghcr.io/matx104/intelliguard-ai/ai-soc-soar:latest`
- `ghcr.io/matx104/intelliguard-ai/ai-soc-data-generator:latest`

## 🎨 Features

- ✅ **Automatic builds** on every push
- ✅ **Multiple tags**: latest, branch name, commit SHA
- ✅ **Build caching** for faster builds
- ✅ **Matrix builds** (parallel, faster)
- ✅ **Summary report** after completion

## 📦 View Your Published Images

After the workflow completes:

1. Go to: https://github.com/matx104?tab=packages
2. You'll see all 4 images
3. Click any image to see versions and details

## 🔓 Making Packages Public

By default, packages are private. To make them public:

1. Go to https://github.com/matx104?tab=packages
2. Click on a package
3. Click "Package settings" (right sidebar)
4. Scroll to "Danger Zone"
5. Click "Change visibility"
6. Select "Public"
7. Confirm by typing the package name
8. Repeat for each package

## 🔄 Manual Trigger

To manually trigger the workflow:

1. Go to: https://github.com/matx104/IntelliGuard-AI/actions
2. Click "Build and Push Docker Images"
3. Click "Run workflow" (top right)
4. Select branch: `main`
5. Click "Run workflow"

## 🎯 Using Auto-Built Images

Once images are published, update your `docker-compose.yml`:

```yaml
services:
  ml-threat-detector:
    image: ghcr.io/matx104/intelliguard-ai/ai-soc-ml-detector:latest
    # Remove the build: section
    environment:
      - ES_HOST=elasticsearch
      - ES_PORT=9200
    # ... rest of config

  threat-hunter:
    image: ghcr.io/matx104/intelliguard-ai/ai-soc-threat-hunter:latest
    # Remove the build: section
    # ... rest of config

  # ... repeat for other services
```

Then anyone can run your project without building:

```bash
git clone https://github.com/matx104/IntelliGuard-AI.git
cd IntelliGuard-AI/demo
docker-compose pull  # Download pre-built images
docker-compose up -d # Start immediately!
```

## 📊 Workflow Status Badge

Add a status badge to your README.md:

```markdown
![Docker Build](https://github.com/matx104/IntelliGuard-AI/actions/workflows/docker-publish.yml/badge.svg)
```

This shows if your builds are passing or failing.

## 🐛 Troubleshooting

### Workflow fails with "permission denied"

**Solution:** The workflow uses `GITHUB_TOKEN` automatically. No extra setup needed!

### Images not appearing in packages

**Solution:** 
1. Check if workflow completed successfully
2. Go to Actions tab and review logs
3. Ensure `demo/` directory structure is correct

### Build takes too long

**Solution:** Workflow uses build caching. First build is slow, subsequent builds are faster.

### "No space left on device"

**Solution:** GitHub Actions runners have limited space. This is rare, but if it happens:
1. Reduce image sizes
2. Remove unnecessary dependencies
3. Use multi-stage Docker builds

## 🎓 For Your Presentation

You can mention:

> "The project uses CI/CD with GitHub Actions. Every code push automatically builds and publishes Docker images, demonstrating modern DevOps practices and making deployment completely automated."

## 🔒 Security Notes

- The workflow uses GitHub's built-in `GITHUB_TOKEN`
- No need to create or store personal access tokens
- Tokens are automatically scoped to the repository
- Images are signed and verified

## 💡 Advanced: Version Tags

The workflow automatically creates multiple tags:

- `latest` - Always the newest build from main
- `main-abc123` - Branch name + commit SHA
- `v1.0.0` - Semantic versioning (if you tag releases)

Example:
```bash
# Latest version
docker pull ghcr.io/matx104/intelliguard-ai/ai-soc-ml-detector:latest

# Specific commit
docker pull ghcr.io/matx104/intelliguard-ai/ai-soc-ml-detector:main-abc1234

# Specific version (if tagged)
docker pull ghcr.io/matx104/intelliguard-ai/ai-soc-ml-detector:v1.0.0
```

## 📈 Benefits Over Manual Push

| Manual | GitHub Actions |
|--------|----------------|
| Build on your machine | Build on GitHub servers |
| Manual push each time | Automatic on every commit |
| Depends on your internet | GitHub's fast network |
| Can forget to push | Never forget - it's automatic |
| Single version | Multiple version tags |
| No build history | Full build logs in Actions |

## ✨ Next Steps

After setting this up:

1. Make a small change to your code
2. Commit and push
3. Watch GitHub Actions build your images automatically
4. Check your packages page to see the new images

## 🎉 That's It!

You now have:
- ✅ Automated image building
- ✅ Automatic publishing to registry
- ✅ Version tagging
- ✅ Build caching
- ✅ Professional CI/CD pipeline

Your AI-SOC project is now fully automated! 🚀

---

**Questions?** Check the main README.md or open an issue on GitHub.
