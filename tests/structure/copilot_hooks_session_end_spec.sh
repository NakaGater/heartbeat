HOOKS_JSON="adapters/copilot/hooks/hooks.json"

check_session_end_exists() {
  jq -e '.hooks.sessionEnd' "$HOOKS_JSON" >/dev/null 2>&1
}

check_session_end_auto_commit() {
  jq -e '.hooks.sessionEnd[] | select(.bash == "./core/scripts/auto-commit.sh")' "$HOOKS_JSON" >/dev/null 2>&1
}

check_subagent_stop_absent() {
  ! jq -e '.hooks.subagentStop' "$HOOKS_JSON" >/dev/null 2>&1
}

check_post_tool_use_unchanged() {
  jq -e '.hooks.postToolUse | length == 2' "$HOOKS_JSON" >/dev/null 2>&1
}

Describe 'Copilot hooks.json sessionEnd'
  It 'has sessionEnd array in hooks'
    When call check_session_end_exists
    The status should be success
  End

  It 'sessionEnd contains auto-commit.sh entry'
    When call check_session_end_auto_commit
    The status should be success
  End

  It 'subagentStop key does not exist'
    When call check_subagent_stop_absent
    The status should be success
  End

  It 'postToolUse hooks have 2 entries (board-stamp + retrospective)'
    When call check_post_tool_use_unchanged
    The status should be success
  End
End
