#!/bin/bash
# worktree-env-setup.sh — Set environment variables for worktree context
# Called by WorktreeCreate hook after EnterWorktree.
# Args: $1 -- worktree name (= story-id)
set -euo pipefail

STORY_ID="${1:-}"
if [ -z "$STORY_ID" ]; then
  echo "error: story-id required" >&2
  exit 1
fi

# Detect main worktree path
MAIN_DIR=$(git worktree list --porcelain 2>/dev/null | head -1 | sed 's/^worktree //')
if [ -z "$MAIN_DIR" ]; then
  MAIN_DIR="$(pwd)"
fi

export HEARTBEAT_ACTIVE_STORY="$STORY_ID"
export HEARTBEAT_IN_WORKTREE="1"
export HEARTBEAT_MAIN_DIR="$MAIN_DIR"

echo "Heartbeat worktree environment set:"
echo "  HEARTBEAT_ACTIVE_STORY=$STORY_ID"
echo "  HEARTBEAT_IN_WORKTREE=1"
echo "  HEARTBEAT_MAIN_DIR=$MAIN_DIR"
