CONVENTIONS="core/knowledge/conventions.md"
SPEC="heartbeat-spec-en.md"

# --- Completion condition 1: conventions.md PostToolUse Hook Ordering ---

check_conventions_no_dashboard_in_posttooluse() {
  # PostToolUse Hook Ordering section must NOT contain generate-dashboard.sh
  sed -n '/## PostToolUse Hook Ordering/,/^## /p' "$CONVENTIONS" \
    | grep -q 'generate-dashboard\.sh' && return 1
  return 0
}

check_conventions_mentions_subagent_stop() {
  # PostToolUse Hook Ordering section (or its replacement) must mention SubagentStop
  sed -n '/## PostToolUse Hook Ordering/,/^## /p' "$CONVENTIONS" \
    | grep -qi 'SubagentStop'
}

# --- Completion condition 2: heartbeat-spec-en.md Copilot hooks.json postToolUse ---

check_spec_copilot_no_dashboard_in_posttooluse() {
  # Extract the Copilot hooks.json code block and verify no generate-dashboard.sh in postToolUse
  sed -n '/#### adapters\/copilot\/hooks\/hooks\.json/,/^```$/p' "$SPEC" \
    | grep -q 'generate-dashboard\.sh' && return 1
  return 0
}

# --- Completion condition 3: heartbeat-spec-en.md Claude Code settings.json PostToolUse ---

check_spec_claude_no_dashboard_in_posttooluse() {
  # Extract PostToolUse block from Claude Code settings.json section and check no generate-dashboard.sh
  # Use awk instead of sed to avoid GNU-only \| alternation (not available on macOS BSD sed)
  awk '/### 7.2 Claude Code/,/### 7.3|### 8|^## 8/' "$SPEC" \
    | awk '/"PostToolUse"/,/"SubagentStop"|"WorktreeCreate"/' \
    | grep -q 'generate-dashboard\.sh' && return 1
  return 0
}

Describe 'Task 4: Remove generate-dashboard.sh from PostToolUse Documentation'
  Describe 'conventions.md PostToolUse Hook Ordering Section'
    It 'does not contain generate-dashboard.sh'
      When call check_conventions_no_dashboard_in_posttooluse
      The status should be success
    End

    It 'mentions execution in SubagentStop'
      When call check_conventions_mentions_subagent_stop
      The status should be success
    End
  End

  Describe 'heartbeat-spec-en.md Copilot hooks.json Section'
    It 'postToolUse does not contain generate-dashboard.sh'
      When call check_spec_copilot_no_dashboard_in_posttooluse
      The status should be success
    End
  End

  Describe 'heartbeat-spec-en.md Claude Code settings.json Section'
    It 'PostToolUse does not contain generate-dashboard.sh'
      When call check_spec_claude_no_dashboard_in_posttooluse
      The status should be success
    End
  End
End
