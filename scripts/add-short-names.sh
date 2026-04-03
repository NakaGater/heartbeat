#!/bin/bash
# Add short names to numeric story IDs: 0001 -> 0001-tdd-workflow
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HB="$PROJECT_ROOT/.heartbeat"
BACKLOG="$HB/backlog.jsonl"
RETRO_LOG="$HB/retrospectives/log.jsonl"
STORIES_DIR="$HB/stories"
MAPFILE=$(mktemp)

# Original mapping from rename-story-ids.sh (number -> old kebab-case name)
cat > "$MAPFILE" <<'MAP'
0001 tdd-workflow
0002 i18n-docs
0003 auto-commit-fix
0004 dashboard-fix
0005 workflow-fix
0006 workflow-boundary
0007 parallel-stories
0008 copilot-hooks
0009 board-cleanup
0010 point-criteria
0011 copilot-tools
0012 dashboard-current-story
0013 dashboard-done-collapse
0014 retro-enforcement
0015 commit-message-accuracy
0016 backlog-display-collapse
0017 dashboard-timestamp
0018 copilot-request-optimization
0019 copilot-hooks-fix
0020 copilot-subagent-dispatch
0021 dashboard-timestamp-empty
0022 claude-subagent-dispatch
0023 auto-commit-broken
0024 plugin-config-cleanup
0025 gantt-timestamp-accuracy
0026 ask-user-enforcement
0027 ask-user-tool-fix
0028 dashboard-data-display
0029 agent-skill-i18n-fix
0030 gantt-timestamp-overwrite
0031 dashboard-backlog-sync
0032 dashboard-gantt-fix
0033 qa-playwright-hang
0034 dashboard-status-sync
0035 commit-scope-storyid
0036 dashboard-backlog-current-fix
0037 dashboard-update-timing
0038 dashboard-inprogress-timing
0039 qa-playwright-nonstop
0040 dashboard-velocity-display
0041 readable-commits
0042 selective-questions
MAP

echo "=== Mapping ==="
while IFS=' ' read -r num name; do
  new_id="${num}-${name}"
  echo "  $num -> $new_id"
done < "$MAPFILE"
echo ""

# --- Rename directories (2-pass) ---
echo "Pass 1: Rename to temporary names..."
while IFS=' ' read -r num name; do
  if [ -d "$STORIES_DIR/$num" ]; then
    mv "$STORIES_DIR/$num" "$STORIES_DIR/${num}__migrating"
  else
    echo "  WARNING: Directory $num not found, skipping"
  fi
done < "$MAPFILE"

echo "Pass 2: Rename to final names..."
while IFS=' ' read -r num name; do
  new_id="${num}-${name}"
  if [ -d "$STORIES_DIR/${num}__migrating" ]; then
    mv "$STORIES_DIR/${num}__migrating" "$STORIES_DIR/${new_id}"
  fi
done < "$MAPFILE"
echo "Directories renamed."
echo ""

# --- Update backlog.jsonl ---
echo "Updating backlog.jsonl..."
tmp=$(mktemp)
while IFS= read -r line; do
  [ -z "$line" ] && continue
  old_id=$(echo "$line" | jq -r '.story_id')
  # Look up the short name for this numeric ID
  name=$(grep "^${old_id} " "$MAPFILE" | awk '{print $2}')
  if [ -n "$name" ]; then
    new_id="${old_id}-${name}"
    echo "$line" | jq -c --arg new "$new_id" '.story_id = $new'
  else
    echo "$line"
  fi
done < "$BACKLOG" > "$tmp"
mv "$tmp" "$BACKLOG"
echo "backlog.jsonl updated."
echo ""

# --- Update retrospectives/log.jsonl ---
if [ -f "$RETRO_LOG" ]; then
  echo "Updating retrospectives/log.jsonl..."
  tmp=$(mktemp)
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    old_id=$(echo "$line" | jq -r '.story_id // empty')
    if [ -n "$old_id" ]; then
      name=$(grep "^${old_id} " "$MAPFILE" | awk '{print $2}')
      if [ -n "$name" ]; then
        new_id="${old_id}-${name}"
        echo "$line" | jq -c --arg new "$new_id" '.story_id = $new'
      else
        echo "$line"
      fi
    else
      echo "$line"
    fi
  done < "$RETRO_LOG" > "$tmp"
  mv "$tmp" "$RETRO_LOG"
  echo "retrospectives/log.jsonl updated."
else
  echo "No retrospectives/log.jsonl found, skipping."
fi
echo ""

# --- Verification ---
echo "=== Verification ==="
errors=0

# Check no purely numeric directories remain
old_remaining=$(ls "$STORIES_DIR" | grep '^[0-9][0-9][0-9][0-9]$' || true)
if [ -n "$old_remaining" ]; then
  echo "  ERROR: Purely numeric directories remain:"
  echo "$old_remaining" | sed 's/^/    /'
  errors=$((errors + 1))
else
  echo "No purely numeric directories remain."
fi

# Check all directories match NNNN-name pattern
bad_dirs=$(ls "$STORIES_DIR" | grep -v '^[0-9][0-9][0-9][0-9]-' || true)
if [ -n "$bad_dirs" ]; then
  echo "  ERROR: Directories not matching NNNN-name pattern:"
  echo "$bad_dirs" | sed 's/^/    /'
  errors=$((errors + 1))
else
  echo "All directories match NNNN-name pattern."
fi

# Check backlog story_ids match NNNN-name pattern
bad_backlog=$(jq -r '.story_id' "$BACKLOG" | grep -v '^[0-9][0-9][0-9][0-9]-' || true)
if [ -n "$bad_backlog" ]; then
  echo "  ERROR: Non-conforming story_ids in backlog.jsonl:"
  echo "$bad_backlog" | sed 's/^/    /'
  errors=$((errors + 1))
else
  echo "All backlog.jsonl story_ids match NNNN-name pattern."
fi

echo ""
if [ "$errors" -eq 0 ]; then
  echo "Migration completed successfully!"
else
  echo "Migration completed with $errors error(s). Please review."
  exit 1
fi

rm -f "$MAPFILE"
