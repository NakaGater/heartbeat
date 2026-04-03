PROTOCOL_MD="core/xp/board-protocol.md"

check_protocol_references_board_write_sh() {
  grep -q "board-write\.sh" "$PROTOCOL_MD"
}

check_protocol_instructs_pipe_invocation() {
  # board-write.sh のパイプ呼び出し例が記載されていること
  grep -q "board-write\.sh" "$PROTOCOL_MD" &&
  grep -q "board\.jsonl" "$PROTOCOL_MD"
}

Describe 'board-protocol.md が board-write.sh 経由の書き込みを指示している'
  It 'board-protocol.md が board-write.sh を参照している'
    When call check_protocol_references_board_write_sh
    The status should be success
  End

  It 'board-protocol.md が board-write.sh のパイプ呼び出しパターンを含む'
    When call check_protocol_instructs_pipe_invocation
    The status should be success
  End
End
