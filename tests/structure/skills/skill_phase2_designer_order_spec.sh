# Tests for SKILL.md Phase 2 designer-before-architect ordering (0051, Task 1)

CORE_SKILL="core/skills/heartbeat/SKILL.md"

# Helper: extract Phase 2 section from Workflow 2 (from "Phase 2" to "Phase 3")
extract_phase2() {
  sed -n '/^Phase 2/,/^Phase 3/p' "$CORE_SKILL" | sed '$d'
}

# Helper: extract Workflow 1 Phase 1 section (from "Phase 1 - Planning:" to end of Workflow 1 block)
extract_wf1_phase1() {
  sed -n '/^Phase 1 - Planning:/,/^END OF WORKFLOW 1/p' "$CORE_SKILL"
}

# --- CC1: Phase 2 has Step 1 and Step 2 ordering numbers ---

check_phase2_has_step_numbers() {
  phase2=$(extract_phase2)
  echo "$phase2" | grep -q "Step 1" || return 1
  echo "$phase2" | grep -q "Step 2" || return 1
}

# --- CC2: Phase 2 has IMPORTANT or MUST ordering enforcement ---

check_phase2_has_ordering_enforcement() {
  phase2=$(extract_phase2)
  echo "$phase2" | grep -qi "IMPORTANT\|MUST" || return 1
}

# --- CC3: Phase 2 states design.md dependency (designer output -> architect input) ---

check_phase2_has_design_md_dependency() {
  phase2=$(extract_phase2)
  # Must mention that design.md is produced by designer and consumed by architect
  echo "$phase2" | grep -q "design\.md" || return 1
  # Must mention dependency or ordering relationship between designer and architect
  echo "$phase2" | grep -qi "depend\|output.*input\|produced\|先に実行" || return 1
}

# --- CC4: Workflow 1 Phase 1 architect description is unchanged ---

check_wf1_phase1_architect_unchanged() {
  wf1_phase1=$(extract_wf1_phase1)
  # Phase 1 architect line must still exist with original wording
  echo "$wf1_phase1" | grep -q "architect (task decomposition + point estimate)" || return 1
  # Phase 1 must NOT contain Step 1/Step 2 ordering (those belong to Phase 2 only)
  if echo "$wf1_phase1" | grep -q "Step 1.*designer"; then
    return 1
  fi
}

Describe 'SKILL.md Phase 2 designer-before-architect ordering (Task 1)'
  It 'has Step 1 and Step 2 ordering numbers in Phase 2'
    When call check_phase2_has_step_numbers
    The status should be success
  End

  It 'has IMPORTANT or MUST ordering enforcement directive in Phase 2'
    When call check_phase2_has_ordering_enforcement
    The status should be success
  End

  It 'states design.md dependency between designer output and architect input in Phase 2'
    When call check_phase2_has_design_md_dependency
    The status should be success
  End

  It 'leaves Workflow 1 Phase 1 architect description unchanged'
    When call check_wf1_phase1_architect_unchanged
    The status should be success
  End
End
