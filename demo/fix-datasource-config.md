# Fix Elasticsearch Datasource Configuration

## The Real Problem

The error "invalid index pattern. Specify an index with a time pattern or select 'No pattern'" means your Elasticsearch datasource is configured incorrectly.

Your indices are:
- `security-events`
- `threat-alerts`
- `ueba-alerts`
- `threat-hunting-findings`

These are **NOT time-based** indices (no date pattern like `logs-2025.10.27`).

## Solution: Reconfigure Your Datasource

### Step 1: Open Datasource Configuration

1. Go to Grafana: **Configuration** (gear icon) → **Data Sources**
2. Click on your Elasticsearch datasource (the one with UID: `P31C819B24CF3C3C7`)

### Step 2: Fix the Index Settings

Look for these fields in the datasource config:

#### Option A: Set to "No Pattern" (Recommended)
```
Index name: [leave this field empty or put a wildcard like "*"]
Pattern: No pattern
Time field name: @timestamp
```

#### Option B: Use a Wildcard Pattern
```
Index name: *
Pattern: No pattern
Time field name: @timestamp
```

### Step 3: Save and Test

1. Click **Save & Test**
2. You should see: "Index OK. Time field name OK."

---

## Alternative: Create Multiple Datasources

If the above doesn't work, create separate datasources for each index:

### Datasource 1: Security Events
```
Name: Elasticsearch - Security Events
URL: http://localhost:9200
Index name: security-events
Pattern: No pattern
Time field name: @timestamp
```

### Datasource 2: Threat Alerts
```
Name: Elasticsearch - Threat Alerts
URL: http://localhost:9200
Index name: threat-alerts
Pattern: No pattern
Time field name: @timestamp
```

Repeat for other indices as needed.

---

## Check Your Current Datasource Config

Run this to see your current datasource configuration:

```bash
# Get datasource details from Grafana
curl -u admin:admin http://localhost:3000/api/datasources/uid/P31C819B24CF3C3C7 | jq
```

Look for these fields in the output:
- `jsonData.database` (should be empty or "*")
- `jsonData.timeField` (should be "@timestamp")
- `jsonData.interval` (should be empty or "Daily")

---

## What the Config Should Look Like

```json
{
  "name": "Elasticsearch",
  "type": "elasticsearch",
  "url": "http://elasticsearch:9200",
  "access": "proxy",
  "jsonData": {
    "database": "",  ← Empty or "*" for no pattern
    "esVersion": "8.0.0",
    "interval": "",  ← Empty for no time pattern
    "maxConcurrentShardRequests": 5,
    "timeField": "@timestamp"
  }
}
```

---

## Quick Fix: Update Datasource via API

If you have admin access, you can fix it with this command:

```bash
# Update datasource configuration
curl -X PUT http://localhost:3000/api/datasources/uid/P31C819B24CF3C3C7 \
  -u admin:admin \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Elasticsearch",
    "type": "elasticsearch",
    "url": "http://elasticsearch:9200",
    "access": "proxy",
    "database": "",
    "jsonData": {
      "esVersion": "8.0.0",
      "timeField": "@timestamp",
      "interval": "",
      "maxConcurrentShardRequests": 5,
      "logMessageField": "",
      "logLevelField": ""
    }
  }'
```

Replace:
- `http://localhost:3000` with your Grafana URL
- `http://elasticsearch:9200` with your Elasticsearch URL
- `admin:admin` with your Grafana credentials

---

## After Fixing Datasource

Once the datasource is configured correctly:
1. The "invalid index pattern" error will disappear
2. Import the dashboard again
3. All panels (metrics + logs) will work

---

## Why This Happens

Grafana's Elasticsearch datasource has two modes:

### Time-based Indices (with pattern)
```
Index pattern: logs-[YYYY.MM.DD]
Time field: @timestamp
Interval: Daily

Example indices:
- logs-2025.10.27
- logs-2025.10.26
```

### Non-time-based Indices (no pattern) ← **YOU NEED THIS**
```
Index pattern: (empty) or "*"
Time field: @timestamp
Interval: (empty)

Example indices:
- security-events
- threat-alerts
```

Your indices don't have dates in the name, so you need the "no pattern" configuration!

---

## Test After Fixing

After updating the datasource, test with this query in Explore:

1. Go to **Explore**
2. Select your Elasticsearch datasource
3. Choose "Raw Document" metric
4. In the query field, type: `security-events`
5. Run query

If the datasource is configured correctly, you'll see data without errors.
