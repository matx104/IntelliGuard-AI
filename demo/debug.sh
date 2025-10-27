#!/bin/bash

echo "=== Data Generator Status ==="
docker ps | grep data-generator

echo -e "\n=== Most Recent Event Timestamp ==="
curl -s "http://localhost:9200/security-events/_search?size=1&sort=@timestamp:desc" | jq -r '.hits.hits[0]._source["@timestamp"]'

echo -e "\n=== Events in Last 6 Hours ==="
curl -s "http://localhost:9200/security-events/_search" -H 'Content-Type: application/json' -d '{
  "query": {"range": {"@timestamp": {"gte": "now-6h"}}},
  "size": 0
}' | jq '.hits.total.value'

echo -e "\n=== Events in Last 24 Hours ==="
curl -s "http://localhost:9200/security-events/_search" -H 'Content-Type: application/json' -d '{
  "query": {"range": {"@timestamp": {"gte": "now-24h"}}},
  "size": 0
}' | jq '.hits.total.value'

echo -e "\n=== Total Events ==="
curl -s "http://localhost:9200/security-events/_count" | jq '.count'

echo -e "\n=== Grafana Time Setting ==="
echo "Check if Grafana is using browser timezone or UTC"
