HOOKS_JSON="adapters/copilot/hooks/hooks.json"

# Task 7: Verify board-stamp.sh is correctly configured as a safety net in the Copilot adapter
# Copilot lacks SubagentStart/SubagentStop, so postToolUse is the only hook.
# board-stamp.sh must run as the first entry (index 0) in the postToolUse array.

check_board_stamp_is_first_hook() {
  first_hook=$(jq -r '.hooks.postToolUse[0].bash' "$HOOKS_JSON" 2>/dev/null)
  [ "$first_hook" = "./core/scripts/board-stamp.sh" ]
}

check_board_stamp_has_no_async_comment() {
  # Safety net must not be async (comment must not contain "async")
  comment=$(jq -r '.hooks.postToolUse[] | select(.bash == "./core/scripts/board-stamp.sh") | .comment // ""' "$HOOKS_JSON" 2>/dev/null)
  echo "$comment" | grep -iq "async" && return 1
  return 0
}

check_no_subagent_hooks() {
  # Verify Copilot does not have SubagentStart/SubagentStop
  ! jq -e '.hooks | has("subagentStart", "subagentStop") | select(. == true)' "$HOOKS_JSON" >/dev/null 2>&1
}

check_post_tool_use_has_board_stamp_type_command() {
  jq -e '.hooks.postToolUse[] | select(.bash == "./core/scripts/board-stamp.sh") | select(.type == "command")' \
    "$HOOKS_JSON" >/dev/null 2>&1
}

Describe 'Copilot board-stamp.sh Safety Net Configuration (Task 7)'
  It 'board-stamp.sh is the first hook in postToolUse'
    When call check_board_stamp_is_first_hook
    The status should be success
  End

  It 'board-stamp.sh has no async comment'
    When call check_board_stamp_has_no_async_comment
    The status should be success
  End

  It 'SubagentStart/SubagentStop hooks do not exist'
    When call check_no_subagent_hooks
    The status should be success
  End

  It 'board-stamp.sh type is command'
    When call check_post_tool_use_has_board_stamp_type_command
    The status should be success
  End
End
