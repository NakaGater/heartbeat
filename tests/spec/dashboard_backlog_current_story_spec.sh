Describe 'generate-dashboard.sh Dashboard Regeneration and Current Story Display'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/story-active"
    mkdir -p "$TEST_HEARTBEAT/stories/story-finished"

    # backlog.jsonl: 1 in_progress + 1 done entry
    cat > "$TEST_HEARTBEAT/backlog.jsonl" <<'JSONL'
{"story_id":"story-active","title":"Active Feature","status":"in_progress","priority":1,"points":2}
{"story_id":"story-finished","title":"Finished Feature","status":"done","priority":2,"points":1}
JSONL

    # Prepare minimal board.jsonl / tasks.jsonl in stories directory
    echo '{"from":"tester","to":"implementer","action":"make_green","status":"done","note":"test","timestamp":"2026-04-03T00:00:00Z"}' \
      > "$TEST_HEARTBEAT/stories/story-active/board.jsonl"
    echo '{"task_id":1,"name":"Task A","status":"in_progress"}' \
      > "$TEST_HEARTBEAT/stories/story-active/tasks.jsonl"

    echo '{"from":"implementer","to":"reviewer","action":"review","status":"done","note":"done","timestamp":"2026-04-02T00:00:00Z"}' \
      > "$TEST_HEARTBEAT/stories/story-finished/board.jsonl"
    echo '{"task_id":1,"name":"Task B","status":"done"}' \
      > "$TEST_HEARTBEAT/stories/story-finished/tasks.jsonl"
  }
  cleanup() {
    rm -rf "$TEST_PROJECT"
  }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'Dashboard Regeneration With in_progress Story in Backlog'
    It 'embeds the in_progress story_id in dashboard HTML'
      When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
      The output should include 'Dashboard generated'
      The file "$TEST_HEARTBEAT/dashboard.html" should be exist
      # in_progress story's story_id is included in BACKLOG_DATA
      The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'story-active'
      # done story is also included
      The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'story-finished'
      # Data includes status so populateStorySelect can detect in_progress
      The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'in_progress'
    End
  End
End
