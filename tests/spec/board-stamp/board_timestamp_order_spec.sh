Describe 'dashboard-backlog-sync board.jsonl Timestamp Consistency'
  BOARD_FILE=".heartbeat/stories/0031-dashboard-backlog-sync/board.jsonl"

  It 'verifies that timestamps are monotonically increasing within a TDD cycle'
    # Extract timestamps from each line and compare adjacent pairs.
    # Verify zero inversions in TDD cycle (red -> green -> refactor) workflow order.
    #
    # 6 corrections required per design.md:
    #   line 7  (implementer make_green 10:12:46 -> 10:31:00)
    #   line 8  (refactor    write_test 10:13:54 -> 10:32:00)
    #   line 17 (refactor    write_test 10:31:50 -> 12:15:00)
    #   line 18 (tester      write_test 13:00:00 -> 12:20:00)
    #   line 19 (refactor    all_tasks  13:15:00 -> 12:25:00)
    #   line 25 (context-mgr knowledge  13:00:00 -> 10:46:00)
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
