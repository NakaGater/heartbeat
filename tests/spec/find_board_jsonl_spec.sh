Describe 'find_board_jsonl() in lib/common.sh'
  # Task 2, CC1: core/scripts/lib/common.sh に find_board_jsonl 関数が定義されており、
  #              source で読み込み可能で構文エラーがない
  # Task 2, CC2-CC4: 環境変数フォールバックチェーン
  # Design spec 8-9: story-id 引数と HEARTBEAT_ACTIVE_STORY

  setup() {
    TEST_DIR=$(mktemp -d)
    mkdir -p "$TEST_DIR/.heartbeat/stories/0099-test-story"
    echo '{"from":"tester","timestamp":"2026-01-01T00:00:00Z"}' \
      > "$TEST_DIR/.heartbeat/stories/0099-test-story/board.jsonl"
  }
  cleanup() {
    rm -rf "$TEST_DIR"
  }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'source 可能性 (CC1)'
    It 'source で読み込んでも構文エラーが発生しない'
      When run source ./core/scripts/lib/common.sh
      The status should be success
    End

    It 'find_board_jsonl 関数が利用可能になる'
      # common.sh が存在しないので type チェックで失敗する
      When run bash -c 'source ./core/scripts/lib/common.sh && type find_board_jsonl >/dev/null 2>&1 && echo "available"'
      The output should equal "available"
      The status should be success
    End
  End

  Describe 'HEARTBEAT_ROOT 設定時 (CC2)'
    It 'HEARTBEAT_ROOT 配下の board.jsonl パスを返す'
      When run bash -c "source ./core/scripts/lib/common.sh && HEARTBEAT_ROOT='$TEST_DIR' find_board_jsonl '0099-test-story'"
      The output should equal "${TEST_DIR}/.heartbeat/stories/0099-test-story/board.jsonl"
      The status should be success
    End
  End

  Describe 'CLAUDE_PROJECT_DIR フォールバック (CC3)'
    It 'HEARTBEAT_ROOT 未設定時に CLAUDE_PROJECT_DIR 配下の board.jsonl を返す'
      When run bash -c "unset HEARTBEAT_ROOT; source ./core/scripts/lib/common.sh && CLAUDE_PROJECT_DIR='$TEST_DIR' find_board_jsonl '0099-test-story'"
      The output should equal "${TEST_DIR}/.heartbeat/stories/0099-test-story/board.jsonl"
      The status should be success
    End
  End

  Describe '両方未設定時のフォールバック (CC4)'
    It 'カレントディレクトリ配下の board.jsonl を返す'
      When run bash -c "unset HEARTBEAT_ROOT; unset CLAUDE_PROJECT_DIR; cd '$TEST_DIR' && source '$PWD/core/scripts/lib/common.sh' && find_board_jsonl '0099-test-story'"
      The output should include "0099-test-story/board.jsonl"
      The status should be success
    End
  End

  Describe 'HEARTBEAT_ACTIVE_STORY フォールバック (design spec 9)'
    It '引数なしで HEARTBEAT_ACTIVE_STORY の story-id が優先される'
      When run bash -c "source ./core/scripts/lib/common.sh && HEARTBEAT_ROOT='$TEST_DIR' HEARTBEAT_ACTIVE_STORY='0099-test-story' find_board_jsonl"
      The output should equal "${TEST_DIR}/.heartbeat/stories/0099-test-story/board.jsonl"
      The status should be success
    End
  End

  Describe '存在しない story-id (design spec 8)'
    It '存在しない story-id を指定した場合、空文字列を返す'
      When run bash -c "source ./core/scripts/lib/common.sh && HEARTBEAT_ROOT='$TEST_DIR' find_board_jsonl '9999-nonexistent'"
      The output should equal ""
      The status should be success
    End
  End
End
