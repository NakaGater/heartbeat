#!/bin/bash
# Safety net: fill empty timestamps in board.jsonl (valid ones are never overwritten).
# Called by PostToolUse, SubagentStart, and SubagentStop hooks.
# - PostToolUse: uses tool_input.file_path from stdin to locate the file.
# - SubagentStart/SubagentStop: no file_path; finds the most recently
#   modified .heartbeat/stories/*/board.jsonl via ls -t.
# Must exit 0 on all paths.  Dependency: jq
set +e

input=$(cat)

# Empty stdin — nothing to do
[ -z "$input" ] && exit 0

# Extract file_path from hook JSON (Claude Code snake_case, VS Code camelCase, or flat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.filePath // .file_path // .filePath // empty' 2>/dev/null)

# No file_path → SubagentStart/SubagentStop context
# Find the most recently modified board.jsonl under .heartbeat/stories/
if [ -z "$file_path" ]; then
  search_root="${HEARTBEAT_ROOT:-.}"
  target=$(ls -t "$search_root"/.heartbeat/stories/*/board.jsonl 2>/dev/null | head -1)
  [ -z "$target" ] && exit 0
  file_path="$target"
fi

# Only act on board.jsonl files
case "$file_path" in
  *board.jsonl) ;;
  *) exit 0 ;;
esac

# File must exist
[ -f "$file_path" ] || exit 0

# Scan all lines: fill empty timestamps, preserve valid ones.
# Safety net only — valid timestamps are never overwritten.
ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
tmp_file=$(mktemp)
has_empty=0

while IFS= read -r line || [ -n "$line" ]; do
  cur_ts=$(echo "$line" | jq -r '.timestamp // empty' 2>/dev/null)
  if [ -z "$cur_ts" ] || ! echo "$cur_ts" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$'; then
    # Empty or missing timestamp — fill it
    new_line=$(echo "$line" | jq -c --arg ts "$ts" '. + {"timestamp": $ts}' 2>/dev/null)
    if [ -n "$new_line" ]; then
      echo "$new_line" >> "$tmp_file"
      has_empty=1
    else
      echo "$line" >> "$tmp_file"
    fi
  else
    # Non-empty timestamp — preserve as-is
    # Future timestamp detection
    cur_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$cur_ts" "+%s" 2>/dev/null \
      || date -d "$cur_ts" "+%s" 2>/dev/null)
    now_epoch=$(date "+%s")
    if [ -n "$cur_epoch" ] && [ "$cur_epoch" -gt "$now_epoch" ]; then
      echo "WARNING: future timestamp detected in $file_path: $cur_ts" >&2
    fi
    echo "$line" >> "$tmp_file"
  fi
done < "$file_path"

if [ "$has_empty" -eq 1 ]; then
  # Had empty timestamps — write back the filled version
  cat "$tmp_file" > "$file_path"
fi
rm -f "$tmp_file"

exit 0
