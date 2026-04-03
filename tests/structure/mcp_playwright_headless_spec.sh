MCP_JSON=".mcp.json"

# .mcp.json の Playwright MCP args に --headless が含まれていることを検証
check_headless_flag() {
  if [ ! -f "$MCP_JSON" ]; then
    echo "File not found: $MCP_JSON"
    return 1
  fi
  jq -e '.mcpServers.playwright.args | index("--headless")' "$MCP_JSON" > /dev/null 2>&1
}

Describe '.mcp.json: Playwright MCP ヘッドレスモード設定'
  It 'Playwright MCP の args に --headless フラグが含まれている'
    When call check_headless_flag
    The status should be success
  End
End
