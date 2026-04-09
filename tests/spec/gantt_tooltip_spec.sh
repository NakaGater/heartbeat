Describe 'generate-dashboard.sh: Gantt Chart Bar Tooltips (T5)'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/tooltip-test"

    echo '{"story_id":"tooltip-test","title":"Tooltip Test","status":"in_progress","priority":1,"points":1}' \
      > "$TEST_HEARTBEAT/backlog.jsonl"

    # board.jsonl: testerとimplementerのエントリを含むテストデータ
    # T5修正前は<rect>要素のみでツールチップ（<title>要素）が付与されていない
    # T5修正後は各バーが<g>でラップされ、内部に<title>要素が含まれる
    cat > "$TEST_HEARTBEAT/stories/tooltip-test/board.jsonl" <<'BOARD'
{"from":"tester","to":"implementer","action":"make_red","status":"ok","note":"red phase","timestamp":"2026-04-03T10:00:00Z"}
{"from":"implementer","to":"tester","action":"make_green","status":"ok","note":"green phase","timestamp":"2026-04-03T10:10:00Z"}
BOARD

    echo '{"task_id":1,"name":"Task 1","status":"done"}' \
      > "$TEST_HEARTBEAT/stories/tooltip-test/tasks.jsonl"
  }

  cleanup() {
    rm -rf "$TEST_PROJECT"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'wraps each bar in <g> with a <title> tooltip containing agent name'
    When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
    The output should include 'Dashboard generated'
    # T5: バー描画ループで各<rect>を<g>でラップし、
    # svg += '<title>' + esc(e.from) + ' / ' + esc(e.action) + ' / ' + esc(e.timestamp) + '</title>';
    # を追加する。このパターンがJavaScript内に存在することを検証する。
    # 修正前: svg += '<rect .../>'; のみ（<title>要素なし）
    # 修正後: svg += '<g>'; svg += '<rect .../>'; svg += '<title>...</title>'; svg += '</g>';
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should include "svg += '<title>'"
  End
End
