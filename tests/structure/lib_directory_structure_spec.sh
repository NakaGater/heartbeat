# タスク7: lib/ ディレクトリの構造テスト (AC-6)
# core/scripts/lib/ ディレクトリの存在・ファイル構成・ライブラリパターンを検証する

LIB_DIR="core/scripts/lib"
COMMON_SH="$LIB_DIR/common.sh"
COMMIT_MSG_SH="$LIB_DIR/commit-message.sh"

# --- ヘルパー関数 ---

# lib/ ディレクトリが存在するか
check_lib_dir_exists() {
  [ -d "$LIB_DIR" ]
}

# common.sh が存在するか
check_common_sh_exists() {
  [ -f "$COMMON_SH" ]
}

# commit-message.sh が存在するか
check_commit_message_sh_exists() {
  [ -f "$COMMIT_MSG_SH" ]
}

# common.sh が構文エラーなく source 可能か
check_common_sh_sourceable() {
  bash -n "$COMMON_SH"
}

# commit-message.sh が構文エラーなく source 可能か
check_commit_message_sh_sourceable() {
  bash -n "$COMMIT_MSG_SH"
}

# common.sh に find_board_jsonl が定義されているか
check_common_has_find_board_jsonl() {
  grep -q '^find_board_jsonl()' "$COMMON_SH"
}

# common.sh に acquire_lock が定義されているか
check_common_has_acquire_lock() {
  grep -q '^acquire_lock()' "$COMMON_SH"
}

# common.sh に release_lock が定義されているか
check_common_has_release_lock() {
  grep -q '^release_lock()' "$COMMON_SH"
}

# commit-message.sh に format_commit_message が定義されているか
check_commit_msg_has_format() {
  grep -q '^format_commit_message()' "$COMMIT_MSG_SH"
}

# common.sh が source 時に副作用（標準出力）を起こさないか
check_common_no_side_effects() {
  local output
  output=$(bash -c 'source "'"$COMMON_SH"'"' 2>&1)
  [ -z "$output" ]
}

# commit-message.sh が source 時に副作用（標準出力）を起こさないか
check_commit_message_no_side_effects() {
  local output
  output=$(bash -c 'source "'"$COMMIT_MSG_SH"'"' 2>&1)
  [ -z "$output" ]
}

Describe 'lib/ ディレクトリの構造テスト (AC-6)'

  Describe 'ディレクトリとファイルの存在 (CC1/CC2)'
    It 'core/scripts/lib/ ディレクトリが存在する'
      When call check_lib_dir_exists
      The status should be success
    End

    It 'lib/common.sh が存在する'
      When call check_common_sh_exists
      The status should be success
    End

    It 'lib/commit-message.sh が存在する'
      When call check_commit_message_sh_exists
      The status should be success
    End
  End

  Describe 'ファイルの source 可能性 (CC1/CC2)'
    It 'common.sh が構文エラーなく source できる'
      When call check_common_sh_sourceable
      The status should be success
    End

    It 'commit-message.sh が構文エラーなく source できる'
      When call check_commit_message_sh_sourceable
      The status should be success
    End
  End

  Describe 'common.sh の必須関数定義 (CC3)'
    It 'find_board_jsonl 関数が定義されている'
      When call check_common_has_find_board_jsonl
      The status should be success
    End

    It 'acquire_lock 関数が定義されている'
      When call check_common_has_acquire_lock
      The status should be success
    End

    It 'release_lock 関数が定義されている'
      When call check_common_has_release_lock
      The status should be success
    End
  End

  Describe 'commit-message.sh の必須関数定義 (CC3)'
    It 'format_commit_message 関数が定義されている'
      When call check_commit_msg_has_format
      The status should be success
    End
  End

  Describe 'ライブラリパターン — source 時の副作用がない (CC4)'
    It 'common.sh は source 時に何も出力しない'
      When call check_common_no_side_effects
      The status should be success
    End

    It 'commit-message.sh は source 時に何も出力しない'
      When call check_commit_message_no_side_effects
      The status should be success
    End
  End
End
