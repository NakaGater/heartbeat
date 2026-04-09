Describe 'worktree-manager.sh'
  # Task 1: worktree-manager.sh (list/remove/merge)
  # CC1: スクリプトが存在し実行可能であること
  # CC2: 引数なしで使い方を表示しexit 1を返すこと
  # CC3: listコマンドがexit 0で正常終了すること
  # CC4: jq以外の外部依存がないこと

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
