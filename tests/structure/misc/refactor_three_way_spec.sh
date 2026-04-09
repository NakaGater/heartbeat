# Tests for refactor.md three-way branching (tdd-workflow story, Task 4)

REFACTOR_PERSONA="core/agent-personas/refactor.md"

# --- CC1: Board Protocol Rules contains write_next_test action ---

check_board_protocol_has_write_next_test() {
  # Extract the Board Protocol Rules section: from "## Board Protocol Rules" to the next "## " heading
  board_section=$(sed -n '/^## Board Protocol Rules$/,/^## /p' "$REFACTOR_PERSONA" | sed '1d;$d')
  # The section must contain write_next_test action for inner-loop handoff
  echo "$board_section" | grep -q "write_next_test" || return 1
}

# --- CC2: refactor.md describes N vs M comparison logic for three-way branching ---

check_three_way_comparison_logic() {
  # The refactor persona must describe how to compare the number of existing tests (M)
  # against the number of completion conditions (N) to determine the branch.
  # Look for "M < N" or equivalent comparison text in the document.
  grep -q "M < N" "$REFACTOR_PERSONA" || return 1
}

# --- CC3: Board Protocol Rules contains all 3 actions: write_next_test, write_test, review ---

check_board_protocol_has_all_three_actions() {
  # Extract the Board Protocol Rules section: from "## Board Protocol Rules" to the next "## " heading
  board_section=$(sed -n '/^## Board Protocol Rules$/,/^## /p' "$REFACTOR_PERSONA" | sed '1d;$d')
  # All three actions must be present for the three-way branching to be complete:
  #   write_next_test - inner-loop: more tests remain in current task
  #   write_test      - outer-loop: current task done, proceed to next task
  #   review          - terminal:   all tasks complete, hand off to reviewer
  echo "$board_section" | grep -q "write_next_test" || return 1
  echo "$board_section" | grep -q "write_test" || return 1
  echo "$board_section" | grep -q "review" || return 1
}

Describe 'Refactor persona three-way branching'
  It 'Board Protocol Rules section contains write_next_test action'
    When call check_board_protocol_has_write_next_test
    The status should be success
  End

  It 'refactor.md describes M < N comparison logic for three-way branching'
    When call check_three_way_comparison_logic
    The status should be success
  End

  It 'Board Protocol Rules contains all 3 actions: write_next_test, write_test, review'
    When call check_board_protocol_has_all_three_actions
    The status should be success
  End
End
