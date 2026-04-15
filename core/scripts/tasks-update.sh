#!/bin/bash
# tasks-update.sh — Update tasks.jsonl with mkdir-based locking
# Usage: tasks-update.sh <tasks-jsonl-path> <task-id> <field> <value>
# Supports concurrent access from multiple agents via mkdir-based locking.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

usage() {
  echo "usage: tasks-update.sh <tasks-jsonl-path> <task-id> <field> <value>" >&2
  exit 1
}

main() {
  [ $# -lt 4 ] && usage

  local tasks_file="$1"
  local task_id="$2"
  local field="$3"
  local value="$4"
  local lock_dir="${tasks_file}.lock"

  if [ ! -f "$tasks_file" ]; then
    echo "error: tasks.jsonl not found at $tasks_file" >&2
    exit 1
  fi

  # Validate JSONL: every non-empty line must be valid JSON
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    if ! echo "$line" | jq empty 2>/dev/null; then
      echo "error: invalid JSONL in $tasks_file" >&2
      exit 1
    fi
  done < "$tasks_file"

  # Ensure lock is released on exit
  trap 'release_lock "$lock_dir"' EXIT
  acquire_lock "$lock_dir"

  # Verify the target task_id exists before updating
  local found=false
  local tmp
  tmp=$(mktemp)
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    local tid
    tid=$(echo "$line" | jq -r '.task_id')
    if [ "$tid" = "$task_id" ]; then
      found=true
      echo "$line" | jq -c --arg f "$field" --arg v "$value" '.[$f] = $v'
    else
      echo "$line"
    fi
  done < "$tasks_file" > "$tmp"

  if [ "$found" = false ]; then
    rm -f "$tmp"
    echo "error: task_id $task_id not found in $tasks_file" >&2
    exit 1
  fi

  mv "$tmp" "$tasks_file"

  release_lock "$lock_dir"
  trap - EXIT
}

main "$@"
