Describe 'worktree-manager.sh'
  # Task 1: worktree-manager.sh (list/remove/merge)
  # CC1: スクリプトが存在し実行可能であること
  # CC2: 引数なしで使い方を表示しexit 1を返すこと
  # CC3: listコマンドがexit 0で正常終了すること
  # CC4: jq以外の外部依存がないこと

  SCRIPT="./core/scripts/worktree-manager.sh"

  Describe 'スクリプトの存在と実行権限 (CC1)'
    It 'core/scripts/worktree-manager.sh が存在する'
      Path script="$SCRIPT"
      The path script should be exist
    End

    It '実行権限がある'
      Path script="$SCRIPT"
      The path script should be executable
    End
  End

  Describe '引数なし実行 (CC2)'
    It '使い方をstderrに表示しexit 1を返す'
      When run "$SCRIPT"
      The status should equal 1
      The stderr should include "usage"
    End
  End

  Describe 'list コマンド (CC3)'
    It 'exit 0で正常終了する'
      When run "$SCRIPT" list
      The status should be success
    End
  End
End
