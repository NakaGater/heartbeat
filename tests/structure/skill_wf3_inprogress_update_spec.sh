CORE_SKILL="core/skills/heartbeat/SKILL.md"
ADAPTER_SKILL="adapters/claude-code/skills/heartbeat/SKILL.md"

# Completion condition:
# SKILL.md Workflow 3 section must contain in_progress status update instruction
# This must exist in both core and adapters

extract_wf3_section() {
  sed -n '/^## Workflow 3: Create and Implement a Story/,/^## /p' "$1"
}

# Workflow 3 section contains status -> "in_progress" update instruction
check_wf3_has_inprogress_update() {
  section=$(extract_wf3_section "$1")
  [ -z "$section" ] && return 1
  echo "$section" | grep -q 'in_progress' || return 1
  echo "$section" | grep -q 'status' || return 1
}

Describe 'SKILL.md Workflow 3 Has Explicit in_progress Update Instruction'
  Describe 'core/skills/heartbeat/SKILL.md'
    It 'Workflow 3 section contains status in_progress update instruction'
      When call check_wf3_has_inprogress_update "$CORE_SKILL"
      The status should be success
    End

  End

  Describe 'adapters/claude-code/skills/heartbeat/SKILL.md'
    It 'Workflow 3 section contains status in_progress update instruction'
      When call check_wf3_has_inprogress_update "$ADAPTER_SKILL"
      The status should be success
    End
  End
End
