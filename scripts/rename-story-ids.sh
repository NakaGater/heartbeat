#!/bin/bash
# Migration script: Rename story IDs from kebab-case to sequential 4-digit numbers.
# Compatible with Bash 3.2 (macOS default).
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HB="$PROJECT_ROOT/.heartbeat"
BACKLOG="$HB/backlog.jsonl"
RETRO_LOG="$HB/retrospectives/log.jsonl"
STORIES_DIR="$HB/stories"
MAPFILE=$(mktemp)

# --- Build mapping ---
n=0

# From backlog.jsonl (line order = creation order)
while IFS= read -r line; do
  [ -z "$line" ] && continue
  n=$((n + 1))
  old_id=$(echo "$line" | jq -r '.story_id')
  new_id=$(printf '%04d' "$n")
  echo "$old_id $new_id" >> "$MAPFILE"
done < "$BACKLOG"

echo "Mapped $n stories from backlog.jsonl"

# Extra directories not in backlog (sorted alphabetically)
for dir in $(ls "$STORIES_DIR" | sort); do
  if ! grep -q "^${dir} " "$MAPFILE"; then
    n=$((n + 1))
    new_id=$(printf '%04d' "$n")
    echo "$dir $new_id" >> "$MAPFILE"
    echo "Extra directory: $dir -> $new_id"
  fi
done

echo "Total: $n stories to rename"
echo ""

# --- Print mapping ---
echo "=== Mapping ==="
while IFS=' ' read -r old_id new_id; do
  echo "  $new_id <- $old_id"
done < "$MAPFILE"
echo ""

# --- Rename directories (2-pass to avoid collisions) ---
echo "Pass 1: Rename to temporary names..."
while IFS=' ' read -r old_id new_id; do
  if [ -d "$STORIES_DIR/$old_id" ]; then
    mv "$STORIES_DIR/$old_id" "$STORIES_DIR/${old_id}__migrating"
  else
    echo "  WARNING: Directory $old_id not found, skipping"
  fi
done < "$MAPFILE"

echo "Pass 2: Rename to final names..."
while IFS=' ' read -r old_id new_id; do
  if [ -d "$STORIES_DIR/${old_id}__migrating" ]; then
    mv "$STORIES_DIR/${old_id}__migrating" "$STORIES_DIR/${new_id}"
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
  new_id=$(grep "^${old_id} " "$MAPFILE" | awk '{print $2}')
  if [ -n "$new_id" ]; then
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
      new_id=$(grep "^${old_id} " "$MAPFILE" | awk '{print $2}')
      if [ -n "$new_id" ]; then
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

# Check directory count
dir_count=$(ls -d "$STORIES_DIR"/*/ 2>/dev/null | wc -l | tr -d ' ')
echo "Directory count: $dir_count (expected: $n)"
if [ "$dir_count" -ne "$n" ]; then
  echo "  ERROR: Directory count mismatch!"
  errors=$((errors + 1))
fi

# Check no old kebab-case directories remain
old_remaining=$(ls "$STORIES_DIR" | grep -v '^[0-9][0-9][0-9][0-9]$' || true)
if [ -n "$old_remaining" ]; then
  echo "  ERROR: Non-numeric directories remain:"
  echo "$old_remaining" | sed 's/^/    /'
  errors=$((errors + 1))
else
  echo "All directories are 4-digit numbers."
fi

# Check backlog.jsonl story_ids are all numeric
bad_backlog=$(jq -r '.story_id' "$BACKLOG" | grep -v '^[0-9][0-9][0-9][0-9]$' || true)
if [ -n "$bad_backlog" ]; then
  echo "  ERROR: Non-numeric story_ids in backlog.jsonl:"
  echo "$bad_backlog" | sed 's/^/    /'
  errors=$((errors + 1))
else
  echo "All backlog.jsonl story_ids are 4-digit numbers."
fi

# Check retrospectives/log.jsonl story_ids
if [ -f "$RETRO_LOG" ]; then
  bad_retro=$(jq -r '.story_id // empty' "$RETRO_LOG" | grep -v '^[0-9][0-9][0-9][0-9]$' || true)
  if [ -n "$bad_retro" ]; then
    echo "  ERROR: Non-numeric story_ids in log.jsonl:"
    echo "$bad_retro" | head -5 | sed 's/^/    /'
    errors=$((errors + 1))
  else
    echo "All retrospectives/log.jsonl story_ids are 4-digit numbers."
  fi
fi

echo ""
if [ "$errors" -eq 0 ]; then
  echo "Migration completed successfully!"
else
  echo "Migration completed with $errors error(s). Please review."
  exit 1
fi

# Cleanup
rm -f "$MAPFILE"
