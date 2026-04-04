#!/bin/bash
# backlog-update.sh — Update backlog.jsonl with mkdir-based locking
# Usage: backlog-update.sh <story-id> <field> <value>
# Supports concurrent access from multiple worktrees.
set -euo pipefail

MAIN_DIR="${HEARTBEAT_MAIN_DIR:-${CLAUDE_PROJECT_DIR:-.}}"
BACKLOG="$MAIN_DIR/.heartbeat/backlog.jsonl"
LOCK_DIR="$MAIN_DIR/.heartbeat/.backlog-lock"
MAX_RETRIES=10
RETRY_INTERVAL=1

usage() {
  echo "usage: backlog-update.sh <story-id> <field> <value>" >&2
  exit 1
}

acquire_lock() {
  local retries=0
  while [ "$retries" -lt "$MAX_RETRIES" ]; do
    if mkdir "$LOCK_DIR" 2>/dev/null; then
      return 0
    fi
    # Stale lock detection (older than 60 seconds)
    if [ -d "$LOCK_DIR" ]; then
      local lock_age
      lock_age=$(( $(date +%s) - $(stat -f %m "$LOCK_DIR" 2>/dev/null || stat -c %Y "$LOCK_DIR" 2>/dev/null || echo 0) ))
      if [ "$lock_age" -gt 60 ]; then
        rmdir "$LOCK_DIR" 2>/dev/null || true
        continue
      fi
    fi
    retries=$((retries + 1))
    sleep "$RETRY_INTERVAL"
  done
  echo "error: failed to acquire backlog lock after $MAX_RETRIES retries" >&2
  return 1
}

release_lock() {
  rmdir "$LOCK_DIR" 2>/dev/null || true
}

# Ensure lock is released on exit
trap release_lock EXIT

main() {
  [ $# -lt 3 ] && usage

  local story_id="$1"
  local field="$2"
  local value="$3"

  if [ ! -f "$BACKLOG" ]; then
    echo "error: backlog.jsonl not found at $BACKLOG" >&2
    exit 1
  fi

  acquire_lock

  local tmp
  tmp=$(mktemp)
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    local sid
    sid=$(echo "$line" | jq -r '.story_id')
    if [ "$sid" = "$story_id" ]; then
      echo "$line" | jq -c --arg f "$field" --arg v "$value" '.[$f] = $v'
    else
      echo "$line"
    fi
  done < "$BACKLOG" > "$tmp"
  mv "$tmp" "$BACKLOG"

  release_lock
  trap - EXIT
}

main "$@"
