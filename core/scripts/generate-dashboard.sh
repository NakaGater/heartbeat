#!/bin/bash
# Generate dashboard HTML with embedded data
# Dependency: jq
#
# Usage: ./core/scripts/generate-dashboard.sh [project_root]

# Skip dashboard generation inside worktrees
if [ "${HEARTBEAT_IN_WORKTREE:-}" = "1" ]; then
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

PROJECT_ROOT="${1:-.}"
HEARTBEAT_DIR="$PROJECT_ROOT/.heartbeat"
# Template source (story 0059a):
#   The dashboard is now authored as a Vite + React + TypeScript project under
#   dashboard/. `npm run build` (with vite-plugin-singlefile) emits a single
#   self-contained HTML at dashboard/dist/index.html that still carries the
#   {{BACKLOG_DATA}} / {{STORIES_DATA}} / {{AGENT_COLORS}} / {{INSIGHTS_DATA}}
#   placeholders inside a non-module <script> tag. This script injects runtime
#   data into those placeholders to produce .heartbeat/dashboard.html.
TEMPLATE="$SCRIPT_DIR/../../dashboard/dist/index.html"
OUTPUT="$HEARTBEAT_DIR/dashboard.html"

# Fail fast with a helpful hint if the React build artifact is missing.
# This typically means `npm run build` has not been run inside dashboard/ yet.
if [ ! -f "$TEMPLATE" ]; then
  echo "generate-dashboard.sh: template not found: $TEMPLATE" >&2
  echo "  Hint: run 'npm install && npm run build' inside the dashboard/ directory" >&2
  echo "  (see story 0059a-dashboard-react-foundation)." >&2
  exit 1
fi

# --- Lock mechanism (mkdir-based, via lib/common.sh) ---
LOCK_DIR="$HEARTBEAT_DIR/.dashboard-lock"
MAX_RETRIES="${DASHBOARD_LOCK_MAX_RETRIES:-10}"
RETRY_INTERVAL="${DASHBOARD_LOCK_RETRY_INTERVAL:-1}"

trap 'release_lock "$LOCK_DIR"' EXIT

acquire_lock "$LOCK_DIR" "$MAX_RETRIES" "$RETRY_INTERVAL" || exit 0
# --- End lock mechanism ---

# Parse a JSONL file safely, skipping invalid lines.
# Outputs a JSON array. Returns "[]" if file is missing or all lines are invalid.
_parse_jsonl_safe() {
  local file="$1"
  [ -f "$file" ] || { echo "[]"; return; }
  local _valid=""
  while IFS= read -r _line || [ -n "$_line" ]; do
    [ -z "$_line" ] && continue
    echo "$_line" | jq -e '.' >/dev/null 2>&1 && _valid="${_valid}${_line}"$'\n'
  done < "$file"
  if [ -n "$_valid" ]; then
    printf '%s' "$_valid" | jq -s '.'
  else
    echo "[]"
  fi
}

export BACKLOG_DATA=$(_parse_jsonl_safe "$HEARTBEAT_DIR/backlog.jsonl")

STORIES_RAW=$(
  for story_dir in "$HEARTBEAT_DIR/stories"/*/; do
    [ -d "$story_dir" ] || continue
    story_id=$(basename "$story_dir")
    board=$(_parse_jsonl_safe "$story_dir/board.jsonl")
    tasks=$(_parse_jsonl_safe "$story_dir/tasks.jsonl")
    jq -n --arg id "$story_id" \
           --argjson board "$board" \
           --argjson tasks "$tasks" \
           '{story_id: $id, board: $board, tasks: $tasks}'
  done
)
export STORIES_DATA=$(echo "$STORIES_RAW" | jq -s '.')
[ -z "$STORIES_DATA" ] && export STORIES_DATA="[]"

export AGENT_COLORS='{"pdm":"#3B82F6","context-manager":"#8B5CF6","designer":"#EC4899","architect":"#F59E0B","tester":"#EF4444","implementer":"#10B981","refactor":"#06B6D4","reviewer":"#6366F1","qa":"#14B8A6","human":"#6B7280","orchestrator":"#9CA3AF"}'

# Build INSIGHTS_DATA from 4 UCD layer JSONL files
_build_insights_data() {
  local insights_dir="$HEARTBEAT_DIR/insights"
  local raw findings insights opportunities
  raw=$(_parse_jsonl_safe "$insights_dir/raw.jsonl")
  findings=$(_parse_jsonl_safe "$insights_dir/findings.jsonl")
  insights=$(_parse_jsonl_safe "$insights_dir/insights.jsonl")
  opportunities=$(_parse_jsonl_safe "$insights_dir/opportunities.jsonl")
  jq -n --argjson raw "$raw" \
        --argjson findings "$findings" \
        --argjson insights "$insights" \
        --argjson opportunities "$opportunities" \
        '{raw: $raw, findings: $findings, insights: $insights, opportunities: $opportunities}'
}
export INSIGHTS_DATA=$(_build_insights_data)

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
  $0 = replace($0, "{{INSIGHTS_DATA}}", "INSIGHTS_DATA")
  print
}' "$TEMPLATE" > "$OUTPUT"

echo "Dashboard generated: $OUTPUT"
