Describe 'acquire_lock() / release_lock() in lib/common.sh'
  # Task 3, CC1: acquire_lock <dir> creates the <dir> directory and
  #              records the current PID in <dir>/pid
  # Design spec 12: acquire_lock acquires lock via mkdir and records PID

  setup() {
    TEST_DIR=$(mktemp -d)
    LOCK_DIR="$TEST_DIR/.test-lock"
  }
  cleanup() {
    rm -rf "$TEST_DIR"
  }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'Lock Acquisition via acquire_lock (CC1)'
    It 'creates a lock directory and records current process PID in pid file'
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

  # Task 3, CC2: release_lock deletes the lock only when PID matches
  # Does not delete if another process PID is recorded
  # Design spec 13
  Describe 'PID Matching in release_lock (CC2)'
    It 'removes lock directory when current process PID is recorded'
      release_own_lock() {
        source ./core/scripts/lib/common.sh
        mkdir -p "$LOCK_DIR"
        echo "$$" > "$LOCK_DIR/pid"
        release_lock "$LOCK_DIR"
        if [ -d "$LOCK_DIR" ]; then
          echo "NOT_REMOVED"
        else
          echo "REMOVED"
        fi
      }
      When call release_own_lock
      The output should equal "REMOVED"
      The status should be success
    End

    It 'does not remove lock directory when another process PID is recorded'
      release_other_lock() {
        source ./core/scripts/lib/common.sh
        mkdir -p "$LOCK_DIR"
        echo "99999" > "$LOCK_DIR/pid"
        release_lock "$LOCK_DIR"
        if [ -d "$LOCK_DIR" ]; then
          echo "KEPT"
        else
          echo "REMOVED"
        fi
      }
      When call release_other_lock
      The output should equal "KEPT"
      The status should be success
    End
  End

  # Task 3, CC3: acquire_lock fails after retries (return 1)
  # Design spec 14
  Describe 'acquire_lock Retry and Failure (CC3)'
    It 'exits non-zero after retries when lock is already held'
      acquire_with_existing_lock() {
        source ./core/scripts/lib/common.sh
        # Simulate another process holding the lock
        mkdir -p "$LOCK_DIR"
        echo "99999" > "$LOCK_DIR/pid"
        # Minimize retry count for faster execution
        acquire_lock "$LOCK_DIR" 2 0
        return $?
      }
      When call acquire_with_existing_lock
      The status should be failure
      The stderr should be present
    End
  End

  # Task 3, CC4: Stale lock detection (removal of old locks via find -mmin)
  # Design spec 15
  Describe 'Stale Lock Detection (CC4)'
    It 'removes stale lock older than 1 minute and acquires successfully'
      acquire_with_stale_lock() {
        source ./core/scripts/lib/common.sh
        # Create a stale lock
        mkdir -p "$LOCK_DIR"
        echo "99999" > "$LOCK_DIR/pid"
        # Set timestamp to 2 minutes ago to make it stale
        touch -t "$(date -v-2M '+%Y%m%d%H%M.%S' 2>/dev/null || date -d '2 minutes ago' '+%Y%m%d%H%M.%S' 2>/dev/null)" "$LOCK_DIR"
        acquire_lock "$LOCK_DIR" 1 0
        local result=$?
        if [ $result -eq 0 ] && [ -f "$LOCK_DIR/pid" ]; then
          local recorded_pid
          recorded_pid=$(cat "$LOCK_DIR/pid")
          if [ "$recorded_pid" = "$$" ]; then
            echo "STALE_CLEANED_AND_ACQUIRED"
          else
            echo "PID_MISMATCH"
          fi
        else
          echo "ACQUIRE_FAILED"
        fi
      }
      When call acquire_with_stale_lock
      The output should equal "STALE_CLEANED_AND_ACQUIRED"
      The status should be success
    End
  End
End
