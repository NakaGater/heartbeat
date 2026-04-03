Describe 'board-stamp.sh 未来タイムスタンプ警告'
  setup() {
    TEST_BOARD_DIR=$(mktemp -d)
    export TEST_BOARD_FILE="${TEST_BOARD_DIR}/board.jsonl"
  }
  cleanup() {
    rm -rf "$TEST_BOARD_DIR"
  }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  # Helper: invoke board-stamp.sh with given stdin JSON
  run_board_stamp() {
    echo "$1" | ./core/scripts/board-stamp.sh
  }

  Describe '未来タイムスタンプが存在する場合'
    It 'stderrに警告メッセージを出力する'
      setup_future_ts() {
        # 2099年のタイムスタンプは確実に未来
        echo '{"from":"tester","to":"implementer","action":"make_green","status":"ok","note":"future","timestamp":"2099-12-31T23:59:59Z"}' > "$TEST_BOARD_FILE"
      }
      BeforeCall 'setup_future_ts'
      When call run_board_stamp "{\"tool_input\":{\"file_path\":\"$TEST_BOARD_FILE\"}}"
      The status should be success
      The error should include 'WARNING: future timestamp detected'
      # 未来タイムスタンプは上書きされない（設計原則: valid timestamps are never overwritten）
      The contents of file "$TEST_BOARD_FILE" should include '2099-12-31T23:59:59Z'
    End
  End

  Describe '過去タイムスタンプのみの場合'
    It 'stderrに警告を出力しない'
      setup_past_ts() {
        echo '{"from":"tester","to":"implementer","action":"make_green","status":"ok","note":"past","timestamp":"2020-01-01T00:00:00Z"}' > "$TEST_BOARD_FILE"
      }
      BeforeCall 'setup_past_ts'
      When call run_board_stamp "{\"tool_input\":{\"file_path\":\"$TEST_BOARD_FILE\"}}"
      The status should be success
      The error should equal ''
    End
  End
End
