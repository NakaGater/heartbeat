Describe 'generate-dashboard.sh: Integration Test - Dashboard Generation With Orchestrator Entries (T6)'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/integration-test"

    echo '{"story_id":"integration-test","title":"Integration Test","status":"in_progress","priority":1,"points":1}' \
      > "$TEST_HEARTBEAT/backlog.jsonl"

    # Complete TDD cycle data including orchestrator entries
    # T1: Preserve line order (timestamps intentionally match line order)
    # T4: orchestrator is not filtered out and appears in Gantt chart
    # T5: All bars have <title> tooltips
    cat > "$TEST_HEARTBEAT/stories/integration-test/board.jsonl" <<'BOARD'
{"from":"tester","to":"implementer","action":"make_red","status":"ok","note":"red phase","timestamp":"2026-04-03T10:00:00Z"}
{"from":"implementer","to":"tester","action":"make_green","status":"ok","note":"green phase","timestamp":"2026-04-03T10:10:00Z"}
{"from":"orchestrator","to":"tester","action":"checkpoint","status":"ok","note":"orchestrator checkpoint","timestamp":"2026-04-03T10:15:00Z"}
{"from":"refactor","to":"tester","action":"refactor","status":"ok","note":"refactor phase","timestamp":"2026-04-03T10:20:00Z"}
BOARD

    echo '{"task_id":1,"name":"Task 1","status":"done"}' \
      > "$TEST_HEARTBEAT/stories/integration-test/tasks.jsonl"
  }

  cleanup() {
    rm -rf "$TEST_PROJECT"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'includes orchestrator entries in STORIES_DATA and contains tooltip <title> code in generated HTML'
    When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
    The output should include 'Dashboard generated'
    # Integration check 1: orchestrator board entries are embedded in STORIES_DATA
    # During the process of generate-dashboard.sh reading board.jsonl and converting to STORIES_DATA
    # confirm orchestrator entries are not filtered out
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include '"from": "orchestrator"'
    # Integration check 2: SVG <title> tooltip code exists in renderGantt()
    # Per T5 fix, each bar has a <title> element
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include "<title>' + esc(e.from)"
  End
End
