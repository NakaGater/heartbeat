#!/bin/bash
# Auto-commit when a subagent finishes
# Reads SubagentStop hook stdin JSON to extract agent info

set -euo pipefail
cd "${CLAUDE_PROJECT_DIR:-.}"

# Read hook stdin JSON
INPUT=$(cat)
AGENT=$(echo "$INPUT" | jq -r '.agent_name // .subagent_type // "unknown"')

# Exit silently if no changes
if ! git status --porcelain | grep -q .; then
  exit 0
fi

# Build change summary from git diff
CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null || git diff --name-only --cached)
SUMMARY=$(echo "$CHANGED_FILES" | head -5 | tr '\n' ', ' | sed 's/,$//')
FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')
if [ "$FILE_COUNT" -gt 5 ]; then
  SUMMARY="${SUMMARY} (+$((FILE_COUNT - 5)) more)"
fi

git add -A
git commit -m "[$AGENT] $SUMMARY"
