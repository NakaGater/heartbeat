# タスク8: 全体回帰テストと最終確認 (AC-6/AC-8)
# リファクタリング全体の目標達成を検証する最終回帰テスト
# - auto-commit.sh が 120 行以下（目標 ~100、実績 ~52）
# - インラインのロック定義が backlog-update.sh / generate-dashboard.sh に残っていない
# - インラインの _find_board_jsonl が auto-commit.sh に残っていない
# - テストケース数が 294 以上（リファクタリング前のベースライン）

AUTO_COMMIT="core/scripts/auto-commit.sh"
BACKLOG_UPDATE="core/scripts/backlog-update.sh"
GENERATE_DASHBOARD="core/scripts/generate-dashboard.sh"
BOARD_STAMP="core/scripts/board-stamp.sh"

# --- ヘルパー関数 ---

# auto-commit.sh の行数が 120 以下であるか
check_auto_commit_line_count() {
  local lines
  lines=$(wc -l < "$AUTO_COMMIT" | tr -d ' ')
  [ "$lines" -le 120 ]
}

# auto-commit.sh の行数を取得（デバッグ用）
get_auto_commit_line_count() {
  wc -l < "$AUTO_COMMIT" | tr -d ' '
}

# backlog-update.sh にインラインの acquire_lock/release_lock 定義が存在しないか
check_backlog_no_inline_lock() {
  ! grep -qE '^(acquire_lock|release_lock)\(\)' "$BACKLOG_UPDATE"
}

# generate-dashboard.sh にインラインの acquire_lock/cleanup/is_lock_stale 定義が存在しないか
check_dashboard_no_inline_lock() {
  ! grep -qE '^(acquire_lock|release_lock|cleanup|is_lock_stale)\(\)' "$GENERATE_DASHBOARD"
}

# auto-commit.sh にインラインの _find_board_jsonl 定義が存在しないか
check_auto_commit_no_inline_find_board() {
  ! grep -q '^_find_board_jsonl()' "$AUTO_COMMIT"
}

# board-stamp.sh にインラインの ls -t board.jsonl 探索が存在しないか
check_board_stamp_no_inline_board_search() {
  ! grep -q 'ls -t.*board\.jsonl' "$BOARD_STAMP"
}

# core/scripts/ 直下のスクリプトに board.jsonl 検索の重複がないか
# (lib/common.sh のみが ls -t board.jsonl パターンを持つべき)
check_no_duplicate_board_search() {
  local count
  count=$(grep -rl 'ls -t.*board\.jsonl' core/scripts/*.sh 2>/dev/null | wc -l | tr -d ' ')
  [ "$count" -eq 0 ]
}

# テストケース数（It ブロック）が 294 以上あるか
check_test_count_not_decreased() {
  local count
  count=$(grep -r '^\s*It ' tests/spec/ tests/structure/ | wc -l | tr -d ' ')
  [ "$count" -ge 294 ]
}

# テストケース数を取得（デバッグ用）
get_test_count() {
  grep -r '^\s*It ' tests/spec/ tests/structure/ | wc -l | tr -d ' '
}

Describe '全体回帰テストと最終確認 (AC-6)'

  Describe 'auto-commit.sh の行数削減 (CC3)'
    It 'auto-commit.sh が 120 行以下である'
      When call check_auto_commit_line_count
      The status should be success
    End
  End

  Describe 'インラインロック定義の排除 (CC5)'
    It 'backlog-update.sh にインラインのロック定義が存在しない'
      When call check_backlog_no_inline_lock
      The status should be success
    End

    It 'generate-dashboard.sh にインラインのロック定義が存在しない'
      When call check_dashboard_no_inline_lock
      The status should be success
    End
  End

  Describe 'インライン board.jsonl 検索の排除 (CC4)'
    It 'auto-commit.sh にインラインの _find_board_jsonl が存在しない'
      When call check_auto_commit_no_inline_find_board
      The status should be success
    End

    It 'board-stamp.sh にインラインの board.jsonl 探索コードが存在しない'
      When call check_board_stamp_no_inline_board_search
      The status should be success
    End

    It 'core/scripts/ 直下に board.jsonl 検索の重複がない'
      When call check_no_duplicate_board_search
      The status should be success
    End
  End

  Describe 'テストケース数の維持 (CC2)'
    It 'テストケース数がリファクタリング前のベースライン 294 以上である'
      When call check_test_count_not_decreased
      The status should be success
    End
  End
End
