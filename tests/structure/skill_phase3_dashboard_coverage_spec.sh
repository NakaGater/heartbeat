SKILL="core/skills/heartbeat/SKILL.md"

# Verify Phase 3 TDD cycle agents (tester, implementer, refactor) are
# launched via Agent tool dispatch.
# Subagents launched via Agent tool return control to the orchestrator
# on completion, so Orchestrator responsibilities apply.

check_tester_uses_agent_tool_dispatch() {
  # Verify tester is launched via Agent tool invocation pattern
  # This ensures Orchestrator responsibilities apply on completion
  grep -q 'subagent_type:.*heartbeat:tester\.agent' "$SKILL" || return 1
}

check_implementer_uses_agent_tool_dispatch() {
  # Verify implementer is launched via Agent tool invocation pattern
  grep -q 'subagent_type:.*heartbeat:implementer\.agent' "$SKILL" || return 1
}

check_refactor_uses_agent_tool_dispatch() {
  # Verify refactor is launched via Agent tool invocation pattern
  grep -q 'subagent_type:.*heartbeat:refactor\.agent' "$SKILL" || return 1
}

check_phase3_agents_in_tdd_cycle_flow() {
  # Verify Phase 3 TDD cycle description includes all 3 agents
  # (= targets for Orchestrator responsibilities)
  phase3_section=$(sed -n '/^Phase 3 - Implementation/,/^Phase 4/p' "$SKILL")
  [ -z "$phase3_section" ] && return 1
  echo "$phase3_section" | grep -q "tester" || return 1
  echo "$phase3_section" | grep -q "implementer" || return 1
  echo "$phase3_section" | grep -q "refactor" || return 1
}

check_orchestrator_responsibilities_section_exists() {
  # Verify Orchestrator responsibilities section exists and applies unconditionally
  # ("after subagent returns" = applies after all subagent completions)
  section=$(sed -n '/^### Orchestrator responsibilities (after subagent returns)/,/^## /p' "$SKILL")
  [ -z "$section" ] && return 1
  return 0
}

Describe 'Phase 3 TDD Cycle Agent Dashboard Update Coverage'
  It 'tester is launched via Agent tool dispatch pattern'
    When call check_tester_uses_agent_tool_dispatch
    The status should be success
  End

  It 'implementer is launched via Agent tool dispatch pattern'
    When call check_implementer_uses_agent_tool_dispatch
    The status should be success
  End

  It 'refactor is launched via Agent tool dispatch pattern'
    When call check_refactor_uses_agent_tool_dispatch
    The status should be success
  End

  It 'Phase 3 TDD cycle includes all agents: tester/implementer/refactor'
    When call check_phase3_agents_in_tdd_cycle_flow
    The status should be success
  End

  It 'Orchestrator responsibilities section exists and applies to all subagents unconditionally'
    When call check_orchestrator_responsibilities_section_exists
    The status should be success
  End
End
