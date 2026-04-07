PLUGIN_JSON=".claude-plugin/plugin.json"

# --- ヘルパー関数 ---

# hooksフィールドがSSoTテンプレートを参照していること
check_hooks_references_ssot_template() {
  jq -e '.hooks == "adapters/claude-code/hooks/settings.json"' "$PLUGIN_JSON" >/dev/null 2>&1
}

# 既存フィールドが変更されていないこと
check_existing_fields_unchanged() {
  name=$(jq -r '.name' "$PLUGIN_JSON" 2>/dev/null)
  desc=$(jq -r '.description' "$PLUGIN_JSON" 2>/dev/null)
  version=$(jq -r '.version' "$PLUGIN_JSON" 2>/dev/null)
  author=$(jq -r '.author.name' "$PLUGIN_JSON" 2>/dev/null)
  [ "$name" = "heartbeat" ] \
    && [ "$desc" = "XP-driven AI agent team for TDD-based development" ] \
    && [ "$version" = "2.0.0" ] \
    && [ "$author" = "NakaG" ]
}

# JSONとして有効であること
check_valid_json() {
  jq empty "$PLUGIN_JSON" >/dev/null 2>&1
}

Describe 'plugin.json hooks フィールド (AC-2)'
  Describe 'hooks フィールドの追加'
    It 'hooks が adapters/claude-code/hooks/settings.json を参照している'
      When call check_hooks_references_ssot_template
      The status should be success
    End
  End

  Describe '既存フィールドの保全'
    It 'name, description, version, author が変更されていない'
      When call check_existing_fields_unchanged
      The status should be success
    End
  End

  Describe 'JSON の妥当性'
    It 'JSONとして有効である'
      When call check_valid_json
      The status should be success
    End
  End
End
