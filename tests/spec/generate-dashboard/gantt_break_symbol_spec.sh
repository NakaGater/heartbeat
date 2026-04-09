Describe 'generate-dashboard.sh: Gantt break symbol for compressed gap (0065-T3)'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/break-sym"

    echo '{"story_id":"break-sym","title":"Break Symbol Test","status":"in_progress","priority":1,"points":1}' \
      > "$TEST_HEARTBEAT/backlog.jsonl"

    # board.jsonl: large 10-hour gap between story creation (10:00) and
    # implementation start (20:00), then 30 minutes of activity (20:00-20:30).
    # Total range = 10.5h; gap = 10h (~95% of range, well above 20% threshold).
    # This gap should trigger compression and a visible break symbol.
    cat > "$TEST_HEARTBEAT/stories/break-sym/board.jsonl" <<'BOARD'
{"from":"pdm","to":"designer","action":"define_story","status":"ok","note":"story created","timestamp":"2026-04-03T10:00:00Z"}
{"from":"tester","to":"implementer","action":"make_red","status":"ok","note":"red phase","timestamp":"2026-04-03T20:00:00Z"}
{"from":"implementer","to":"tester","action":"make_green","status":"ok","note":"green phase","timestamp":"2026-04-03T20:15:00Z"}
{"from":"refactor","to":"tester","action":"write_test","status":"ok","note":"refactor done","timestamp":"2026-04-03T20:30:00Z"}
BOARD

    echo '{"task_id":1,"name":"Task 1","status":"done"}' \
      > "$TEST_HEARTBEAT/stories/break-sym/tasks.jsonl"
  }

  cleanup() {
    rm -rf "$TEST_PROJECT"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'renders an SVG break symbol with class gap-break in the compressed gap region'
    When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
    The output should include 'Dashboard generated'
    # When a gap >= 20% of total range is detected and compressed,
    # the renderGantt function must draw a zigzag/wave SVG path element
    # with class "gap-break" inside the compressed gap region.
    # This visually indicates to the user that the time axis is discontinuous (AC-1).
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'class="gap-break"'
  End
End
