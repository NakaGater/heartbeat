SKILL_MD="adapters/claude-code/skills/heartbeat/SKILL.md"
SKILL_MD_COPILOT="adapters/copilot/skills/heartbeat/SKILL.md"

check_workflow1_stop() {
  grep -A 40 "## Workflow 1" "$SKILL_MD" | grep -q "STOP"
}

check_workflow1_end() {
  grep -A 40 "## Workflow 1" "$SKILL_MD" | grep -q "END OF WORKFLOW 1"
}

check_workflow2_stop() {
  grep -A 50 "## Workflow 2" "$SKILL_MD" | grep -q "STOP"
}

check_workflow3_stop_override() {
  grep -A 30 "## Workflow 3" "$SKILL_MD" | grep -q "IGNORE"
}

check_workflow3_own_stop() {
  grep -A 30 "## Workflow 3" "$SKILL_MD" | grep -q "Workflow 3 complete"
}

check_agent_startup_workflow_branch() {
  grep -A 50 "## Agent Startup Method" "$SKILL_MD" | grep -q "Check current workflow context"
}

check_platform_sync() {
  grep -q "Copilot-Specific" "$SKILL_MD_COPILOT"
}

Describe 'Workflow boundary enforcement in SKILL.md'
  It 'Workflow 1 has STOP directive'
    When call check_workflow1_stop
    The status should be success
  End

  It 'Workflow 1 has END OF WORKFLOW 1 marker'
    When call check_workflow1_end
    The status should be success
  End

  It 'Workflow 2 has STOP directive'
    When call check_workflow2_stop
    The status should be success
  End

  It 'Workflow 3 has STOP override instruction (IGNORE)'
    When call check_workflow3_stop_override
    The status should be success
  End

  It 'Workflow 3 has its own STOP directive'
    When call check_workflow3_own_stop
    The status should be success
  End

  It 'Agent Startup Method has workflow context check'
    When call check_agent_startup_workflow_branch
    The status should be success
  End

  It 'copilot SKILL.md has Copilot-Specific section'
    When call check_platform_sync
    The status should be success
  End
End
