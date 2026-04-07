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

  Describe 'SubagentStart イベントの記録'
    It 'SubagentStart stdin を受け取ると timeline.jsonl に agent-start エントリを追記する'
      When call run_timeline_record '{"hook_event_name":"SubagentStart","agent_type":"heartbeat:implementer","session_id":"def456"}'
      The status should be success
      The contents of file "$STORY_DIR/timeline.jsonl" should include '"event":"agent-start"'
      The contents of file "$STORY_DIR/timeline.jsonl" should include '"agent":"implementer"'
    End
  End

  Describe 'agent_type が空の場合のフォールバック'
    It 'agent_type が空文字列のとき agent を "unknown" にフォールバックする'
      When call run_timeline_record '{"hook_event_name":"SubagentStop","agent_type":"","session_id":"ghi789"}'
      The status should be success
      The contents of file "$STORY_DIR/timeline.jsonl" should include '"agent":"unknown"'
    End
  End

  Describe 'ストーリーディレクトリが見つからない場合'
    It 'find_board_jsonl が空を返すとき、エラーなしで exit 0 する'
      # board.jsonl を削除して find_board_jsonl が空を返す状態にする
      setup_no_story() {
        NO_STORY_DIR=$(mktemp -d)
        export HEARTBEAT_ROOT="${NO_STORY_DIR}"
        export HEARTBEAT_ACTIVE_STORY="nonexistent-story"
      }
      cleanup_no_story() {
        rm -rf "$NO_STORY_DIR"
      }
      setup_no_story
      When call run_timeline_record '{"hook_event_name":"SubagentStop","agent_type":"heartbeat:tester","session_id":"jkl012"}'
      The status should be success
      The stderr should be blank
      cleanup_no_story
    End
  End

  Describe 'board.jsonl への非書き込み保証'
    It 'timeline-record.sh 実行後に board.jsonl の内容が変化しない'
      # 実行前の board.jsonl の内容を記録
      save_board() {
        BOARD_BEFORE=$(cat "$STORY_DIR/board.jsonl")
      }
      save_board
      When call run_timeline_record '{"hook_event_name":"SubagentStop","agent_type":"heartbeat:tester","session_id":"mno345"}'
      The status should be success
      The contents of file "$STORY_DIR/board.jsonl" should equal "$BOARD_BEFORE"
    End
  End
End
