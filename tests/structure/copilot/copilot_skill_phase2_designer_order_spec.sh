# Tests for copilot SKILL.md Phase 2 designer-before-architect ordering (0051, Task 2)

COPILOT_SKILL="adapters/copilot/skills/heartbeat/SKILL.md"

# Helper: extract Phase 2 section from Workflow 2 (from "Phase 2" to "Phase 3")
extract_copilot_phase2() {
  sed -n '/^Phase 2/,/^Phase 3/p' "$COPILOT_SKILL" | sed '$d'
}

# --- CC1: Phase 2 has Step 1 and Step 2 ordering numbers ---

check_copilot_phase2_has_step_numbers() {
  phase2=$(extract_copilot_phase2)
  echo "$phase2" | grep -q "Step 1" || return 1
  echo "$phase2" | grep -q "Step 2" || return 1
}

Describe 'Copilot SKILL.md Phase 2 designer-before-architect ordering (Task 2)'
  It 'has Step 1 and Step 2 ordering numbers in Phase 2'
    When call check_copilot_phase2_has_step_numbers
    The status should be success
  End
End
