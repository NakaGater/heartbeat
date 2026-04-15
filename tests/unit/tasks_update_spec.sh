Describe 'tasks-update.sh'
  SCRIPT="./core/scripts/tasks-update.sh"

  Describe 'status フィールドの更新'
    setup_tasks() {
      TEST_DIR=$(mktemp -d)
      TASKS_FILE="${TEST_DIR}/tasks.jsonl"
      cat > "$TASKS_FILE" <<'JSONL'
{"task_id":1,"name":"タスク1","status":"pending","started":null,"completed":null}
{"task_id":2,"name":"タスク2","status":"pending","started":null,"completed":null}
JSONL
    }

    cleanup_tasks() {
      rm -rf "$TEST_DIR"
    }

    BeforeEach 'setup_tasks'
    AfterEach 'cleanup_tasks'

    It 'task_id=1 の status を in_progress に更新する'
      run_update() {
        bash "$SCRIPT" "$TASKS_FILE" 1 status in_progress
        jq -r 'select(.task_id == 1) | .status' "$TASKS_FILE"
      }
      When call run_update
      The output should equal "in_progress"
    End
  End
End
