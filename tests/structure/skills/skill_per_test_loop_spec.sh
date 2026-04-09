# Tests for SKILL.md Phase 3 per-test nested loop structure (tdd-workflow story, Task 5)

CLAUDE_SKILL="adapters/claude-code/skills/heartbeat/SKILL.md"
COPILOT_SKILL="adapters/copilot/skills/heartbeat/SKILL.md"

# --- CC1: Phase 3 has nested structure (outer task loop + inner per-test loop) ---

check_phase3_nested_structure() {
  # Extract Phase 3 section: from "Phase 3" up to "Phase 4"
  phase3_section=$(sed -n '/^Phase 3/,/^Phase 4/p' "$CLAUDE_SKILL" | sed '$d')
  # Must contain the outer loop marker
  echo "$phase3_section" | grep -q "outer loop" || return 1
  # Must contain the inner loop marker
  echo "$phase3_section" | grep -q "Per-test inner loop" || return 1
}

# --- CC2: Both SKILL.md files have identical Phase 3 sections ---

check_phase3_identical_across_adapters() {
  # Extract Phase 3 section from Claude Code SKILL.md
  claude_phase3=$(sed -n '/^Phase 3/,/^Phase 4/p' "$CLAUDE_SKILL" | sed '$d')
  # Extract Phase 3 section from Copilot SKILL.md
  copilot_phase3=$(sed -n '/^Phase 3/,/^Phase 4/p' "$COPILOT_SKILL" | sed '$d')
  # Both must be non-empty
  [ -n "$claude_phase3" ] || return 1
  [ -n "$copilot_phase3" ] || return 1
  # Compare: sections must be identical
  [ "$claude_phase3" = "$copilot_phase3" ] || return 1
}

# --- CC3: Inner loop uses "write_next_test" action name ---

check_inner_loop_uses_write_next_test() {
  # Extract Phase 3 section from Claude Code SKILL.md
  phase3_section=$(sed -n '/^Phase 3/,/^Phase 4/p' "$CLAUDE_SKILL" | sed '$d')
  # The inner loop must reference "write_next_test" as the action name
  echo "$phase3_section" | grep -q "write_next_test" || return 1
}

Describe 'SKILL.md Phase 3 per-test nested loop structure'
  It 'contains nested structure with outer task loop and per-test inner loop'
    When call check_phase3_nested_structure
    The status should be success
  End

  It 'has identical Phase 3 section in both Claude Code and Copilot SKILL.md'
    When call check_phase3_identical_across_adapters
    The status should be success
  End

  It 'uses write_next_test action in inner loop for continuing tests within a task'
    When call check_inner_loop_uses_write_next_test
    The status should be success
  End
End
