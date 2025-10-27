# 🚨 QUICK FIX: Invalid Index Pattern Error

## The Root Cause

Your **Elasticsearch datasource** in Grafana is configured for time-based indices (like `logs-2025.10.27`), but your actual indices are NOT time-based:
- `security-events` ← No date pattern
- `threat-alerts` ← No date pattern  
- `ueba-alerts` ← No date pattern

This mismatch causes: "invalid index pattern. Specify an index with a time pattern or select 'No pattern'"

---

## 🎯 Solution: Fix the Datasource (Choose ONE method)

### Method 1: Use the Auto-Fix Script (Easiest)

```bash
cd ~/IntelliGuard-AI/demo
chmod +x fix-datasource.sh
./fix-datasource.sh
```

The script will:
1. Check your datasource configuration
2. Show you what's wrong
3. Ask if you want to auto-fix it
4. Update the configuration

---

### Method 2: Manual Fix via Grafana UI

1. **Open Grafana** → `http://localhost:3000`
2. **Login** (default: admin/admin)
3. **Go to**: Configuration (⚙️) → Data Sources
4. **Click on**: Your Elasticsearch datasource
5. **Update these fields**:
   ```
   Index name: [DELETE EVERYTHING or type "*"]
   Pattern: Select "No pattern" from dropdown
   Time field name: @timestamp
   ```
6. **Scroll down** → Click **"Save & Test"**
7. You should see: ✅ "Index OK. Time field name OK."

---

### Method 3: Fix via API (Advanced)

```bash
curl -X PUT http://localhost:3000/api/datasources/uid/P31C819B24CF3C3C7 \
  -u admin:admin \
  -H "Content-Type: application/json" \
  -d '{
    "uid": "P31C819B24CF3C3C7",
    "name": "Elasticsearch",
    "type": "elasticsearch",
    "url": "http://elasticsearch:9200",
    "access": "proxy",
    "database": "",
    "jsonData": {
      "esVersion": "8.0.0",
      "timeField": "@timestamp",
      "interval": "",
      "maxConcurrentShardRequests": 5
    }
  }'
```

---

## ✅ After Fixing

1. **Refresh your browser** (Ctrl+F5 or Cmd+Shift+R)
2. **Import the dashboard again**: `grafana-dashboard-final.json`
3. **All panels should work** without the "invalid index pattern" error

---

## 🔍 Verify It's Fixed

Test in Explore:
1. Go to Grafana → **Explore**
2. Select your Elasticsearch datasource
3. Choose **"Logs"** query type
4. In the query field: `security-events`
5. Click **Run Query**

If fixed, you'll see logs without errors!

---

## 📋 Visual Guide

### ❌ WRONG Configuration (Current)
```
┌─────────────────────────────────────┐
│ Elasticsearch Datasource Settings  │
├─────────────────────────────────────┤
│ Index name: security-events-*       │ ← Has a pattern
│ Pattern: Daily                      │ ← Time-based
│ Time field: @timestamp              │
└─────────────────────────────────────┘
```

### ✅ CORRECT Configuration (Target)
```
┌─────────────────────────────────────┐
│ Elasticsearch Datasource Settings  │
├─────────────────────────────────────┤
│ Index name: [empty] or *            │ ← No pattern
│ Pattern: No pattern                 │ ← Not time-based
│ Time field: @timestamp              │
└─────────────────────────────────────┘
```

---

## 💡 Why This Matters

**Time-based indices** (with date pattern):
- Used for indices like: `logs-2025.10.27`, `metrics-2025.10.26`
- Grafana knows which index to query based on time range
- Requires pattern: `[prefix-]YYYY.MM.DD`

**Non-time-based indices** (your case):
- Used for indices like: `security-events`, `threat-alerts`
- Single index name, no date rotation
- Requires: No pattern, just index name

Your indices are non-time-based, so the datasource must be configured with "No pattern"!

---

## 🚀 Quick Start (TL;DR)

```bash
# Download and run the fix script
cd ~/IntelliGuard-AI/demo
./fix-datasource.sh

# Follow prompts, then refresh browser and import dashboard
```

Done! 🎉
