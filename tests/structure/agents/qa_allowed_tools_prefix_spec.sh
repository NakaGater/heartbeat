QA_AGENT="adapters/claude-code/agents/qa.agent.md"

# Extract allowed-tools line
extract_allowed_tools() {
  sed -n '/^---$/,/^---$/p' "$QA_AGENT" \
    | grep '^allowed-tools:' \
    | sed 's/^allowed-tools: *//'
}

# Verify correct prefix mcp__plugin_heartbeat_playwright__ is present
check_correct_playwright_prefix() {
  local tools
  tools=$(extract_allowed_tools)
  echo "$tools" | grep -q 'mcp__plugin_heartbeat_playwright__'
}

# Verify incorrect prefix mcp__playwright is not used alone
check_no_wrong_playwright_prefix() {
  local tools
  tools=$(extract_allowed_tools)
  # Matches mcp__playwright but not mcp__plugin_heartbeat_playwright__
  if echo "$tools" | grep -q 'mcp__playwright' && ! echo "$tools" | grep -q 'mcp__plugin_heartbeat_playwright__'; then
    return 1
  fi
  return 0
}

Describe 'QA Agent allowed-tools: Playwright MCP Prefix'
  It 'allowed-tools contains the correct prefix mcp__plugin_heartbeat_playwright__'
    When call check_correct_playwright_prefix
    The status should be success
  End

  It 'allowed-tools does not use the incorrect prefix mcp__playwright alone'
    When call check_no_wrong_playwright_prefix
    The status should be success
  End
End
