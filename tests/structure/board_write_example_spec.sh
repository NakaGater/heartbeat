check_persona_board_write_example() {
  for agent in core/agent-personas/*.md; do
    grep -q "board.jsonl" "$agent" || return 1
    # Check for a concrete write example with JSON-like structure
    grep -q '"from"' "$agent" || return 1
  done
}

check_persona_board_timestamp() {
  for agent in core/agent-personas/*.md; do
    grep -q '"timestamp"' "$agent" || return 1
  done
}

check_persona_board_language_rule() {
  for agent in core/agent-personas/*.md; do
    grep -A 50 "Board Protocol Rules" "$agent" | grep -q "output-language-rule" || return 1
  done
}

Describe 'Board Protocol write examples in personas'
  It 'all personas have board.jsonl write example with from field'
    When call check_persona_board_write_example
    The status should be success
  End

  It 'all personas have timestamp in board.jsonl write example'
    When call check_persona_board_timestamp
    The status should be success
  End

  It 'all personas reference output-language-rule in Board Protocol Rules'
    When call check_persona_board_language_rule
    The status should be success
  End
End
