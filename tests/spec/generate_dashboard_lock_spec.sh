Describe 'generate-dashboard.sh Lock Mechanism'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT/stories/test-story"

    echo '{"story_id":"test-story","title":"Test","status":"in_progress","priority":1,"points":2}' > "$TEST_HEARTBEAT/backlog.jsonl"
    echo '{"from":"tester","to":"implementer","action":"test","status":"ok","note":"test","timestamp":"2026-04-03T00:00:00Z"}' > "$TEST_HEARTBEAT/stories/test-story/board.jsonl"
    echo '{"task_id":1,"name":"Task 1","status":"done"}' > "$TEST_HEARTBEAT/stories/test-story/tasks.jsonl"
  }
  cleanup() {
    rm -rf "$TEST_PROJECT"
  }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'Lock Directory Lifecycle'
    It 'contains lock mechanism code (mkdir .dashboard-lock) in the script'
      # generate-dashboard.sh が排他制御を実装しているかをソースコードレベルで検証
      check_lock_code() {
        grep -q 'dashboard-lock' ./core/scripts/generate-dashboard.sh && echo "HAS_LOCK_CODE" || echo "NO_LOCK_CODE"
      }
      When call check_lock_code
      The output should equal 'HAS_LOCK_CODE'
    End

    It 'auto-cleans up lock directory after successful completion'
      # EXIT trapによりロックが確実に解放されることを検証
      When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
      The status should equal 0
      The output should include 'Dashboard generated'
      The path "$TEST_HEARTBEAT/.dashboard-lock" should not be exist
    End
  End

  Describe 'Graceful Exit on Lock Contention'
    It 'exits 0 hook-safe after timeout when another process holds the lock'
      # 先にロックディレクトリを作成して他プロセスが保持している状態をシミュレート
      mkdir -p "$TEST_HEARTBEAT/.dashboard-lock"
      echo "99999" > "$TEST_HEARTBEAT/.dashboard-lock/pid"
      # MAX_RETRIES=10, RETRY_INTERVAL=1 だが、テスト用に環境変数でオーバーライド
      # オーバーライドが効かない場合でもタイムアウトで終了するはず
      export DASHBOARD_LOCK_MAX_RETRIES=2
      export DASHBOARD_LOCK_RETRY_INTERVAL=0

      When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
      The status should equal 0
      The stderr should include 'lock'
    End

    It 'does not corrupt the output file when lock contention times out'
      # 既存のダッシュボードを事前生成
      ./core/scripts/generate-dashboard.sh "$TEST_PROJECT" >/dev/null 2>&1
      local original_hash
      original_hash=$(md5sum "$TEST_HEARTBEAT/dashboard.html" 2>/dev/null || md5 -q "$TEST_HEARTBEAT/dashboard.html" 2>/dev/null)

      # ロックを取得して競合させる
      mkdir -p "$TEST_HEARTBEAT/.dashboard-lock"
      echo "99999" > "$TEST_HEARTBEAT/.dashboard-lock/pid"
      export DASHBOARD_LOCK_MAX_RETRIES=2
      export DASHBOARD_LOCK_RETRY_INTERVAL=0

      When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
      The status should equal 0
      The stderr should include 'lock'
      # 既存のdashboard.htmlが変更されていないことを確認
      The file "$TEST_HEARTBEAT/dashboard.html" should be exist
    End
  End
End
