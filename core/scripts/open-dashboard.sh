#!/bin/bash
# Open .heartbeat/dashboard.html in the default browser.
# Called from SubagentStart hook. Must exit 0 on all paths.
set +e

# Skip inside worktrees
if [ "${HEARTBEAT_IN_WORKTREE:-}" = "1" ]; then
  exit 0
fi

PROJECT_ROOT="${HEARTBEAT_ROOT:-.}"
DASHBOARD="$PROJECT_ROOT/.heartbeat/dashboard.html"

# Skip if dashboard does not exist yet
if [ ! -f "$DASHBOARD" ]; then
  exit 0
fi

# Determine OS and open command
case "$(uname -s)" in
  Darwin) open "$DASHBOARD" ;;
  Linux)  xdg-open "$DASHBOARD" ;;
esac

exit 0
