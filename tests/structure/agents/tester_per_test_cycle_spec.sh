# Tests for tester.md per-test TDD cycle (tdd-workflow story, Task 2)

TESTER_PERSONA="core/agent-personas/tester.md"

# --- CC1: Role section states one test at a time ---

check_role_one_test_at_a_time() {
  # Extract the Role section: from "## Role" up to the next "## " heading
  role_section=$(sed -n '/^## Role$/,/^## /p' "$TESTER_PERSONA" | sed '1d;$d')
  # The Role section must contain language about writing one test per cycle
  echo "$role_section" | grep -iq "one test\|single test\|1 test\|exactly one\|exactly ONE" || return 1
}

# --- CC2: Per-Test TDD Cycle section exists ---

check_per_test_tdd_cycle_section_exists() {
  # tester.md must contain a "## Per-Test TDD Cycle" heading
  grep -q "^## Per-Test TDD Cycle" "$TESTER_PERSONA" || return 1
}

# --- CC3: Board Protocol Rules contains write_next_test action note format ---

check_board_protocol_has_write_next_test() {
  # Extract the Board Protocol Rules section: from "## Board Protocol Rules" to the next "## " heading
  board_section=$(sed -n '/^## Board Protocol Rules$/,/^## /p' "$TESTER_PERSONA" | sed '1d;$d')
  # The section must reference write_next_test action
  echo "$board_section" | grep -q "write_next_test" || return 1
}

Describe 'Tester persona per-test TDD cycle'
  It 'Role section instructs writing exactly one test at a time'
    When call check_role_one_test_at_a_time
    The status should be success
  End

  It 'contains a Per-Test TDD Cycle section'
    When call check_per_test_tdd_cycle_section_exists
    The status should be success
  End

  It 'Board Protocol Rules section contains write_next_test action note format'
    When call check_board_protocol_has_write_next_test
    The status should be success
  End
End
