#!/bin/bash
# Record retrospective to JSONL
# Dependency: jq
set +e

# Worktree support: use HEARTBEAT_MAIN_DIR for global retro log
if [ -n "${HEARTBEAT_MAIN_DIR:-}" ]; then
  _DEFAULT_LOG="$HEARTBEAT_MAIN_DIR/.heartbeat/retrospectives/log.jsonl"
else
  _DEFAULT_LOG="./.heartbeat/retrospectives/log.jsonl"
fi
LOG_FILE="${HEARTBEAT_RETRO_LOG:-$_DEFAULT_LOG}"

input=$(cat)

if [ -z "$input" ]; then
  echo "Error: empty input" >&2
  exit 0
fi

if ! echo "$input" | jq empty 2>/dev/null; then
  echo "Error: invalid JSON" >&2
  exit 0
fi

agent=$(echo "$input" | jq -r '.agent // empty')
if [ -z "$agent" ]; then
  echo "Error: agent field required" >&2
  exit 0
fi

mkdir -p "$(dirname "$LOG_FILE")"

ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "$input" | jq -c --arg ts "$ts" '. + {"timestamp": $ts}' >> "$LOG_FILE"

exit 0
