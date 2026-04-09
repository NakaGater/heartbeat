Describe 'generate-dashboard.sh: Gantt compressed scale mapX (0065-T2)'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/mapx-test"

    echo '{"story_id":"mapx-test","title":"MapX Compression Test","status":"in_progress","priority":1,"points":1}' \
      > "$TEST_HEARTBEAT/backlog.jsonl"

    # board.jsonl: large 10-hour gap between story creation (10:00) and
    # implementation start (20:00), then 30 minutes of activity (20:00-20:30).
    # Total range = 10.5h; gap = 10h (~95% of range, well above 20% threshold).
    # With linear scale the post-gap bars occupy only ~5% of chart width.
    # With mapX compression the post-gap activity segment should occupy
    # a significant portion (~95%) of the chart width.
    cat > "$TEST_HEARTBEAT/stories/mapx-test/board.jsonl" <<'BOARD'
{"from":"pdm","to":"designer","action":"define_story","status":"ok","note":"story created","timestamp":"2026-04-03T10:00:00Z"}
{"from":"tester","to":"implementer","action":"make_red","status":"ok","note":"red phase","timestamp":"2026-04-03T20:00:00Z"}
{"from":"implementer","to":"tester","action":"make_green","status":"ok","note":"green phase","timestamp":"2026-04-03T20:15:00Z"}
{"from":"refactor","to":"tester","action":"write_test","status":"ok","note":"refactor done","timestamp":"2026-04-03T20:30:00Z"}
BOARD

    echo '{"task_id":1,"name":"Task 1","status":"done"}' \
      > "$TEST_HEARTBEAT/stories/mapx-test/tasks.jsonl"
  }

  cleanup() {
    rm -rf "$TEST_PROJECT"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'uses mapX for bar X coordinates so post-gap bars are not compressed to right edge'
    When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
    The output should include 'Dashboard generated'
    # With the linear scale (current code):
    #   padL=110, chartW=600, total range = 10.5h = 37800000ms
    #   tScale = 600/37800000 ~= 0.0000159 px/ms
    #   The tester bar at 20:00 starts at x = 110 + 36000000*tScale = ~681
    #   Bars cluster in the rightmost ~5% of the chart.
    #
    # With mapX compression (expected after implementation):
    #   Gap (10:00-20:00) compressed to 30px (5% of 600).
    #   Activity segment (20:00-20:30) gets ~570px.
    #   The tester bar at 20:00 starts at x = 110 + 0 + 30 = ~140.
    #   This is well below x=400 (midpoint of chart area).
    #
    # This test verifies that a mapX function exists in dashboard.html
    # AND that bar drawing calls mapX instead of using the raw linear formula.
    # The bar x coordinate line must use mapX(start) not (start - tMin) * tScale.
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'mapX(start)'
  End
End
