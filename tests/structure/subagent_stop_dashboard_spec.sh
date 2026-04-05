CLAUDE_SETTINGS="adapters/claude-code/hooks/settings.json"

# --- Helper functions ---

check_subagent_stop_has_generate_dashboard() {
  jq -e '.hooks.SubagentStop[].hooks[] | select(.command == "./core/scripts/generate-dashboard.sh")' \
    "$CLAUDE_SETTINGS" >/dev/null 2>&1
}

check_generate_dashboard_is_sync() {
  # generate-dashboard.sh が存在し、async プロパティを持たないことを検証
  jq -e '.hooks.SubagentStop[].hooks[] | select(.command == "./core/scripts/generate-dashboard.sh")' \
    "$CLAUDE_SETTINGS" >/dev/null 2>&1 || return 1
  # async キーが存在する場合は失敗（同期実行 = async キーなし）
  if jq -e '.hooks.SubagentStop[].hooks[] | select(.command == "./core/scripts/generate-dashboard.sh") | select(.async)' \
    "$CLAUDE_SETTINGS" >/dev/null 2>&1; then
    return 1
  fi
  return 0
}

check_subagent_stop_has_retrospective_record() {
  jq -e '.hooks.SubagentStop[].hooks[] | select(.command == "./core/scripts/retrospective-record.sh")' \
    "$CLAUDE_SETTINGS" >/dev/null 2>&1
}

check_generate_dashboard_after_board_stamp() {
  stamp_idx=$(jq '[.hooks.SubagentStop[0].hooks[] | .command] | to_entries[] | select(.value == "./core/scripts/board-stamp.sh") | .key' "$CLAUDE_SETTINGS" 2>/dev/null)
  dash_idx=$(jq '[.hooks.SubagentStop[0].hooks[] | .command] | to_entries[] | select(.value == "./core/scripts/generate-dashboard.sh") | .key' "$CLAUDE_SETTINGS" 2>/dev/null)
  [ -n "$stamp_idx" ] && [ -n "$dash_idx" ] && [ "$stamp_idx" -lt "$dash_idx" ]
}

check_generate_dashboard_before_auto_commit() {
  dash_idx=$(jq '[.hooks.SubagentStop[0].hooks[] | .command] | to_entries[] | select(.value == "./core/scripts/generate-dashboard.sh") | .key' "$CLAUDE_SETTINGS" 2>/dev/null)
  commit_idx=$(jq '[.hooks.SubagentStop[0].hooks[] | .command] | to_entries[] | select(.value == "./core/scripts/auto-commit.sh") | .key' "$CLAUDE_SETTINGS" 2>/dev/null)
  [ -n "$dash_idx" ] && [ -n "$commit_idx" ] && [ "$dash_idx" -lt "$commit_idx" ]
}

Describe 'SubagentStop hook wiring for generate-dashboard.sh'
  It 'SubagentStop hooks contain generate-dashboard.sh entry'
    When call check_subagent_stop_has_generate_dashboard
    The status should be success
  End

  It 'generate-dashboard.sh is configured for synchronous execution (no async key)'
    When call check_generate_dashboard_is_sync
    The status should be success
  End

  It 'SubagentStop hooks contain retrospective-record.sh entry'
    When call check_subagent_stop_has_retrospective_record
    The status should be success
  End

  It 'generate-dashboard.sh appears after board-stamp.sh'
    When call check_generate_dashboard_after_board_stamp
    The status should be success
  End

  It 'generate-dashboard.sh appears before auto-commit.sh'
    When call check_generate_dashboard_before_auto_commit
    The status should be success
  End
End
