# 🔍 Visual Diagnostic: Why You're Getting the Error

## Your Elasticsearch Indices (Actual)

```
┌─────────────────────────────────────┐
│   Elasticsearch Indices             │
├─────────────────────────────────────┤
│  📁 security-events                 │ ← No date in name
│  📁 threat-alerts                   │ ← No date in name
│  📁 ueba-alerts                     │ ← No date in name
│  📁 threat-hunting-findings         │ ← No date in name
│  📁 hunting-reports                 │ ← No date in name
│  📁 thehive_global                  │ ← No date in name
└─────────────────────────────────────┘
```

These are **static index names** (non-time-based).

---

## Your Grafana Datasource (Current Config)

```
┌────────────────────────────────────────────┐
│  Grafana Elasticsearch Datasource Config  │
├────────────────────────────────────────────┤
│  Index name: [something-with-pattern]      │ ← Expects time pattern
│  Pattern: Daily/Monthly/Yearly             │ ← Looking for dates
│  Time field: @timestamp                    │
└────────────────────────────────────────────┘
      │
      │  Grafana tries to find:
      ├─→ security-events-2025.10.27  ❌ Doesn't exist
      ├─→ security-events-2025.10.26  ❌ Doesn't exist
      └─→ security-events-2025.10.25  ❌ Doesn't exist
      
      Result: "invalid index pattern" error!
```

---

## The Mismatch

```
┌─────────────────────────┐         ┌──────────────────────────┐
│  What You Have          │    ≠    │  What Grafana Expects    │
├─────────────────────────┤         ├──────────────────────────┤
│  security-events        │         │  logs-[YYYY.MM.DD]       │
│  threat-alerts          │         │  metrics-[YYYY.MM.DD]    │
│  (no date pattern)      │         │  (with date pattern)     │
└─────────────────────────┘         └──────────────────────────┘
```

**This mismatch causes the error!**

---

## The Fix

```
BEFORE (Causes Error):
┌────────────────────────────────────────────┐
│  Grafana Elasticsearch Datasource         │
├────────────────────────────────────────────┤
│  Index name: security-events-*             │ ← Pattern expected
│  Pattern: Daily                            │ ← Time-based
│  Time field: @timestamp                    │
└────────────────────────────────────────────┘
         ❌ Looks for: security-events-2025.10.27
         ❌ But exists: security-events


AFTER (Fixed):
┌────────────────────────────────────────────┐
│  Grafana Elasticsearch Datasource         │
├────────────────────────────────────────────┤
│  Index name: [empty or "*"]                │ ← No pattern
│  Pattern: No pattern                       │ ← Static names
│  Time field: @timestamp                    │
└────────────────────────────────────────────┘
         ✅ Queries: security-events directly
         ✅ Queries: threat-alerts directly
         ✅ No date pattern needed!
```

---

## How Queries Work After Fix

### Panel Query
```json
{
  "query": "security-events",
  "metrics": [{"type": "raw_document"}]
}
```

### What Grafana Does
```
1. Check datasource config → "No pattern" ✅
2. Use query as-is → "security-events" ✅
3. Query Elasticsearch → GET /security-events/_search ✅
4. Return documents → Success! ✅
```

---

## Compare: Time-based vs. Non-time-based

### Time-based Indices (NOT your case)
```
Indices:
  logs-2025.10.27
  logs-2025.10.26
  logs-2025.10.25

Datasource Config:
  Index name: logs-[YYYY.MM.DD]
  Pattern: Daily
  
Grafana automatically:
  - Queries correct date indices based on time range
  - Merges results from multiple indices
```

### Non-time-based Indices (YOUR case)
```
Indices:
  security-events
  threat-alerts
  ueba-alerts

Datasource Config:
  Index name: [empty]
  Pattern: No pattern
  
Grafana:
  - Uses exact index name from query
  - No date calculation needed
```

---

## Summary Flow

```
User Query: "security-events"
    ↓
Datasource Config Check
    ↓
┌─────────────────────────────────────────┐
│ Pattern: Daily/Monthly?                 │
│    YES → Add date to query ❌ WRONG     │
│    NO  → Use query as-is ✅ CORRECT     │
└─────────────────────────────────────────┘
    ↓
Query Elasticsearch: /security-events/_search
    ↓
Return Results ✅
```

---

## Action Required

**Fix the datasource to use "No pattern" mode!**

Choose one method:
1. ✅ Run `./fix-datasource.sh` (automated)
2. ✅ Manually in Grafana UI (Configuration → Data Sources)
3. ✅ Use API call (see QUICK-FIX-GUIDE.md)

After fixing:
- Import dashboard
- No more "invalid index pattern" errors
- All panels work perfectly!

---

## Final Checklist

```
Before Fix:
[ ] Datasource expects date patterns
[ ] Grafana looks for security-events-YYYY.MM.DD
[ ] Error: "invalid index pattern"
[ ] Dashboard panels fail

After Fix:
[✓] Datasource uses "No pattern"
[✓] Grafana queries security-events directly
[✓] No errors
[✓] Dashboard panels work!
```

🎯 **Fix the datasource configuration and you're done!**
