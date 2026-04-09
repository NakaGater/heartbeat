Describe 'generate-dashboard.sh Fallback When All Lines Are Invalid JSON'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/dummy-story"

    # backlog.jsonl: all lines are invalid JSON
    cat > "$TEST_HEARTBEAT/backlog.jsonl" <<'JSONL'
"{"story_id":"broken-1","title":"Broken 1","status":"draft","priority":1,"points":1}
not json at all
{"missing-closing-brace": true
JSONL

    echo '{"from":"tester","to":"implementer","action":"make_green","status":"done","note":"test","timestamp":"2026-04-03T00:00:00Z"}' > "$TEST_HEARTBEAT/stories/dummy-story/board.jsonl"
    echo '{"task_id":1,"name":"Task 1","status":"done"}' > "$TEST_HEARTBEAT/stories/dummy-story/tasks.jsonl"
  }
  cleanup() {
    rm -rf "$TEST_PROJECT"
  }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'Handling backlog.jsonl With All Invalid Lines'
    It 'falls back to an empty array and generates dashboard successfully'
      When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
      The output should include 'Dashboard generated'
      The file "$TEST_HEARTBEAT/dashboard.html" should be exist
      # BACKLOG_DATA should be empty array [] (no invalid story_id included)
      The contents of file "$TEST_HEARTBEAT/dashboard.html" should not include 'broken-1'
      The contents of file "$TEST_HEARTBEAT/dashboard.html" should not include 'missing-closing-brace'
    End
  End
End
