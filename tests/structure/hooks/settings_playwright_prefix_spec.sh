SETTINGS_FILE=".claude/settings.local.json"

# Extract all entries from permissions.allow
extract_allow_entries() {
  jq -r '.permissions.allow[]' "$SETTINGS_FILE"
}

# Verify correct prefix mcp__plugin_heartbeat_playwright__* is present
check_correct_playwright_prefix() {
  extract_allow_entries | grep -qx 'mcp__plugin_heartbeat_playwright__\*'
}

# Verify incorrect prefix mcp__playwright__* does not exist alone
# mcp__plugin_heartbeat_playwright__* is allowed but mcp__playwright__* alone is not
check_no_wrong_playwright_prefix() {
  if extract_allow_entries | grep -qx 'mcp__playwright__\*'; then
    return 1
  fi
  return 0
}

Describe 'settings.local.json permissions.allow: Playwright MCP Prefix'
  It 'permissions.allow contains the correct prefix mcp__plugin_heartbeat_playwright__*'
    When call check_correct_playwright_prefix
    The status should be success
  End

  It 'permissions.allow does not have the incorrect prefix mcp__playwright__* alone'
    When call check_no_wrong_playwright_prefix
    The status should be success
  End
End
