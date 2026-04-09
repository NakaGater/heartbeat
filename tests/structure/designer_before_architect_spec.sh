# Consolidated structure tests for 0051-designer-before-architect (Task 4)
# Covers: core SKILL.md Phase 2, copilot SKILL.md Phase 2, architect.md design.md check

CORE_SKILL="core/skills/heartbeat/SKILL.md"
COPILOT_SKILL="adapters/copilot/skills/heartbeat/SKILL.md"
ARCHITECT="core/agent-personas/architect.md"

# Helper: extract Phase 2 section from core SKILL.md
extract_core_phase2() {
  sed -n '/^Phase 2/,/^Phase 3/p' "$CORE_SKILL" | sed '$d'
}

# Helper: extract Phase 2 section from copilot SKILL.md
extract_copilot_phase2() {
  sed -n '/^Phase 2/,/^Phase 3/p' "$COPILOT_SKILL" | sed '$d'
}

# --- core SKILL.md Phase 2: Step 1 / Step 2 ---

check_core_phase2_has_step1_and_step2() {
  phase2=$(extract_core_phase2)
  echo "$phase2" | grep -q "Step 1" || return 1
  echo "$phase2" | grep -q "Step 2" || return 1
}

# --- copilot SKILL.md Phase 2: Step 1 / Step 2 ---

check_copilot_phase2_has_step1_and_step2() {
  phase2=$(extract_copilot_phase2)
  echo "$phase2" | grep -q "Step 1" || return 1
  echo "$phase2" | grep -q "Step 2" || return 1
}

# --- architect.md: design.md existence check ---

check_architect_has_design_md_check() {
  grep -qi "Phase 2.*Input\|Phase 2.*Validation\|Phase 2.*入力" "$ARCHITECT" || return 1
  grep -q "design\.md" "$ARCHITECT" || return 1
}

Describe 'designer-before-architect consolidated structure tests (Task 4)'
  It 'core SKILL.md Phase 2 has Step 1 and Step 2 ordering'
    When call check_core_phase2_has_step1_and_step2
    The status should be success
  End

  It 'copilot SKILL.md Phase 2 has Step 1 and Step 2 ordering'
    When call check_copilot_phase2_has_step1_and_step2
    The status should be success
  End

  It 'architect.md contains design.md existence check for Phase 2'
    When call check_architect_has_design_md_check
    The status should be success
  End
End
