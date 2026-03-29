CLAUDE_SETTINGS="adapters/claude-code/hooks/settings.json"
COPILOT_HOOKS="adapters/copilot/hooks/hooks.json"

# --- Task 2: Claude Code hooks ---

check_claude_has_board_stamp() {
  jq -e '.hooks.PostToolUse[].hooks[] | select(.command == "./core/scripts/board-stamp.sh")' \
    "$CLAUDE_SETTINGS" >/dev/null 2>&1
}

check_claude_board_stamp_before_dashboard() {
  # board-stamp.sh index must be less than generate-dashboard.sh index
  stamp_idx=$(jq '[.hooks.PostToolUse[0].hooks[] | .command] | to_entries[] | select(.value == "./core/scripts/board-stamp.sh") | .key' "$CLAUDE_SETTINGS" 2>/dev/null)
  dash_idx=$(jq '[.hooks.PostToolUse[0].hooks[] | .command] | to_entries[] | select(.value == "./core/scripts/generate-dashboard.sh") | .key' "$CLAUDE_SETTINGS" 2>/dev/null)
  [ -n "$stamp_idx" ] && [ -n "$dash_idx" ] && [ "$stamp_idx" -lt "$dash_idx" ]
}

# --- Task 3: Copilot hooks ---

check_copilot_has_board_stamp() {
  jq -e '.hooks.postToolUse[] | select(.bash == "./core/scripts/board-stamp.sh")' \
    "$COPILOT_HOOKS" >/dev/null 2>&1
}

check_copilot_board_stamp_before_dashboard() {
  stamp_idx=$(jq '[.hooks.postToolUse[] | .bash] | to_entries[] | select(.value == "./core/scripts/board-stamp.sh") | .key' "$COPILOT_HOOKS" 2>/dev/null)
  dash_idx=$(jq '[.hooks.postToolUse[] | .bash] | to_entries[] | select(.value == "./core/scripts/generate-dashboard.sh") | .key' "$COPILOT_HOOKS" 2>/dev/null)
  [ -n "$stamp_idx" ] && [ -n "$dash_idx" ] && [ "$stamp_idx" -lt "$dash_idx" ]
}

Describe 'Hook wiring for board-stamp.sh'
  Describe 'Claude Code settings.json (Task 2)'
    It 'PostToolUse hooks contain board-stamp.sh entry'
      When call check_claude_has_board_stamp
      The status should be success
    End

    It 'board-stamp.sh appears before generate-dashboard.sh'
      When call check_claude_board_stamp_before_dashboard
      The status should be success
    End
  End

  Describe 'Copilot hooks.json (Task 3)'
    It 'postToolUse hooks contain board-stamp.sh entry'
      When call check_copilot_has_board_stamp
      The status should be success
    End

    It 'board-stamp.sh appears before generate-dashboard.sh'
      When call check_copilot_board_stamp_before_dashboard
      The status should be success
    End
  End
End
