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

  # Helper: check that the timestamp in the last line of a given file
  # is within 5 seconds of now.  Defaults to $TEST_BOARD_FILE.
  assert_timestamp_recent() {
    local target_file="${1:-$TEST_BOARD_FILE}"
    local ts
    ts=$(tail -1 "$target_file" | jq -r '.timestamp')
    local injected_epoch now_epoch diff

    # macOS date conversion (TZ=UTC0 so the trailing Z is honoured)
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

  # Backward-compatible alias used by existing Assert calls
  timestamp_is_recent() { assert_timestamp_recent "$TEST_BOARD_FILE"; }

  Describe 'Normal cases'
    It 'preserves valid timestamp (no-op for already-stamped entries)'
      When call run_board_stamp "{\"tool_input\":{\"file_path\":\"$TEST_BOARD_FILE\"}}"
      The status should be success
      The contents of file "$TEST_BOARD_FILE" should include '"timestamp"'
      # Valid timestamps are never overwritten (design principle: timestamp immutability)
      The contents of file "$TEST_BOARD_FILE" should include '2026-01-01T00:00:00Z'
    End

    It 'adds timestamp field when last line has no timestamp'
      setup_no_ts() {
        echo '{"from":"tester","to":"implementer","action":"make_green","status":"ok","note":"no ts"}' > "$TEST_BOARD_FILE"
      }
      BeforeCall 'setup_no_ts'
      When call run_board_stamp "{\"tool_input\":{\"file_path\":\"$TEST_BOARD_FILE\"}}"
      The status should be success
      The contents of file "$TEST_BOARD_FILE" should include '"timestamp"'
      Assert timestamp_is_recent
    End

    It 'fills empty-string timestamp with current time'
      setup_empty_ts() {
        echo '{"from":"tester","to":"implementer","action":"make_green","status":"ok","note":"empty ts","timestamp":""}' > "$TEST_BOARD_FILE"
      }
      BeforeCall 'setup_empty_ts'
      When call run_board_stamp "{\"tool_input\":{\"file_path\":\"$TEST_BOARD_FILE\"}}"
      The status should be success
      The contents of file "$TEST_BOARD_FILE" should not include '"timestamp":""'
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

  Describe 'SubagentStop hook context (no file_path in stdin)'
    # SubagentStop stdin does not contain file_path.
    # board-stamp.sh should scan .heartbeat/stories/*/board.jsonl and
    # overwrite the timestamp of the last line in the most recently modified file.

    setup_subagent_stop() {
      # Create story directory structure for testing
      STORIES_DIR=$(mktemp -d)
      mkdir -p "${STORIES_DIR}/.heartbeat/stories/story-alpha"
      mkdir -p "${STORIES_DIR}/.heartbeat/stories/story-beta"

      # story-alpha board.jsonl (older)
      echo '{"from":"tester","to":"impl","action":"test","status":"ok","note":"alpha","timestamp":"2026-01-01T00:00:00Z"}' \
        > "${STORIES_DIR}/.heartbeat/stories/story-alpha/board.jsonl"

      # Wait briefly then create story-beta (this one is newer)
      sleep 1
      echo '{"from":"architect","to":"impl","action":"design","status":"ok","note":"beta","timestamp":"2026-02-01T00:00:00Z"}' \
        > "${STORIES_DIR}/.heartbeat/stories/story-beta/board.jsonl"

      export HEARTBEAT_ROOT="${STORIES_DIR}"
    }

    cleanup_subagent_stop() {
      rm -rf "$STORIES_DIR"
    }

    BeforeEach 'setup_subagent_stop'
    AfterEach 'cleanup_subagent_stop'

    # SubagentStop stdin is JSON without file_path
    # (e.g., {"event":"SubagentStop","subagent_id":"..."})

    It 'preserves valid timestamps in most recently modified board.jsonl (no-op)'
      When call run_board_stamp '{"event":"SubagentStop","subagent_id":"sub-123"}'
      The status should be success
      # Valid timestamps are not overwritten (design principle: timestamp immutability)
      The contents of file "${STORIES_DIR}/.heartbeat/stories/story-beta/board.jsonl" should include '2026-02-01T00:00:00Z'
    End

    It 'fills empty timestamp in most recently modified board.jsonl'
      setup_empty_ts_beta() {
        # Append an entry with empty timestamp to story-beta
        echo '{"from":"implementer","to":"tester","action":"test","status":"ok","note":"empty","timestamp":""}' \
          >> "${STORIES_DIR}/.heartbeat/stories/story-beta/board.jsonl"
      }
      BeforeCall 'setup_empty_ts_beta'
      timestamp_is_recent_for() {
        # Check whether the last line (the appended empty-TS line) was filled
        assert_timestamp_recent "${STORIES_DIR}/.heartbeat/stories/story-beta/board.jsonl"
      }
      When call run_board_stamp '{"event":"SubagentStop","subagent_id":"sub-123"}'
      The status should be success
      # Empty timestamp is filled
      The contents of file "${STORIES_DIR}/.heartbeat/stories/story-beta/board.jsonl" should not include '"timestamp":""'
      # Original valid timestamp is preserved
      The contents of file "${STORIES_DIR}/.heartbeat/stories/story-beta/board.jsonl" should include '2026-02-01T00:00:00Z'
      Assert timestamp_is_recent_for
    End

    It 'does not modify older board.jsonl files'
      When call run_board_stamp '{"event":"SubagentStop","subagent_id":"sub-123"}'
      The status should be success
      # story-alpha is older and should not be modified
      The contents of file "${STORIES_DIR}/.heartbeat/stories/story-alpha/board.jsonl" should include '2026-01-01T00:00:00Z'
    End
  End

  Describe 'No board.jsonl exists (SubagentStop context)'
    # Should exit 0 gracefully when no board.jsonl files exist

    setup_no_board() {
      STORIES_DIR=$(mktemp -d)
      mkdir -p "${STORIES_DIR}/.heartbeat/stories/empty-story"
      export HEARTBEAT_ROOT="${STORIES_DIR}"
    }

    cleanup_no_board() {
      rm -rf "$STORIES_DIR"
    }

    BeforeEach 'setup_no_board'
    AfterEach 'cleanup_no_board'

    It 'exits 0 gracefully when no board.jsonl exists'
      When call run_board_stamp '{"event":"SubagentStop","subagent_id":"sub-456"}'
      The status should be success
    End
  End

  Describe 'SubagentStart hook context'
    # board-stamp.sh is also invoked on SubagentStart and should
    # overwrite the timestamp of the last line in the most recent board.jsonl.

    setup_subagent_start() {
      STORIES_DIR=$(mktemp -d)
      mkdir -p "${STORIES_DIR}/.heartbeat/stories/active-story"
      echo '{"from":"pdm","to":"architect","action":"start","status":"ok","note":"kick off","timestamp":"2026-03-01T00:00:00Z"}' \
        > "${STORIES_DIR}/.heartbeat/stories/active-story/board.jsonl"
      export HEARTBEAT_ROOT="${STORIES_DIR}"
    }

    cleanup_subagent_start() {
      rm -rf "$STORIES_DIR"
    }

    BeforeEach 'setup_subagent_start'
    AfterEach 'cleanup_subagent_start'

    It 'preserves valid timestamp in SubagentStart context (no-op)'
      When call run_board_stamp '{"event":"SubagentStart","subagent_id":"sub-789"}'
      The status should be success
      # Valid timestamps are not overwritten even in SubagentStart context
      The contents of file "${STORIES_DIR}/.heartbeat/stories/active-story/board.jsonl" should include '2026-03-01T00:00:00Z'
    End

    It 'fills empty timestamp in SubagentStart context'
      setup_empty_ts_start() {
        echo '{"from":"tester","to":"implementer","action":"test","status":"ok","note":"empty","timestamp":""}' \
          >> "${STORIES_DIR}/.heartbeat/stories/active-story/board.jsonl"
      }
      BeforeCall 'setup_empty_ts_start'
      timestamp_is_recent_start() {
        assert_timestamp_recent "${STORIES_DIR}/.heartbeat/stories/active-story/board.jsonl"
      }
      When call run_board_stamp '{"event":"SubagentStart","subagent_id":"sub-789"}'
      The status should be success
      # Empty timestamp is filled
      The contents of file "${STORIES_DIR}/.heartbeat/stories/active-story/board.jsonl" should not include '"timestamp":""'
      # Original valid timestamp is preserved
      The contents of file "${STORIES_DIR}/.heartbeat/stories/active-story/board.jsonl" should include '2026-03-01T00:00:00Z'
      Assert timestamp_is_recent_start
    End
  End

  Describe 'Full Row Scan: Fill Only Empty Timestamps'
    # Verify that in a multi-line board.jsonl, only empty timestamps are filled
    # while existing valid timestamps are not overwritten.

    setup_multi_line() {
      # 3 lines: valid TS -> empty TS -> valid TS
      {
        echo '{"from":"pdm","to":"architect","action":"define_story","status":"ok","note":"line1","timestamp":"2026-03-15T10:00:00Z"}'
        echo '{"from":"architect","to":"designer","action":"estimate","status":"ok","note":"line2","timestamp":""}'
        echo '{"from":"designer","to":"tester","action":"design","status":"ok","note":"line3","timestamp":"2026-03-15T12:00:00Z"}'
      } > "$TEST_BOARD_FILE"
    }

    BeforeEach 'setup_multi_line'

    It 'fills empty timestamps and preserves existing ones across all lines'
      When call run_board_stamp "{\"tool_input\":{\"file_path\":\"$TEST_BOARD_FILE\"}}"
      The status should be success
      # line1 valid timestamp should not be changed
      The contents of file "$TEST_BOARD_FILE" should include '2026-03-15T10:00:00Z'
      # line3 valid timestamp should also not be changed
      The contents of file "$TEST_BOARD_FILE" should include '2026-03-15T12:00:00Z'
      # line2 empty timestamp has been filled (no empty string remaining)
      The contents of file "$TEST_BOARD_FILE" should not include '"timestamp":""'
    End
  End

  Describe 'Invalid Timestamp Value Correction'
    # Invalid values that do not match ISO 8601 format (e.g., "invalid")
    # should be treated as empty and overwritten with the correct UTC time.

    It 'overwrites invalid non-ISO-8601 timestamp with current UTC time'
      setup_invalid_ts() {
        {
          echo '{"from":"pdm","to":"architect","action":"define_story","status":"ok","note":"valid","timestamp":"2026-03-15T10:00:00Z"}'
          echo '{"from":"architect","to":"designer","action":"estimate","status":"ok","note":"invalid ts","timestamp":"invalid"}'
        } > "$TEST_BOARD_FILE"
      }
      BeforeCall 'setup_invalid_ts'
      When call run_board_stamp "{\"tool_input\":{\"file_path\":\"$TEST_BOARD_FILE\"}}"
      The status should be success
      # Valid timestamp is preserved
      The contents of file "$TEST_BOARD_FILE" should include '2026-03-15T10:00:00Z'
      # Invalid value "invalid" should be replaced with correct UTC time
      The contents of file "$TEST_BOARD_FILE" should not include '"invalid"'
    End
  End

  Describe 'PostToolUse safety net'
    # Verify normal operation as a safety net via the PostToolUse path (with file_path)

    It 'preserves valid timestamp via file_path path (no-op)'
      When call run_board_stamp "{\"tool_input\":{\"file_path\":\"$TEST_BOARD_FILE\"}}"
      The status should be success
      # Valid timestamp is preserved
      The contents of file "$TEST_BOARD_FILE" should include '2026-01-01T00:00:00Z'
    End

    It 'fills empty timestamp via file_path path'
      setup_empty_ts_post() {
        echo '{"from":"tester","to":"implementer","action":"test","status":"ok","note":"empty","timestamp":""}' >> "$TEST_BOARD_FILE"
      }
      BeforeCall 'setup_empty_ts_post'
      When call run_board_stamp "{\"tool_input\":{\"file_path\":\"$TEST_BOARD_FILE\"}}"
      The status should be success
      The contents of file "$TEST_BOARD_FILE" should not include '"timestamp":""'
      # Existing valid timestamp in other lines is also preserved
      The contents of file "$TEST_BOARD_FILE" should include '2026-01-01T00:00:00Z'
    End
  End
End
