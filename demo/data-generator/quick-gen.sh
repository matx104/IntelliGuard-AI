#!/bin/bash

set -e  # Exit on error

echo "=================================================="
echo "Quick Bulk Event Generator"
echo "=================================================="

# Install dependencies (using --break-system-packages for Ubuntu 24.04)
echo ""
echo "📦 Installing Python dependencies..."
pip3 install elasticsearch faker --break-system-packages 2>/dev/null || pip3 install elasticsearch faker --user

# Check if bulk_event_generator.py exists
if [ ! -f "bulk_event_generator.py" ]; then
    echo "❌ Error: bulk_event_generator.py not found in current directory"
    exit 1
fi

# Check Elasticsearch connection
echo ""
echo "🔍 Checking Elasticsearch connection..."
if python3 -c "from elasticsearch import Elasticsearch; es = Elasticsearch(['http://elasticsearch:9200']); print('✓ Connected' if es.ping() else '✗ Failed')" 2>/dev/null; then
    :
else
    echo "⚠️  Warning: Cannot connect to Elasticsearch at elasticsearch:9200"
fi

# Run generator with menu
echo ""
echo "=================================================="
echo "🚀 Bulk Event Generation Options"
echo "=================================================="
echo ""
echo "1) 500 events per type (default)"
echo "2) 1000 events per type"
echo "3) 5000 events per type"
echo "4) 10000 events per type (LARGE)"
echo ""
read -p "Enter choice [1-4] or press Enter for default: " choice

case $choice in
    2)
        python3 bulk_event_generator.py --count 1000
        ;;
    3)
        python3 bulk_event_generator.py --count 5000
        ;;
    4)
        python3 bulk_event_generator.py --count 10000
        ;;
    *)
        python3 bulk_event_generator.py --count 500
        ;;
esac

echo ""
echo "✅ Done! Check your Grafana dashboard."
