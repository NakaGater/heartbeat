#!/bin/bash
# Generate dashboard HTML with embedded data
# Dependency: jq
#
# Usage: ./core/scripts/generate-dashboard.sh [project_root]

PROJECT_ROOT="${1:-.}"
HEARTBEAT_DIR="$PROJECT_ROOT/.heartbeat"
TEMPLATE="$(dirname "$0")/../templates/dashboard.html"
OUTPUT="$HEARTBEAT_DIR/dashboard.html"

export BACKLOG_DATA=$(cat "$HEARTBEAT_DIR/backlog.jsonl" 2>/dev/null | jq -s '.')
[ -z "$BACKLOG_DATA" ] && export BACKLOG_DATA="[]"

STORIES_RAW=$(
  for story_dir in "$HEARTBEAT_DIR/stories"/*/; do
    [ -d "$story_dir" ] || continue
    story_id=$(basename "$story_dir")
    board=$(cat "$story_dir/board.jsonl" 2>/dev/null | jq -s '.')
    tasks=$(cat "$story_dir/tasks.jsonl" 2>/dev/null | jq -s '.')
    jq -n --arg id "$story_id" \
           --argjson board "${board:-[]}" \
           --argjson tasks "${tasks:-[]}" \
           '{story_id: $id, board: $board, tasks: $tasks}'
  done
)
export STORIES_DATA=$(echo "$STORIES_RAW" | jq -s '.')
[ -z "$STORIES_DATA" ] && export STORIES_DATA="[]"

export AGENT_COLORS='{"pdm":"#3B82F6","context-manager":"#8B5CF6","designer":"#EC4899","architect":"#F59E0B","tester":"#EF4444","implementer":"#10B981","refactor":"#06B6D4","reviewer":"#6366F1","qa":"#14B8A6","human":"#6B7280","orchestrator":"#9CA3AF"}'

# Use awk with index/substr for robust replacement (immune to &, \, | in data)
awk '
function replace(str, placeholder, key,    idx, len, result) {
  len = length(placeholder)
  result = ""
  while ((idx = index(str, placeholder)) > 0) {
    result = result substr(str, 1, idx - 1) ENVIRON[key]
    str = substr(str, idx + len)
  }
  return result str
}
{
  $0 = replace($0, "{{BACKLOG_DATA}}", "BACKLOG_DATA")
  $0 = replace($0, "{{STORIES_DATA}}", "STORIES_DATA")
  $0 = replace($0, "{{AGENT_COLORS}}", "AGENT_COLORS")
  print
}' "$TEMPLATE" > "$OUTPUT"

echo "Dashboard generated: $OUTPUT"
