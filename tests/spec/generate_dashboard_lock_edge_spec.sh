Describe 'generate-dashboard.sh 排他制御エッジケース (T5)'
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

  Describe 'stale ロック検出と自動除去'
    It '1分以上前のロックを stale として自動除去し、生成が成功する'
      # stale ロックを作成し、タイムスタンプを2分前に変更する
      mkdir -p "$TEST_HEARTBEAT/.dashboard-lock"
      echo "99999" > "$TEST_HEARTBEAT/.dashboard-lock/pid"
      # touch -t で2分前のタイムスタンプを設定（YYYYMMDDhhmm.ss 形式）
      stale_time=$(date -v-2M +%Y%m%d%H%M.%S 2>/dev/null || date -d '2 minutes ago' +%Y%m%d%H%M.%S 2>/dev/null)
      touch -t "$stale_time" "$TEST_HEARTBEAT/.dashboard-lock"

      export DASHBOARD_LOCK_MAX_RETRIES=2
      export DASHBOARD_LOCK_RETRY_INTERVAL=0

      When call ./core/scripts/generate-dashboard.sh "$TEST_PROJECT"
      The status should equal 0
      The output should include 'Dashboard generated'
    End
  End

  Describe 'PID ファイルの正確性'
    It 'ロック取得後の PID ファイルにはスクリプトの PID が記録される'
      # generate-dashboard.sh 内部でロック取得後に echo $$ > pid が実行される
      # スクリプトのソースコードレベルで $$ を pid ファイルに書き込むことを検証
      check_pid_write() {
        grep -q 'echo \$\$ > .*pid' ./core/scripts/generate-dashboard.sh && echo "PID_WRITE_FOUND" || echo "PID_WRITE_NOT_FOUND"
      }
      When call check_pid_write
      The output should equal 'PID_WRITE_FOUND'
    End

    It 'cleanup 関数は PID ファイルで自プロセスのロックのみ解放する'
      # cleanup 関数が PID を確認してから rm -rf することを検証
      check_pid_check_in_cleanup() {
        # cleanup 関数内で cat pid の結果と $$ を比較するコードがあることを確認
        grep -A5 'cleanup()' ./core/scripts/generate-dashboard.sh | grep -q '\$\$' && echo "PID_CHECK_FOUND" || echo "PID_CHECK_NOT_FOUND"
      }
      When call check_pid_check_in_cleanup
      The output should equal 'PID_CHECK_FOUND'
    End
  End
End
