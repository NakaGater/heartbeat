PLUGIN_MANIFESTS="core/knowledge/plugin-manifests.md"
SPEC_EN="heartbeat-spec-en.md"
SETTINGS_TEMPLATE="adapters/claude-code/hooks/settings.json"
PLUGIN_JSON=".claude-plugin/plugin.json"

# --- ヘルパー関数 ---

# heartbeat-spec-en.md の 7.2 節テキストを抽出する共通ヘルパー
extract_spec_section_7_2() {
  sed -n '/^### 7\.2/,/^---\|^## 8/p' "$SPEC_EN"
}

# 完了条件1: plugin-manifests.md の hooks フィールド記述が plugin.json の実際の構成と整合
check_manifests_hooks_field_matches_plugin_json() {
  actual_hooks=$(jq -r '.hooks' "$PLUGIN_JSON" 2>/dev/null)
  grep -q "\"hooks\": \"${actual_hooks}\"" "$PLUGIN_MANIFESTS" 2>/dev/null
}

# 完了条件2: heartbeat-spec-en.md の 7.2 節に WorktreeCreate（worktree-env-setup.sh）が記載
check_spec_has_worktree_create() {
  extract_spec_section_7_2 | grep -q "WorktreeCreate" 2>/dev/null
}

check_spec_has_worktree_env_setup_script() {
  extract_spec_section_7_2 | grep -q "worktree-env-setup.sh" 2>/dev/null
}

# 完了条件3: heartbeat-spec-en.md の 7.2 節のフック一覧が SSoT テンプレートの構成と一致
check_spec_lists_all_ssot_events() {
  section=$(extract_spec_section_7_2)
  events=$(jq -r '.hooks | keys[]' "$SETTINGS_TEMPLATE" 2>/dev/null)
  for event in $events; do
    echo "$section" | grep -q "$event" 2>/dev/null || return 1
  done
}

check_spec_lists_all_ssot_scripts() {
  section=$(extract_spec_section_7_2)
  scripts=$(jq -r '[.hooks[][].hooks[] | .command | capture("(?<name>[^/]+\\.sh)$") | .name] | unique[]' "$SETTINGS_TEMPLATE" 2>/dev/null)
  for script in $scripts; do
    echo "$section" | grep -q "$script" 2>/dev/null || return 1
  done
}

check_spec_has_subagent_stop() {
  extract_spec_section_7_2 | grep -q "SubagentStop" 2>/dev/null
}

check_spec_has_subagent_start() {
  extract_spec_section_7_2 | grep -q "SubagentStart" 2>/dev/null
}

Describe '仕様書のhooks記述がSSoT構成と整合 (AC-5)'
  Describe 'plugin-manifests.md の hooks フィールド'
    It 'plugin.json の実際の hooks 値と整合している'
      When call check_manifests_hooks_field_matches_plugin_json
      The status should be success
    End
  End

  Describe 'heartbeat-spec-en.md 7.2節の WorktreeCreate 記載'
    It 'WorktreeCreate イベントが記載されている'
      When call check_spec_has_worktree_create
      The status should be success
    End

    It 'worktree-env-setup.sh スクリプトが記載されている'
      When call check_spec_has_worktree_env_setup_script
      The status should be success
    End
  End

  Describe 'heartbeat-spec-en.md 7.2節のフック一覧とSSoT整合'
    It 'SSoTテンプレートの全イベント名が記載されている'
      When call check_spec_lists_all_ssot_events
      The status should be success
    End

    It 'SSoTテンプレートの全スクリプト名が記載されている'
      When call check_spec_lists_all_ssot_scripts
      The status should be success
    End

    It 'SubagentStart が記載されている'
      When call check_spec_has_subagent_start
      The status should be success
    End

    It 'SubagentStop が記載されている'
      When call check_spec_has_subagent_stop
      The status should be success
    End
  End
End
