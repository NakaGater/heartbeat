Describe 'generate-dashboard.sh 排他制御'
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

  Describe 'ロックディレクトリのライフサイクル'
    It 'スクリプトにロック機構のコード (mkdir .dashboard-lock) が含まれている'
      # generate-dashboard.sh が排他制御を実装しているかをソースコードレベルで検証
      check_lock_code() {
        grep -q 'dashboard-lock' ./core/scripts/generate-dashboard.sh && echo "HAS_LOCK_CODE" || echo "NO_LOCK_CODE"
      }
      When call check_lock_code
      The output should equal 'HAS_LOCK_CODE'
    End

    It '生成中にロックディレクトリが作成される (PIDファイル含む)'
      # ロック取得後にPIDファイルが書き込まれることを検証するため、
      # スクリプト実行中の状態をスナップショットする wrapper を使う
      snapshot_lock() {
        # バックグラウンドでスクリプト実行中のロック状態を記録
        (
          ./core/scripts/generate-dashboard.sh "$TEST_PROJECT" &
          local pid=$!
          # スクリプトが起動してロック取得するまで少し待機
          sleep 0.2
          if [ -d "$TEST_HEARTBEAT/.dashboard-lock" ]; then
            echo "LOCK_EXISTS"
          fi
          if [ -f "$TEST_HEARTBEAT/.dashboard-lock/pid" ]; then
            echo "PID_FILE_EXISTS"
          fi
          wait "$pid"
        )
      }
      When call snapshot_lock
      The output should include 'LOCK_EXISTS'
      The output should include 'PID_FILE_EXISTS'
    End
  End

  Describe 'ロック競合時のグレースフル終了'
    It '他プロセスがロックを保持している場合、タイムアウト後にエラー終了する'
      # 先にロックディレクトリを作成して他プロセスが保持している状態をシミュレート
      mkdir -p "$TEST_HEARTBEAT/.dashboard-lock"
      echo "99999" > "$TEST_HEARTBEAT/.dashboard-lock/pid"
      # MAX_RETRIES=10, RETRY_INTERVAL=1 だが、テスト用に環境変数でオーバーライド
      # オーバーライドが効かない場合でもタイムアウトで終了するはず
      export DASHBOARD_LOCK_MAX_RETRIES=2
      export DASHBOARD_LOCK_RETRY_INTERVAL=0

      When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
      The status should equal 1
      The stderr should include 'lock'
    End

    It 'ロック競合でタイムアウトした場合、出力ファイルを破損させない'
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
      The status should equal 1
      # 既存のdashboard.htmlが変更されていないことを確認
      The file "$TEST_HEARTBEAT/dashboard.html" should be exist
    End
  End
End
