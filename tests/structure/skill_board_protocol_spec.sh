SKILL_MD="adapters/claude-code/skills/heartbeat/SKILL.md"

check_skill_board_required_fields() {
  grep -q "from" "$SKILL_MD" &&
  grep -q "to" "$SKILL_MD" &&
  grep -q "action" "$SKILL_MD" &&
  grep -q "output" "$SKILL_MD" &&
  grep -q "status" "$SKILL_MD" &&
  grep -q "note" "$SKILL_MD" &&
  grep -q "timestamp" "$SKILL_MD"
}

check_skill_board_timestamp_required() {
  grep -q "timestamp" "$SKILL_MD" &&
  grep -q "ISO 8601" "$SKILL_MD"
}

check_skill_board_note_language_rule() {
  grep -q "output-language-rule\|language.*note\|note.*language" "$SKILL_MD"
}

Describe 'SKILL.md board.jsonl protocol'
  It 'SKILL.md contains all required board.jsonl fields'
    When call check_skill_board_required_fields
    The status should be success
  End

  It 'SKILL.md specifies timestamp as ISO 8601'
    When call check_skill_board_timestamp_required
    The status should be success
  End

  It 'SKILL.md specifies language rule for note field'
    When call check_skill_board_note_language_rule
    The status should be success
  End
End
