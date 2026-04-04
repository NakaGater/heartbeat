#!/bin/bash
set -euo pipefail
# Aggregate patterns from retrospective log
# Dependency: jq

LOG_FILE="${HEARTBEAT_RETRO_LOG:-./.heartbeat/retrospectives/log.jsonl}"
OUTPUT_FILE="${HEARTBEAT_INSIGHTS:-./.heartbeat/retrospectives/insights.md}"

if [ ! -f "$LOG_FILE" ]; then
  echo "No retrospective log found" >&2
  exit 1
fi

echo "# Heartbeat Learning Insights" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "## Patterns Requiring Attention" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

jq -r 'select(.xp_check != null) |
  .xp_check | to_entries[] |
  select(.value.score == "yellow" or .value.score == "red") |
  "- **\(.key)** (\(.value.score)): \(.value.note // "no details")"' \
  "$LOG_FILE" 2>/dev/null >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "## Agent Trends" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

jq -r '.agent' "$LOG_FILE" 2>/dev/null | sort | uniq -c | sort -rn | \
  while read count agent; do
    echo "- $agent: ${count} retrospectives"
  done >> "$OUTPUT_FILE"
