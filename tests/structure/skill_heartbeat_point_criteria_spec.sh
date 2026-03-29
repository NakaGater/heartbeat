# Tests for heartbeat SKILL.md updates (point-criteria story, Task 5)
# CC1: 3pt gate branch after architect estimation step in Workflow 1
# CC2: backlog schema documents valid point values as 1, 2, or 3
# CC3: Both adapter SKILL.md files have identical point-related content (AC9)

CLAUDE_SKILL="adapters/claude-code/skills/heartbeat/SKILL.md"
COPILOT_SKILL="adapters/copilot/skills/heartbeat/SKILL.md"

# --- CC1: Workflow 1 contains a 3pt gate branch after architect estimation ---

check_claude_skill_3pt_gate_branch() {
  grep -qi "3pt\|3 *pt" "$CLAUDE_SKILL" | head -1 > /dev/null 2>&1
  # Must mention 3pt gate logic in workflow context
  grep -qi "if.*3pt\|3pt.*gate\|estimates 3pt\|architect.*3pt\|3pt.*split_story\|3pt.*rework\|3pt.*pdm" "$CLAUDE_SKILL" || return 1
}

check_copilot_skill_3pt_gate_branch() {
  grep -qi "if.*3pt\|3pt.*gate\|estimates 3pt\|architect.*3pt\|3pt.*split_story\|3pt.*rework\|3pt.*pdm" "$COPILOT_SKILL" || return 1
}

check_claude_skill_3pt_split_story_action() {
  grep -q "split_story" "$CLAUDE_SKILL" || return 1
}

check_copilot_skill_3pt_split_story_action() {
  grep -q "split_story" "$COPILOT_SKILL" || return 1
}

check_claude_skill_3pt_rework_status() {
  grep -q "rework" "$CLAUDE_SKILL" || return 1
}

check_copilot_skill_3pt_rework_status() {
  grep -q "rework" "$COPILOT_SKILL" || return 1
}

check_claude_skill_1_2pt_proceed() {
  grep -qi "1.*2.*pt.*proceed\|1-2pt\|1pt.*2pt.*proceed\|estimates 1-2pt\|proceed to approval" "$CLAUDE_SKILL" || return 1
}

check_copilot_skill_1_2pt_proceed() {
  grep -qi "1.*2.*pt.*proceed\|1-2pt\|1pt.*2pt.*proceed\|estimates 1-2pt\|proceed to approval" "$COPILOT_SKILL" || return 1
}

# --- CC2: backlog schema documents valid point values as 1, 2, or 3 ---

check_claude_skill_points_valid_values() {
  grep -qi "points.*1.*2.*3\|valid.*values.*1.*2.*3\|1=Clear.*2=Challenging.*3=Uncertain" "$CLAUDE_SKILL" || return 1
}

check_copilot_skill_points_valid_values() {
  grep -qi "points.*1.*2.*3\|valid.*values.*1.*2.*3\|1=Clear.*2=Challenging.*3=Uncertain" "$COPILOT_SKILL" || return 1
}

check_claude_skill_points_complexity_uncertainty() {
  grep -qi "complexity.*uncertainty\|complexity/uncertainty" "$CLAUDE_SKILL" || return 1
}

check_copilot_skill_points_complexity_uncertainty() {
  grep -qi "complexity.*uncertainty\|complexity/uncertainty" "$COPILOT_SKILL" || return 1
}

# --- CC3: Adapter symmetry -- point-related content is identical (AC9) ---

extract_point_lines() {
  # Extract lines that contain point-related keywords for comparison
  grep -i "3pt\|1pt\|2pt\|split_story\|rework\|complexity.*uncertainty\|complexity/uncertainty\|1=Clear\|2=Challenging\|3=Uncertain\|valid.*values.*1.*2.*3\|points.*(1\|human override\|1-2pt\|proceed to approval" "$1" 2>/dev/null | sort
}

check_adapter_symmetry_point_content() {
  claude_lines=$(extract_point_lines "$CLAUDE_SKILL")
  copilot_lines=$(extract_point_lines "$COPILOT_SKILL")
  [ -n "$claude_lines" ] || return 1
  [ "$claude_lines" = "$copilot_lines" ] || return 1
}

Describe 'Heartbeat SKILL.md point criteria (Task 5)'

  Describe 'Workflow 1 3pt gate branch (CC1)'
    It 'claude-code SKILL.md contains a 3pt gate branch'
      When call check_claude_skill_3pt_gate_branch
      The status should be success
    End

    It 'copilot SKILL.md contains a 3pt gate branch'
      When call check_copilot_skill_3pt_gate_branch
      The status should be success
    End

    It 'claude-code SKILL.md references split_story action'
      When call check_claude_skill_3pt_split_story_action
      The status should be success
    End

    It 'copilot SKILL.md references split_story action'
      When call check_copilot_skill_3pt_split_story_action
      The status should be success
    End

    It 'claude-code SKILL.md references rework status'
      When call check_claude_skill_3pt_rework_status
      The status should be success
    End

    It 'copilot SKILL.md references rework status'
      When call check_copilot_skill_3pt_rework_status
      The status should be success
    End

    It 'claude-code SKILL.md shows 1-2pt proceed to approval'
      When call check_claude_skill_1_2pt_proceed
      The status should be success
    End

    It 'copilot SKILL.md shows 1-2pt proceed to approval'
      When call check_copilot_skill_1_2pt_proceed
      The status should be success
    End
  End

  Describe 'Backlog schema valid point values (CC2)'
    It 'claude-code SKILL.md documents valid point values 1, 2, 3'
      When call check_claude_skill_points_valid_values
      The status should be success
    End

    It 'copilot SKILL.md documents valid point values 1, 2, 3'
      When call check_copilot_skill_points_valid_values
      The status should be success
    End

    It 'claude-code SKILL.md references complexity/uncertainty'
      When call check_claude_skill_points_complexity_uncertainty
      The status should be success
    End

    It 'copilot SKILL.md references complexity/uncertainty'
      When call check_copilot_skill_points_complexity_uncertainty
      The status should be success
    End
  End

  Describe 'Adapter symmetry for point-related content (CC3 / AC9)'
    It 'point-related lines are identical between claude-code and copilot'
      When call check_adapter_symmetry_point_content
      The status should be success
    End
  End

End
