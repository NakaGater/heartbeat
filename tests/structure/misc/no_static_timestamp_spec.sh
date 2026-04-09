check_no_static_timestamp_in_personas() {
  for agent in core/agent-personas/*.md; do
    if grep -q '2026-01-01T00:00:00Z' "$agent"; then
      echo "FAIL: $agent contains static placeholder 2026-01-01T00:00:00Z" >&2
      return 1
    fi
  done
}

check_persona_timestamp_field_reference() {
  for agent in core/agent-personas/*.md; do
    if ! grep -q '"timestamp"' "$agent"; then
      echo "FAIL: $agent missing timestamp field reference" >&2
      return 1
    fi
  done
}

check_persona_timestamp_instruction() {
  for agent in core/agent-personas/*.md; do
    if ! grep -q 'agent writes current time\|auto-injected by hook' "$agent"; then
      echo "FAIL: $agent missing timestamp instruction" >&2
      return 1
    fi
  done
}

Describe 'No static timestamp placeholder in persona files'
  It 'no persona file contains 2026-01-01T00:00:00Z'
    When call check_no_static_timestamp_in_personas
    The status should be success
  End

  It 'all persona files still reference timestamp field'
    When call check_persona_timestamp_field_reference
    The status should be success
  End

  It 'all persona files contain timestamp instruction'
    When call check_persona_timestamp_instruction
    The status should be success
  End
End

check_board_protocol_auto_injection_docs() {
  if ! grep -q 'auto-injected\|auto-injection\|board-stamp\.sh' "core/xp/board-protocol.md"; then
    echo "FAIL: board-protocol.md missing documentation about auto-injection of timestamps" >&2
    return 1
  fi
}

check_no_static_timestamp_in_board_protocol() {
  if grep -q '2026-01-01T00:00:00Z' "core/xp/board-protocol.md"; then
    echo "FAIL: board-protocol.md contains static placeholder 2026-01-01T00:00:00Z" >&2
    return 1
  fi
}

check_no_static_timestamp_in_skills() {
  for skill in adapters/*/skills/heartbeat/SKILL.md; do
    if grep -q '2026-01-01T00:00:00Z' "$skill"; then
      echo "FAIL: $skill contains static placeholder 2026-01-01T00:00:00Z" >&2
      return 1
    fi
  done
}

check_skill_timestamp_instruction() {
  for skill in adapters/*/skills/heartbeat/SKILL.md; do
    if ! grep -q 'agent MUST write\|auto-injected by.*hook' "$skill"; then
      echo "FAIL: $skill missing timestamp instruction" >&2
      return 1
    fi
  done
}

Describe 'Documentation and SKILL.md timestamp updates (Task 5)'
  It 'board-protocol.md contains auto-injection documentation'
    When call check_board_protocol_auto_injection_docs
    The status should be success
  End

  It 'board-protocol.md does not contain static placeholder 2026-01-01T00:00:00Z'
    When call check_no_static_timestamp_in_board_protocol
    The status should be success
  End

  It 'no SKILL.md file contains 2026-01-01T00:00:00Z'
    When call check_no_static_timestamp_in_skills
    The status should be success
  End

  It 'all SKILL.md files contain timestamp instruction'
    When call check_skill_timestamp_instruction
    The status should be success
  End
End
