Describe 'generate-dashboard.sh: Integration Test - Dashboard Generation With Orchestrator Entries (T6)'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/integration-test"

    echo '{"story_id":"integration-test","title":"Integration Test","status":"in_progress","priority":1,"points":1}' \
      > "$TEST_HEARTBEAT/backlog.jsonl"

    # orchestratorエントリを含む完全なTDDサイクルデータ
    # T1: 行順保持（タイムスタンプは意図的に行順と一致させる）
    # T4: orchestratorがフィルタされずガントに表示される
    # T5: 全バーに<title>ツールチップが付与される
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
    # 統合検証1: STORIES_DATAにorchestratorのboardエントリが埋め込まれている
    # generate-dashboard.shがboard.jsonlを読み込みSTORIES_DATAに変換する過程で
    # orchestratorエントリがフィルタされていないことを確認
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include '"from": "orchestrator"'
    # 統合検証2: renderGantt()にSVG <title>ツールチップのコードが存在する
    # T5の修正により、各バーに<title>要素が付与されている
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include "<title>' + esc(e.from)"
  End
End
