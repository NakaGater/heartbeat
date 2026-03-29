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
        read|edit|execute|search|playwright/*) ;;
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

# --- Condition 3: architect has exactly read, edit, search ---
check_architect_tools() {
  tools=$(extract_tools "$AGENTS_DIR/architect.agent.md")
  expected="edit
read
search"
  actual=$(echo "$tools" | sort)
  [ "$actual" = "$expected" ]
}

# --- Condition 4: qa has read, execute, search, playwright/* ---
check_qa_tools() {
  tools=$(extract_tools "$AGENTS_DIR/qa.agent.md")
  expected="execute
playwright/*
read
search"
  actual=$(echo "$tools" | sort)
  [ "$actual" = "$expected" ]
}

# --- Condition 5: reviewer has exactly read, search ---
check_reviewer_tools() {
  tools=$(extract_tools "$AGENTS_DIR/reviewer.agent.md")
  expected="read
search"
  actual=$(echo "$tools" | sort)
  [ "$actual" = "$expected" ]
}

Describe 'Copilot agent tools: front matter'
  It 'all 9 agents contain only recognized Copilot tool aliases'
    When call check_only_recognized_aliases
    The status should be success
  End

  It 'no old-style tool names exist (read_file, edit_file, create_file, shell(...), playwright(*))'
    When call check_no_old_style_names
    The status should be success
  End

  It 'architect agent has exactly read, edit, search'
    When call check_architect_tools
    The status should be success
  End

  It 'qa agent has read, execute, search, playwright/*'
    When call check_qa_tools
    The status should be success
  End

  It 'reviewer agent has exactly read, search'
    When call check_reviewer_tools
    The status should be success
  End
End
