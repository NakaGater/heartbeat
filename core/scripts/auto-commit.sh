#!/bin/bash
# Auto-commit when a subagent finishes.
# Reads SubagentStop hook stdin JSON to extract agent info.
# Dependency: jq

# --- Function definitions ---

# Internal helper: locate a board.jsonl under .heartbeat/stories.
# Args: $1 (optional) -- story-id for deterministic lookup
# Output: full path to board.jsonl, or empty string if not found
_find_board_jsonl() {
  local story_id="${1:-}"
  local project_dir="${CLAUDE_PROJECT_DIR:-.}"

  if [ -n "$story_id" ]; then
    local path="$project_dir/.heartbeat/stories/$story_id/board.jsonl"
    [ -f "$path" ] && echo "$path"
    return 0
  fi

  # Fallback: most recently modified board.jsonl
  ls -t "$project_dir"/.heartbeat/stories/*/board.jsonl 2>/dev/null | head -1
}

# Extract agent name from stdin JSON, with fallback to board.jsonl,
# then to "unknown".
# Args: $1 -- stdin JSON string
# Output: agent name on stdout (always returns a value)
get_agent_name() {
  local input="$1"
  local agent

  # 1. stdin JSON の .agent_type
  agent=$(echo "$input" | jq -r '.agent_type // empty' 2>/dev/null)
  if [ -n "$agent" ]; then
    echo "$agent"
    return 0
  fi

  # 2. board.jsonl 最新エントリの .from
  local board
  board=$(_find_board_jsonl)
  if [ -n "$board" ]; then
    agent=$(tail -1 "$board" | jq -r '.from // empty' 2>/dev/null)
    if [ -n "$agent" ]; then
      echo "$agent"
      return 0
    fi
  fi

  # 3. フォールバック
  echo "unknown"
}

# Map Heartbeat agent name to Conventional Commits type.
# Args: $1 -- agent name
# Output: type string on stdout (always returns a value)
map_agent_to_type() {
  local agent="$1"
  case "$agent" in
    tester)           echo "test" ;;
    implementer)      echo "feat" ;;
    refactor)         echo "refactor" ;;
    *)                echo "chore" ;;
  esac
}

# Extract the active story ID from the board.jsonl directory path.
# Output: story ID on stdout, or empty string if not found
get_story_scope() {
  local board
  board=$(_find_board_jsonl)
  if [ -n "$board" ]; then
    basename "$(dirname "$board")"
    return 0
  fi
  echo ""
}

# Derive scope from staged file paths.
# No args. Reads git diff --cached --name-only internally.
# Output: scope string on stdout (may be empty)
get_scope_from_diff() {
  local project_dir="${CLAUDE_PROJECT_DIR:-.}"
  local files
  files=$(git -C "$project_dir" diff --cached --name-only 2>/dev/null)

  # No staged files
  if [ -z "$files" ]; then
    echo ""
    return 0
  fi

  local file_count
  file_count=$(echo "$files" | wc -l | tr -d ' ')

  # Single file: use filename without extension
  if [ "$file_count" -eq 1 ]; then
    local filename
    filename=$(basename "$files")
    echo "${filename%.*}"
    return 0
  fi

  # Check if all files share a common top-level directory pattern
  # .heartbeat/stories/{story-id}/ -> story-id
  local story_ids
  story_ids=$(echo "$files" | grep '^\.heartbeat/stories/' | sed 's|^\.heartbeat/stories/\([^/]*\)/.*|\1|' | sort -u)
  local non_story_files
  non_story_files=$(echo "$files" | grep -v '^\.heartbeat/stories/' | head -1)

  if [ -n "$story_ids" ] && [ -z "$non_story_files" ]; then
    local story_count
    story_count=$(echo "$story_ids" | wc -l | tr -d ' ')
    if [ "$story_count" -eq 1 ]; then
      echo "$story_ids"
      return 0
    fi
  fi

  # tests/ only -> "tests"
  local non_test_files
  non_test_files=$(echo "$files" | grep -v '^tests/' | head -1)
  if [ -z "$non_test_files" ]; then
    echo "tests"
    return 0
  fi

  # core/scripts/ only -> script name (without extension) if single script, else "scripts"
  local non_scripts_files
  non_scripts_files=$(echo "$files" | grep -v '^core/scripts/' | head -1)
  if [ -z "$non_scripts_files" ]; then
    local script_names
    script_names=$(echo "$files" | sed 's|^core/scripts/||' | sed 's|\.[^.]*$||' | sort -u)
    local script_count
    script_count=$(echo "$script_names" | wc -l | tr -d ' ')
    if [ "$script_count" -eq 1 ]; then
      echo "$script_names"
      return 0
    fi
    echo "scripts"
    return 0
  fi

  # adapters/{platform}/ only -> platform name
  local non_adapter_files
  non_adapter_files=$(echo "$files" | grep -v '^adapters/' | head -1)
  if [ -z "$non_adapter_files" ]; then
    local platforms
    platforms=$(echo "$files" | sed 's|^adapters/\([^/]*\)/.*|\1|' | sort -u)
    local platform_count
    platform_count=$(echo "$platforms" | wc -l | tr -d ' ')
    if [ "$platform_count" -eq 1 ]; then
      echo "$platforms"
      return 0
    fi
  fi

  # Multiple areas -> empty scope
  echo ""
}

# Trim trailing period and truncate to 72 characters (69 + "...").
# Args: $1 -- raw description string
# Output: cleaned description on stdout
_truncate_description() {
  local desc="$1"
  # Remove trailing period (Conventional Commits convention)
  desc="${desc%.}"
  # Truncate to 69 chars + "..." if over 72 characters
  if [ "${#desc}" -gt 72 ]; then
    desc="${desc:0:69}..."
  fi
  echo "$desc"
}

# Generate the commit description from multiple sources.
# Fallback chain: board.jsonl .note -> last_assistant_message -> git diff --stat
# Args: $1 -- stdin JSON string
# Output: description on stdout (may be empty; caller handles final fallback)
get_description() {
  local input="$1"
  local project_dir="${CLAUDE_PROJECT_DIR:-.}"
  local desc

  # 1. board.jsonl 最新エントリの .note
  local board
  board=$(_find_board_jsonl)
  if [ -n "$board" ]; then
    desc=$(tail -1 "$board" | jq -r '.note // empty' 2>/dev/null)
    if [ -n "$desc" ]; then
      _truncate_description "$desc"
      return 0
    fi
  fi

  # 2. input JSON の .last_assistant_message 先頭行
  desc=$(printf '%s' "$input" | jq -r '.last_assistant_message // empty' 2>/dev/null | head -1)
  if [ -n "$desc" ]; then
    _truncate_description "$desc"
    return 0
  fi

  # 3. git diff --cached --stat サマリーにフォールバック
  desc=$(git -C "$project_dir" diff --cached --stat 2>/dev/null | tail -1 | sed 's/^ *//')
  if [ -n "$desc" ]; then
    _truncate_description "$desc"
    return 0
  fi

  echo ""
}

# Assemble a Conventional Commits message: "<type>(<scope>): <desc>"
# or "<type>: <desc>" when scope is empty.
# Args: $1 -- type, $2 -- scope, $3 -- description
format_commit_message() {
  local type="$1"
  local scope="$2"
  local description="$3"
  if [ -n "$scope" ]; then
    echo "${type}(${scope}): ${description}"
  else
    echo "${type}: ${description}"
  fi
}

# Orchestrate agent detection, type mapping, scope/description extraction,
# and git commit.
main() {
  set -euo pipefail
  local project_dir="${CLAUDE_PROJECT_DIR:-.}"
  cd "$project_dir"

  local input
  input=$(cat)

  # Exit silently if no changes (staged or unstaged)
  if ! git status --porcelain | grep -q .; then
    exit 0
  fi

  local agent type scope desc msg
  agent=$(get_agent_name "$input")
  type=$(map_agent_to_type "$agent")
  scope=$(get_story_scope)
  desc=$(get_description "$input")

  # Fallback description if still empty
  [ -z "$desc" ] && desc="update files"

  msg=$(format_commit_message "$type" "$scope" "$desc")

  git add -A
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
fi
