# Structure test: board protocol documentation references
# Consolidated from:
#   board_protocol_write_sh_spec.sh (2 It)
#   board_write_example_spec.sh (3 It)
#   persona_board_write_sh_spec.sh (2 It)
# Story: 0042-test-cleanup, Task 5 (AC-4)

Describe 'Board protocol documentation references'
  # Shared file paths
  PROTOCOL_MD="core/xp/board-protocol.md"

  # --- board-protocol.md references board-write.sh (2 It) ---

  check_protocol_references_board_write_sh() {
    grep -q "board-write\.sh" "$PROTOCOL_MD"
  }

  check_protocol_instructs_pipe_invocation() {
    # Verify board-write.sh pipe invocation example is documented
    grep -q "board-write\.sh" "$PROTOCOL_MD" &&
    grep -q "board\.jsonl" "$PROTOCOL_MD"
  }

  It 'board-protocol.md references board-write.sh'
    When call check_protocol_references_board_write_sh
    The status should be success
  End

  It 'board-protocol.md contains board-write.sh pipe invocation pattern'
    When call check_protocol_instructs_pipe_invocation
    The status should be success
  End

  # --- Board write examples in personas (3 It) ---

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

  # --- Persona and SKILL.md reference board-write.sh (2 It) ---

  check_persona_references_board_write_sh() {
    for agent in core/agent-personas/*.md; do
      grep -q "board-write\.sh" "$agent" || return 1
    done
  }

  check_skill_references_board_write_sh() {
    skill="core/skills/heartbeat/SKILL.md"
    grep -q "board-write\.sh" "$skill" || return 1
  }

  It 'all 9 personas instruct board-write.sh for writing'
    When call check_persona_references_board_write_sh
    The status should be success
  End

  It 'heartbeat SKILL.md references board-write.sh'
    When call check_skill_references_board_write_sh
    The status should be success
  End
End
