SETTINGS_TEMPLATE="adapters/claude-code/hooks/settings.json"

# --- ヘルパー関数 ---

# SSoTテンプレートが存在するか確認
check_settings_template_exists() {
  [ -f "$SETTINGS_TEMPLATE" ]
}

# PostToolUse に board-stamp.sh が登録されているか確認
check_post_tool_use_has_board_stamp() {
  jq -e '.hooks.PostToolUse[].hooks[] | select(.command | contains("board-stamp.sh"))' \
    "$SETTINGS_TEMPLATE" >/dev/null 2>&1
}

# PostToolUse の実行順序が正しいか確認
# board-stamp.sh -> retrospective-record.sh -> generate-dashboard.sh (async)
check_post_tool_use_order() {
  stamp_idx=$(jq '[.hooks.PostToolUse[0].hooks[] | .command] | to_entries[] | select(.value | contains("board-stamp.sh")) | .key' "$SETTINGS_TEMPLATE" 2>/dev/null)
  retro_idx=$(jq '[.hooks.PostToolUse[0].hooks[] | .command] | to_entries[] | select(.value | contains("retrospective-record.sh")) | .key' "$SETTINGS_TEMPLATE" 2>/dev/null)
  dash_idx=$(jq '[.hooks.PostToolUse[0].hooks[] | .command] | to_entries[] | select(.value | contains("generate-dashboard.sh")) | .key' "$SETTINGS_TEMPLATE" 2>/dev/null)
  [ -n "$stamp_idx" ] && [ -n "$retro_idx" ] && [ -n "$dash_idx" ] \
    && [ "$stamp_idx" -lt "$retro_idx" ] && [ "$retro_idx" -lt "$dash_idx" ]
}

# SubagentStop に board-stamp.sh が登録されているか確認
check_subagent_stop_has_board_stamp() {
  jq -e '.hooks.SubagentStop[].hooks[] | select(.command | contains("board-stamp.sh"))' \
    "$SETTINGS_TEMPLATE" >/dev/null 2>&1
}

# SubagentStop に generate-dashboard.sh が同期実行で登録されているか確認
check_subagent_stop_has_generate_dashboard_sync() {
  jq -e '.hooks.SubagentStop[].hooks[] | select(.command | contains("generate-dashboard.sh"))' \
    "$SETTINGS_TEMPLATE" >/dev/null 2>&1 \
  && ! jq -e '.hooks.SubagentStop[].hooks[] | select(.command | contains("generate-dashboard.sh")) | select(.async)' \
    "$SETTINGS_TEMPLATE" >/dev/null 2>&1
}

# SubagentStop に retrospective-record.sh が登録されているか確認
check_subagent_stop_has_retrospective_record() {
  jq -e '.hooks.SubagentStop[].hooks[] | select(.command | contains("retrospective-record.sh"))' \
    "$SETTINGS_TEMPLATE" >/dev/null 2>&1
}

Describe 'SSoTテンプレート フック登録 (AC-1)'
  Describe 'ファイルの存在'
    It 'SSoTテンプレートが存在する'
      When call check_settings_template_exists
      The status should be success
    End
  End

  Describe 'PostToolUse フック登録'
    It 'PostToolUse に board-stamp.sh が登録されている'
      When call check_post_tool_use_has_board_stamp
      The status should be success
    End

    It 'PostToolUse の実行順序が board-stamp.sh -> retrospective-record.sh -> generate-dashboard.sh である'
      When call check_post_tool_use_order
      The status should be success
    End
  End

  Describe 'SubagentStop フック登録'
    It 'SubagentStop に board-stamp.sh が登録されている'
      When call check_subagent_stop_has_board_stamp
      The status should be success
    End

    It 'SubagentStop に generate-dashboard.sh が同期実行で登録されている'
      When call check_subagent_stop_has_generate_dashboard_sync
      The status should be success
    End

    It 'SubagentStop に retrospective-record.sh が登録されている'
      When call check_subagent_stop_has_retrospective_record
      The status should be success
    End
  End
End
