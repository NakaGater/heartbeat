# Verify that obsolete dashboard-related test files have been deleted.
# These tests validated behaviors that no longer exist after
# restricting dashboard generation to SubagentStop only.

check_file_does_not_exist() {
  local file="$1"
  if [ -f "$file" ]; then
    return 1
  fi
  return 0
}

Describe 'Obsolete dashboard test files are removed'
  It 'tests/structure/skill_acceptance_dashboard_invocations_spec.sh does not exist'
    When call check_file_does_not_exist "tests/structure/skill_acceptance_dashboard_invocations_spec.sh"
    The status should be success
  End

  It 'tests/structure/skill_orchestrator_dashboard_update_spec.sh does not exist'
    When call check_file_does_not_exist "tests/structure/skill_orchestrator_dashboard_update_spec.sh"
    The status should be success
  End

  It 'tests/spec/skill_backlog_dashboard_sync_spec.sh does not exist'
    When call check_file_does_not_exist "tests/spec/skill_backlog_dashboard_sync_spec.sh"
    The status should be success
  End

  It 'tests/spec/skill_workflow1_dashboard_sync_spec.sh does not exist'
    When call check_file_does_not_exist "tests/spec/skill_workflow1_dashboard_sync_spec.sh"
    The status should be success
  End

  It 'tests/spec/skill_workflow2_dashboard_sync_spec.sh does not exist'
    When call check_file_does_not_exist "tests/spec/skill_workflow2_dashboard_sync_spec.sh"
    The status should be success
  End

  It 'tests/spec/skill_workflow2_inprogress_status_spec.sh does not exist'
    When call check_file_does_not_exist "tests/spec/skill_workflow2_inprogress_status_spec.sh"
    The status should be success
  End

  It 'tests/spec/skill_workflow1_draft_status_spec.sh does not exist'
    When call check_file_does_not_exist "tests/spec/skill_workflow1_draft_status_spec.sh"
    The status should be success
  End
End
