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

# Internal helper: count lines in a string.
# Args: $1 -- string to count lines in
# Output: line count on stdout (trimmed)
_count_lines() {
  echo "$1" | wc -l | tr -d ' '
}

# Internal helper: check whether all files reside under a given prefix.
# Args: $1 -- file list, $2 -- grep pattern (e.g. '^tests/')
# Returns: 0 if all files match the pattern, 1 otherwise
_all_files_match() {
  local files="$1" pattern="$2"
  [ -z "$(echo "$files" | grep -v "$pattern" | head -1)" ]
}

# Internal helper: return staged file list from git.
# No args. Uses CLAUDE_PROJECT_DIR for repo location.
# Output: newline-separated file paths on stdout (may be empty)
_get_staged_files() {
  local project_dir="${CLAUDE_PROJECT_DIR:-.}"
  git -C "$project_dir" diff --cached --name-only 2>/dev/null
}

# Derive scope from staged file paths.
# No args. Reads git diff --cached --name-only internally.
# Output: scope string on stdout (may be empty)
get_scope_from_diff() {
  local files
  files=$(_get_staged_files)

  # No staged files
  if [ -z "$files" ]; then
    echo ""
    return 0
  fi

  # Single file: use filename without extension
  if [ "$(_count_lines "$files")" -eq 1 ]; then
    local filename
    filename=$(basename "$files")
    echo "${filename%.*}"
    return 0
  fi

  # .heartbeat/stories/{story-id}/ -> story-id (if single story)
  if _all_files_match "$files" '^\.heartbeat/stories/'; then
    local story_ids
    story_ids=$(echo "$files" | sed 's|^\.heartbeat/stories/\([^/]*\)/.*|\1|' | sort -u)
    if [ "$(_count_lines "$story_ids")" -eq 1 ]; then
      echo "$story_ids"
      return 0
    fi
  fi

  # tests/ only -> "tests"
  if _all_files_match "$files" '^tests/'; then
    echo "tests"
    return 0
  fi

  # core/scripts/ only -> script name (without extension) if single, else "scripts"
  if _all_files_match "$files" '^core/scripts/'; then
    local script_names
    script_names=$(echo "$files" | sed 's|^core/scripts/||' | sed 's|\.[^.]*$||' | sort -u)
    if [ "$(_count_lines "$script_names")" -eq 1 ]; then
      echo "$script_names"
      return 0
    fi
    echo "scripts"
    return 0
  fi

  # adapters/{platform}/ only -> platform name (if single platform)
  if _all_files_match "$files" '^adapters/'; then
    local platforms
    platforms=$(echo "$files" | sed 's|^adapters/\([^/]*\)/.*|\1|' | sort -u)
    if [ "$(_count_lines "$platforms")" -eq 1 ]; then
      echo "$platforms"
      return 0
    fi
  fi

  # Multiple areas -> empty scope
  echo ""
}

# Derive Conventional Commits type from staged file paths.
# No args. Reads git diff --cached --name-only internally.
# Output: type string on stdout (always returns a value)
get_type_from_diff() {
  local files
  files=$(_get_staged_files)

  # No staged files -> chore
  if [ -z "$files" ]; then
    echo "chore"
    return 0
  fi

  local has_test_files=false
  local has_impl_files=false
  local has_heartbeat_files=false
  local has_other_files=false

  while IFS= read -r f; do
    case "$f" in
      tests/*)           has_test_files=true ;;
      core/scripts/*)    has_impl_files=true ;;
      core/*)            has_impl_files=true ;;
      adapters/*)        has_impl_files=true ;;
      .heartbeat/*)      has_heartbeat_files=true ;;
      *)                 has_other_files=true ;;
    esac
  done <<< "$files"

  # tests/ + implementation files mixed -> feat (implementation is primary)
  if [ "$has_impl_files" = true ]; then
    echo "feat"
    return 0
  fi

  # tests/ only -> test
  if [ "$has_test_files" = true ] && [ "$has_heartbeat_files" = false ] && [ "$has_other_files" = false ]; then
    echo "test"
    return 0
  fi

  # .heartbeat/ only -> chore
  if [ "$has_heartbeat_files" = true ] && [ "$has_test_files" = false ] && [ "$has_other_files" = false ]; then
    echo "chore"
    return 0
  fi

  # Default
  echo "chore"
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

# Generate commit description from staged file metadata.
# No args. Reads git diff --cached internally.
# Output: description string on stdout (never empty)
get_description_from_diff() {
  local files
  files=$(_get_staged_files)

  # No staged files
  if [ -z "$files" ]; then
    echo "update files"
    return 0
  fi

  local file_count
  file_count=$(_count_lines "$files")

  # Determine verb: check if all files are new (added) or all deleted
  local project_dir="${CLAUDE_PROJECT_DIR:-.}"
  local added_files
  added_files=$(git -C "$project_dir" diff --cached --name-only --diff-filter=A 2>/dev/null)
  local deleted_files
  deleted_files=$(git -C "$project_dir" diff --cached --name-only --diff-filter=D 2>/dev/null)

  local verb="update"
  if [ -n "$added_files" ] && [ -z "$deleted_files" ]; then
    local added_count
    added_count=$(_count_lines "$added_files")
    if [ "$added_count" -eq "$file_count" ]; then
      verb="add"
    fi
  elif [ -n "$deleted_files" ] && [ -z "$added_files" ]; then
    local deleted_count
    deleted_count=$(_count_lines "$deleted_files")
    if [ "$deleted_count" -eq "$file_count" ]; then
      verb="remove"
    fi
  fi

  # Single file
  if [ "$file_count" -eq 1 ]; then
    local filename
    filename=$(basename "$files")
    _truncate_description "$verb $filename"
    return 0
  fi

  # Multiple files: check if all in same directory
  local dirs
  dirs=$(echo "$files" | xargs -I{} dirname {} | sort -u)
  local dir_count
  dir_count=$(_count_lines "$dirs")

  if [ "$dir_count" -eq 1 ]; then
    _truncate_description "$verb $file_count files in $dirs"
  else
    _truncate_description "$verb $file_count files across $dir_count directories"
  fi
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
  scope=$(get_scope_from_diff)
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
fi
