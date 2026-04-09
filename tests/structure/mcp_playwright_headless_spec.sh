MCP_JSON=".mcp.json"

# Verify .mcp.json Playwright MCP args contain --headless
check_headless_flag() {
  if [ ! -f "$MCP_JSON" ]; then
    echo "File not found: $MCP_JSON"
    return 1
  fi
  jq -e '.mcpServers.playwright.args | index("--headless")' "$MCP_JSON" > /dev/null 2>&1
}

Describe '.mcp.json: Playwright MCP Headless Mode Configuration'
  It 'Playwright MCP args contain the --headless flag'
    When call check_headless_flag
    The status should be success
  End
End
