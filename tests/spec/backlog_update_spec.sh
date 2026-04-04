Describe 'backlog-update.sh'
  SCRIPT="./core/scripts/backlog-update.sh"

  Describe 'スクリプトの存在と実行権限'
    It 'core/scripts/backlog-update.sh が存在する'
      Path script="$SCRIPT"
      The path script should be exist
    End

    It '実行権限がある'
      Path script="$SCRIPT"
      The path script should be executable
    End
  End

  Describe '引数バリデーション'
    It '引数なしでexit 1を返す'
      When run "$SCRIPT"
      The status should equal 1
      The stderr should include "usage"
    End
  End

  Describe 'backlog.jsonl更新'
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

    It '指定story-idのstatusを更新できる'
      run_update() {
        HEARTBEAT_MAIN_DIR="$TEST_DIR" "$SCRIPT" "0007-test" "status" "in_progress"
        jq -r 'select(.story_id == "0007-test") | .status' "$TEST_DIR/.heartbeat/backlog.jsonl"
      }
      When call run_update
      The output should equal "in_progress"
    End
  End
End
