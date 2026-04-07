SETTINGS_TEMPLATE="adapters/claude-code/hooks/settings.json"

# --- ヘルパー関数 ---

# SSoTテンプレートが存在するか確認
check_template_exists() {
  [ -f "$SETTINGS_TEMPLATE" ]
}

# SubagentStart に timeline-record.sh が1件定義されていること
check_subagent_start_has_timeline_record() {
  count=$(jq '[.hooks.SubagentStart[0].hooks[] | select(.command | contains("timeline-record.sh"))] | length' "$SETTINGS_TEMPLATE" 2>/dev/null)
  [ "$count" = "1" ]
}

check_subagent_start_hook_count() {
  count=$(jq '[.hooks.SubagentStart[0].hooks[]] | length' "$SETTINGS_TEMPLATE" 2>/dev/null)
  [ "$count" = "1" ]
}

# PostToolUse (Write|Edit) に board-stamp.sh, retrospective-record.sh が順序通り定義
check_post_tool_use_matcher() {
  jq -e '.hooks.PostToolUse[0].matcher == "Write|Edit"' "$SETTINGS_TEMPLATE" >/dev/null 2>&1
}

check_post_tool_use_order() {
  stamp_idx=$(jq '[.hooks.PostToolUse[0].hooks[] | .command] | to_entries[] | select(.value | contains("board-stamp.sh")) | .key' "$SETTINGS_TEMPLATE" 2>/dev/null)
  retro_idx=$(jq '[.hooks.PostToolUse[0].hooks[] | .command] | to_entries[] | select(.value | contains("retrospective-record.sh")) | .key' "$SETTINGS_TEMPLATE" 2>/dev/null)
  [ -n "$stamp_idx" ] && [ -n "$retro_idx" ] \
    && [ "$stamp_idx" -lt "$retro_idx" ]
}

check_post_tool_use_hook_count() {
  count=$(jq '[.hooks.PostToolUse[0].hooks[]] | length' "$SETTINGS_TEMPLATE" 2>/dev/null)
  [ "$count" = "2" ]
}

# WorktreeCreate に worktree-env-setup.sh が1件定義されていること
check_worktree_create_has_setup() {
  jq -e '.hooks.WorktreeCreate[0].hooks[] | select(.command | contains("worktree-env-setup.sh"))' "$SETTINGS_TEMPLATE" >/dev/null 2>&1
}

check_worktree_create_hook_count() {
  count=$(jq '[.hooks.WorktreeCreate[0].hooks[]] | length' "$SETTINGS_TEMPLATE" 2>/dev/null)
  [ "$count" = "1" ]
}

# SubagentStop に5件が順序通り定義されていること
check_subagent_stop_order() {
  scripts=$(jq -r '[.hooks.SubagentStop[0].hooks[] | .command | capture("(?<name>[^/]+\\.sh)$") | .name] | join(",")' "$SETTINGS_TEMPLATE" 2>/dev/null)
  [ "$scripts" = "timeline-record.sh,board-stamp.sh,retrospective-record.sh,generate-dashboard.sh,auto-commit.sh" ]
}

check_subagent_stop_hook_count() {
  count=$(jq '[.hooks.SubagentStop[0].hooks[]] | length' "$SETTINGS_TEMPLATE" 2>/dev/null)
  [ "$count" = "5" ]
}

# 全スクリプトパスが bash ${CLAUDE_PLUGIN_ROOT}/core/scripts/... 形式であること
check_all_paths_use_plugin_root() {
  # 全commandフィールドを取得し、bash ${CLAUDE_PLUGIN_ROOT}/core/scripts/ で始まらないものがあれば失敗
  non_matching=$(jq -r '
    [.hooks[][].hooks[] | .command]
    | map(select(startswith("bash ${CLAUDE_PLUGIN_ROOT}/core/scripts/") | not))
    | length
  ' "$SETTINGS_TEMPLATE" 2>/dev/null)
  [ "$non_matching" = "0" ]
}

Describe 'SSoTテンプレート hooks定義 (AC-1)'
  Describe 'ファイルの存在'
    It 'SSoTテンプレートが存在する'
      When call check_template_exists
      The status should be success
    End
  End

  Describe 'SubagentStart フック'
    It 'timeline-record.sh が1件定義されている'
      When call check_subagent_start_has_timeline_record
      The status should be success
    End

    It 'フックが1件のみ定義されている'
      When call check_subagent_start_hook_count
      The status should be success
    End
  End

  Describe 'PostToolUse フック'
    It 'matcher が Write|Edit である'
      When call check_post_tool_use_matcher
      The status should be success
    End

    It 'board-stamp.sh -> retrospective-record.sh の順序で定義されている'
      When call check_post_tool_use_order
      The status should be success
    End

    It 'フックが2件定義されている'
      When call check_post_tool_use_hook_count
      The status should be success
    End
  End

  Describe 'WorktreeCreate フック'
    It 'worktree-env-setup.sh が定義されている'
      When call check_worktree_create_has_setup
      The status should be success
    End

    It 'フックが1件のみ定義されている'
      When call check_worktree_create_hook_count
      The status should be success
    End
  End

  Describe 'SubagentStop フック'
    It 'timeline-record.sh, board-stamp.sh, retrospective-record.sh, generate-dashboard.sh, auto-commit.sh が順序通り定義されている'
      When call check_subagent_stop_order
      The status should be success
    End

    It 'フックが5件定義されている'
      When call check_subagent_stop_hook_count
      The status should be success
    End
  End

  Describe 'スクリプトパス形式'
    It '全パスが bash ${CLAUDE_PLUGIN_ROOT}/core/scripts/... 形式である'
      When call check_all_paths_use_plugin_root
      The status should be success
    End
  End
End
