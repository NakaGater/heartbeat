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

check_persona_auto_injected_note() {
  for agent in core/agent-personas/*.md; do
    if ! grep -q 'auto-injected by hook' "$agent"; then
      echo "FAIL: $agent missing auto-injected by hook note" >&2
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

  It 'all persona files contain auto-injected by hook note'
    When call check_persona_auto_injected_note
    The status should be success
  End
End
