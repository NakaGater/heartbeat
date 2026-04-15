# Tests for tester.md completion condition category verification and rejection rule (0066, Task 2)

TESTER="core/agent-personas/tester.md"

# --- CC1: Three category verification keywords exist in tester.md ---

check_happy_path_keyword() {
  grep -q "Happy path" "$TESTER" || return 1
}

check_error_keyword() {
  grep -q "Error" "$TESTER" || return 1
}

check_boundary_keyword() {
  grep -q "Boundary" "$TESTER" || return 1
}

# --- CC2: Rejection board entry example for architect exists ---

check_rejection_board_entry_example() {
  # tester.md must contain a board entry example that sends back to architect
  # with status blocked when categories are missing
  grep -q '"to":"architect"' "$TESTER" && grep -q '"status":"blocked"' "$TESTER" && grep -q 'categor' "$TESTER" || return 1
}

Describe 'Tester completion condition category rejection rule (0066 Task 2)'
  It 'contains Happy path keyword for category verification'
    When call check_happy_path_keyword
    The status should be success
  End

  It 'contains Error keyword for category verification'
    When call check_error_keyword
    The status should be success
  End

  It 'contains Boundary keyword for category verification'
    When call check_boundary_keyword
    The status should be success
  End

  It 'contains architect rejection board entry example with category reference'
    When call check_rejection_board_entry_example
    The status should be success
  End
End
