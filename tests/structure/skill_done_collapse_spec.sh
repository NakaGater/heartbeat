CLAUDE_SKILL="adapters/claude-code/skills/heartbeat/SKILL.md"
COPILOT_SKILL="adapters/copilot/skills/heartbeat/SKILL.md"

check_done_summary_pattern_claude() {
  grep -q 'Done:' "$CLAUDE_SKILL" &&
  grep -q 'stories' "$CLAUDE_SKILL" &&
  grep -q 'pt)' "$CLAUDE_SKILL"
}

check_done_summary_pattern_copilot() {
  grep -q 'Done:' "$COPILOT_SKILL" &&
  grep -q 'stories' "$COPILOT_SKILL" &&
  grep -q 'pt)' "$COPILOT_SKILL"
}

check_no_individual_done_listing_claude() {
  # Status Display Example should NOT have individual done items like "✅ login: Login feature (3pt) Done"
  ! grep -q '✅.*Done$' "$CLAUDE_SKILL"
}

check_startup_collapse_instruction_claude() {
  grep -q 'Done' "$CLAUDE_SKILL" &&
  grep -q 'summary\|サマリー\|collapse\|折りたた' "$CLAUDE_SKILL"
}

check_startup_collapse_instruction_copilot() {
  grep -q 'Done' "$COPILOT_SKILL" &&
  grep -q 'summary\|サマリー\|collapse\|折りたた' "$COPILOT_SKILL"
}

Describe 'SKILL.md Done collapse display'
  It 'claude-code SKILL.md has Done summary pattern in Status Display Example'
    When call check_done_summary_pattern_claude
    The status should be success
  End

  It 'copilot SKILL.md has Done summary pattern in Status Display Example'
    When call check_done_summary_pattern_copilot
    The status should be success
  End

  It 'claude-code SKILL.md does not list individual Done items in example'
    When call check_no_individual_done_listing_claude
    The status should be success
  End

  It 'claude-code SKILL.md has Done collapse instruction in Startup Behavior'
    When call check_startup_collapse_instruction_claude
    The status should be success
  End

  It 'copilot SKILL.md has Done collapse instruction in Startup Behavior'
    When call check_startup_collapse_instruction_copilot
    The status should be success
  End
End
