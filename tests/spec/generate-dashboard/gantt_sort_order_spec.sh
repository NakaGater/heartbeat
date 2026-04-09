Describe 'generate-dashboard.sh: Gantt Chart Row Order Preservation (T1)'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/sort-order-test"

    echo '{"story_id":"sort-order-test","title":"Sort Order Test","status":"in_progress","priority":1,"points":1}' \
      > "$TEST_HEARTBEAT/backlog.jsonl"

    # board.jsonl: line order is red->green->refactor, but timestamps are reversed
    # line 1 (red) has the latest timestamp, line 3 (refactor) has the earliest
    # If entries.sort() exists, this order would be rearranged by timestamp
    cat > "$TEST_HEARTBEAT/stories/sort-order-test/board.jsonl" <<'BOARD'
{"from":"tester","to":"implementer","action":"make_red","status":"ok","note":"red phase","timestamp":"2026-04-03T10:30:00Z"}
{"from":"implementer","to":"tester","action":"make_green","status":"ok","note":"green phase","timestamp":"2026-04-03T10:20:00Z"}
{"from":"refactor","to":"tester","action":"refactor","status":"ok","note":"refactor phase","timestamp":"2026-04-03T10:10:00Z"}
BOARD

    echo '{"task_id":1,"name":"Task 1","status":"done"}' \
      > "$TEST_HEARTBEAT/stories/sort-order-test/tasks.jsonl"
  }

  cleanup() {
    rm -rf "$TEST_PROJECT"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'preserves board.jsonl row order in STORIES_DATA without timestamp sorting'
    When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
    The output should include 'Dashboard generated'
    # Verify that entries.sort() does not exist in renderGantt()
    # As long as this line remains in the template, line order would be overridden by timestamp order
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should not include 'entries.sort(function(a,b){ return new Date(a.timestamp) - new Date(b.timestamp); })'
  End
End
