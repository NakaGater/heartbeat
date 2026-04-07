Describe 'backlog.jsonl ポイント再見積もり (0055)'
  backlog_file=".heartbeat/backlog.jsonl"

  get_points() {
    jq -r --arg sid "$1" 'select(.story_id == $sid) | .points' "$backlog_file"
  }

  Describe '対象9ストーリーのポイント値が現行基準に更新されていること'
    It '0001-tdd-workflow の points が 2 であること'
      When call get_points "0001-tdd-workflow"
      The output should equal "2"
    End

    It '0002-i18n-docs の points が 2 であること'
      When call get_points "0002-i18n-docs"
      The output should equal "2"
    End

    It '0003-auto-commit-fix の points が 2 であること'
      When call get_points "0003-auto-commit-fix"
      The output should equal "2"
    End

    It '0004-dashboard-fix の points が 2 であること'
      When call get_points "0004-dashboard-fix"
      The output should equal "2"
    End

    It '0005-workflow-fix の points が 1 であること'
      When call get_points "0005-workflow-fix"
      The output should equal "1"
    End

    It '0006-workflow-boundary の points が 1 であること'
      When call get_points "0006-workflow-boundary"
      The output should equal "1"
    End

    It '0009-board-cleanup の points が 2 であること'
      When call get_points "0009-board-cleanup"
      The output should equal "2"
    End

    It '0015-commit-message-accuracy の points が 2 であること'
      When call get_points "0015-commit-message-accuracy"
      The output should equal "2"
    End

    It '0024-plugin-config-cleanup の points が 2 であること'
      When call get_points "0024-plugin-config-cleanup"
      The output should equal "2"
    End
  End

  Describe '更新後の検証: 不正なポイント値が残存していないこと'
    It 'points=5 のエントリが 0件であること'
      When call jq -r 'select(.points == 5) | .story_id' "$backlog_file"
      The output should equal ""
    End

    It 'points=10 のエントリが 0件であること'
      When call jq -r 'select(.points == 10) | .story_id' "$backlog_file"
      The output should equal ""
    End

    It '全 done ストーリーの points が 1, 2, 3 のいずれかであること'
      count_invalid() {
        local result
        result=$(jq -r 'select(.status == "done") | select(.points != 1 and .points != 2 and .points != 3) | .story_id' "$backlog_file" | wc -l | tr -d ' ')
        echo "$result"
      }
      When call count_invalid
      The output should equal "0"
    End

    It '0019-copilot-hooks-fix の points が 3 のまま変更されていないこと'
      When call get_points "0019-copilot-hooks-fix"
      The output should equal "3"
    End
  End
End
