Describe 'tasks-update.sh 後方互換性'
  SCRIPT="./core/scripts/tasks-update.sh"

  Describe 'parallel_group フィールドなしの tasks.jsonl での正常動作'
    setup() {
      TEST_DIR=$(mktemp -d)
      TASKS_FILE="${TEST_DIR}/tasks.jsonl"
      # parallel_group / depends_on フィールドを持たない従来形式の tasks.jsonl
      cat > "$TASKS_FILE" <<'JSONL'
{"task_id":1,"name":"タスクA","status":"pending","started":null,"completed":null}
{"task_id":2,"name":"タスクB","status":"pending","started":null,"completed":null}
{"task_id":3,"name":"タスクC","status":"pending","started":null,"completed":null}
JSONL
    }

    cleanup() {
      rm -rf "$TEST_DIR"
    }

    BeforeEach 'setup'
    AfterEach 'cleanup'

    It 'parallel_group がない tasks.jsonl の task_id=1 の status を in_progress に更新できる'
      run_update() {
        bash "$SCRIPT" "$TASKS_FILE" 1 status in_progress
        jq -r 'select(.task_id == 1) | .status' "$TASKS_FILE"
      }
      When call run_update
      The status should be success
      The output should equal "in_progress"
    End

    It '更新対象以外のタスクが変更されない'
      run_update_check_others() {
        bash "$SCRIPT" "$TASKS_FILE" 1 status in_progress
        jq -r 'select(.task_id == 2) | .status' "$TASKS_FILE"
      }
      When call run_update_check_others
      The status should be success
      The output should equal "pending"
    End
  End
End
