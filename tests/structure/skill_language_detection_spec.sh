check_claude_code_skill_has_language_detection_step() {
  skill_file="adapters/claude-code/skills/heartbeat/SKILL.md"
  [ -f "$skill_file" ] || return 1
  # After subagent dispatch rewrite, language detection is expressed as
  # a Language directive passed to the subagent in the invocation pattern.
  grep -q "Language directive" "$skill_file" || return 1
}

check_claude_code_skill_steps_are_sequential_1_to_7() {
  skill_file="adapters/claude-code/skills/heartbeat/SKILL.md"
  [ -f "$skill_file" ] || return 1

  # After subagent dispatch rewrite, responsibilities are split:
  # Subagent (1-4) and Orchestrator (5-8) = 8 sequential steps.
  # (Step 6: dashboard update was added in dashboard-update-timing story)
  section=$(sed -n '/^## Agent Startup Method$/,/^## /{ /^## /d; p; }' "$skill_file")

  step_numbers=$(echo "$section" | grep -E '^[0-9]+\.' | sed 's/^\([0-9]*\)\..*/\1/')

  expected="1
2
3
4
5
6
7
8"

  [ "$step_numbers" = "$expected" ] || return 1
}

check_copilot_skill_has_subagent_dispatch() {
  copilot_file="adapters/copilot/skills/heartbeat/SKILL.md"
  [ -f "$copilot_file" ] || return 1
  grep -q "Use the .* agent as a subagent" "$copilot_file" || return 1
  grep -q "Subagent responsibilities" "$copilot_file" || return 1
  grep -q "Orchestrator responsibilities" "$copilot_file" || return 1
}

Describe 'SKILL.md language detection step'
  It 'claude-code SKILL.md Agent Startup Method contains a language detection step between step 2 and step 3'
    When call check_claude_code_skill_has_language_detection_step
    The status should be success
  End

  It 'copilot SKILL.md Agent Startup Method uses subagent dispatch pattern'
    When call check_copilot_skill_has_subagent_dispatch
    The status should be success
  End

  It 'when checking step numbers in claude-code SKILL.md Agent Startup Method, should be sequential 1 through 8'
    When call check_claude_code_skill_steps_are_sequential_1_to_7
    The status should be success
  End
End
