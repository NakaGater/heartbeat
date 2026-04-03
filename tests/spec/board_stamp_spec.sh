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

  Describe 'SubagentStop hook context (no file_path in stdin)'
    # SubagentStop の stdin には file_path が含まれない。
    # board-stamp.sh は .heartbeat/stories/*/board.jsonl を走査し、
    # 最も最近変更されたファイルの最終行 timestamp を上書きすべき。

    setup_subagent_stop() {
      # テスト用のストーリーディレクトリ構造を作成
      STORIES_DIR=$(mktemp -d)
      mkdir -p "${STORIES_DIR}/.heartbeat/stories/story-alpha"
      mkdir -p "${STORIES_DIR}/.heartbeat/stories/story-beta"

      # story-alpha の board.jsonl（古い）
      echo '{"from":"tester","to":"impl","action":"test","status":"ok","note":"alpha","timestamp":"2026-01-01T00:00:00Z"}' \
        > "${STORIES_DIR}/.heartbeat/stories/story-alpha/board.jsonl"

      # 少し待って story-beta を作成（こちらが最新）
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

    # SubagentStop の stdin は file_path を含まない JSON
    # （例: {"event":"SubagentStop","subagent_id":"..."}）

    It 'overwrites timestamp of most recently modified board.jsonl last line'
      When call run_board_stamp '{"event":"SubagentStop","subagent_id":"sub-123"}'
      The status should be success
      # story-beta が最新のため、そのタイムスタンプが上書きされるべき
      The contents of file "${STORIES_DIR}/.heartbeat/stories/story-beta/board.jsonl" should not include '2026-02-01T00:00:00Z'
    End

    It 'injects accurate ISO 8601 UTC timestamp within 5 seconds of system time'
      timestamp_is_recent_for() {
        assert_timestamp_recent "${STORIES_DIR}/.heartbeat/stories/story-beta/board.jsonl"
      }
      When call run_board_stamp '{"event":"SubagentStop","subagent_id":"sub-123"}'
      The status should be success
      Assert timestamp_is_recent_for
    End

    It 'does not modify older board.jsonl files'
      When call run_board_stamp '{"event":"SubagentStop","subagent_id":"sub-123"}'
      The status should be success
      # story-alpha は古いので変更されないべき
      The contents of file "${STORIES_DIR}/.heartbeat/stories/story-alpha/board.jsonl" should include '2026-01-01T00:00:00Z'
    End
  End

  Describe 'No board.jsonl exists (SubagentStop context)'
    # board.jsonl が1つも存在しない場合、exit 0 で正常終了すべき

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
    # SubagentStart でも board-stamp.sh が呼び出され、
    # 最新の board.jsonl の最終行 timestamp を上書きすべき。

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

    It 'overwrites timestamp when called from SubagentStart context'
      When call run_board_stamp '{"event":"SubagentStart","subagent_id":"sub-789"}'
      The status should be success
      The contents of file "${STORIES_DIR}/.heartbeat/stories/active-story/board.jsonl" should not include '2026-03-01T00:00:00Z'
    End

    It 'injects accurate timestamp in SubagentStart context'
      timestamp_is_recent_start() {
        assert_timestamp_recent "${STORIES_DIR}/.heartbeat/stories/active-story/board.jsonl"
      }
      When call run_board_stamp '{"event":"SubagentStart","subagent_id":"sub-789"}'
      The status should be success
      Assert timestamp_is_recent_start
    End
  End

  Describe '全行走査・空タイムスタンプのみ補完'
    # 複数行の board.jsonl で、空タイムスタンプの行のみ補完し、
    # 既存の有効なタイムスタンプは上書きしないことを検証する。

    setup_multi_line() {
      # 3行: 有効TS → 空TS → 有効TS
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
      # line1 の有効なタイムスタンプは変更されない
      The contents of file "$TEST_BOARD_FILE" should include '2026-03-15T10:00:00Z'
      # line3 の有効なタイムスタンプも変更されない
      The contents of file "$TEST_BOARD_FILE" should include '2026-03-15T12:00:00Z'
      # line2 の空タイムスタンプが補完されている（空文字が残っていない）
      The contents of file "$TEST_BOARD_FILE" should not include '"timestamp":""'
    End
  End

  Describe 'PostToolUse backward compatibility'
    # 既存の PostToolUse パス（file_path あり）が引き続き正常動作することを確認

    It 'still overwrites timestamp via file_path path'
      When call run_board_stamp "{\"tool_input\":{\"file_path\":\"$TEST_BOARD_FILE\"}}"
      The status should be success
      The contents of file "$TEST_BOARD_FILE" should not include '2026-01-01T00:00:00Z'
      Assert timestamp_is_recent
    End
  End
End
