HOOKS_JSON="adapters/copilot/hooks/hooks.json"

check_subagent_stop_exists() {
  jq -e '.hooks.subagentStop' "$HOOKS_JSON" >/dev/null 2>&1
}

check_subagent_stop_auto_commit() {
  jq -e '.hooks.subagentStop[] | select(.bash == "./core/scripts/auto-commit.sh")' "$HOOKS_JSON" >/dev/null 2>&1
}

check_post_tool_use_unchanged() {
  jq -e '.hooks.postToolUse | length == 2' "$HOOKS_JSON" >/dev/null 2>&1
}

Describe 'Copilot hooks.json subagentStop'
  It 'has subagentStop array in hooks'
    When call check_subagent_stop_exists
    The status should be success
  End

  It 'subagentStop contains auto-commit.sh entry'
    When call check_subagent_stop_auto_commit
    The status should be success
  End

  It 'postToolUse hooks are unchanged (2 entries)'
    When call check_post_tool_use_unchanged
    The status should be success
  End
End
