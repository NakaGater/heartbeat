# Tests for architect.md design.md existence check (0051, Task 3)

ARCHITECT="core/agent-personas/architect.md"

# --- CC1: architect.md contains design.md existence check instruction ---

check_has_design_md_check() {
  grep -q "design\.md" "$ARCHITECT" || return 1
  # Must mention checking existence / verifying presence
  grep -qi "exist\|存在\|verify\|check\|確認" "$ARCHITECT" | grep -qi "design\.md" && return 0
  # Alternative: look for a section about Phase 2 input validation
  grep -qi "Phase 2.*Input\|Phase 2.*Validation\|Phase 2.*入力" "$ARCHITECT" || return 1
}

# --- CC2: Contains instruction to stop / send back when design.md is missing ---

check_has_sendback_instruction() {
  # Must mention stopping or not proceeding when design.md is missing
  grep -qi "not proceed\|stop\|中断\|差し戻\|blocked" "$ARCHITECT" || return 1
  # Must be in the context of design.md missing
  grep -qi "design\.md.*not exist\|design\.md.*missing\|design\.md.*存在しない\|design\.md.*未作成" "$ARCHITECT" || return 1
}

# --- CC3: Board Protocol entry defines to: "designer" and status: "blocked" for missing design.md ---

check_board_protocol_designer_blocked_for_design_md() {
  # Must define a board protocol entry specifically for missing design.md
  # (not just the existing "technical concerns" entry)
  # Look for a board protocol subsection mentioning design.md missing
  grep -qi "design\.md.*missing\|design\.md.*未作成\|design\.md.*存在しない\|design\.md is missing" "$ARCHITECT" || return 1
  # That section must reference designer and blocked
  grep -qi "designer.*blocked\|to.*designer.*blocked" "$ARCHITECT" || return 1
}

# --- CC4: Phase 1 is explicitly excluded from design.md check ---

check_phase1_excluded() {
  # Must state that Phase 1 does not require design.md check
  grep -qi "Phase 1.*not.*require\|Phase 1.*不要\|Phase 1.*design\.md.*不要\|ONLY.*Phase 2\|Phase 2.*のみ\|Phase 2.*only" "$ARCHITECT" || return 1
}

Describe 'architect.md design.md existence check (Task 3)'
  It 'contains a Phase 2 input validation section for design.md'
    When call check_has_design_md_check
    The status should be success
  End

  It 'instructs to stop and send back when design.md is missing'
    When call check_has_sendback_instruction
    The status should be success
  End

  It 'defines Board Protocol entry with to designer and status blocked for missing design.md'
    When call check_board_protocol_designer_blocked_for_design_md
    The status should be success
  End

  It 'explicitly excludes Phase 1 from design.md check'
    When call check_phase1_excluded
    The status should be success
  End
End
