Describe 'dashboard-backlog-sync board.jsonl タイムスタンプ整合性'
  BOARD_FILE=".heartbeat/stories/0031/board.jsonl"

  It 'TDDサイクル内でタイムスタンプが単調増加である'
    # 各行のタイムスタンプを抽出し、隣接する行のペアを比較する。
    # TDDサイクル (red -> green -> refactor) のワークフロー順序で
    # タイムスタンプが逆転している箇所がゼロであることを検証する。
    #
    # design.md に記載の6箇所の修正が必要:
    #   行7  (implementer make_green 10:12:46 -> 10:31:00)
    #   行8  (refactor    write_test 10:13:54 -> 10:32:00)
    #   行17 (refactor    write_test 10:31:50 -> 12:15:00)
    #   行18 (tester      write_test 13:00:00 -> 12:20:00)
    #   行19 (refactor    all_tasks  13:15:00 -> 12:25:00)
    #   行25 (context-mgr knowledge  13:00:00 -> 10:46:00)
    check_monotonic() {
      local violations=0
      local prev_epoch=0
      local line_num=0
      while IFS= read -r line; do
        line_num=$((line_num + 1))
        local ts
        ts=$(echo "$line" | jq -r '.timestamp // empty')
        [ -z "$ts" ] && continue

        local cur_epoch
        if TZ=UTC0 date -j -f "%Y-%m-%dT%H:%M:%SZ" "$ts" "+%s" >/dev/null 2>&1; then
          cur_epoch=$(TZ=UTC0 date -j -f "%Y-%m-%dT%H:%M:%SZ" "$ts" "+%s")
        else
          cur_epoch=$(date -d "$ts" "+%s" 2>/dev/null) || continue
        fi

        if [ "$prev_epoch" -gt 0 ] && [ "$cur_epoch" -lt "$prev_epoch" ]; then
          violations=$((violations + 1))
        fi
        prev_epoch=$cur_epoch
      done < "$BOARD_FILE"
      [ "$violations" -eq 0 ]
    }
    When call check_monotonic
    The status should be success
  End
End
