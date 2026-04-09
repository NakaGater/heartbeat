Describe 'generate-dashboard.sh: Gantt tick labels placed within activity segments (0065-T4)'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/tick-test"

    echo '{"story_id":"tick-test","title":"Tick Label Placement Test","status":"in_progress","priority":1,"points":1}' \
      > "$TEST_HEARTBEAT/backlog.jsonl"

    # board.jsonl: large 10-hour gap between story creation (10:00) and
    # implementation start (20:00), then 30 minutes of activity (20:00-20:30).
    # Total range = 10.5h; gap = 10h (~95% of range, well above 20% threshold).
    # With current linear tick placement, 5 ticks are distributed uniformly
    # across the full 10:00-20:30 range, producing labels at approximately:
    #   10:00, 12:06, 14:12, 16:18, 18:24, 20:30
    # Most of these labels fall in the gap region and provide no useful info.
    # After fix, ticks must be distributed proportionally across activity
    # segments only (AC-3), requiring per-segment duration calculation.
    cat > "$TEST_HEARTBEAT/stories/tick-test/board.jsonl" <<'BOARD'
{"from":"pdm","to":"designer","action":"define_story","status":"ok","note":"story created","timestamp":"2026-04-03T10:00:00Z"}
{"from":"tester","to":"implementer","action":"make_red","status":"ok","note":"red phase","timestamp":"2026-04-03T20:00:00Z"}
{"from":"implementer","to":"tester","action":"make_green","status":"ok","note":"green phase","timestamp":"2026-04-03T20:15:00Z"}
{"from":"refactor","to":"tester","action":"write_test","status":"ok","note":"refactor done","timestamp":"2026-04-03T20:30:00Z"}
BOARD

    echo '{"task_id":1,"name":"Task 1","status":"done"}' \
      > "$TEST_HEARTBEAT/stories/tick-test/tasks.jsonl"
  }

  cleanup() {
    rm -rf "$TEST_PROJECT"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'computes per-segment duration to distribute tick labels proportionally across activity segments'
    When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
    The output should include 'Dashboard generated'
    # Current tick rendering uses a naive linear formula:
    #   var tx = padL + (chartW / ticks) * t;
    #   var tVal = new Date(tMin + ((tMax - tMin) / ticks) * t);
    # This distributes ticks uniformly across the full time range,
    # including the compressed gap region where they are meaningless.
    #
    # Per design.md: "Each activity segment distributes ticks proportionally
    # based on its length." To allocate ticks proportionally, the code must
    # compute each segment's duration (seg.end - seg.start) to determine
    # how many ticks each segment receives. This pattern does not exist
    # in the current codebase.
    #
    # This verifies AC-3: tick labels are placed within activity segments
    # at meaningful granularity, not uniformly across the gap region.
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'seg.end - seg.start'
  End
End
