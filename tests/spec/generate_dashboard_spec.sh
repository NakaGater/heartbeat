Describe 'generate-dashboard.sh'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/test-story"

    echo '{"story_id":"test-story","title":"Test Story","status":"in_progress","priority":1,"points":2}' > "$TEST_HEARTBEAT/backlog.jsonl"
    echo '{"from":"tester","to":"implementer","action":"make_green","status":"done","note":"test note","timestamp":"2026-03-30T00:00:00Z"}' > "$TEST_HEARTBEAT/stories/test-story/board.jsonl"
    echo '{"task_id":1,"name":"Task 1","status":"done"}' > "$TEST_HEARTBEAT/stories/test-story/tasks.jsonl"
  }
  cleanup() {
    rm -rf "$TEST_PROJECT"
  }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'Normal cases'
    It 'generates dashboard HTML file'
      When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
      The output should include 'Dashboard generated'
      The file "$TEST_HEARTBEAT/dashboard.html" should be exist
    End

    It 'embeds BACKLOG_DATA from backlog.jsonl'
      When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
      The output should include 'Dashboard generated'
      The contents of file "$TEST_HEARTBEAT/dashboard.html" should include '"story_id": "test-story"'
    End

    It 'embeds STORIES_DATA with board and tasks'
      When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
      The output should include 'Dashboard generated'
      The contents of file "$TEST_HEARTBEAT/dashboard.html" should include '"from": "tester"'
      The contents of file "$TEST_HEARTBEAT/dashboard.html" should include '"task_id": 1'
    End

    It 'embeds AGENT_COLORS JSON'
      When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
      The output should include 'Dashboard generated'
      The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'pdm'
      The contents of file "$TEST_HEARTBEAT/dashboard.html" should include '#3B82F6'
    End

    It 'replaces all template placeholders'
      When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
      The output should include 'Dashboard generated'
      The contents of file "$TEST_HEARTBEAT/dashboard.html" should not include '{{BACKLOG_DATA}}'
      The contents of file "$TEST_HEARTBEAT/dashboard.html" should not include '{{STORIES_DATA}}'
      The contents of file "$TEST_HEARTBEAT/dashboard.html" should not include '{{AGENT_COLORS}}'
    End
  End

  Describe 'Edge cases'
    It 'handles empty backlog gracefully'
      rm -f "$TEST_HEARTBEAT/backlog.jsonl"
      When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
      The output should include 'Dashboard generated'
      The file "$TEST_HEARTBEAT/dashboard.html" should be exist
    End

    It 'handles missing stories directory gracefully'
      rm -rf "$TEST_HEARTBEAT/stories"
      When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
      The output should include 'Dashboard generated'
      The file "$TEST_HEARTBEAT/dashboard.html" should be exist
    End
  End
End
