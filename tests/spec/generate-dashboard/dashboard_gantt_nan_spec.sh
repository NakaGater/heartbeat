Describe 'generate-dashboard.sh: Gantt chart NaN defense'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/empty-timestamps"

    # Backlog with one story
    echo '{"story_id":"empty-timestamps","title":"Empty TS Story","status":"in_progress","priority":1,"points":1}' \
      > "$TEST_HEARTBEAT/backlog.jsonl"

    # Board entries with ALL timestamps as empty strings (reproduces NaN bug)
    cat > "$TEST_HEARTBEAT/stories/empty-timestamps/board.jsonl" <<'BOARD'
{"from":"pdm","to":"context-manager","action":"investigate","output":"brief.md","status":"ok","note":"test","timestamp":""}
{"from":"context-manager","to":"pdm","action":"define_story","output":"context.md","status":"ok","note":"test","timestamp":""}
{"from":"tester","to":"implementer","action":"make_green","output":"test.sh","status":"ok","note":"test","timestamp":""}
BOARD

    echo '{"task_id":1,"name":"Task 1","status":"done"}' \
      > "$TEST_HEARTBEAT/stories/empty-timestamps/tasks.jsonl"
  }

  cleanup() {
    rm -rf "$TEST_PROJECT"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'does not produce NaN in SVG attributes when all timestamps are empty strings'
    check_no_svg_nan() {
      ./core/scripts/generate-dashboard.sh "$TEST_PROJECT" >/dev/null 2>&1
      # Check for NaN in SVG attribute values (e.g. x="NaN", width="NaN")
      # but not in JavaScript code like isNaN()
      ! grep -qE '="NaN[^"]*"' "$TEST_HEARTBEAT/dashboard.html"
    }
    When call check_no_svg_nan
    The status should be success
  End
End
