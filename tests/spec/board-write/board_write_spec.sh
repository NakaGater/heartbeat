Describe 'board-write.sh'
  setup() {
    TEST_DIR=$(mktemp -d)
    export TEST_BOARD_FILE="${TEST_DIR}/board.jsonl"
  }
  cleanup() {
    rm -rf "$TEST_DIR"
  }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  # Helper: invoke board-write.sh via pipe
  run_board_write() {
    echo "$1" | ./core/scripts/board-write.sh "$2"
  }

  # Helper: verify that the last line's timestamp is within 5 seconds of now
  assert_timestamp_recent() {
    local target_file="${1:-$TEST_BOARD_FILE}"
    local ts
    ts=$(tail -1 "$target_file" | jq -r '.timestamp')

    # Must be in ISO 8601 UTC format
    echo "$ts" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' || return 1

    local injected_epoch now_epoch diff
    # macOS date conversion
    if TZ=UTC0 date -j -f "%Y-%m-%dT%H:%M:%SZ" "$ts" "+%s" >/dev/null 2>&1; then
      injected_epoch=$(TZ=UTC0 date -j -f "%Y-%m-%dT%H:%M:%SZ" "$ts" "+%s")
    else
      # Linux date conversion
      injected_epoch=$(date -d "$ts" "+%s")
    fi
    now_epoch=$(date -u "+%s")
    diff=$(( now_epoch - injected_epoch ))
    if [ "$diff" -lt 0 ]; then diff=$(( -diff )); fi
    [ "$diff" -le 5 ]
  }

  timestamp_is_recent() { assert_timestamp_recent "$TEST_BOARD_FILE"; }

  # Helper: verify that the file does not exist or is empty
  assert_file_not_exists_or_empty() {
    [ ! -f "$TEST_BOARD_FILE" ] || [ ! -s "$TEST_BOARD_FILE" ]
  }
  file_not_exists_or_empty() { assert_file_not_exists_or_empty; }

  Describe 'Normal Cases: Appending JSON Entry via Pipe Input'
    It 'appends a piped JSON entry to board.jsonl with an accurate UTC timestamp'
      When call run_board_write '{"from":"tester","to":"implementer","action":"make_green","status":"ok","note":"テスト"}' "$TEST_BOARD_FILE"
      The status should be success
      The contents of file "$TEST_BOARD_FILE" should include '"from"'
      The contents of file "$TEST_BOARD_FILE" should include '"timestamp"'
      Assert timestamp_is_recent
    End
  End

  Describe 'Normal Cases: Consecutive Writes'
    It 'appends 2 lines with valid timestamps when called twice consecutively'
      When call run_board_write '{"from":"tester","to":"implementer","action":"first","status":"ok"}' "$TEST_BOARD_FILE"
      The status should be success
    End

    It 'results in 2 lines after the second write'
      run_board_write '{"from":"tester","to":"implementer","action":"first","status":"ok"}' "$TEST_BOARD_FILE"
      When call run_board_write '{"from":"designer","to":"architect","action":"second","status":"ok"}' "$TEST_BOARD_FILE"
      The status should be success
      The lines of contents of file "$TEST_BOARD_FILE" should equal 2
    End

    assert_both_lines_have_timestamp() {
      local line_count
      line_count=$(wc -l < "$TEST_BOARD_FILE" | tr -d ' ')
      [ "$line_count" -eq 2 ] || return 1
      local ts1 ts2
      ts1=$(sed -n '1p' "$TEST_BOARD_FILE" | jq -r '.timestamp')
      ts2=$(sed -n '2p' "$TEST_BOARD_FILE" | jq -r '.timestamp')
      echo "$ts1" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' || return 1
      echo "$ts2" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' || return 1
    }
    both_lines_have_timestamp() { assert_both_lines_have_timestamp; }

    It 'verifies that both lines have valid ISO 8601 timestamps'
      run_board_write '{"from":"tester","to":"implementer","action":"first","status":"ok"}' "$TEST_BOARD_FILE"
      When call run_board_write '{"from":"designer","to":"architect","action":"second","status":"ok"}' "$TEST_BOARD_FILE"
      The status should be success
      Assert both_lines_have_timestamp
    End
  End

  Describe 'Normal Cases: Input Without Timestamp Field'
    It 'adds a timestamp field when JSON without timestamp is provided'
      When call run_board_write '{"from":"tester","to":"implementer","action":"test","status":"ok"}' "$TEST_BOARD_FILE"
      The status should be success
      The contents of file "$TEST_BOARD_FILE" should include '"timestamp"'
      Assert timestamp_is_recent
    End
  End

  Describe 'Normal Cases: Empty String Timestamp Input'
    It 'overwrites an empty-string timestamp with the current time'
      When call run_board_write '{"from":"tester","to":"implementer","action":"test","status":"ok","timestamp":""}' "$TEST_BOARD_FILE"
      The status should be success
      Assert timestamp_is_recent
    End

    assert_timestamp_not_empty() {
      local ts
      ts=$(tail -1 "$TEST_BOARD_FILE" | jq -r '.timestamp')
      [ -n "$ts" ] && [ "$ts" != "" ]
    }
    timestamp_not_empty() { assert_timestamp_not_empty; }

    It 'does not leave the timestamp as an empty string'
      When call run_board_write '{"from":"tester","to":"implementer","action":"test","status":"ok","timestamp":""}' "$TEST_BOARD_FILE"
      The status should be success
      Assert timestamp_not_empty
    End
  End

  Describe 'Error Cases: Empty Stdin'
    It 'writes nothing and exits 0 when stdin is empty'
      When call run_board_write '' "$TEST_BOARD_FILE"
      The status should be success
    End

    It 'does not create a file or leaves it empty when stdin is empty'
      When call run_board_write '' "$TEST_BOARD_FILE"
      The status should be success
      Assert file_not_exists_or_empty
    End
  End

  Describe 'Error Cases: No Arguments'
    run_board_write_no_args() {
      echo '{"from":"tester","to":"implementer","action":"test","status":"ok"}' | ./core/scripts/board-write.sh
    }

    It 'writes nothing and exits 0 when called without arguments'
      When call run_board_write_no_args
      The status should be success
    End
  End

  Describe 'Error Cases: Invalid JSON'
    It 'writes nothing and exits 0 when given invalid JSON'
      When call run_board_write 'this is not json at all' "$TEST_BOARD_FILE"
      The status should be success
      Assert file_not_exists_or_empty
    End
  End
End
