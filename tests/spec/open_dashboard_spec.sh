Describe 'open-dashboard.sh'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT"
    # Create dashboard HTML for existence check
    echo '<html></html>' > "$TEST_HEARTBEAT/dashboard.html"
    export HEARTBEAT_ROOT="$TEST_PROJECT"
    # Re-set DASHBOARD variable after Include to reflect test tmpdir
    DASHBOARD="$TEST_PROJECT/.heartbeat/dashboard.html"
    # Disable worktree guard
    unset HEARTBEAT_IN_WORKTREE
    # Add stub directory for xdg-open to PATH
    TEST_BIN="$TEST_PROJECT/bin"
    mkdir -p "$TEST_BIN"
  }
  cleanup() {
    rm -rf "$TEST_PROJECT"
    unset HEARTBEAT_ROOT HEARTBEAT_IN_WORKTREE
  }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  Include ./core/scripts/open-dashboard.sh

  Describe 'Happy path on macOS'
    It 'calls open command with .heartbeat/dashboard.html path on Darwin'
      uname() { echo "Darwin"; }
      open() { echo "OPEN_CALLED:$*"; }
      When call open_dashboard
      The status should be success
      The output should include "OPEN_CALLED:"
      The output should include ".heartbeat/dashboard.html"
    End
  End

  Describe 'Happy path on Linux'
    It 'calls xdg-open command with .heartbeat/dashboard.html path on Linux'
      uname() { echo "Linux"; }
      # xdg-open contains a hyphen so cannot be used as a function name
      # Place a stub script on PATH to mock it as a command
      printf '#!/bin/sh\necho "XDG_OPEN_CALLED:$*"\n' > "$TEST_BIN/xdg-open"
      chmod +x "$TEST_BIN/xdg-open"
      PATH="$TEST_BIN:$PATH"
      When call open_dashboard
      The status should be success
      The output should include "XDG_OPEN_CALLED:"
      The output should include ".heartbeat/dashboard.html"
    End
  End

  Describe 'Error handling'
    It 'returns exit code 0 even when open command fails'
      uname() { echo "Darwin"; }
      open() { return 1; }
      When call open_dashboard
      The status should be success
    End
  End

  Describe 'Unknown OS'
    It 'returns exit code 0 without calling any open command when uname returns unknown OS'
      uname() { echo "FreeBSD"; }
      open() { echo "OPEN_CALLED:$*"; }
      When call open_dashboard
      The status should be success
      The output should equal ""
    End
  End

  Describe 'Worktree guard'
    It 'returns exit code 0 without calling open/xdg-open when HEARTBEAT_IN_WORKTREE=1'
      export HEARTBEAT_IN_WORKTREE=1
      uname() { echo "Darwin"; }
      open() { echo "OPEN_CALLED:$*"; }
      When call open_dashboard
      The status should be success
      The output should equal ""
    End
  End

  Describe 'File not found'
    It 'returns exit code 0 without calling open/xdg-open when dashboard.html does not exist'
      rm -f "$TEST_HEARTBEAT/dashboard.html"
      uname() { echo "Darwin"; }
      open() { echo "OPEN_CALLED:$*"; }
      When call open_dashboard
      The status should be success
      The output should equal ""
    End
  End
End
