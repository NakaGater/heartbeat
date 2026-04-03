Describe 'generate-dashboard.sh: ガントチャートの行順保持（T1）'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/sort-order-test"

    echo '{"story_id":"sort-order-test","title":"Sort Order Test","status":"in_progress","priority":1,"points":1}' \
      > "$TEST_HEARTBEAT/backlog.jsonl"

    # board.jsonl: 行順はred->green->refactorだが、タイムスタンプは逆順
    # 行1(red)のタイムスタンプが最も遅く、行3(refactor)が最も早い
    # entries.sort()が存在する場合、この順序がタイムスタンプ順に並び替えられてしまう
    cat > "$TEST_HEARTBEAT/stories/sort-order-test/board.jsonl" <<'BOARD'
{"from":"tester","to":"implementer","action":"make_red","status":"ok","note":"red phase","timestamp":"2026-04-03T10:30:00Z"}
{"from":"implementer","to":"tester","action":"make_green","status":"ok","note":"green phase","timestamp":"2026-04-03T10:20:00Z"}
{"from":"refactor","to":"tester","action":"refactor","status":"ok","note":"refactor phase","timestamp":"2026-04-03T10:10:00Z"}
BOARD

    echo '{"task_id":1,"name":"Task 1","status":"done"}' \
      > "$TEST_HEARTBEAT/stories/sort-order-test/tasks.jsonl"
  }

  cleanup() {
    rm -rf "$TEST_PROJECT"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'board.jsonlの行順がSTORIES_DATAに保持され、タイムスタンプ順ソートが存在しない'
    When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
    The output should include 'Dashboard generated'
    # renderGantt()内のentries.sort()が存在しないことを検証する
    # この行がテンプレートに残っている限り、行順がタイムスタンプ順に上書きされてしまう
    The contents of file "$TEST_HEARTBEAT/dashboard.html" should not include 'entries.sort(function(a,b){ return new Date(a.timestamp) - new Date(b.timestamp); })'
  End
End
