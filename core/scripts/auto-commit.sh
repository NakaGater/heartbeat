#!/bin/bash
# Auto-commit when a subagent finishes.
# Reads SubagentStop hook stdin JSON to extract agent info.
# Dependency: jq
set +e

# --- Load shared libraries ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/commit-message.sh"

# --- Main ---

# Orchestrate agent detection, type mapping, scope/description extraction,
# and git commit.
main() {
  local project_dir="${CLAUDE_PROJECT_DIR:-.}"
  cd "$project_dir"

  # Consume stdin (hook may provide JSON, but we no longer use it)
  cat > /dev/null

  # Exit silently if no changes (staged or unstaged)
  if ! git status --porcelain | grep -q .; then
    exit 0
  fi

  # Stage all changes first so diff --cached reflects everything
  git add -A

  local type scope desc msg
  type=$(get_type_from_diff)
  scope=$(get_story_scope)
  if [ -z "$scope" ]; then
    scope=$(get_scope_from_diff)
  fi
  desc=$(get_description_from_diff)

  msg=$(format_commit_message "$type" "$scope" "$desc")

  # --no-verify is intentional: this script runs as a SubagentStop hook,
  # so without it a pre-commit hook could re-trigger this script and
  # cause infinite recursion.
  git commit -m "$msg" --no-verify
}

# --- Main guard ---
# When sourced, only function definitions are loaded.
# When executed directly, main runs.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
  exit 0
fi
