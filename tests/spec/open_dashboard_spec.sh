Describe 'open-dashboard.sh'
  setup() {
    TEST_PROJECT=$(mktemp -d)
    TEST_HEARTBEAT="$TEST_PROJECT/.heartbeat"
    mkdir -p "$TEST_HEARTBEAT"
    # ダッシュボード HTML を作成（存在チェック用）
    echo '<html></html>' > "$TEST_HEARTBEAT/dashboard.html"
    export HEARTBEAT_ROOT="$TEST_PROJECT"
    # worktree ガードを無効化
    unset HEARTBEAT_IN_WORKTREE
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
      # uname をスタブ化して Darwin を返す
      uname() { echo "Darwin"; }
      # open コマンドをスタブ化して引数を記録
      open() { echo "OPEN_CALLED:$*"; }
      When call open_dashboard
      The status should be success
      The output should include "OPEN_CALLED:"
      The output should include ".heartbeat/dashboard.html"
    End
  End
End
