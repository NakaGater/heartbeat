CLAUDE_SETTINGS="adapters/claude-code/hooks/settings.json"

# --- Helper function ---

check_subagent_start_does_not_call_board_stamp() {
  # SubagentStart hook must NOT contain board-stamp.sh
  # Returns success (0) when board-stamp.sh is absent from SubagentStart
  result=$(jq -e '.hooks.SubagentStart[].hooks[] | select(.command == "./core/scripts/board-stamp.sh")' \
    "$CLAUDE_SETTINGS" 2>/dev/null)
  # If jq found a match, the command exists — that is a failure
  [ -z "$result" ]
}

Describe 'SubagentStart hook must not call board-stamp.sh (Task 3)'
  It 'SubagentStart hooks do not contain board-stamp.sh entry'
    When call check_subagent_start_does_not_call_board_stamp
    The status should be success
  End
End
