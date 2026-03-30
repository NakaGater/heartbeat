check_agents_xp_values() {
  for agent in core/agent-personas/*.md; do
    grep -q "values.md\|xp/values\|XP Alignment" "$agent" || return 1
  done
}

check_agents_retrospective() {
  for agent in core/agent-personas/*.md; do
    grep -q "retrospective\|Retrospective" "$agent" || return 1
  done
}

check_agents_board_protocol() {
  for agent in core/agent-personas/*.md; do
    grep -q "Board Protocol\|board" "$agent" || return 1
  done
}

check_copilot_adapters() {
  for adapter in adapters/copilot/agents/*.agent.md; do
    # Skip orchestrator (heartbeat) — it delegates to sub-agents, not a core persona
    case "$adapter" in
      */heartbeat.agent.md) continue ;;
    esac
    grep -q "core/agent-personas" "$adapter" || return 1
  done
}

check_claude_code_adapters() {
  for adapter in adapters/claude-code/agents/*.agent.md; do
    grep -q "core/agent-personas" "$adapter" || return 1
  done
}

check_agents_output_language() {
  for agent in core/agent-personas/*.md; do
    grep -q "output-language-rule\|Output Language" "$agent" || return 1
  done
}

Describe 'Agent definition structure'
  It 'all agents reference XP values'
    When call check_agents_xp_values
    The status should be success
  End

  It 'all agents have retrospective trigger'
    When call check_agents_retrospective
    The status should be success
  End

  It 'all agents have board protocol rules'
    When call check_agents_board_protocol
    The status should be success
  End

  It 'Copilot adapters reference core personas'
    When call check_copilot_adapters
    The status should be success
  End

  It 'Claude Code adapters reference core personas'
    When call check_claude_code_adapters
    The status should be success
  End

  It 'all agents reference output language rule'
    When call check_agents_output_language
    The status should be success
  End
End
