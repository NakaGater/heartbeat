Describe 'acquire_lock() / release_lock() in lib/common.sh'
  # Task 3, CC1: acquire_lock <dir> 呼び出しで <dir> ディレクトリが作成され、
  #              <dir>/pid に現在の PID が記録される
  # Design spec 12: acquire_lock が mkdir ベースでロックを取得し PID を記録する

  setup() {
    TEST_DIR=$(mktemp -d)
    LOCK_DIR="$TEST_DIR/.test-lock"
  }
  cleanup() {
    rm -rf "$TEST_DIR"
  }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'acquire_lock によるロック取得 (CC1)'
    It 'ロックディレクトリが作成され、pid ファイルに現プロセスの PID が記録される'
      acquire_and_check() {
        source ./core/scripts/lib/common.sh
        acquire_lock "$LOCK_DIR"
        local result=$?
        if [ $result -ne 0 ]; then
          echo "ACQUIRE_FAILED"
          return 1
        fi
        if [ ! -d "$LOCK_DIR" ]; then
          echo "NO_LOCK_DIR"
          return 1
        fi
        if [ ! -f "$LOCK_DIR/pid" ]; then
          echo "NO_PID_FILE"
          return 1
        fi
        local recorded_pid
        recorded_pid=$(cat "$LOCK_DIR/pid")
        if [ "$recorded_pid" = "$$" ]; then
          echo "OK"
        else
          echo "PID_MISMATCH:expected=$$,got=$recorded_pid"
          return 1
        fi
      }
      When call acquire_and_check
      The output should equal "OK"
      The status should be success
    End
  End
End
