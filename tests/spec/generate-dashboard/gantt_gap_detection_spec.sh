Describe 'generate-dashboard.sh: ガントチャート時間ギャップ検出 (0065-T1)'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/gap-test"

    echo '{"story_id":"gap-test","title":"Gap Detection Test","status":"in_progress","priority":1,"points":1}' \
      > "$TEST_HEARTBEAT/backlog.jsonl"

    # board.jsonl: ストーリー作成(10:00)から実装開始(20:00)まで10時間のギャップ
    # 全区間は10:00-20:30の10.5時間 -> ギャップ10時間は約95%（20%閾値を大幅超過）
    cat > "$TEST_HEARTBEAT/stories/gap-test/board.jsonl" <<'BOARD'
{"from":"pdm","to":"designer","action":"define_story","status":"ok","note":"story created","timestamp":"2026-04-03T10:00:00Z"}
{"from":"tester","to":"implementer","action":"make_red","status":"ok","note":"red phase","timestamp":"2026-04-03T20:00:00Z"}
{"from":"implementer","to":"tester","action":"make_green","status":"ok","note":"green phase","timestamp":"2026-04-03T20:30:00Z"}
BOARD

    echo '{"task_id":1,"name":"Task 1","status":"done"}' \
      > "$TEST_HEARTBEAT/stories/gap-test/tasks.jsonl"
  }

  cleanup() {
    rm -rf "$TEST_PROJECT"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It '全区間の20%以上を占めるギャップを検出してセグメント配列を構築する'
    When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
    The output should include 'Dashboard generated'
    # ギャップ検出ロジック: 隣接エントリ間のタイムスタンプ差を走査し、
    # 全区間(tMax - tMin)の20%以上を占める単一ギャップを検出する。
    # 検出結果をセグメント配列として構造化する。
    # このロジックが renderGantt() 内に存在することを確認する。
    # 現時点では未実装のため Red になる。
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'segments'
  End
End
