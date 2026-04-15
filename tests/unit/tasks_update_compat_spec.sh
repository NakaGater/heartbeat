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

  Describe 'parallel_group フィールドありの tasks.jsonl での正常動作'
    setup() {
      TEST_DIR=$(mktemp -d)
      TASKS_FILE="${TEST_DIR}/tasks.jsonl"
      # parallel_group フィールドを含む tasks.jsonl
      cat > "$TASKS_FILE" <<'JSONL'
{"task_id":1,"name":"タスクA","status":"pending","parallel_group":"group-alpha","started":null,"completed":null}
{"task_id":2,"name":"タスクB","status":"pending","parallel_group":"group-alpha","started":null,"completed":null}
{"task_id":3,"name":"タスクC","status":"pending","parallel_group":"group-beta","started":null,"completed":null}
JSONL
    }

    cleanup() {
      rm -rf "$TEST_DIR"
    }

    BeforeEach 'setup'
    AfterEach 'cleanup'

    It 'parallel_group がある tasks.jsonl の task_id=1 の status を in_progress に更新できる'
      run_update() {
        bash "$SCRIPT" "$TASKS_FILE" 1 status in_progress
        jq -r 'select(.task_id == 1) | .status' "$TASKS_FILE"
      }
      When call run_update
      The status should be success
      The output should equal "in_progress"
    End

    It 'status 更新後も parallel_group フィールドが保持される'
      run_update_check_parallel_group() {
        bash "$SCRIPT" "$TASKS_FILE" 1 status in_progress
        jq -r 'select(.task_id == 1) | .parallel_group' "$TASKS_FILE"
      }
      When call run_update_check_parallel_group
      The status should be success
      The output should equal "group-alpha"
    End

    It '更新対象以外のタスクの parallel_group が変更されない'
      run_update_check_others_pg() {
        bash "$SCRIPT" "$TASKS_FILE" 1 status in_progress
        jq -r 'select(.task_id == 3) | .parallel_group' "$TASKS_FILE"
      }
      When call run_update_check_others_pg
      The status should be success
      The output should equal "group-beta"
    End
  End

  Describe 'depends_on フィールドありの tasks.jsonl での正常動作'
    setup() {
      TEST_DIR=$(mktemp -d)
      TASKS_FILE="${TEST_DIR}/tasks.jsonl"
      # depends_on フィールドを含む tasks.jsonl
      cat > "$TASKS_FILE" <<'JSONL'
{"task_id":1,"name":"タスクA","status":"pending","depends_on":[],"started":null,"completed":null}
{"task_id":2,"name":"タスクB","status":"pending","depends_on":[1],"started":null,"completed":null}
{"task_id":3,"name":"タスクC","status":"pending","depends_on":[1,2],"started":null,"completed":null}
JSONL
    }

    cleanup() {
      rm -rf "$TEST_DIR"
    }

    BeforeEach 'setup'
    AfterEach 'cleanup'

    It 'depends_on がある tasks.jsonl の task_id=2 の status を in_progress に更新できる'
      run_update() {
        bash "$SCRIPT" "$TASKS_FILE" 2 status in_progress
        jq -r 'select(.task_id == 2) | .status' "$TASKS_FILE"
      }
      When call run_update
      The status should be success
      The output should equal "in_progress"
    End

    It 'status 更新後も depends_on フィールドが保持される'
      run_update_check_depends_on() {
        bash "$SCRIPT" "$TASKS_FILE" 2 status in_progress
        jq -c 'select(.task_id == 2) | .depends_on' "$TASKS_FILE"
      }
      When call run_update_check_depends_on
      The status should be success
      The output should equal "[1]"
    End

    It '更新対象以外のタスクの depends_on が変更されない'
      run_update_check_others_dep() {
        bash "$SCRIPT" "$TASKS_FILE" 2 status in_progress
        jq -c 'select(.task_id == 3) | .depends_on' "$TASKS_FILE"
      }
      When call run_update_check_others_dep
      The status should be success
      The output should equal "[1,2]"
    End
  End
End
