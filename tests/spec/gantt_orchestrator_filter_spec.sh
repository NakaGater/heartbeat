Describe 'generate-dashboard.sh: Orchestrator Appears in Gantt Chart (T4)'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/orch-filter-test"

    echo '{"story_id":"orch-filter-test","title":"Orchestrator Filter Test","status":"in_progress","priority":1,"points":1}' \
      > "$TEST_HEARTBEAT/backlog.jsonl"

    # board.jsonl: orchestratorのcheckpointエントリを含むデータ
    # T4修正前はorchestratorがagentsフィルタで除外されるため、
    # ガントチャートのY軸ラベルに表示されない
    cat > "$TEST_HEARTBEAT/stories/orch-filter-test/board.jsonl" <<'BOARD'
{"from":"tester","to":"implementer","action":"make_red","status":"ok","note":"red phase","timestamp":"2026-04-03T10:00:00Z"}
{"from":"orchestrator","to":"tester","action":"checkpoint","status":"ok","note":"checkpoint","timestamp":"2026-04-03T10:05:00Z"}
{"from":"implementer","to":"tester","action":"make_green","status":"ok","note":"green phase","timestamp":"2026-04-03T10:10:00Z"}
BOARD

    echo '{"task_id":1,"name":"Task 1","status":"done"}' \
      > "$TEST_HEARTBEAT/stories/orch-filter-test/tasks.jsonl"
  }

  cleanup() {
    rm -rf "$TEST_PROJECT"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'filters only human from agents, not orchestrator'
    When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
    The output should include 'Dashboard generated'
    # renderGantt()のagentsフィルタにorchestratorの除外条件が含まれていないことを検証
    # 修正前: return a !== 'human' && a !== 'orchestrator'
    # 修正後: return a !== 'human'
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should not include "a !== 'orchestrator'"
  End
End
