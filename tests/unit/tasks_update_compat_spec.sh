Describe 'tasks-update.sh 後方互換性'
  SCRIPT="./core/scripts/tasks-update.sh"

  Describe 'parallel_group フィールドなしの tasks.jsonl での正常動作'
    setup_legacy_tasks() {
      TEST_DIR=$(mktemp -d)
      # parallel_group / depends_on フィールドを持たない従来形式の tasks.jsonl
      cat > "$TEST_DIR/tasks.jsonl" <<'JSONL'
{"task_id":1,"name":"タスクA","status":"pending","started":null,"completed":null}
{"task_id":2,"name":"タスクB","status":"pending","started":null,"completed":null}
{"task_id":3,"name":"タスクC","status":"pending","started":null,"completed":null}
JSONL
    }

    cleanup_legacy_tasks() {
      rm -rf "$TEST_DIR"
    }

    BeforeEach 'setup_legacy_tasks'
    AfterEach 'cleanup_legacy_tasks'

    It 'parallel_group がない tasks.jsonl の task_id=1 の status を in_progress に更新できる'
      run_update() {
        bash "$SCRIPT" "$TEST_DIR/tasks.jsonl" 1 status in_progress
        jq -r 'select(.task_id == 1) | .status' "$TEST_DIR/tasks.jsonl"
      }
      When call run_update
      The status should be success
      The output should equal "in_progress"
    End
  End
End
