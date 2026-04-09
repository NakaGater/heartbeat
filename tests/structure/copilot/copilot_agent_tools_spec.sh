AGENTS_DIR="adapters/copilot/agents"

# --- Helper: extract tools list from YAML front matter ---
# Outputs one tool name per line from the tools: block
extract_tools() {
  local file="$1"
  sed -n '/^---$/,/^---$/p' "$file" \
    | sed -n '/^tools:/,/^[^ -]/p' \
    | grep '^ *- ' \
    | sed 's/^ *- //'
}

# --- Condition 1: All 9 agent files contain only recognized aliases ---
check_only_recognized_aliases() {
  for agent in "$AGENTS_DIR"/*.agent.md; do
    tools=$(extract_tools "$agent")
    while IFS= read -r tool; do
      case "$tool" in
        agent|read|edit|execute|search|playwright/*) ;;
        *) return 1 ;;
      esac
    done <<EOF
$tools
EOF
  done
}

# --- Condition 2: No old-style tool names exist anywhere ---
check_no_old_style_names() {
  for agent in "$AGENTS_DIR"/*.agent.md; do
    tools=$(extract_tools "$agent")
    echo "$tools" | grep -qE 'read_file|edit_file|create_file|shell\(|playwright\(' && return 1
  done
  return 0
}

# --- Shared helper: verify an agent has exactly the expected tools ---
# Usage: check_agent_has_tools <agent-basename> <space-separated-expected-tools>
# Expected tools are passed space-separated; both sides are sorted for comparison.
check_agent_has_tools() {
  local agent="$1"; shift
  local expected actual
  expected=$(printf '%s\n' "$@" | sort)
  actual=$(extract_tools "$AGENTS_DIR/${agent}.agent.md" | sort)
  [ "$actual" = "$expected" ]
}

Describe 'Copilot agent tools: front matter'
  It 'all 10 agents contain only recognized Copilot tool aliases'
    When call check_only_recognized_aliases
    The status should be success
  End

  It 'no old-style tool names exist (read_file, edit_file, create_file, shell(...), playwright(*))'
    When call check_no_old_style_names
    The status should be success
  End

  It 'architect agent has exactly read, edit, search'
    When call check_agent_has_tools architect read edit search
    The status should be success
  End

  It 'qa agent has read, execute, search, playwright/*'
    When call check_agent_has_tools qa read execute search "playwright/*"
    The status should be success
  End

  It 'reviewer agent has exactly read, search'
    When call check_agent_has_tools reviewer read search
    The status should be success
  End
End
