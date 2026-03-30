PLUGIN_JSON=".claude-plugin/plugin.json"

EXPECTED_AGENT_COUNT=9
EXPECTED_AGENTS="
adapters/claude-code/agents/pdm.agent.md
adapters/claude-code/agents/context-manager.agent.md
adapters/claude-code/agents/designer.agent.md
adapters/claude-code/agents/architect.agent.md
adapters/claude-code/agents/tester.agent.md
adapters/claude-code/agents/implementer.agent.md
adapters/claude-code/agents/refactor.agent.md
adapters/claude-code/agents/reviewer.agent.md
adapters/claude-code/agents/qa.agent.md
"

# --- Condition 1: plugin.json is valid JSON ---
check_valid_json() {
  jq empty "$PLUGIN_JSON" >/dev/null 2>&1
}

# --- Condition 2: agents field exists and has 9 entries ---
check_agents_field_exists() {
  jq -e '.agents' "$PLUGIN_JSON" >/dev/null 2>&1
}

check_agents_count() {
  local count
  count=$(jq '.agents | length' "$PLUGIN_JSON" 2>/dev/null)
  [ "$count" -eq "$EXPECTED_AGENT_COUNT" ]
}

# --- Condition 3: skills field exists ---
check_skills_field_exists() {
  jq -e '.skills' "$PLUGIN_JSON" >/dev/null 2>&1
}

# --- Condition 4: hooks field exists ---
check_hooks_field_exists() {
  jq -e '.hooks' "$PLUGIN_JSON" >/dev/null 2>&1
}

# --- Condition 5: mcpServers field exists ---
check_mcpservers_field_exists() {
  jq -e '.mcpServers' "$PLUGIN_JSON" >/dev/null 2>&1
}

# --- Condition 6: each agent path points to an existing file ---
check_agent_paths_exist() {
  local agents
  agents=$(jq -r '.agents[]' "$PLUGIN_JSON" 2>/dev/null) || return 1
  while IFS= read -r path; do
    [ -z "$path" ] && continue
    [ -f "$path" ] || return 1
  done <<EOF
$agents
EOF
}

Describe 'Claude Code plugin.json manifest'
  It 'is valid JSON'
    When call check_valid_json
    The status should be success
  End

  It 'has agents field'
    When call check_agents_field_exists
    The status should be success
  End

  It 'has exactly 9 agent paths'
    When call check_agents_count
    The status should be success
  End

  It 'has skills field'
    When call check_skills_field_exists
    The status should be success
  End

  It 'has hooks field'
    When call check_hooks_field_exists
    The status should be success
  End

  It 'has mcpServers field'
    When call check_mcpservers_field_exists
    The status should be success
  End

  It 'all agent paths point to existing files'
    When call check_agent_paths_exist
    The status should be success
  End
End
