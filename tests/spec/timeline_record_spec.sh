Describe 'timeline-record.sh'
  setup() {
    STORIES_DIR=$(mktemp -d)
    STORY_DIR="${STORIES_DIR}/.heartbeat/stories/test-story"
    mkdir -p "$STORY_DIR"
    # board.jsonl を用意して find_board_jsonl() がストーリーディレクトリを特定できるようにする
    echo '{"from":"tester","to":"implementer","action":"make_green","status":"ok","note":"test","timestamp":"2026-01-01T00:00:00Z"}' \
      > "$STORY_DIR/board.jsonl"
    export HEARTBEAT_ROOT="${STORIES_DIR}"
    export HEARTBEAT_ACTIVE_STORY="test-story"
  }
  cleanup() {
    rm -rf "$STORIES_DIR"
    unset HEARTBEAT_ROOT HEARTBEAT_ACTIVE_STORY
  }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  # Helper: invoke timeline-record.sh with given stdin JSON
  run_timeline_record() {
    echo "$1" | ./core/scripts/timeline-record.sh
  }

  Describe 'スクリプトの存在と実行権限'
    It 'core/scripts/timeline-record.sh が存在し実行権限を持つ'
      Path script="core/scripts/timeline-record.sh"
      The path script should be executable
    End
  End

  Describe 'SubagentStop イベントの記録'
    It 'SubagentStop stdin を受け取ると timeline.jsonl に agent-stop エントリを追記する'
      When call run_timeline_record '{"hook_event_name":"SubagentStop","agent_type":"heartbeat:tester","session_id":"abc123"}'
      The status should be success
      The contents of file "$STORY_DIR/timeline.jsonl" should include '"event":"agent-stop"'
      The contents of file "$STORY_DIR/timeline.jsonl" should include '"agent":"tester"'
      The contents of file "$STORY_DIR/timeline.jsonl" should include '"timestamp"'
    End
  End
End
