# FINAL FIX - The Real Issue

## The Problem

Your original working panel (Panel 9 - "Recent Threat Alerts") uses this configuration:
```json
{
  "query": "threat-alerts",  ← Just the index name
  "bucketAggs": [
    {
      "field": "@timestamp",
      "type": "date_histogram"
    }
  ],
  "metrics": [
    {
      "type": "raw_document",
      "settings": {"size": "10"}
    }
  ]
}
```

## What I Did Wrong

I tried to use `_index:security-events` or removed bucketAggs entirely, which caused the "invalid index pattern" error.

## The Correct Configuration

For Elasticsearch datasource with `raw_document` type in Grafana:

### ✅ CORRECT Pattern
```json
{
  "query": "index-name",           ← Index name only, no _index: prefix
  "bucketAggs": [                  ← Keep the date_histogram
    {
      "field": "@timestamp",
      "type": "date_histogram",
      "settings": {
        "interval": "auto",
        "min_doc_count": "0"
      }
    }
  ],
  "metrics": [
    {
      "type": "raw_document",
      "settings": {"size": "100"}
    }
  ],
  "timeField": "@timestamp"
}
```

## Query Syntax Rules

1. **Simple index queries** (just get all docs from an index):
   ```
   "query": "security-events"
   ```

2. **Filtering within an index** (use Lucene query syntax):
   ```
   "query": "security-events AND event_type:authentication"
   "query": "security-events AND risk_score:>50"
   "query": "security-events AND (status:failed OR failed_logins:>0)"
   ```

3. **Wildcard queries** (all indices):
   ```
   "query": "*"
   ```

## All New Log Panels - Correct Queries

| Panel | Query | What It Shows |
|-------|-------|---------------|
| Recent Security Events | `security-events` | All security events |
| Threat Alerts | `threat-alerts` | All threat alerts |
| Authentication Events | `security-events AND event_type:authentication` | Only auth events |
| High Risk Activity | `security-events AND risk_score:>50` | Events with risk > 50 |
| Failed Logins | `security-events AND (status:failed OR failed_logins:>0)` | Failed auth attempts |
| UEBA Alerts | `ueba-alerts` | All UEBA alerts |
| All Events | `*` | Everything from all indices |

## Why This Works

The Grafana Elasticsearch datasource:
1. Uses the `query` field to specify BOTH the index pattern AND filtering
2. Requires `bucketAggs` with `date_histogram` even for raw documents (for time-series organization)
3. Expects just the index name, not `_index:` prefix
4. Applies Lucene query syntax for filters after the index name

## Changes Made to Your Dashboard

✅ Fixed all 7 log panel queries
✅ Kept proper bucketAggs structure  
✅ Removed `_index:` prefixes
✅ Changed time range to `now-6h` (matches your data)
✅ All panels now match your working Panel 9's configuration

This should work now! 🎯
