# Tests for handoff-protocol.md nested loop structure (tdd-workflow story)

HANDOFF_PROTOCOL="core/xp/handoff-protocol.md"

check_nested_loop_structure() {
  grep -q "outer loop" "$HANDOFF_PROTOCOL" || return 1
  grep -q "Per-test inner loop" "$HANDOFF_PROTOCOL" || return 1
}

Describe 'Handoff protocol nested loop structure'
  It 'contains nested loop with outer task loop and per-test inner loop'
    When call check_nested_loop_structure
    The status should be success
  End
End

check_write_next_test_action() {
  grep -q 'action="write_next_test"' "$HANDOFF_PROTOCOL" || \
  grep -q "action.*write_next_test" "$HANDOFF_PROTOCOL" || return 1
}

Describe 'Handoff protocol TDD inner-loop actions'
  It 'defines the write_next_test action for continuing the inner loop'
    When call check_write_next_test_action
    The status should be success
  End
End

check_refactor_three_way_branching() {
  # Extract Refactor section: from ### Refactor up to next ###heading or EOF
  refactor_section=$(sed -n '/^### Refactor$/,/^###[^#]/{ /^###[^#]/!p; }' "$HANDOFF_PROTOCOL")
  # All 3 actions must be present in the Refactor section
  echo "$refactor_section" | grep -q 'action="write_next_test"' || return 1
  echo "$refactor_section" | grep -q 'action="write_test"' || return 1
  echo "$refactor_section" | grep -q 'action="review"' || return 1
}

Describe 'Handoff protocol Refactor three-way branching'
  It 'contains write_next_test, write_test, and review actions in the Refactor section'
    When call check_refactor_three_way_branching
    The status should be success
  End
End
