Describe 'generate-dashboard.sh: ダッシュボード統合 - INSIGHTS_DATAの注入とUser Insightsパネル（タスク5）'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/test-story"
    mkdir -p "$TEST_HEARTBEAT/insights"

    echo '{"story_id":"test-story","title":"Test","status":"in_progress","priority":1,"points":1}' \
      > "$TEST_HEARTBEAT/backlog.jsonl"

    echo '{"from":"tester","to":"implementer","action":"test","status":"ok","note":"test","timestamp":"2026-04-04T10:00:00Z"}' \
      > "$TEST_HEARTBEAT/stories/test-story/board.jsonl"

    echo '{"task_id":1,"name":"Task 1","status":"done"}' \
      > "$TEST_HEARTBEAT/stories/test-story/tasks.jsonl"
  }

  cleanup() {
    rm -rf "$TEST_PROJECT"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'INSIGHTS_DATAプレースホルダーが4層統合JSONに置換される'
    # 4層のテストデータを用意
    echo '{"id":"RAW-001","source_type":"interview","source_ref":"test.md","title":"テスト","excerpt":"要約","created_by":"insight-analyst","timestamp":"2026-04-04T10:00:00Z"}' \
      > "$TEST_HEARTBEAT/insights/raw.jsonl"
    echo '{"id":"FND-001","source_raw":"RAW-001","type":"statement","content":"発言内容","created_by":"insight-analyst","timestamp":"2026-04-04T10:00:00Z"}' \
      > "$TEST_HEARTBEAT/insights/findings.jsonl"
    echo '{"id":"INS-001","source_findings":["FND-001"],"category":"pain","theme":"テスト課題","insight":"テストインサイト","evidence_summary":"証拠","severity":"high","confidence":"high","created_by":"insight-analyst","timestamp":"2026-04-04T10:00:00Z"}' \
      > "$TEST_HEARTBEAT/insights/insights.jsonl"
    echo '{"id":"OPP-001","source_insights":["INS-001"],"title":"テスト機会","description":"改善案","impact":"high","effort":"medium","related_stories":[],"created_by":"insight-analyst","timestamp":"2026-04-04T10:00:00Z"}' \
      > "$TEST_HEARTBEAT/insights/opportunities.jsonl"

    When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
    The output should include 'Dashboard generated'
    # INSIGHTS_DATAが置換されており、プレースホルダーが残っていないこと
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should not include '{{INSIGHTS_DATA}}'
    # 4層のデータ構造がJSONとして注入されていること
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include '"raw"'
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include '"findings"'
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include '"insights"'
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include '"opportunities"'
  End

  It 'User Insightsパネルが生成HTMLに存在する'
    echo '{"id":"RAW-001","source_type":"interview","source_ref":"test.md","title":"テスト","excerpt":"要約","created_by":"insight-analyst","timestamp":"2026-04-04T10:00:00Z"}' \
      > "$TEST_HEARTBEAT/insights/raw.jsonl"

    When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
    The output should include 'Dashboard generated'
    # User Insightsパネルの存在確認
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'User Insights'
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'id="insights-panel"'
  End

  It 'ES5スタイル準拠: INSIGHTS_DATA宣言にconstを使わずvarを使用する'
    echo '{"id":"RAW-001","source_type":"interview","source_ref":"test.md","title":"テスト","excerpt":"要約","created_by":"insight-analyst","timestamp":"2026-04-04T10:00:00Z"}' \
      > "$TEST_HEARTBEAT/insights/raw.jsonl"

    When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
    The output should include 'Dashboard generated'
    # INSIGHTS_DATAの宣言がvar（ES5）であること
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'var INSIGHTS_DATA'
    # renderInsights関数がfunction宣言であること
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'function renderInsights()'
  End

  It 'JSONLファイルが存在しない場合にエラーにならずデータなしと表示される'
    # insightsディレクトリは空（JSONLファイルなし）
    rm -rf "$TEST_HEARTBEAT/insights"

    When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
    The status should eq 0
    The output should include 'Dashboard generated'
    # データなし表示のための空配列またはデータなし文字列が含まれること
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'データなし'
  End
End
