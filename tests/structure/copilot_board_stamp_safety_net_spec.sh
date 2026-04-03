HOOKS_JSON="adapters/copilot/hooks/hooks.json"

# タスク7: Copilot アダプタで board-stamp.sh がセーフティネットとして正しく設定されていること
# Copilot には SubagentStart/SubagentStop がないため、postToolUse が唯一のフック。
# board-stamp.sh は postToolUse 配列の先頭（インデックス0）で実行されなければならない。

check_board_stamp_is_first_hook() {
  first_hook=$(jq -r '.hooks.postToolUse[0].bash' "$HOOKS_JSON" 2>/dev/null)
  [ "$first_hook" = "./core/scripts/board-stamp.sh" ]
}

check_board_stamp_has_no_async_comment() {
  # セーフティネットは非同期であってはならない（comment に async を含まない）
  comment=$(jq -r '.hooks.postToolUse[] | select(.bash == "./core/scripts/board-stamp.sh") | .comment // ""' "$HOOKS_JSON" 2>/dev/null)
  echo "$comment" | grep -iq "async" && return 1
  return 0
}

check_no_subagent_hooks() {
  # Copilot には SubagentStart/SubagentStop がないことを確認
  ! jq -e '.hooks | has("subagentStart", "subagentStop") | select(. == true)' "$HOOKS_JSON" >/dev/null 2>&1
}

check_post_tool_use_has_board_stamp_type_command() {
  jq -e '.hooks.postToolUse[] | select(.bash == "./core/scripts/board-stamp.sh") | select(.type == "command")' \
    "$HOOKS_JSON" >/dev/null 2>&1
}

Describe 'Copilot board-stamp.sh セーフティネット設定 (タスク7)'
  It 'board-stamp.sh は postToolUse の先頭フックである'
    When call check_board_stamp_is_first_hook
    The status should be success
  End

  It 'board-stamp.sh に非同期を示すコメントがない'
    When call check_board_stamp_has_no_async_comment
    The status should be success
  End

  It 'SubagentStart/SubagentStop フックが存在しない'
    When call check_no_subagent_hooks
    The status should be success
  End

  It 'board-stamp.sh のタイプが command である'
    When call check_post_tool_use_has_board_stamp_type_command
    The status should be success
  End
End
