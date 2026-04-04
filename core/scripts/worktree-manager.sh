#!/bin/bash
# worktree-manager.sh — git worktree lifecycle management for Heartbeat
# Subcommands: list, remove, merge
# EnterWorktree handles worktree creation; this script handles the rest.
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${HEARTBEAT_MAIN_DIR:-.}}"
WORKTREE_BASE="$PROJECT_DIR/.claude/worktrees"

usage() {
  echo "usage: worktree-manager.sh <list|remove|merge> [story-id]" >&2
  exit 1
}

# --- list: show active worktrees ---
cmd_list() {
  git worktree list --porcelain 2>/dev/null | awk '
    /^worktree / { path=$2 }
    /^branch /   { branch=$2 }
    /^$/ {
      if (path ~ /\.claude\/worktrees\//) {
        n = split(path, parts, "/")
        sid = parts[n]
        printf "%s\t%s\t%s\n", sid, branch, path
      }
      path=""; branch=""
    }
    END {
      if (path ~ /\.claude\/worktrees\//) {
        n = split(path, parts, "/")
        sid = parts[n]
        printf "%s\t%s\t%s\n", sid, branch, path
      }
    }
  '
}

# --- remove: delete worktree and branch ---
cmd_remove() {
  local story_id="$1"
  local wt_path="$WORKTREE_BASE/$story_id"

  if [ ! -d "$wt_path" ]; then
    echo "error: worktree for '$story_id' not found at $wt_path" >&2
    return 1
  fi

  git worktree remove "$wt_path" 2>/dev/null || {
    echo "error: failed to remove worktree '$story_id'" >&2
    return 1
  }

  git branch -d "story/$story_id" 2>/dev/null || true
}

# --- merge: merge story branch into main, then cleanup ---
cmd_merge() {
  local story_id="$1"
  local branch="story/$story_id"

  # Verify branch exists
  if ! git rev-parse --verify "$branch" >/dev/null 2>&1; then
    echo "error: branch '$branch' not found" >&2
    return 2
  fi

  # Verify no uncommitted changes
  if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "error: uncommitted changes detected. Commit or stash before merging." >&2
    return 1
  fi

  # Switch to main and merge
  local main_branch
  main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

  git checkout "$main_branch" 2>/dev/null || {
    echo "error: failed to checkout $main_branch" >&2
    return 1
  }

  if ! git merge "$branch" 2>/dev/null; then
    echo "error: merge conflict. Resolve manually, then run: worktree-manager.sh remove $story_id" >&2
    return 1
  fi

  # Cleanup
  cmd_remove "$story_id" 2>/dev/null || true
}

# --- main ---
main() {
  [ $# -eq 0 ] && usage

  local cmd="$1"
  shift

  case "$cmd" in
    list)
      cmd_list
      ;;
    remove)
      [ $# -eq 0 ] && { echo "error: story-id required" >&2; return 1; }
      cmd_remove "$1"
      ;;
    merge)
      [ $# -eq 0 ] && { echo "error: story-id required" >&2; return 1; }
      cmd_merge "$1"
      ;;
    *)
      usage
      ;;
  esac
}

# Main guard for testability
if [ "${0##*/}" = "worktree-manager.sh" ]; then
  main "$@"
fi
