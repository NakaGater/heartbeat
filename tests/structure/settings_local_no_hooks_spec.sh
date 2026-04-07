SETTINGS_LOCAL=".claude/settings.local.json"

# --- ヘルパー関数 ---

# hooksキーが存在しないこと
check_no_hooks_key() {
  jq -e 'has("hooks") | not' "$SETTINGS_LOCAL" >/dev/null 2>&1
}

# permissions, enableAllProjectMcpServers, enabledMcpjsonServers が維持されていること
check_non_hooks_fields_preserved() {
  jq -e '
    has("permissions")
    and has("enableAllProjectMcpServers")
    and has("enabledMcpjsonServers")
  ' "$SETTINGS_LOCAL" >/dev/null 2>&1
}

# JSONとして有効であること
check_valid_json() {
  jq empty "$SETTINGS_LOCAL" >/dev/null 2>&1
}

Describe 'settings.local.json hooks セクション削除 (AC-3)'
  Describe 'hooks キーの除去'
    It 'settings.local.json に hooks キーが存在しない'
      When call check_no_hooks_key
      The status should be success
    End
  End

  Describe 'hooks 以外の設定の保全'
    It 'permissions, enableAllProjectMcpServers, enabledMcpjsonServers が維持されている'
      When call check_non_hooks_fields_preserved
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
