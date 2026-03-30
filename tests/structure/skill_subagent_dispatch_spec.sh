SKILL_FILE="adapters/claude-code/skills/heartbeat/SKILL.md"

# --- Condition 1: SKILL.md contains subagent-related keywords ---
check_subagent_keywords() {
  grep -q "subagent" "$SKILL_FILE" &&
  grep -q "Subagent responsibilities" "$SKILL_FILE" &&
  grep -q "Orchestrator responsibilities" "$SKILL_FILE"
}

# --- Condition 2: Claude Code Agent tool invocation pattern ---
check_invocation_pattern() {
  grep -q 'heartbeat:.*\.agent' "$SKILL_FILE"
}

# --- Condition 3: Responsibilities split into Subagent (1-4) and Orchestrator (5-7) ---
check_responsibility_separation() {
  # Subagent section must contain numbered items 1-4
  local subagent_section
  subagent_section=$(sed -n '/### Subagent responsibilities/,/### /p' "$SKILL_FILE")
  echo "$subagent_section" | grep -qE '^\s*[1-4]\.' || return 1

  # Orchestrator section must contain numbered items 5-7
  local orchestrator_section
  orchestrator_section=$(sed -n '/### Orchestrator responsibilities/,/^##[^#]/p' "$SKILL_FILE")
  echo "$orchestrator_section" | grep -qE '^\s*[5-7]\.' || return 1
}

Describe 'SKILL.md subagent dispatch: Agent Startup Method'
  It 'contains subagent, Subagent responsibilities, and Orchestrator responsibilities keywords'
    When call check_subagent_keywords
    The status should be success
  End

  It 'documents Claude Code Agent tool invocation pattern heartbeat:{name}.agent'
    When call check_invocation_pattern
    The status should be success
  End

  It 'separates responsibilities into Subagent (1-4) and Orchestrator (5-7)'
    When call check_responsibility_separation
    The status should be success
  End
End
