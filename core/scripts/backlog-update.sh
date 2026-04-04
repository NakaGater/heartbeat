#!/bin/bash
# backlog-update.sh — Update backlog.jsonl with mkdir-based locking
# Usage: backlog-update.sh <story-id> <field> <value>
# Supports concurrent access from multiple worktrees.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

MAIN_DIR="${HEARTBEAT_MAIN_DIR:-${CLAUDE_PROJECT_DIR:-.}}"
BACKLOG="$MAIN_DIR/.heartbeat/backlog.jsonl"
LOCK_DIR="$MAIN_DIR/.heartbeat/.backlog-lock"

usage() {
  echo "usage: backlog-update.sh <story-id> <field> <value>" >&2
  exit 1
}

# Ensure lock is released on exit
trap 'release_lock "$LOCK_DIR"' EXIT

main() {
  [ $# -lt 3 ] && usage

  local story_id="$1"
  local field="$2"
  local value="$3"

  if [ ! -f "$BACKLOG" ]; then
    echo "error: backlog.jsonl not found at $BACKLOG" >&2
    exit 1
  fi

  acquire_lock "$LOCK_DIR"

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

  release_lock "$LOCK_DIR"
  trap - EXIT
}

main "$@"
