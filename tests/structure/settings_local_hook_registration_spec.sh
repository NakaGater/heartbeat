SETTINGS_LOCAL="adapters/claude-code/hooks/settings.local.json"

# --- ヘルパー関数 ---

# settings.local.json が存在するか確認
check_settings_local_exists() {
  [ -f "$SETTINGS_LOCAL" ]
}

# PostToolUse に board-stamp.sh が登録されているか確認
check_post_tool_use_has_board_stamp() {
  jq -e '.hooks.PostToolUse[].hooks[] | select(.command == "./core/scripts/board-stamp.sh")' \
    "$SETTINGS_LOCAL" >/dev/null 2>&1
}

# PostToolUse の実行順序が正しいか確認
# board-stamp.sh -> retrospective-record.sh -> generate-dashboard.sh (async)
check_post_tool_use_order() {
  stamp_idx=$(jq '[.hooks.PostToolUse[0].hooks[] | .command] | to_entries[] | select(.value == "./core/scripts/board-stamp.sh") | .key' "$SETTINGS_LOCAL" 2>/dev/null)
  retro_idx=$(jq '[.hooks.PostToolUse[0].hooks[] | .command] | to_entries[] | select(.value == "./core/scripts/retrospective-record.sh") | .key' "$SETTINGS_LOCAL" 2>/dev/null)
  dash_idx=$(jq '[.hooks.PostToolUse[0].hooks[] | .command] | to_entries[] | select(.value == "./core/scripts/generate-dashboard.sh") | .key' "$SETTINGS_LOCAL" 2>/dev/null)
  [ -n "$stamp_idx" ] && [ -n "$retro_idx" ] && [ -n "$dash_idx" ] \
    && [ "$stamp_idx" -lt "$retro_idx" ] && [ "$retro_idx" -lt "$dash_idx" ]
}

# SubagentStop に board-stamp.sh が登録されているか確認
check_subagent_stop_has_board_stamp() {
  jq -e '.hooks.SubagentStop[].hooks[] | select(.command == "./core/scripts/board-stamp.sh")' \
    "$SETTINGS_LOCAL" >/dev/null 2>&1
}

# SubagentStop に generate-dashboard.sh が async で登録されているか確認
check_subagent_stop_has_generate_dashboard_async() {
  jq -e '.hooks.SubagentStop[].hooks[] | select(.command == "./core/scripts/generate-dashboard.sh") | select(.async == true)' \
    "$SETTINGS_LOCAL" >/dev/null 2>&1
}

# SubagentStop に retrospective-record.sh が登録されているか確認
check_subagent_stop_has_retrospective_record() {
  jq -e '.hooks.SubagentStop[].hooks[] | select(.command == "./core/scripts/retrospective-record.sh")' \
    "$SETTINGS_LOCAL" >/dev/null 2>&1
}

# settings.local.json のフック構成が settings.json テンプレートと一致するか確認
check_hooks_match_template() {
  template="adapters/claude-code/hooks/settings.json"
  [ -f "$template" ] || return 1

  # テンプレートのフックキーを抽出し、settings.local.json と比較
  template_hooks=$(jq -S '.hooks' "$template" 2>/dev/null)
  local_hooks=$(jq -S '.hooks' "$SETTINGS_LOCAL" 2>/dev/null)
  [ "$template_hooks" = "$local_hooks" ]
}

Describe 'settings.local.json フック登録 (AC-1)'
  Describe 'ファイルの存在'
    It 'settings.local.json が存在する'
      When call check_settings_local_exists
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

    It 'SubagentStop に generate-dashboard.sh が async: true で登録されている'
      When call check_subagent_stop_has_generate_dashboard_async
      The status should be success
    End

    It 'SubagentStop に retrospective-record.sh が登録されている'
      When call check_subagent_stop_has_retrospective_record
      The status should be success
    End
  End

  Describe 'テンプレートとの整合性'
    It 'settings.local.json のフック構成が settings.json テンプレートと一致する'
      When call check_hooks_match_template
      The status should be success
    End
  End
End
