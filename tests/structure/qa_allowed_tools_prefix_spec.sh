QA_AGENT="adapters/claude-code/agents/qa.agent.md"

# allowed-tools 行を抽出する
extract_allowed_tools() {
  sed -n '/^---$/,/^---$/p' "$QA_AGENT" \
    | grep '^allowed-tools:' \
    | sed 's/^allowed-tools: *//'
}

# 正しいプレフィックス mcp__plugin_heartbeat_playwright__ が含まれていることを検証
check_correct_playwright_prefix() {
  local tools
  tools=$(extract_allowed_tools)
  echo "$tools" | grep -q 'mcp__plugin_heartbeat_playwright__'
}

# 誤ったプレフィックス mcp__playwright が含まれていないことを検証
check_no_wrong_playwright_prefix() {
  local tools
  tools=$(extract_allowed_tools)
  # mcp__playwright にマッチするが mcp__plugin_heartbeat_playwright__ にはマッチしないパターン
  if echo "$tools" | grep -q 'mcp__playwright' && ! echo "$tools" | grep -q 'mcp__plugin_heartbeat_playwright__'; then
    return 1
  fi
  return 0
}

Describe 'QA agent allowed-tools: Playwright MCPプレフィックス'
  It 'allowed-tools に正しいプレフィックス mcp__plugin_heartbeat_playwright__ が含まれている'
    When call check_correct_playwright_prefix
    The status should be success
  End

  It 'allowed-tools に誤ったプレフィックス mcp__playwright が単独で使われていない'
    When call check_no_wrong_playwright_prefix
    The status should be success
  End
End
