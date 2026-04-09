# Task 8: Final regression test and verification (AC-6/AC-8)
# Final regression test to verify overall refactoring goals are met
# - auto-commit.sh is 120 lines or fewer (target ~100, actual ~52)
# - No inline lock definitions remain in backlog-update.sh / generate-dashboard.sh
# - No inline _find_board_jsonl remains in auto-commit.sh
# - Test case count is 294 or more (pre-refactoring baseline)

AUTO_COMMIT="core/scripts/auto-commit.sh"
BACKLOG_UPDATE="core/scripts/backlog-update.sh"
GENERATE_DASHBOARD="core/scripts/generate-dashboard.sh"
BOARD_STAMP="core/scripts/board-stamp.sh"

# --- Helper functions ---

# Check auto-commit.sh line count is 120 or fewer
check_auto_commit_line_count() {
  local lines
  lines=$(wc -l < "$AUTO_COMMIT" | tr -d ' ')
  [ "$lines" -le 120 ]
}

# Get auto-commit.sh line count (for debugging)
get_auto_commit_line_count() {
  wc -l < "$AUTO_COMMIT" | tr -d ' '
}

# Check backlog-update.sh has no inline acquire_lock/release_lock definitions
check_backlog_no_inline_lock() {
  ! grep -qE '^(acquire_lock|release_lock)\(\)' "$BACKLOG_UPDATE"
}

# Check generate-dashboard.sh has no inline acquire_lock/cleanup/is_lock_stale definitions
check_dashboard_no_inline_lock() {
  ! grep -qE '^(acquire_lock|release_lock|cleanup|is_lock_stale)\(\)' "$GENERATE_DASHBOARD"
}

# Check auto-commit.sh has no inline _find_board_jsonl definition
check_auto_commit_no_inline_find_board() {
  ! grep -q '^_find_board_jsonl()' "$AUTO_COMMIT"
}

# Check board-stamp.sh has no inline ls -t board.jsonl search
check_board_stamp_no_inline_board_search() {
  ! grep -q 'ls -t.*board\.jsonl' "$BOARD_STAMP"
}

# Check no duplicate board.jsonl search in core/scripts/ top-level scripts
# (only lib/common.sh should have the ls -t board.jsonl pattern)
check_no_duplicate_board_search() {
  local count
  count=$(grep -rl 'ls -t.*board\.jsonl' core/scripts/*.sh 2>/dev/null | wc -l | tr -d ' ')
  [ "$count" -eq 0 ]
}

# Check test case count (It blocks) is 294 or more
check_test_count_not_decreased() {
  local count
  count=$(grep -r '^\s*It ' tests/spec/ tests/structure/ | wc -l | tr -d ' ')
  [ "$count" -ge 294 ]
}

# Get test case count (for debugging)
get_test_count() {
  grep -r '^\s*It ' tests/spec/ tests/structure/ | wc -l | tr -d ' '
}

Describe 'Final Regression Test and Verification (AC-6)'

  Describe 'auto-commit.sh Line Count Reduction (CC3)'
    It 'auto-commit.sh is 120 lines or fewer'
      When call check_auto_commit_line_count
      The status should be success
    End
  End

  Describe 'Inline Lock Definition Removal (CC5)'
    It 'backlog-update.sh has no inline lock definitions'
      When call check_backlog_no_inline_lock
      The status should be success
    End

    It 'generate-dashboard.sh has no inline lock definitions'
      When call check_dashboard_no_inline_lock
      The status should be success
    End
  End

  Describe 'Inline board.jsonl Search Removal (CC4)'
    It 'auto-commit.sh has no inline _find_board_jsonl'
      When call check_auto_commit_no_inline_find_board
      The status should be success
    End

    It 'board-stamp.sh has no inline board.jsonl search code'
      When call check_board_stamp_no_inline_board_search
      The status should be success
    End

    It 'no duplicate board.jsonl search in core/scripts/'
      When call check_no_duplicate_board_search
      The status should be success
    End
  End

  Describe 'Test Case Count Preservation (CC2)'
    It 'test case count is at or above pre-refactoring baseline of 294'
      When call check_test_count_not_decreased
      The status should be success
    End
  End
End
