Describe 'generate-dashboard.sh: Velocity chart message when all iterations are null'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/story-a"

    # Backlog with done stories where iteration is null (reproduces misleading "Collecting data" message)
    cat > "$TEST_HEARTBEAT/backlog.jsonl" <<'BACKLOG'
{"story_id":"story-a","title":"Story A","status":"done","priority":1,"points":2,"iteration":null}
{"story_id":"story-b","title":"Story B","status":"done","priority":2,"points":1,"iteration":null}
BACKLOG

    # Minimal board and tasks so generate-dashboard.sh runs successfully
    echo '{"from":"tester","to":"implementer","action":"make_green","output":"test.sh","status":"ok","note":"test","timestamp":"2026-01-01T00:00:00Z"}' \
      > "$TEST_HEARTBEAT/stories/story-a/board.jsonl"
    echo '{"task_id":1,"name":"Task 1","status":"done"}' \
      > "$TEST_HEARTBEAT/stories/story-a/tasks.jsonl"
  }

  cleanup() {
    rm -rf "$TEST_PROJECT"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'displays week-based fallback chart when done stories have null iteration but completed dates'
    # Add completed dates so the week-based fallback activates
    cat > "$TEST_HEARTBEAT/backlog.jsonl" <<'BACKLOG'
{"story_id":"story-a","title":"Story A","status":"done","priority":1,"points":2,"iteration":null,"completed":"2026-01-05"}
{"story_id":"story-b","title":"Story B","status":"done","priority":2,"points":1,"iteration":null,"completed":"2026-01-12"}
BACKLOG
    When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
    The output should include 'Dashboard generated'
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'Week'
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should not include 'Collecting data'
  End
End
