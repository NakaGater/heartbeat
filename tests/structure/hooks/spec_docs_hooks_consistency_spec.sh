PLUGIN_MANIFESTS="core/knowledge/plugin-manifests.md"
SPEC_EN="heartbeat-spec-en.md"
SETTINGS_TEMPLATE="adapters/claude-code/hooks/settings.json"
PLUGIN_JSON=".claude-plugin/plugin.json"

# --- Helper functions ---

# Common helper to extract section 7.2 text from heartbeat-spec-en.md
extract_spec_section_7_2() {
  sed -n '/^### 7\.2/,/^---\|^## 8/p' "$SPEC_EN"
}

# CC1: plugin-manifests.md hooks field description matches actual plugin.json configuration
check_manifests_hooks_field_matches_plugin_json() {
  actual_hooks=$(jq -r '.hooks' "$PLUGIN_JSON" 2>/dev/null)
  grep -q "\"hooks\": \"${actual_hooks}\"" "$PLUGIN_MANIFESTS" 2>/dev/null
}

# CC2: heartbeat-spec-en.md section 7.2 documents WorktreeCreate (worktree-env-setup.sh)
check_spec_has_worktree_create() {
  extract_spec_section_7_2 | grep -q "WorktreeCreate" 2>/dev/null
}

check_spec_has_worktree_env_setup_script() {
  extract_spec_section_7_2 | grep -q "worktree-env-setup.sh" 2>/dev/null
}

# CC3: heartbeat-spec-en.md section 7.2 hook list matches SSoT template configuration
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

Describe 'Spec Document Hooks Description Matches SSoT Configuration (AC-5)'
  Describe 'plugin-manifests.md hooks Field'
    It 'matches the actual hooks value in plugin.json'
      When call check_manifests_hooks_field_matches_plugin_json
      The status should be success
    End
  End

  Describe 'heartbeat-spec-en.md Section 7.2 WorktreeCreate Documentation'
    It 'WorktreeCreate event is documented'
      When call check_spec_has_worktree_create
      The status should be success
    End

    It 'worktree-env-setup.sh script is documented'
      When call check_spec_has_worktree_env_setup_script
      The status should be success
    End
  End

  Describe 'heartbeat-spec-en.md Section 7.2 Hook List and SSoT Consistency'
    It 'all SSoT template event names are documented'
      When call check_spec_lists_all_ssot_events
      The status should be success
    End

    It 'all SSoT template script names are documented'
      When call check_spec_lists_all_ssot_scripts
      The status should be success
    End

    It 'SubagentStart is documented'
      When call check_spec_has_subagent_start
      The status should be success
    End

    It 'SubagentStop is documented'
      When call check_spec_has_subagent_stop
      The status should be success
    End
  End
End
