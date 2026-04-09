# Task 3, CC5/CC6: backlog-update.sh and generate-dashboard.sh
# source lib/common.sh and use shared acquire_lock/release_lock
# Design spec 17, 18

BACKLOG_UPDATE="core/scripts/backlog-update.sh"
GENERATE_DASHBOARD="core/scripts/generate-dashboard.sh"

# --- Helper functions ---

# Check backlog-update.sh sources lib/common.sh
check_backlog_sources_common() {
  grep -q 'source.*lib/common\.sh' "$BACKLOG_UPDATE"
}

# Check backlog-update.sh has no own acquire_lock definition
check_backlog_no_own_acquire_lock() {
  # Verify no function definition "acquire_lock()" exists
  ! grep -q '^acquire_lock()' "$BACKLOG_UPDATE"
}

# Check backlog-update.sh has no own release_lock definition
check_backlog_no_own_release_lock() {
  ! grep -q '^release_lock()' "$BACKLOG_UPDATE"
}

# Check generate-dashboard.sh sources lib/common.sh
check_dashboard_sources_common() {
  grep -q 'source.*lib/common\.sh' "$GENERATE_DASHBOARD"
}

# Check generate-dashboard.sh has no own acquire_lock definition
check_dashboard_no_own_acquire_lock() {
  ! grep -q '^acquire_lock()' "$GENERATE_DASHBOARD"
}

# Check generate-dashboard.sh has no own cleanup/is_lock_stale definitions
check_dashboard_no_own_cleanup() {
  ! grep -q '^cleanup()' "$GENERATE_DASHBOARD"
}

check_dashboard_no_own_is_lock_stale() {
  ! grep -q '^is_lock_stale()' "$GENERATE_DASHBOARD"
}

Describe 'Lock Mechanism Consolidation -- Script Integration (CC5/CC6)'

  Describe 'backlog-update.sh Uses lib/common.sh (CC5)'
    It 'sources lib/common.sh'
      When call check_backlog_sources_common
      The status should be success
    End

    It 'has no own acquire_lock definition'
      When call check_backlog_no_own_acquire_lock
      The status should be success
    End

    It 'has no own release_lock definition'
      When call check_backlog_no_own_release_lock
      The status should be success
    End
  End

  Describe 'generate-dashboard.sh Uses lib/common.sh (CC6)'
    It 'sources lib/common.sh'
      When call check_dashboard_sources_common
      The status should be success
    End

    It 'has no own acquire_lock definition'
      When call check_dashboard_no_own_acquire_lock
      The status should be success
    End

    It 'has no own cleanup definition'
      When call check_dashboard_no_own_cleanup
      The status should be success
    End

    It 'has no own is_lock_stale definition'
      When call check_dashboard_no_own_is_lock_stale
      The status should be success
    End
  End
End
