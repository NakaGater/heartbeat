SKILL="core/skills/heartbeat/SKILL.md"

# Task 1 completion condition:
# SKILL.md の "Orchestrator responsibilities (after subagent returns)" セクションに
# retro.jsonl 検証（責務5）の直後に generate-dashboard.sh 実行指示が存在する

check_orchestrator_has_dashboard_update() {
  # Extract the orchestrator responsibilities section
  section=$(sed -n '/^### Orchestrator responsibilities (after subagent returns)/,/^## /p' "$SKILL")
  [ -z "$section" ] && return 1
  # Check that generate-dashboard.sh instruction exists in this section
  echo "$section" | grep -q "generate-dashboard.sh" || return 1
}

check_dashboard_update_after_retro_verification() {
  # The generate-dashboard.sh step must appear AFTER the retro.jsonl verification step
  section=$(sed -n '/^### Orchestrator responsibilities (after subagent returns)/,/^## /p' "$SKILL")
  [ -z "$section" ] && return 1
  retro_line=$(echo "$section" | grep -n "retro.jsonl" | head -1 | cut -d: -f1)
  dashboard_line=$(echo "$section" | grep -n "generate-dashboard.sh" | head -1 | cut -d: -f1)
  [ -n "$retro_line" ] && [ -n "$dashboard_line" ] && [ "$retro_line" -lt "$dashboard_line" ]
}

check_dashboard_update_before_workflow_context() {
  # The generate-dashboard.sh step must appear BEFORE the workflow context check step
  section=$(sed -n '/^### Orchestrator responsibilities (after subagent returns)/,/^## /p' "$SKILL")
  [ -z "$section" ] && return 1
  dashboard_line=$(echo "$section" | grep -n "generate-dashboard.sh" | head -1 | cut -d: -f1)
  workflow_line=$(echo "$section" | grep -n "Check current workflow context" | head -1 | cut -d: -f1)
  [ -n "$dashboard_line" ] && [ -n "$workflow_line" ] && [ "$dashboard_line" -lt "$workflow_line" ]
}

check_dashboard_update_is_synchronous() {
  # The instruction must specify synchronous execution (matching existing pattern)
  section=$(sed -n '/^### Orchestrator responsibilities (after subagent returns)/,/^## /p' "$SKILL")
  [ -z "$section" ] && return 1
  echo "$section" | grep -q "synchronous" || return 1
}

Describe 'SKILL.md orchestrator dashboard update after subagent returns'
  It 'has generate-dashboard.sh in Orchestrator responsibilities section'
    When call check_orchestrator_has_dashboard_update
    The status should be success
  End

  It 'generate-dashboard.sh appears after retro.jsonl verification'
    When call check_dashboard_update_after_retro_verification
    The status should be success
  End

  It 'generate-dashboard.sh appears before workflow context check'
    When call check_dashboard_update_before_workflow_context
    The status should be success
  End

  It 'specifies synchronous execution for generate-dashboard.sh'
    When call check_dashboard_update_is_synchronous
    The status should be success
  End
End
