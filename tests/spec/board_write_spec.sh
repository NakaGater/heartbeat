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

  # Helper: パイプ経由で board-write.sh を呼び出す
  run_board_write() {
    echo "$1" | ./core/scripts/board-write.sh "$2"
  }

  # Helper: 最終行のタイムスタンプが現在時刻から5秒以内か検証
  assert_timestamp_recent() {
    local target_file="${1:-$TEST_BOARD_FILE}"
    local ts
    ts=$(tail -1 "$target_file" | jq -r '.timestamp')

    # ISO 8601 UTC 形式であること
    echo "$ts" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' || return 1

    local injected_epoch now_epoch diff
    # macOS date 変換
    if TZ=UTC0 date -j -f "%Y-%m-%dT%H:%M:%SZ" "$ts" "+%s" >/dev/null 2>&1; then
      injected_epoch=$(TZ=UTC0 date -j -f "%Y-%m-%dT%H:%M:%SZ" "$ts" "+%s")
    else
      # Linux date 変換
      injected_epoch=$(date -d "$ts" "+%s")
    fi
    now_epoch=$(date -u "+%s")
    diff=$(( now_epoch - injected_epoch ))
    if [ "$diff" -lt 0 ]; then diff=$(( -diff )); fi
    [ "$diff" -le 5 ]
  }

  timestamp_is_recent() { assert_timestamp_recent "$TEST_BOARD_FILE"; }

  Describe '正常系: パイプ入力で JSON エントリが追記される'
    It 'JSON エントリをパイプで渡すと board.jsonl に正確な UTC タイムスタンプ付きで追記される'
      When call run_board_write '{"from":"tester","to":"implementer","action":"make_green","status":"ok","note":"テスト"}' "$TEST_BOARD_FILE"
      The status should be success
      The contents of file "$TEST_BOARD_FILE" should include '"from"'
      The contents of file "$TEST_BOARD_FILE" should include '"timestamp"'
      Assert timestamp_is_recent
    End
  End
End
