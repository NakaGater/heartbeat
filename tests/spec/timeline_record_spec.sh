Describe 'timeline-record.sh'
  setup() {
    STORIES_DIR=$(mktemp -d)
    STORY_DIR="${STORIES_DIR}/.heartbeat/stories/test-story"
    mkdir -p "$STORY_DIR"
    # Prepare board.jsonl so find_board_jsonl() can locate the story directory
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

  Describe 'Script Existence and Permissions'
    It 'verifies that core/scripts/timeline-record.sh exists and is executable'
      Path script="core/scripts/timeline-record.sh"
      The path script should be executable
    End
  End

  Describe 'SubagentStop Event Recording'
    It 'appends agent-stop entry to timeline.jsonl when receiving SubagentStop stdin'
      When call run_timeline_record '{"hook_event_name":"SubagentStop","agent_type":"heartbeat:tester","session_id":"abc123"}'
      The status should be success
      The contents of file "$STORY_DIR/timeline.jsonl" should include '"event":"agent-stop"'
      The contents of file "$STORY_DIR/timeline.jsonl" should include '"agent":"tester"'
      The contents of file "$STORY_DIR/timeline.jsonl" should include '"timestamp"'
    End
  End

  Describe 'SubagentStart Event Recording'
    It 'appends agent-start entry to timeline.jsonl when receiving SubagentStart stdin'
      When call run_timeline_record '{"hook_event_name":"SubagentStart","agent_type":"heartbeat:implementer","session_id":"def456"}'
      The status should be success
      The contents of file "$STORY_DIR/timeline.jsonl" should include '"event":"agent-start"'
      The contents of file "$STORY_DIR/timeline.jsonl" should include '"agent":"implementer"'
    End
  End

  Describe 'Fallback When agent_type Is Empty'
    It 'falls back agent to "unknown" when agent_type is an empty string'
      When call run_timeline_record '{"hook_event_name":"SubagentStop","agent_type":"","session_id":"ghi789"}'
      The status should be success
      The contents of file "$STORY_DIR/timeline.jsonl" should include '"agent":"unknown"'
    End
  End

  Describe 'When Story Directory Is Not Found'
    It 'exits 0 without error when find_board_jsonl returns empty'
      # Delete board.jsonl so find_board_jsonl returns empty
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

  Describe 'Non-write Guarantee for board.jsonl'
    It 'does not change board.jsonl contents after timeline-record.sh execution'
      # Record board.jsonl contents before execution
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
