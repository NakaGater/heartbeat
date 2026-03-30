#!/bin/bash
# Inject accurate UTC timestamp into last line of board.jsonl
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

# Read last line
last_line=$(tail -1 "$file_path")
[ -z "$last_line" ] && exit 0

# Inject/overwrite timestamp with current UTC time
ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
new_last_line=$(echo "$last_line" | jq -c --arg ts "$ts" '. + {"timestamp": $ts}' 2>/dev/null)
[ -z "$new_last_line" ] && exit 0

# Replace last line in-place (platform-aware sed)
if sed --version 2>/dev/null | grep -q GNU; then
  sed -i '$d' "$file_path"
else
  sed -i '' '$d' "$file_path"
fi
echo "$new_last_line" >> "$file_path"

exit 0
