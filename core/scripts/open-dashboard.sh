#!/bin/bash
# Open .heartbeat/dashboard.html in the default browser.
# Called from SubagentStart hook. Must exit 0 on all paths.
set +e

PROJECT_ROOT="${HEARTBEAT_ROOT:-.}"
DASHBOARD="$PROJECT_ROOT/.heartbeat/dashboard.html"

open_dashboard() {
  # Skip inside worktrees
  if [ "${HEARTBEAT_IN_WORKTREE:-}" = "1" ]; then
    return 0
  fi

  # Skip if dashboard does not exist yet
  if [ ! -f "$DASHBOARD" ]; then
    return 0
  fi

  # Determine OS and open command
  case "$(uname -s)" in
    Darwin) open "$DASHBOARD" ;;
    Linux)  xdg-open "$DASHBOARD" ;;
  esac

  return 0
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  open_dashboard
  exit 0
fi
