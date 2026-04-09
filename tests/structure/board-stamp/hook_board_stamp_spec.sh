CLAUDE_SETTINGS="adapters/claude-code/hooks/settings.json"
COPILOT_HOOKS="adapters/copilot/hooks/hooks.json"

# --- Task 2: Claude Code hooks ---

check_claude_has_board_stamp() {
  jq -e '.hooks.PostToolUse[].hooks[] | select(.command | contains("board-stamp.sh"))' \
    "$CLAUDE_SETTINGS" >/dev/null 2>&1
}

# --- Task 3: Copilot hooks ---

check_copilot_has_board_stamp() {
  jq -e '.hooks.postToolUse[] | select(.bash == "./core/scripts/board-stamp.sh")' \
    "$COPILOT_HOOKS" >/dev/null 2>&1
}

Describe 'Hook wiring for board-stamp.sh'
  Describe 'Claude Code settings.json (Task 2)'
    It 'PostToolUse hooks contain board-stamp.sh entry'
      When call check_claude_has_board_stamp
      The status should be success
    End

  End

  Describe 'Copilot hooks.json (Task 3)'
    It 'postToolUse hooks contain board-stamp.sh entry'
      When call check_copilot_has_board_stamp
      The status should be success
    End
  End
End
