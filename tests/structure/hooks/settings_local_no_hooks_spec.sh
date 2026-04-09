SETTINGS_LOCAL=".claude/settings.local.json"

# --- Helper functions ---

# hooks key must not exist
check_no_hooks_key() {
  jq -e 'has("hooks") | not' "$SETTINGS_LOCAL" >/dev/null 2>&1
}

# permissions, enableAllProjectMcpServers, enabledMcpjsonServers must be preserved
check_non_hooks_fields_preserved() {
  jq -e '
    has("permissions")
    and has("enableAllProjectMcpServers")
    and has("enabledMcpjsonServers")
  ' "$SETTINGS_LOCAL" >/dev/null 2>&1
}

# Valid JSON
check_valid_json() {
  jq empty "$SETTINGS_LOCAL" >/dev/null 2>&1
}

Describe 'settings.local.json hooks Section Removal (AC-3)'
  Describe 'hooks Key Removal'
    It 'settings.local.json does not have a hooks key'
      When call check_no_hooks_key
      The status should be success
    End
  End

  Describe 'Non-hooks Settings Preservation'
    It 'permissions, enableAllProjectMcpServers, enabledMcpjsonServers are preserved'
      When call check_non_hooks_fields_preserved
      The status should be success
    End
  End

  Describe 'JSON Validity'
    It 'is valid JSON'
      When call check_valid_json
      The status should be success
    End
  End
End
