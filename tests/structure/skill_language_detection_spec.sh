check_claude_code_skill_has_language_detection_step() {
  skill_file="adapters/claude-code/skills/heartbeat/SKILL.md"
  [ -f "$skill_file" ] || return 1
  grep -q "Detect the language" "$skill_file" || return 1
}

check_claude_code_skill_steps_are_sequential_1_to_9() {
  skill_file="adapters/claude-code/skills/heartbeat/SKILL.md"
  [ -f "$skill_file" ] || return 1

  # Extract the Agent Startup Method section (between ## Agent Startup Method and next ## heading)
  section=$(sed -n '/^## Agent Startup Method$/,/^## /{ /^## /d; p; }' "$skill_file")

  # Extract step numbers (lines starting with a digit followed by a dot)
  step_numbers=$(echo "$section" | grep -E '^[0-9]+\.' | sed 's/^\([0-9]*\)\..*/\1/')

  expected="1
2
3
4
5
6
7
8
9"

  [ "$step_numbers" = "$expected" ] || return 1
}

check_copilot_skill_language_detection_matches_claude_code() {
  claude_code_file="adapters/claude-code/skills/heartbeat/SKILL.md"
  copilot_file="adapters/copilot/skills/heartbeat/SKILL.md"
  [ -f "$claude_code_file" ] || return 1
  [ -f "$copilot_file" ] || return 1

  claude_code_section=$(sed -n '/^## Agent Startup Method$/,/^## /{ /^## Agent Startup Method$/d; /^## /d; p; }' "$claude_code_file")
  copilot_section=$(sed -n '/^## Agent Startup Method$/,/^## /{ /^## Agent Startup Method$/d; /^## /d; p; }' "$copilot_file")

  [ "$claude_code_section" = "$copilot_section" ] || return 1
}

Describe 'SKILL.md language detection step'
  It 'claude-code SKILL.md Agent Startup Method contains a language detection step between step 2 and step 3'
    When call check_claude_code_skill_has_language_detection_step
    The status should be success
  End

  It 'copilot SKILL.md Agent Startup Method is identical to claude-code version'
    When call check_copilot_skill_language_detection_matches_claude_code
    The status should be success
  End

  It 'when checking step numbers in claude-code SKILL.md Agent Startup Method, should be sequential 1 through 9'
    When call check_claude_code_skill_steps_are_sequential_1_to_9
    The status should be success
  End
End
