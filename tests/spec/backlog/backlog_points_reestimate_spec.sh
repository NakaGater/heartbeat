Describe 'backlog.jsonl Points Re-estimation (0055)'
  backlog_file=".heartbeat/backlog.jsonl"

  get_points() {
    jq -r --arg sid "$1" 'select(.story_id == $sid) | .points' "$backlog_file"
  }

  Describe 'Target 9 Stories Updated to Current Criteria'
    It 'verifies that 0001-tdd-workflow points equals 2'
      When call get_points "0001-tdd-workflow"
      The output should equal "2"
    End

    It 'verifies that 0002-i18n-docs points equals 2'
      When call get_points "0002-i18n-docs"
      The output should equal "2"
    End

    It 'verifies that 0003-auto-commit-fix points equals 2'
      When call get_points "0003-auto-commit-fix"
      The output should equal "2"
    End

    It 'verifies that 0004-dashboard-fix points equals 2'
      When call get_points "0004-dashboard-fix"
      The output should equal "2"
    End

    It 'verifies that 0005-workflow-fix points equals 1'
      When call get_points "0005-workflow-fix"
      The output should equal "1"
    End

    It 'verifies that 0006-workflow-boundary points equals 1'
      When call get_points "0006-workflow-boundary"
      The output should equal "1"
    End

    It 'verifies that 0009-board-cleanup points equals 2'
      When call get_points "0009-board-cleanup"
      The output should equal "2"
    End

    It 'verifies that 0015-commit-message-accuracy points equals 2'
      When call get_points "0015-commit-message-accuracy"
      The output should equal "2"
    End

    It 'verifies that 0024-plugin-config-cleanup points equals 2'
      When call get_points "0024-plugin-config-cleanup"
      The output should equal "2"
    End
  End

  Describe 'Post-update Validation: No Invalid Point Values Remain'
    It 'verifies that no entries have points=5'
      When call jq -r 'select(.points == 5) | .story_id' "$backlog_file"
      The output should equal ""
    End

    It 'verifies that no entries have points=10'
      When call jq -r 'select(.points == 10) | .story_id' "$backlog_file"
      The output should equal ""
    End

    It 'verifies that all done stories have points of 1, 2, or 3'
      count_invalid() {
        local result
        result=$(jq -r 'select(.status == "done") | select(.points != 1 and .points != 2 and .points != 3) | .story_id' "$backlog_file" | wc -l | tr -d ' ')
        echo "$result"
      }
      When call count_invalid
      The output should equal "0"
    End

    It 'verifies that 0019-copilot-hooks-fix points remains unchanged at 3'
      When call get_points "0019-copilot-hooks-fix"
      The output should equal "3"
    End
  End
End
