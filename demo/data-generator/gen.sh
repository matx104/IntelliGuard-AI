#!/bin/bash

set -e  # Exit on error

echo "=================================================="
echo "Bulk Security Event Generator Setup & Execution"
echo "=================================================="

# Check if running as root for system packages
if [ "$EUID" -ne 0 ]; then 
    echo "⚠️  This script needs sudo privileges to install system packages"
    echo "Please run with: sudo ./generate_bulk_events.sh"
    exit 1
fi

# Step 1: Install system dependencies
echo ""
echo "📦 Step 1: Installing system dependencies..."
apt update
apt install python3-pip python3-venv -y

# Step 2: Create virtual environment
echo ""
echo "🐍 Step 2: Setting up Python virtual environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "✓ Virtual environment created"
else
    echo "✓ Virtual environment already exists"
fi

# Step 3: Activate virtual environment and install Python packages
echo ""
echo "📚 Step 3: Installing Python packages..."
source venv/bin/activate
pip install --upgrade pip
pip install elasticsearch faker

# Step 4: Check Elasticsearch connection
echo ""
echo "🔍 Step 4: Checking Elasticsearch connection..."
if curl -s http://localhost:9200 > /dev/null 2>&1; then
    echo "✓ Elasticsearch is accessible at localhost:9200"
elif curl -s http://elasticsearch:9200 > /dev/null 2>&1; then
    echo "✓ Elasticsearch is accessible at elasticsearch:9200"
else
    echo "⚠️  Warning: Cannot connect to Elasticsearch"
    echo "Make sure Elasticsearch is running before generating events"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Step 5: Run bulk event generator
echo ""
echo "=================================================="
echo "🚀 Starting Bulk Event Generation"
echo "=================================================="
echo ""
echo "Choose an option:"
echo "1) Generate 500 events per type (default - 24 hours)"
echo "2) Generate 1000 events per type (24 hours)"
echo "3) Generate 500 events per type (6 hours)"
echo "4) Generate 10000 events per type (24 hours) - LARGE DATASET"
echo "5) Custom configuration"
echo ""
read -p "Enter choice [1-5]: " choice

case $choice in
    1)
        echo "Generating 500 events per type over 24 hours..."
        python3 bulk_event_generator.py
        ;;
    2)
        echo "Generating 1000 events per type over 24 hours..."
        python3 bulk_event_generator.py --count 1000
        ;;
    3)
        echo "Generating 500 events per type over 6 hours..."
        python3 bulk_event_generator.py --count 500 --hours 6
        ;;
    4)
        echo "Generating 10000 events per type over 24 hours... (This will take a while!)"
        python3 bulk_event_generator.py --count 10000
        ;;
    5)
        read -p "Enter number of events per type: " count
        read -p "Enter hours to spread events over: " hours
        read -p "Enter Elasticsearch host (default: elasticsearch): " host
        host=${host:-elasticsearch}
        read -p "Enter Elasticsearch port (default: 9200): " port
        port=${port:-9200}
        
        echo "Generating $count events per type over $hours hours..."
        python3 bulk_event_generator.py --count $count --hours $hours --host $host --port $port
        ;;
    *)
        echo "Invalid choice. Running default (500 events per type)..."
        python3 bulk_event_generator.py
        ;;
esac

# Deactivate virtual environment
deactivate

echo ""
echo "=================================================="
echo "✅ Bulk Event Generation Complete!"
echo "=================================================="
echo ""
echo "📊 Check your Grafana dashboard to see the populated metrics"
echo "🔍 Elasticsearch index: security-events"
echo ""
