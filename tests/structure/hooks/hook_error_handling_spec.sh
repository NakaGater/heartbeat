# Task 5, CC1-CC4: Error handling standardization for hook scripts
# Hook scripts = set +e + guaranteed exit 0
# Design spec 25-28 (AC-5)

RETRO_RECORD="core/scripts/retrospective-record.sh"
GENERATE_DASHBOARD="core/scripts/generate-dashboard.sh"
AUTO_COMMIT="core/scripts/auto-commit.sh"
BOARD_STAMP="core/scripts/board-stamp.sh"

# --- Helper functions ---

# Check retrospective-record.sh contains set +e
check_retro_has_set_plus_e() {
  grep -q '^set +e' "$RETRO_RECORD"
}

# Check retrospective-record.sh has no exit 1 (guaranteed exit 0 on all paths)
check_retro_no_exit_1() {
  ! grep -q 'exit 1' "$RETRO_RECORD"
}

# Check generate-dashboard.sh exits 0 on acquire_lock failure
check_dashboard_acquire_lock_exit_0() {
  # Must be acquire_lock ... || exit 0 (not exit 1)
  ! grep -q 'acquire_lock.*exit 1' "$GENERATE_DASHBOARD"
}

# Check auto-commit.sh main does not contain set -euo pipefail
check_auto_commit_no_set_e_in_main() {
  ! grep -q 'set -euo pipefail' "$AUTO_COMMIT"
}

# Check auto-commit.sh has set +e at the top
check_auto_commit_has_set_plus_e() {
  grep -q '^set +e' "$AUTO_COMMIT"
}

# Check board-stamp.sh contains set +e (existing pattern preserved)
check_board_stamp_has_set_plus_e() {
  grep -q '^set +e' "$BOARD_STAMP"
}

Describe 'Hook Script Error Handling Standardization (AC-5)'

  Describe 'retrospective-record.sh (CC1)'
    It 'has set +e at the top'
      When call check_retro_has_set_plus_e
      The status should be success
    End

    It 'has no exit 1 (guaranteed exit 0 on all paths)'
      When call check_retro_no_exit_1
      The status should be success
    End
  End

  Describe 'generate-dashboard.sh (CC2)'
    It 'exits 0 instead of 1 on acquire_lock failure'
      When call check_dashboard_acquire_lock_exit_0
      The status should be success
    End
  End

  Describe 'auto-commit.sh (CC3)'
    It 'does not contain set -euo pipefail'
      When call check_auto_commit_no_set_e_in_main
      The status should be success
    End

    It 'has set +e at the top'
      When call check_auto_commit_has_set_plus_e
      The status should be success
    End
  End

  Describe 'board-stamp.sh (CC4)'
    It 'existing set +e pattern is preserved'
      When call check_board_stamp_has_set_plus_e
      The status should be success
    End
  End
End
