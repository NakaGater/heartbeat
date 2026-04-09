# Tests for implementer.md single-test Green workflow (tdd-workflow story, Task 3)

IMPLEMENTER_PERSONA="core/agent-personas/implementer.md"

# --- CC1: Role section specifies making ONE new Red test pass ---

check_role_one_test_green() {
  # Extract the Role section: from "## Role" up to the next "## " heading
  role_section=$(sed -n '/^## Role$/,/^## /p' "$IMPLEMENTER_PERSONA" | sed '1d;$d')
  # The Role section must contain language about making ONE/single new test Green
  echo "$role_section" | grep -iq "one.*test\|single.*test\|1 test" || return 1
}

# --- CC2: Implementation Rules section says not to implement beyond what the test requires ---

check_implementation_rules_no_beyond() {
  # Extract the Implementation Rules section: from "## Implementation Rules" up to the next "## " heading
  rules_section=$(sed -n '/^## Implementation Rules$/,/^## /p' "$IMPLEMENTER_PERSONA" | sed '1d;$d')
  # The section must contain instruction not to implement beyond what the test requires
  echo "$rules_section" | grep -iq "not.*implement beyond\|do not.*beyond.*test\|no more than.*test\|beyond what the test" || return 1
}

# --- CC3: Board Protocol Rules section contains note field ---

check_board_protocol_has_note() {
  # Extract the Board Protocol Rules section: from "## Board Protocol Rules" up to the next "## " heading
  board_section=$(sed -n '/^## Board Protocol Rules$/,/^## /p' "$IMPLEMENTER_PERSONA" | sed '1d;$d')
  # The section must contain "note" field reference
  echo "$board_section" | grep -q "note" || return 1
}

Describe 'Implementer persona single-test Green workflow'
  It 'Role section instructs making only ONE new Red test Green'
    When call check_role_one_test_green
    The status should be success
  End

  It 'Implementation Rules section instructs not to implement beyond what the test requires'
    When call check_implementation_rules_no_beyond
    The status should be success
  End

  It 'Board Protocol Rules section contains note field'
    When call check_board_protocol_has_note
    The status should be success
  End
End
