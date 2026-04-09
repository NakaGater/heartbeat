Describe 'generate-dashboard.sh Defensive Parsing of Invalid JSON Lines'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/valid-story"

    # backlog.jsonl: 2 valid lines + 1 invalid line (line with extra leading ")
    cat > "$TEST_HEARTBEAT/backlog.jsonl" <<'JSONL'
{"story_id":"story-alpha","title":"Alpha Story","status":"draft","priority":1,"points":1}
"{"story_id":"story-broken","title":"Broken Story","status":"draft","priority":2,"points":1}
{"story_id":"story-beta","title":"Beta Story","status":"in_progress","priority":3,"points":2}
JSONL

    echo '{"from":"tester","to":"implementer","action":"make_green","status":"done","note":"test","timestamp":"2026-04-03T00:00:00Z"}' > "$TEST_HEARTBEAT/stories/valid-story/board.jsonl"
    echo '{"task_id":1,"name":"Task 1","status":"done"}' > "$TEST_HEARTBEAT/stories/valid-story/tasks.jsonl"
  }
  cleanup() {
    rm -rf "$TEST_PROJECT"
  }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'Handling backlog.jsonl Containing Invalid JSON Lines'
    It 'skips invalid lines and generates dashboard with valid lines only'
      When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
      The output should include 'Dashboard generated'
      The file "$TEST_HEARTBEAT/dashboard.html" should be exist
      # Valid line story-alpha should be included
      The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'story-alpha'
      # Valid line story-beta should be included
      The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'story-beta'
      # Invalid line story-broken should not be included
      The contents of file "$TEST_HEARTBEAT/dashboard.html" should not include 'story-broken'
    End
  End
End
