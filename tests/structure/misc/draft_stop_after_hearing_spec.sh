SKILL_FILE="core/skills/heartbeat/SKILL.md"

# Helper: extract the entire Workflow 1 section
extract_wf1() {
  local wf1_start wf1_stop
  wf1_start=$(grep -n 'Workflow 1: Create a Story' "$SKILL_FILE" | head -1 | cut -d: -f1)
  wf1_stop=$(grep -n 'END OF WORKFLOW 1' "$SKILL_FILE" | head -1 | cut -d: -f1)
  sed -n "${wf1_start},${wf1_stop}p" "$SKILL_FILE"
}

# Verify Draft-stop choice exists between pdm (hearing) and context-manager lines
check_draft_stop_between_hearing_and_context() {
  local wf1_section
  wf1_section=$(extract_wf1)

  # Get line number of pdm (hearing)
  local hearing_line
  hearing_line=$(echo "$wf1_section" | grep -n 'pdm.*hearing\|hearing.*brief' | head -1 | cut -d: -f1)
  [ -n "$hearing_line" ] || return 1

  # Get line number of context-manager
  local context_line
  context_line=$(echo "$wf1_section" | grep -n 'context-manager' | head -1 | cut -d: -f1)
  [ -n "$context_line" ] || return 1

  # Verify "Draft-stop choice" or "Stop at draft" exists between pdm (hearing) and context-manager
  local between
  between=$(echo "$wf1_section" | sed -n "${hearing_line},${context_line}p")

  echo "$between" | grep -qi 'draft.*stop\|stop.*draft'
}

Describe 'Draft-stop Choice Placed After PdM Hearing and Before context-manager (0052 Task 1)'
  It 'Draft-stop choice exists between pdm (hearing) and context-manager'
    When call check_draft_stop_between_hearing_and_context
    The status should be success
  End
End

COPILOT_SKILL_FILE="adapters/copilot/skills/heartbeat/SKILL.md"

# Helper: extract the entire Copilot Workflow 1 section
extract_copilot_wf1() {
  local wf1_start wf1_stop
  wf1_start=$(grep -n 'Workflow 1: Create a Story' "$COPILOT_SKILL_FILE" | head -1 | cut -d: -f1)
  wf1_stop=$(grep -n 'END OF WORKFLOW 1' "$COPILOT_SKILL_FILE" | head -1 | cut -d: -f1)
  sed -n "${wf1_start},${wf1_stop}p" "$COPILOT_SKILL_FILE"
}

# Copilot: Verify Draft-stop choice exists between pdm (hearing) and context-manager lines
check_copilot_draft_stop_between_hearing_and_context() {
  local wf1_section
  wf1_section=$(extract_copilot_wf1)

  # Get line number of pdm (hearing)
  local hearing_line
  hearing_line=$(echo "$wf1_section" | grep -n 'pdm.*hearing\|hearing.*brief' | head -1 | cut -d: -f1)
  [ -n "$hearing_line" ] || return 1

  # Get line number of context-manager
  local context_line
  context_line=$(echo "$wf1_section" | grep -n 'context-manager' | head -1 | cut -d: -f1)
  [ -n "$context_line" ] || return 1

  # Verify "Draft-stop choice" or "Stop at draft" exists between pdm (hearing) and context-manager
  local between
  between=$(echo "$wf1_section" | sed -n "${hearing_line},${context_line}p")

  echo "$between" | grep -qi 'draft.*stop\|stop.*draft'
}

Describe 'Copilot Draft-stop Choice Placed After PdM Hearing and Before context-manager (0052 Task 2)'
  It 'Draft-stop choice exists between pdm (hearing) and context-manager in Copilot SKILL.md'
    When call check_copilot_draft_stop_between_hearing_and_context
    The status should be success
  End
End
