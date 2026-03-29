Describe 'board-stamp.sh'
  setup() {
    TEST_BOARD_DIR=$(mktemp -d)
    export TEST_BOARD_FILE="${TEST_BOARD_DIR}/board.jsonl"
    echo '{"from":"tester","to":"implementer","action":"make_green","output":"test.sh","status":"ok","note":"test","timestamp":"2026-01-01T00:00:00Z"}' > "$TEST_BOARD_FILE"
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

  # Helper: check that a timestamp string is within 5 seconds of now
  timestamp_is_recent() {
    local ts
    ts=$(tail -1 "$TEST_BOARD_FILE" | jq -r '.timestamp')
    local injected_epoch
    local now_epoch
    local diff

    # macOS date conversion
    if date -j -f "%Y-%m-%dT%H:%M:%SZ" "$ts" "+%s" >/dev/null 2>&1; then
      injected_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$ts" "+%s")
    else
      # Linux date conversion
      injected_epoch=$(date -d "$ts" "+%s")
    fi
    now_epoch=$(date -u "+%s")
    diff=$(( now_epoch - injected_epoch ))
    if [ "$diff" -lt 0 ]; then
      diff=$(( -diff ))
    fi
    [ "$diff" -le 5 ]
  }

  Describe 'Normal cases'
    It 'overwrites placeholder timestamp with current system time'
      When call run_board_stamp "{\"tool_input\":{\"file_path\":\"$TEST_BOARD_FILE\"}}"
      The status should be success
      The contents of file "$TEST_BOARD_FILE" should include '"timestamp"'
      The contents of file "$TEST_BOARD_FILE" should not include '2026-01-01T00:00:00Z'
    End

    It 'injects a timestamp within 5 seconds of actual system time'
      When call run_board_stamp "{\"tool_input\":{\"file_path\":\"$TEST_BOARD_FILE\"}}"
      The status should be success
      Assert timestamp_is_recent
    End

    It 'adds timestamp field when last line has no timestamp'
      setup_no_ts() {
        echo '{"from":"tester","to":"implementer","action":"make_green","status":"ok","note":"no ts"}' > "$TEST_BOARD_FILE"
      }
      BeforeCall 'setup_no_ts'
      When call run_board_stamp "{\"tool_input\":{\"file_path\":\"$TEST_BOARD_FILE\"}}"
      The status should be success
      The contents of file "$TEST_BOARD_FILE" should include '"timestamp"'
    End

    It 'replaces fabricated placeholder with actual current time'
      When call run_board_stamp "{\"tool_input\":{\"file_path\":\"$TEST_BOARD_FILE\"}}"
      The status should be success
      Assert timestamp_is_recent
    End
  End

  Describe 'No-op cases'
    It 'does nothing for non-board.jsonl file paths'
      When call run_board_stamp '{"tool_input":{"file_path":"/tmp/some/other/file.json"}}'
      The status should be success
      The contents of file "$TEST_BOARD_FILE" should include '2026-01-01T00:00:00Z'
    End

    It 'exits 0 on empty stdin'
      When call run_board_stamp ''
      The status should be success
    End

    It 'exits 0 on malformed stdin JSON'
      When call run_board_stamp 'not json at all'
      The status should be success
    End
  End
End
