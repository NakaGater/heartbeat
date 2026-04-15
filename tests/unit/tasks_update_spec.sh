Describe 'tasks-update.sh'
  SCRIPT="./core/scripts/tasks-update.sh"

  # 共通ヘルパー: 2行 JSONL のセットアップ
  setup_standard_tasks() {
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

  Describe 'status フィールドの更新'
    BeforeEach 'setup_standard_tasks'
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

  Describe '存在しない task_id を指定した場合'
    BeforeEach 'setup_standard_tasks'
    AfterEach 'cleanup_tasks'

    It 'エラーメッセージを stderr に出力し exit 1 で終了する'
      When run bash "$SCRIPT" "$TASKS_FILE" 999 status in_progress
      The status should equal 1
      The stderr should include "task_id 999 not found"
    End
  End

  Describe '引数が不足している場合'
    It '使用方法を stderr に出力し exit 1 で終了する'
      When run bash "$SCRIPT"
      The status should equal 1
      The stderr should include "usage:"
    End
  End

  Describe 'ロック取得のリトライ'
    setup_locked_tasks() {
      setup_standard_tasks
      # 先にロックディレクトリを作成して別プロセスがロックを保持している状態を模擬
      mkdir -p "${TASKS_FILE}.lock"
      echo 99999 > "${TASKS_FILE}.lock/pid"
      # 1秒後にロックを解放するバックグラウンドプロセス
      (sleep 1 && rm -rf "${TASKS_FILE}.lock") &
      BG_PID=$!
    }

    cleanup_locked_tasks() {
      kill "$BG_PID" 2>/dev/null || true
      cleanup_tasks
    }

    BeforeEach 'setup_locked_tasks'
    AfterEach 'cleanup_locked_tasks'

    It 'リトライ後にロックを取得して更新に成功する'
      run_update() {
        bash "$SCRIPT" "$TASKS_FILE" 1 status in_progress
        jq -r 'select(.task_id == 1) | .status' "$TASKS_FILE"
      }
      When call run_update
      The output should equal "in_progress"
    End
  End

  Describe '不正な JSON ファイルを指定した場合'
    setup_invalid_tasks() {
      TEST_DIR=$(mktemp -d)
      TASKS_FILE="${TEST_DIR}/tasks.jsonl"
      echo "this is not json at all" > "$TASKS_FILE"
    }

    BeforeEach 'setup_invalid_tasks'
    AfterEach 'cleanup_tasks'

    It 'エラーメッセージを出力し exit 1 で終了する'
      When run bash "$SCRIPT" "$TASKS_FILE" 1 status in_progress
      The status should equal 1
      The stderr should be present
    End
  End

  Describe 'started フィールドの更新'
    BeforeEach 'setup_standard_tasks'
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
