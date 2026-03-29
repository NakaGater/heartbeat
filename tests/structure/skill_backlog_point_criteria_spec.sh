# Tests for heartbeat-backlog SKILL.md updates (point-criteria story, Task 6)
# CC1: Valid point values documented as 1, 2, or 3
# CC2: No examples use point values outside the 1-3 range
# CC3: Both adapter heartbeat-backlog SKILL.md files have identical point-related content (AC9)

CLAUDE_BACKLOG_SKILL="adapters/claude-code/skills/heartbeat-backlog/SKILL.md"
COPILOT_BACKLOG_SKILL="adapters/copilot/skills/heartbeat-backlog/SKILL.md"

# --- CC1: Valid point values documented as 1, 2, or 3 ---

check_claude_backlog_valid_point_values() {
  grep -qi "valid.*point.*values\|valid.*values.*1.*2.*3\|1.*Clear.*2.*Challenging.*3.*Uncertain" "$CLAUDE_BACKLOG_SKILL" || return 1
}

check_copilot_backlog_valid_point_values() {
  grep -qi "valid.*point.*values\|valid.*values.*1.*2.*3\|1.*Clear.*2.*Challenging.*3.*Uncertain" "$COPILOT_BACKLOG_SKILL" || return 1
}

check_claude_backlog_important_notes_point_criteria() {
  # Important Notes section must document the 1-3 scale with complexity/uncertainty semantics
  grep -qi "complexity.*uncertainty\|complexity/uncertainty" "$CLAUDE_BACKLOG_SKILL" || return 1
}

check_copilot_backlog_important_notes_point_criteria() {
  grep -qi "complexity.*uncertainty\|complexity/uncertainty" "$COPILOT_BACKLOG_SKILL" || return 1
}

check_claude_backlog_change_points_validation_guidance() {
  # Change Points section must warn about invalid values outside 1-3
  grep -qi "outside 1-3\|warn.*valid\|ask for a valid" "$CLAUDE_BACKLOG_SKILL" || return 1
}

check_copilot_backlog_change_points_validation_guidance() {
  grep -qi "outside 1-3\|warn.*valid\|ask for a valid" "$COPILOT_BACKLOG_SKILL" || return 1
}

# --- CC2: No examples use point values outside the 1-3 range ---

check_claude_backlog_no_out_of_range_examples() {
  # Examples showing point values (Npt) must only use 1, 2, or 3
  # Match patterns like (5pt), (8pt), (13pt), "to 5", "to 8" etc. in example contexts
  if grep -E '\([456789][0-9]*pt\)' "$CLAUDE_BACKLOG_SKILL" > /dev/null 2>&1; then
    return 1
  fi
  if grep -Ei 'points to [456789][0-9]*"?' "$CLAUDE_BACKLOG_SKILL" > /dev/null 2>&1; then
    return 1
  fi
  return 0
}

check_copilot_backlog_no_out_of_range_examples() {
  if grep -E '\([456789][0-9]*pt\)' "$COPILOT_BACKLOG_SKILL" > /dev/null 2>&1; then
    return 1
  fi
  if grep -Ei 'points to [456789][0-9]*"?' "$COPILOT_BACKLOG_SKILL" > /dev/null 2>&1; then
    return 1
  fi
  return 0
}

# --- CC3: Adapter symmetry -- point-related content is identical (AC9) ---

extract_backlog_point_lines() {
  grep -i "1pt\|2pt\|3pt\|1.*Clear\|2.*Challenging\|3.*Uncertain\|complexity.*uncertainty\|complexity/uncertainty\|valid.*point\|valid.*values\|outside 1-3\|warn.*valid\|ask for a valid\|not workload" "$1" 2>/dev/null | sort
}

check_backlog_adapter_symmetry_point_content() {
  claude_lines=$(extract_backlog_point_lines "$CLAUDE_BACKLOG_SKILL")
  copilot_lines=$(extract_backlog_point_lines "$COPILOT_BACKLOG_SKILL")
  [ -n "$claude_lines" ] || return 1
  [ "$claude_lines" = "$copilot_lines" ] || return 1
}

Describe 'Heartbeat-backlog SKILL.md point criteria (Task 6)'

  Describe 'Valid point values documented as 1, 2, or 3 (CC1)'
    It 'claude-code backlog SKILL.md documents valid point values'
      When call check_claude_backlog_valid_point_values
      The status should be success
    End

    It 'copilot backlog SKILL.md documents valid point values'
      When call check_copilot_backlog_valid_point_values
      The status should be success
    End

    It 'claude-code backlog SKILL.md references complexity/uncertainty'
      When call check_claude_backlog_important_notes_point_criteria
      The status should be success
    End

    It 'copilot backlog SKILL.md references complexity/uncertainty'
      When call check_copilot_backlog_important_notes_point_criteria
      The status should be success
    End

    It 'claude-code backlog SKILL.md has validation guidance for out-of-range values'
      When call check_claude_backlog_change_points_validation_guidance
      The status should be success
    End

    It 'copilot backlog SKILL.md has validation guidance for out-of-range values'
      When call check_copilot_backlog_change_points_validation_guidance
      The status should be success
    End
  End

  Describe 'No examples use point values outside 1-3 range (CC2)'
    It 'claude-code backlog SKILL.md has no out-of-range point examples'
      When call check_claude_backlog_no_out_of_range_examples
      The status should be success
    End

    It 'copilot backlog SKILL.md has no out-of-range point examples'
      When call check_copilot_backlog_no_out_of_range_examples
      The status should be success
    End
  End

  Describe 'Adapter symmetry for point-related content (CC3 / AC9)'
    It 'point-related lines are identical between claude-code and copilot'
      When call check_backlog_adapter_symmetry_point_content
      The status should be success
    End
  End

End
