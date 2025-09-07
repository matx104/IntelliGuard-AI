#!/bin/bash
# IntelliGuard-AI Directory Structure Setup Script

# Create main directories
mkdir -p docs/{architecture,deployment,presentation}
mkdir -p configs/{wazuh/{rules,decoders},grafana/{dashboards,datasources},prometheus,shuffle/workflows,cortex/analyzers,thehive/case-templates,dfir-iris/playbooks}
mkdir -p scripts/{deployment,automation,maintenance}
mkdir -p assets/{images,diagrams,screenshots}
mkdir -p resources/{threat-intelligence,playbooks}
mkdir -p examples/{use-cases,sample-alerts,demo-scenarios}

# Create init.txt files in all directories
find docs configs scripts assets resources examples -type d -exec sh -c 'echo "BISMILLAH!" > "$1/init.txt"' _ {} \;

echo "Directory structure created successfully!"
echo "All directories now contain init.txt files with 'BISMILLAH!'"
