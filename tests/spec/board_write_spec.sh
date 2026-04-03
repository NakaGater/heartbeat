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

  # Helper: ファイルが存在しないか空であることを検証
  assert_file_not_exists_or_empty() {
    [ ! -f "$TEST_BOARD_FILE" ] || [ ! -s "$TEST_BOARD_FILE" ]
  }
  file_not_exists_or_empty() { assert_file_not_exists_or_empty; }

  Describe '正常系: パイプ入力で JSON エントリが追記される'
    It 'JSON エントリをパイプで渡すと board.jsonl に正確な UTC タイムスタンプ付きで追記される'
      When call run_board_write '{"from":"tester","to":"implementer","action":"make_green","status":"ok","note":"テスト"}' "$TEST_BOARD_FILE"
      The status should be success
      The contents of file "$TEST_BOARD_FILE" should include '"from"'
      The contents of file "$TEST_BOARD_FILE" should include '"timestamp"'
      Assert timestamp_is_recent
    End
  End

  Describe '正常系: 連続書き込み'
    It '2回連続で呼び出すと2行が追記され、両方に有効なタイムスタンプがある'
      When call run_board_write '{"from":"tester","to":"implementer","action":"first","status":"ok"}' "$TEST_BOARD_FILE"
      The status should be success
    End

    It '2回目の書き込み後にファイルが2行になる'
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

    It '2行とも有効な ISO 8601 タイムスタンプを持つ'
      run_board_write '{"from":"tester","to":"implementer","action":"first","status":"ok"}' "$TEST_BOARD_FILE"
      When call run_board_write '{"from":"designer","to":"architect","action":"second","status":"ok"}' "$TEST_BOARD_FILE"
      The status should be success
      Assert both_lines_have_timestamp
    End
  End

  Describe '正常系: timestamp フィールドなし入力'
    It 'timestamp フィールドがない JSON を渡すと timestamp フィールドが追加される'
      When call run_board_write '{"from":"tester","to":"implementer","action":"test","status":"ok"}' "$TEST_BOARD_FILE"
      The status should be success
      The contents of file "$TEST_BOARD_FILE" should include '"timestamp"'
      Assert timestamp_is_recent
    End
  End

  Describe '正常系: timestamp に空文字入力'
    It 'timestamp が空文字の JSON を渡すと正確な時刻で上書きされる'
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

    It 'timestamp が空文字のまま残らない'
      When call run_board_write '{"from":"tester","to":"implementer","action":"test","status":"ok","timestamp":""}' "$TEST_BOARD_FILE"
      The status should be success
      Assert timestamp_not_empty
    End
  End

  Describe '異常系: stdin が空'
    It 'stdin が空の場合、何も書き込まれず exit 0'
      When call run_board_write '' "$TEST_BOARD_FILE"
      The status should be success
    End

    It 'stdin が空の場合、ファイルが作成されないか空のまま'
      When call run_board_write '' "$TEST_BOARD_FILE"
      The status should be success
      Assert file_not_exists_or_empty
    End
  End

  Describe '異常系: 引数なし'
    run_board_write_no_args() {
      echo '{"from":"tester","to":"implementer","action":"test","status":"ok"}' | ./core/scripts/board-write.sh
    }

    It '引数なしで呼び出すと何も書き込まれず exit 0'
      When call run_board_write_no_args
      The status should be success
    End
  End

  Describe '異常系: 不正 JSON'
    It '不正 JSON を渡すと何も書き込まれず exit 0'
      When call run_board_write 'this is not json at all' "$TEST_BOARD_FILE"
      The status should be success
      Assert file_not_exists_or_empty
    End
  End
End
