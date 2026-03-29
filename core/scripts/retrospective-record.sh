#!/bin/bash
# Record retrospective to JSONL
# Dependency: jq

LOG_FILE="${HEARTBEAT_RETRO_LOG:-./.heartbeat/retrospectives/log.jsonl}"

input=$(cat)

if [ -z "$input" ]; then
  echo "Error: empty input" >&2
  exit 1
fi

if ! echo "$input" | jq empty 2>/dev/null; then
  echo "Error: invalid JSON" >&2
  exit 1
fi

agent=$(echo "$input" | jq -r '.agent // empty')
if [ -z "$agent" ]; then
  echo "Error: agent field required" >&2
  exit 1
fi

mkdir -p "$(dirname "$LOG_FILE")"

ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "$input" | jq -c --arg ts "$ts" '. + {"timestamp": $ts}' >> "$LOG_FILE"
