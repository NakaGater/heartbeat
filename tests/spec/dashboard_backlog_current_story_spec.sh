Describe 'generate-dashboard.sh ダッシュボード再生成とCurrent Story表示'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/story-active"
    mkdir -p "$TEST_HEARTBEAT/stories/story-finished"

    # backlog.jsonl: in_progress 1件 + done 1件
    cat > "$TEST_HEARTBEAT/backlog.jsonl" <<'JSONL'
{"story_id":"story-active","title":"Active Feature","status":"in_progress","priority":1,"points":2}
{"story_id":"story-finished","title":"Finished Feature","status":"done","priority":2,"points":1}
JSONL

    # stories ディレクトリに最小限の board.jsonl / tasks.jsonl を用意
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

  Describe 'in_progressストーリーを含むbacklogでダッシュボード再生成'
    It 'in_progressのstory_idがダッシュボードHTMLに埋め込まれること'
      When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
      The output should include 'Dashboard generated'
      The file "$TEST_HEARTBEAT/dashboard.html" should be exist
      # in_progress ストーリーのstory_idがBACKLOG_DATAに含まれる
      The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'story-active'
      # done ストーリーも含まれる
      The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'story-finished'
      # populateStorySelectが in_progress を検出できるようデータに status が含まれる
      The contents of file "$TEST_HEARTBEAT/dashboard.html" should include 'in_progress'
    End
  End
End
