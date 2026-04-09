Describe 'board-stamp.sh Future Timestamp Warning'
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

  Describe 'When Future Timestamps Exist'
    It 'outputs a warning message to stderr'
      setup_future_ts() {
        # A timestamp in year 2099 is guaranteed to be in the future
        echo '{"from":"tester","to":"implementer","action":"make_green","status":"ok","note":"future","timestamp":"2099-12-31T23:59:59Z"}' > "$TEST_BOARD_FILE"
      }
      BeforeCall 'setup_future_ts'
      When call run_board_stamp "{\"tool_input\":{\"file_path\":\"$TEST_BOARD_FILE\"}}"
      The status should be success
      The error should include 'WARNING: future timestamp detected'
      # Future timestamps are not overwritten (design principle: valid timestamps are never overwritten)
      The contents of file "$TEST_BOARD_FILE" should include '2099-12-31T23:59:59Z'
    End
  End

  Describe 'When Only Past Timestamps Exist'
    It 'does not output a warning to stderr'
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
