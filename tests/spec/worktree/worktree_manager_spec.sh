Describe 'worktree-manager.sh'
  # Task 1: worktree-manager.sh (list/remove/merge)
  # CC1: Script exists and is executable
  # CC2: Shows usage and returns exit 1 when called without arguments
  # CC3: list command exits 0 successfully
  # CC4: No external dependencies other than jq

  SCRIPT="./core/scripts/worktree-manager.sh"

  Describe 'Script Existence and Permissions (CC1)'
    It 'verifies that core/scripts/worktree-manager.sh exists'
      Path script="$SCRIPT"
      The path script should be exist
    End

    It 'has execute permission'
      Path script="$SCRIPT"
      The path script should be executable
    End
  End

  Describe 'No-argument Execution (CC2)'
    It 'displays usage to stderr and returns exit 1'
      When run "$SCRIPT"
      The status should equal 1
      The stderr should include "usage"
    End
  End

  Describe 'list Command (CC3)'
    It 'exits 0 successfully'
      When run "$SCRIPT" list
      The status should be success
    End
  End
End
