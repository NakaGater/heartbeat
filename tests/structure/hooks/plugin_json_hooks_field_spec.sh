PLUGIN_JSON=".claude-plugin/plugin.json"

# --- Helper functions ---

# hooks field references the SSoT template
check_hooks_references_ssot_template() {
  jq -e '.hooks == "./adapters/claude-code/hooks/settings.json"' "$PLUGIN_JSON" >/dev/null 2>&1
}

# Existing fields are unchanged
check_existing_fields_unchanged() {
  jq -e '
    .name == "heartbeat"
    and .description == "XP-driven AI agent team for TDD-based development"
    and .version == "2.0.0"
    and .author.name == "NakaG"
  ' "$PLUGIN_JSON" >/dev/null 2>&1
}

# Valid JSON
check_valid_json() {
  jq empty "$PLUGIN_JSON" >/dev/null 2>&1
}

Describe 'plugin.json hooks Field (AC-2)'
  Describe 'Hooks Field Addition'
    It 'hooks references adapters/claude-code/hooks/settings.json'
      When call check_hooks_references_ssot_template
      The status should be success
    End
  End

  Describe 'Existing Field Preservation'
    It 'name, description, version, author are unchanged'
      When call check_existing_fields_unchanged
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
