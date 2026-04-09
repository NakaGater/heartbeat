Describe 'backlog-update.sh'
  SCRIPT="./core/scripts/backlog-update.sh"

  Describe 'Script Existence and Permissions'
    It 'verifies that core/scripts/backlog-update.sh exists'
      Path script="$SCRIPT"
      The path script should be exist
    End

    It 'has execute permission'
      Path script="$SCRIPT"
      The path script should be executable
    End
  End

  Describe 'Argument Validation'
    It 'returns exit 1 when called without arguments'
      When run "$SCRIPT"
      The status should equal 1
      The stderr should include "usage"
    End
  End

  Describe 'backlog.jsonl Update'
    setup_backlog() {
      TEST_DIR=$(mktemp -d)
      mkdir -p "$TEST_DIR/.heartbeat"
      echo '{"story_id":"0007-test","title":"Test Story","status":"ready","priority":1,"points":2,"iteration":null}' \
        > "$TEST_DIR/.heartbeat/backlog.jsonl"
    }

    cleanup_backlog() {
      rm -rf "$TEST_DIR"
    }

    BeforeEach 'setup_backlog'
    AfterEach 'cleanup_backlog'

    It 'updates the status of a specified story-id'
      run_update() {
        HEARTBEAT_MAIN_DIR="$TEST_DIR" "$SCRIPT" "0007-test" "status" "in_progress"
        jq -r 'select(.story_id == "0007-test") | .status' "$TEST_DIR/.heartbeat/backlog.jsonl"
      }
      When call run_update
      The output should equal "in_progress"
    End
  End
End
