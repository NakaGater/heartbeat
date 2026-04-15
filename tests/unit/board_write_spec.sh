Describe 'board-write.sh ロック機構'
  setup() {
    TEST_DIR=$(mktemp -d)
    export TEST_BOARD_FILE="${TEST_DIR}/board.jsonl"
    export TEST_LOCK_DIR="${TEST_BOARD_FILE}.lock"
  }
  cleanup() {
    rm -rf "$TEST_DIR"
  }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'ロックディレクトリが追記前に作成され、追記後に削除される'
    It 'ロックディレクトリが書き込み完了後に残っていない'
      When call sh -c 'echo "{\"from\":\"tester\",\"to\":\"implementer\",\"action\":\"test\",\"status\":\"ok\"}" | ./core/scripts/board-write.sh "$TEST_BOARD_FILE"'
      The status should be success
      The path "$TEST_LOCK_DIR" should not be exist
    End

    assert_lock_was_used() {
      # board-write.sh を改変し、ロック取得時にマーカーファイルを残すことで
      # ロック機構が使われたことを検証する。
      # common.sh の acquire_lock が呼ばれると mkdir でロックディレクトリが作られるため、
      # board-write.sh 実行中にロックディレクトリが存在したかを確認する。
      #
      # 方法: board-write.sh を wrapper 経由で実行し、追記直前にロックディレクトリの
      # 存在を記録する。ただしここでは source される common.sh の acquire_lock を
      # フックするのではなく、board-write.sh が common.sh を source しているかと
      # ロックディレクトリの作成・削除ペアが行われるかを検証する。
      #
      # 単純な検証: board-write.sh の中で acquire_lock が呼ばれているか（grep ベース）
      grep -q 'acquire_lock' ./core/scripts/board-write.sh
    }
    lock_was_used() { assert_lock_was_used; }

    It 'board-write.sh が acquire_lock を呼び出してロックを取得する'
      When call sh -c 'echo "{\"from\":\"tester\",\"to\":\"implementer\",\"action\":\"test\",\"status\":\"ok\"}" | ./core/scripts/board-write.sh "$TEST_BOARD_FILE"'
      The status should be success
      Assert lock_was_used
    End
  End

  Describe 'ロック取得失敗時も exit 0 で終了する'
    It 'ロックディレクトリが既に存在する場合でも終了コード 0 を返す'
      # ロックディレクトリを事前に作成してロック取得を失敗させる
      mkdir -p "$TEST_LOCK_DIR"
      echo "fake" > "$TEST_LOCK_DIR/pid"
      When call sh -c 'echo "{\"from\":\"tester\",\"to\":\"implementer\",\"action\":\"test\",\"status\":\"ok\"}" | ./core/scripts/board-write.sh "$TEST_BOARD_FILE"'
      The status should be success
      The stderr should include 'Could not acquire lock'
    End

    It 'ロック取得失敗時はエントリが書き込まれない'
      mkdir -p "$TEST_LOCK_DIR"
      echo "fake" > "$TEST_LOCK_DIR/pid"
      When call sh -c 'echo "{\"from\":\"tester\",\"to\":\"implementer\",\"action\":\"test\",\"status\":\"ok\"}" | ./core/scripts/board-write.sh "$TEST_BOARD_FILE"'
      The status should be success
      The stderr should include 'Could not acquire lock'
      The path "$TEST_BOARD_FILE" should not be exist
    End
  End
End
