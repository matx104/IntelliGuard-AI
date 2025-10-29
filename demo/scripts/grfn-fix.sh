#!/bin/bash

# Script to diagnose and fix Grafana Elasticsearch datasource configuration
# for non-time-based indices

GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
GRAFANA_USER="${GRAFANA_USER:-admin}"
GRAFANA_PASS="${GRAFANA_PASS:-admin}"
DATASOURCE_UID="P31C819B24CF3C3C7"

echo "==================================="
echo "Grafana Datasource Configuration Check"
echo "==================================="
echo ""

# Check if Grafana is accessible
echo "1. Checking Grafana connection..."
if curl -s -f -u "$GRAFANA_USER:$GRAFANA_PASS" "$GRAFANA_URL/api/health" > /dev/null 2>&1; then
    echo "   ✅ Grafana is accessible"
else
    echo "   ❌ Cannot connect to Grafana at $GRAFANA_URL"
    echo "   Please check if Grafana is running and credentials are correct"
    exit 1
fi
echo ""

# Get current datasource configuration
echo "2. Fetching datasource configuration..."
DATASOURCE_CONFIG=$(curl -s -u "$GRAFANA_USER:$GRAFANA_PASS" \
    "$GRAFANA_URL/api/datasources/uid/$DATASOURCE_UID")

if [ $? -eq 0 ]; then
    echo "   ✅ Datasource found"
else
    echo "   ❌ Failed to fetch datasource"
    exit 1
fi
echo ""

# Display current configuration
echo "3. Current datasource configuration:"
echo "$DATASOURCE_CONFIG" | jq '{
    name: .name,
    type: .type,
    url: .url,
    database: .database,
    jsonData: {
        esVersion: .jsonData.esVersion,
        timeField: .jsonData.timeField,
        interval: .jsonData.interval,
        database: .jsonData.database
    }
}'
echo ""

# Check if configuration is problematic
DATABASE=$(echo "$DATASOURCE_CONFIG" | jq -r '.database // empty')
JSON_DATABASE=$(echo "$DATASOURCE_CONFIG" | jq -r '.jsonData.database // empty')
INTERVAL=$(echo "$DATASOURCE_CONFIG" | jq -r '.jsonData.interval // empty')

echo "4. Diagnosis:"
echo "   Database field: ${DATABASE:-'(empty)'}"
echo "   jsonData.database: ${JSON_DATABASE:-'(empty)'}"
echo "   Interval: ${INTERVAL:-'(empty)'}"
echo ""

NEEDS_FIX=false

if [ -n "$DATABASE" ] && [ "$DATABASE" != "*" ]; then
    echo "   ⚠️  ISSUE: 'database' field is set to '$DATABASE'"
    echo "      This should be empty or '*' for non-time-based indices"
    NEEDS_FIX=true
fi

if [ -n "$JSON_DATABASE" ] && [ "$JSON_DATABASE" != "*" ]; then
    echo "   ⚠️  ISSUE: 'jsonData.database' is set to '$JSON_DATABASE'"
    echo "      This should be empty or '*' for non-time-based indices"
    NEEDS_FIX=true
fi

if [ -n "$INTERVAL" ] && [ "$INTERVAL" != "No interval" ]; then
    echo "   ⚠️  ISSUE: 'interval' is set to '$INTERVAL'"
    echo "      This should be empty for non-time-based indices"
    NEEDS_FIX=true
fi

if [ "$NEEDS_FIX" = false ]; then
    echo "   ✅ Configuration looks correct!"
    echo ""
    echo "If you're still getting errors, the issue might be in the panel configuration."
    exit 0
fi

echo ""
echo "5. Recommended fix:"
echo "   Set database field to: '' (empty) or '*'"
echo "   Set interval to: '' (empty)"
echo ""

read -p "Would you like to fix the datasource configuration now? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Configuration NOT updated. Please fix manually in Grafana UI:"
    echo "   Configuration → Data Sources → [Your Elasticsearch DS]"
    echo "   Set 'Index name' to empty or '*'"
    echo "   Set 'Pattern' to 'No pattern'"
    exit 0
fi

echo ""
echo "6. Updating datasource configuration..."

# Get full datasource config and update it
UPDATED_CONFIG=$(echo "$DATASOURCE_CONFIG" | jq '
    .database = "" |
    .jsonData.database = "" |
    .jsonData.interval = ""
')

# Update datasource
UPDATE_RESPONSE=$(curl -s -X PUT \
    -u "$GRAFANA_USER:$GRAFANA_PASS" \
    -H "Content-Type: application/json" \
    -d "$UPDATED_CONFIG" \
    "$GRAFANA_URL/api/datasources/$DATASOURCE_UID")

if echo "$UPDATE_RESPONSE" | jq -e '.message' > /dev/null 2>&1; then
    echo "   ✅ Datasource updated successfully!"
    echo ""
    echo "7. Testing datasource..."
    
    # Test datasource
    TEST_RESPONSE=$(curl -s -X POST \
        -u "$GRAFANA_USER:$GRAFANA_PASS" \
        -H "Content-Type: application/json" \
        "$GRAFANA_URL/api/datasources/uid/$DATASOURCE_UID/health")
    
    if echo "$TEST_RESPONSE" | jq -e '.status == "success"' > /dev/null 2>&1; then
        echo "   ✅ Datasource test successful!"
    else
        echo "   ⚠️  Datasource test returned: $(echo "$TEST_RESPONSE" | jq -r '.status')"
    fi
    
    echo ""
    echo "✅ DONE! Your datasource is now configured for non-time-based indices."
    echo ""
    echo "Next steps:"
    echo "1. Refresh your Grafana dashboard"
    echo "2. The 'invalid index pattern' error should be gone"
    echo "3. Import the dashboard again if needed"
    
else
    echo "   ❌ Failed to update datasource"
    echo "   Response: $UPDATE_RESPONSE"
    echo ""
    echo "Please update manually in Grafana UI:"
    echo "   Configuration → Data Sources → [Your Elasticsearch DS]"
    echo "   Set 'Index name' to empty or '*'"
    echo "   Set 'Pattern' to 'No pattern'"
fi

echo ""
echo "==================================="
