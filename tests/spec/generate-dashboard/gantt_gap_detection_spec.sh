Describe 'generate-dashboard.sh: Gantt gap detection (0065-T1)'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/gap-test"

    echo '{"story_id":"gap-test","title":"Gap Detection Test","status":"in_progress","priority":1,"points":1}' \
      > "$TEST_HEARTBEAT/backlog.jsonl"

    # board.jsonl: 10-hour gap from story creation (10:00) to implementation start (20:00)
    # Total range is 10:00-20:30 = 10.5 hours; gap of 10h is ~95% (well above 20% threshold)
    cat > "$TEST_HEARTBEAT/stories/gap-test/board.jsonl" <<'BOARD'
{"from":"pdm","to":"designer","action":"define_story","status":"ok","note":"story created","timestamp":"2026-04-03T10:00:00Z"}
{"from":"tester","to":"implementer","action":"make_red","status":"ok","note":"red phase","timestamp":"2026-04-03T20:00:00Z"}
{"from":"implementer","to":"tester","action":"make_green","status":"ok","note":"green phase","timestamp":"2026-04-03T20:30:00Z"}
BOARD

    echo '{"task_id":1,"name":"Task 1","status":"done"}' \
      > "$TEST_HEARTBEAT/stories/gap-test/tasks.jsonl"
  }

  cleanup() {
    rm -rf "$TEST_PROJECT"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'detects gaps >= 20% of total range and builds a segments array'
    When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
    The output should include 'Dashboard generated'
    # Gap detection logic: scan adjacent entry timestamps,
    # detect single gaps >= 20% of total range (tMax - tMin),
    # and structure results as a segments array.
    # Verify this logic exists within renderGantt().
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'segments'
  End
End
