# Side-by-Side: Wrong vs. Correct Configuration

## Example: Security Events Log Panel

### ❌ WRONG (Version 2 - Caused "invalid index pattern" error)

```json
{
  "targets": [
    {
      "bucketAggs": [],  ← REMOVED bucketAggs (WRONG!)
      "metrics": [
        {
          "id": "1",
          "type": "raw_document",
          "settings": {"size": "100"}
        }
      ],
      "query": "_index:security-events",  ← Used _index: prefix (WRONG!)
      "timeField": "@timestamp"
    }
  ]
}
```

**Result**: ❌ "failed to get indices from index pattern. invalid index pattern"

---

### ✅ CORRECT (Version 3 - Final working version)

```json
{
  "targets": [
    {
      "bucketAggs": [  ← Kept bucketAggs with date_histogram (CORRECT!)
        {
          "field": "@timestamp",
          "id": "2",
          "settings": {
            "interval": "auto",
            "min_doc_count": "0"
          },
          "type": "date_histogram"
        }
      ],
      "metrics": [
        {
          "id": "1",
          "type": "raw_document",
          "settings": {"size": "100"}
        }
      ],
      "query": "security-events",  ← Just index name (CORRECT!)
      "timeField": "@timestamp"
    }
  ]
}
```

**Result**: ✅ Works! Shows 100 raw documents from security-events index

---

## Key Differences

| Aspect | Wrong (v2) | Correct (v3) |
|--------|-----------|--------------|
| **bucketAggs** | Empty array `[]` | Has date_histogram |
| **Query syntax** | `_index:security-events` | `security-events` |
| **Why it failed** | Missing time bucketing | - |
| **Why it works** | - | Proper ES datasource format |

---

## Pattern for All Panels

All 7 new log panels follow this SAME CORRECT pattern:

```json
{
  "bucketAggs": [
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
      "settings": {"size": "100-200"}
    }
  ],
  "query": "INDEX-NAME [AND optional-filters]",
  "timeField": "@timestamp"
}
```

---

## Query Examples from Your Dashboard

### Simple Index Query
```json
"query": "security-events"
"query": "threat-alerts"
"query": "ueba-alerts"
```

### Index + Filter Query
```json
"query": "security-events AND event_type:authentication"
"query": "security-events AND risk_score:>50"
"query": "security-events AND (status:failed OR failed_logins:>0)"
```

### Wildcard Query
```json
"query": "*"  ← Gets all indices
```

---

## Your Working Panel 9 (for reference)

Panel 9 "Recent Threat Alerts" from your original dashboard already worked because it had:

✅ bucketAggs with date_histogram
✅ raw_document metric type  
✅ Simple query: "threat-alerts"
✅ timeField: "@timestamp"

I simply copied this exact pattern to all new log panels!

---

## Bottom Line

**The secret**: Elasticsearch datasource in Grafana needs the `bucketAggs` with `date_histogram` even when fetching raw documents. This is NOT optional - it's how Grafana knows to organize the data by time.

Your Panel 9 worked all along. I just needed to copy its exact configuration! 🎯
