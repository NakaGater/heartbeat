# Task 5, CC1-CC4: フックスクリプトのエラーハンドリング標準化
# フックスクリプト = set +e + exit 0 保証
# Design spec 25-28 (AC-5)

RETRO_RECORD="core/scripts/retrospective-record.sh"
GENERATE_DASHBOARD="core/scripts/generate-dashboard.sh"
AUTO_COMMIT="core/scripts/auto-commit.sh"
BOARD_STAMP="core/scripts/board-stamp.sh"

# --- ヘルパー関数 ---

# retrospective-record.sh に set +e が含まれているか
check_retro_has_set_plus_e() {
  grep -q '^set +e' "$RETRO_RECORD"
}

# retrospective-record.sh に exit 1 が存在しないか（全パス exit 0 保証）
check_retro_no_exit_1() {
  ! grep -q 'exit 1' "$RETRO_RECORD"
}

# generate-dashboard.sh の acquire_lock 失敗時に exit 0 であるか
check_dashboard_acquire_lock_exit_0() {
  # acquire_lock ... || exit 0 であること（exit 1 ではない）
  ! grep -q 'acquire_lock.*exit 1' "$GENERATE_DASHBOARD"
}

# auto-commit.sh の main 内に set -euo pipefail が存在しないか
check_auto_commit_no_set_e_in_main() {
  ! grep -q 'set -euo pipefail' "$AUTO_COMMIT"
}

# auto-commit.sh の先頭に set +e が含まれているか
check_auto_commit_has_set_plus_e() {
  grep -q '^set +e' "$AUTO_COMMIT"
}

# board-stamp.sh に set +e が含まれているか（既存パターン維持）
check_board_stamp_has_set_plus_e() {
  grep -q '^set +e' "$BOARD_STAMP"
}

Describe 'フックスクリプトのエラーハンドリング標準化 (AC-5)'

  Describe 'retrospective-record.sh (CC1)'
    It 'set +e が先頭に存在する'
      When call check_retro_has_set_plus_e
      The status should be success
    End

    It 'exit 1 が存在しない（全パス exit 0 保証）'
      When call check_retro_no_exit_1
      The status should be success
    End
  End

  Describe 'generate-dashboard.sh (CC2)'
    It 'acquire_lock 失敗時に exit 1 ではなく exit 0 で終了する'
      When call check_dashboard_acquire_lock_exit_0
      The status should be success
    End
  End

  Describe 'auto-commit.sh (CC3)'
    It 'set -euo pipefail が存在しない'
      When call check_auto_commit_no_set_e_in_main
      The status should be success
    End

    It 'set +e が先頭に存在する'
      When call check_auto_commit_has_set_plus_e
      The status should be success
    End
  End

  Describe 'board-stamp.sh (CC4)'
    It '既存の set +e パターンが維持されている'
      When call check_board_stamp_has_set_plus_e
      The status should be success
    End
  End
End
