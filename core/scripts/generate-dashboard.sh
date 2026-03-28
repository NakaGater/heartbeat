#!/bin/bash
# Generate dashboard HTML with embedded data
# Dependency: jq
#
# Usage: ./core/scripts/generate-dashboard.sh [project_root]

PROJECT_ROOT="${1:-.}"
HEARTBEAT_DIR="$PROJECT_ROOT/.heartbeat"
TEMPLATE="$(dirname "$0")/../templates/dashboard.html"
OUTPUT="$HEARTBEAT_DIR/dashboard.html"

BACKLOG_DATA=$(cat "$HEARTBEAT_DIR/backlog.jsonl" 2>/dev/null | jq -s '.')

STORIES_DATA=$(
  for story_dir in "$HEARTBEAT_DIR/stories"/*/; do
    [ -d "$story_dir" ] || continue
    story_id=$(basename "$story_dir")
    board=$(cat "$story_dir/board.jsonl" 2>/dev/null | jq -s '.')
    tasks=$(cat "$story_dir/tasks.jsonl" 2>/dev/null | jq -s '.')
    jq -n --arg id "$story_id" \
           --argjson board "${board:-[]}" \
           --argjson tasks "${tasks:-[]}" \
           '{story_id: $id, board: $board, tasks: $tasks}'
  done | jq -s '.'
)

AGENT_COLORS='{"pdm":"#3B82F6","context-manager":"#8B5CF6","designer":"#EC4899","architect":"#F59E0B","tester":"#EF4444","implementer":"#10B981","refactor":"#06B6D4","reviewer":"#6366F1","qa":"#14B8A6","human":"#6B7280","orchestrator":"#9CA3AF"}'

sed -e "s|{{BACKLOG_DATA}}|$BACKLOG_DATA|" \
    -e "s|{{STORIES_DATA}}|$STORIES_DATA|" \
    -e "s|{{AGENT_COLORS}}|$AGENT_COLORS|" \
    "$TEMPLATE" > "$OUTPUT"

echo "Dashboard generated: $OUTPUT"
