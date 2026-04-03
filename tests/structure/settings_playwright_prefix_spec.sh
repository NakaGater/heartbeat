SETTINGS_FILE=".claude/settings.local.json"

# permissions.allow から全エントリを抽出する
extract_allow_entries() {
  jq -r '.permissions.allow[]' "$SETTINGS_FILE"
}

# 正しいプレフィックス mcp__plugin_heartbeat_playwright__* が含まれていることを検証
check_correct_playwright_prefix() {
  extract_allow_entries | grep -qx 'mcp__plugin_heartbeat_playwright__\*'
}

# 誤ったプレフィックス mcp__playwright__* が単独で存在しないことを検証
# mcp__plugin_heartbeat_playwright__* は許可するが mcp__playwright__* 単独は不可
check_no_wrong_playwright_prefix() {
  if extract_allow_entries | grep -qx 'mcp__playwright__\*'; then
    return 1
  fi
  return 0
}

Describe 'settings.local.json permissions.allow: Playwright MCPプレフィックス'
  It 'permissions.allow に正しいプレフィックス mcp__plugin_heartbeat_playwright__* が含まれている'
    When call check_correct_playwright_prefix
    The status should be success
  End

  It 'permissions.allow に誤ったプレフィックス mcp__playwright__* が単独で存在しない'
    When call check_no_wrong_playwright_prefix
    The status should be success
  End
End
