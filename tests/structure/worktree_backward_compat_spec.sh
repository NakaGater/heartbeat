Describe 'Worktree backward compatibility'

  check_dashboard_has_worktree_guard() {
    grep -q 'HEARTBEAT_IN_WORKTREE' core/scripts/generate-dashboard.sh
  }

  check_autocommit_has_active_story() {
    # After refactoring, HEARTBEAT_ACTIVE_STORY logic lives in lib/common.sh
    # which auto-commit.sh sources. Verify the capability exists in the lib.
    grep -q 'HEARTBEAT_ACTIVE_STORY' core/scripts/lib/common.sh &&
      grep -q 'source.*lib/common.sh' core/scripts/auto-commit.sh
  }

  check_retro_has_main_dir() {
    grep -q 'HEARTBEAT_MAIN_DIR' core/scripts/retrospective-record.sh
  }

  check_dashboard_works_without_env() {
    unset HEARTBEAT_IN_WORKTREE 2>/dev/null || true
    bash core/scripts/generate-dashboard.sh >/dev/null 2>&1
  }

  check_workflow6_exists() {
    grep -q 'Workflow 6' core/skills/heartbeat/SKILL.md
  }

  check_choice6_exists() {
    grep -q 'Implement in parallel' core/skills/heartbeat/SKILL.md
  }

  check_worktree_hook_exists() {
    jq -e '.hooks.WorktreeCreate' .claude/settings.local.json >/dev/null 2>&1
  }

  It 'generate-dashboard.sh has HEARTBEAT_IN_WORKTREE early exit guard'
    When call check_dashboard_has_worktree_guard
    The status should be success
  End

  It 'auto-commit.sh has HEARTBEAT_ACTIVE_STORY fallback'
    When call check_autocommit_has_active_story
    The status should be success
  End

  It 'retrospective-record.sh has HEARTBEAT_MAIN_DIR fallback'
    When call check_retro_has_main_dir
    The status should be success
  End

  It 'generate-dashboard.sh still works without worktree env vars'
    When call check_dashboard_works_without_env
    The status should be success
  End

  It 'SKILL.md Workflow 6 exists in core'
    When call check_workflow6_exists
    The status should be success
  End

  It 'SKILL.md choice 6 exists in core'
    When call check_choice6_exists
    The status should be success
  End

  It 'settings.local.json has WorktreeCreate hook'
    When call check_worktree_hook_exists
    The status should be success
  End
End
