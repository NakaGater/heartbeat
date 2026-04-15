# Structure test: per-test board record rule in tester.md and refactor.md
# Story: 0066-insufficient-tests, Task 3

TESTER_PERSONA="core/agent-personas/tester.md"
REFACTOR_PERSONA="core/agent-personas/refactor.md"

# --- CC1: tester.md Board Protocol section contains "per-test" and "board" ---

check_tester_board_protocol_has_per_test() {
  # Extract the Board Protocol Rules section
  section=$(sed -n '/^## Board Protocol Rules$/,/^## /p' "$TESTER_PERSONA" | sed '1d;$d')
  echo "$section" | grep -qi "per-test" || return 1
  echo "$section" | grep -qi "board" || return 1
}

# --- CC2: refactor.md Board Protocol section contains "per-test" and "board" ---

check_refactor_board_protocol_has_per_test() {
  # Extract the Board Protocol Rules section
  section=$(sed -n '/^## Board Protocol Rules$/,/^## /p' "$REFACTOR_PERSONA" | sed '1d;$d')
  echo "$section" | grep -qi "per-test" || return 1
  echo "$section" | grep -qi "board" || return 1
}

Describe 'Per-test board record rule in agent personas'
  It 'tester.md Board Protocol section contains per-test and board keywords'
    When call check_tester_board_protocol_has_per_test
    The status should be success
  End

  It 'refactor.md Board Protocol section contains per-test and board keywords'
    When call check_refactor_board_protocol_has_per_test
    The status should be success
  End
End
