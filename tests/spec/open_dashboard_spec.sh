Describe 'open-dashboard.sh'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT"
    # ダッシュボード HTML を作成（存在チェック用）
    echo '<html></html>' > "$TEST_HEARTBEAT/dashboard.html"
    export HEARTBEAT_ROOT="$TEST_PROJECT"
    # DASHBOARD 変数を Include 後に再設定（テスト用 tmpdir を反映）
    DASHBOARD="$TEST_PROJECT/.heartbeat/dashboard.html"
    # worktree ガードを無効化
    unset HEARTBEAT_IN_WORKTREE
    # xdg-open スタブ用のディレクトリを PATH に追加
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

  Describe 'macOS 環境での正常系'
    It 'Darwin 環境で open コマンドが .heartbeat/dashboard.html のパスを引数に呼ばれる'
      uname() { echo "Darwin"; }
      open() { echo "OPEN_CALLED:$*"; }
      When call open_dashboard
      The status should be success
      The output should include "OPEN_CALLED:"
      The output should include ".heartbeat/dashboard.html"
    End
  End

  Describe 'Linux 環境での正常系'
    It 'Linux 環境で xdg-open コマンドが .heartbeat/dashboard.html のパスを引数に呼ばれる'
      uname() { echo "Linux"; }
      # xdg-open はハイフン入りのため関数名として使えない場合がある
      # PATH 上にスタブスクリプトを配置してコマンドとしてスタブ化
      printf '#!/bin/sh\necho "XDG_OPEN_CALLED:$*"\n' > "$TEST_BIN/xdg-open"
      chmod +x "$TEST_BIN/xdg-open"
      PATH="$TEST_BIN:$PATH"
      When call open_dashboard
      The status should be success
      The output should include "XDG_OPEN_CALLED:"
      The output should include ".heartbeat/dashboard.html"
    End
  End

  Describe 'エラーハンドリング'
    It 'open コマンドが失敗しても終了コード 0 で返る'
      uname() { echo "Darwin"; }
      open() { return 1; }
      When call open_dashboard
      The status should be success
    End
  End

  Describe '未知の OS'
    It 'uname が Darwin/Linux 以外を返す場合、何も呼ばず終了コード 0 で返る'
      uname() { echo "FreeBSD"; }
      open() { echo "OPEN_CALLED:$*"; }
      When call open_dashboard
      The status should be success
      The output should equal ""
    End
  End

  Describe 'ワークツリーガード'
    It 'HEARTBEAT_IN_WORKTREE=1 の場合、open/xdg-open を呼ばず終了コード 0 で返る'
      export HEARTBEAT_IN_WORKTREE=1
      uname() { echo "Darwin"; }
      open() { echo "OPEN_CALLED:$*"; }
      When call open_dashboard
      The status should be success
      The output should equal ""
    End
  End

  Describe 'ファイル未存在'
    It 'dashboard.html が存在しない場合、open/xdg-open を呼ばず終了コード 0 で返る'
      rm -f "$TEST_HEARTBEAT/dashboard.html"
      uname() { echo "Darwin"; }
      open() { echo "OPEN_CALLED:$*"; }
      When call open_dashboard
      The status should be success
      The output should equal ""
    End
  End
End
