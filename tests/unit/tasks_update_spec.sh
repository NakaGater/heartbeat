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

  Describe 'started フィールドの更新'
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

    It 'task_id=1 の started を ISO8601 タイムスタンプに更新する'
      run_update() {
        bash "$SCRIPT" "$TASKS_FILE" 1 started "2026-04-15T10:30:00Z"
        jq -r 'select(.task_id == 1) | .started' "$TASKS_FILE"
      }
      When call run_update
      The output should equal "2026-04-15T10:30:00Z"
    End
  End
End
