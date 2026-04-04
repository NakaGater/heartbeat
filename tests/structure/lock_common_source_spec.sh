# Task 3, CC5/CC6: backlog-update.sh と generate-dashboard.sh が
# lib/common.sh を source し、共通の acquire_lock/release_lock を使用する
# Design spec 17, 18

BACKLOG_UPDATE="core/scripts/backlog-update.sh"
GENERATE_DASHBOARD="core/scripts/generate-dashboard.sh"

# --- ヘルパー関数 ---

# backlog-update.sh が lib/common.sh を source しているか
check_backlog_sources_common() {
  grep -q 'source.*lib/common\.sh' "$BACKLOG_UPDATE"
}

# backlog-update.sh に独自の acquire_lock 定義が存在しないか
check_backlog_no_own_acquire_lock() {
  # 関数定義 "acquire_lock()" が存在しないことを確認
  ! grep -q '^acquire_lock()' "$BACKLOG_UPDATE"
}

# backlog-update.sh に独自の release_lock 定義が存在しないか
check_backlog_no_own_release_lock() {
  ! grep -q '^release_lock()' "$BACKLOG_UPDATE"
}

# generate-dashboard.sh が lib/common.sh を source しているか
check_dashboard_sources_common() {
  grep -q 'source.*lib/common\.sh' "$GENERATE_DASHBOARD"
}

# generate-dashboard.sh に独自の acquire_lock 定義が存在しないか
check_dashboard_no_own_acquire_lock() {
  ! grep -q '^acquire_lock()' "$GENERATE_DASHBOARD"
}

# generate-dashboard.sh に独自の cleanup/is_lock_stale 定義が存在しないか
check_dashboard_no_own_cleanup() {
  ! grep -q '^cleanup()' "$GENERATE_DASHBOARD"
}

check_dashboard_no_own_is_lock_stale() {
  ! grep -q '^is_lock_stale()' "$GENERATE_DASHBOARD"
}

Describe 'ロック機構の共通化 — スクリプト統合 (CC5/CC6)'

  Describe 'backlog-update.sh が lib/common.sh を使用 (CC5)'
    It 'lib/common.sh を source している'
      When call check_backlog_sources_common
      The status should be success
    End

    It '独自の acquire_lock 定義が存在しない'
      When call check_backlog_no_own_acquire_lock
      The status should be success
    End

    It '独自の release_lock 定義が存在しない'
      When call check_backlog_no_own_release_lock
      The status should be success
    End
  End

  Describe 'generate-dashboard.sh が lib/common.sh を使用 (CC6)'
    It 'lib/common.sh を source している'
      When call check_dashboard_sources_common
      The status should be success
    End

    It '独自の acquire_lock 定義が存在しない'
      When call check_dashboard_no_own_acquire_lock
      The status should be success
    End

    It '独自の cleanup 定義が存在しない'
      When call check_dashboard_no_own_cleanup
      The status should be success
    End

    It '独自の is_lock_stale 定義が存在しない'
      When call check_dashboard_no_own_is_lock_stale
      The status should be success
    End
  End
End
