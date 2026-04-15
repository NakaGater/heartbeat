# Structure test: YAGNI category exception in tester.md
# Story: 0066-insufficient-tests, Task 4

TESTER_PERSONA="core/agent-personas/tester.md"

# --- CC1: "YAGNI" and "Error" and "Boundary" co-exist in the same section ---

check_yagni_section_has_error_and_boundary() {
  # Extract the Test Writing Rules section
  section=$(sed -n '/^## Test Writing Rules$/,/^## /p' "$TESTER_PERSONA" | sed '1d;$d')
  echo "$section" | grep -q "YAGNI" || return 1
  echo "$section" | grep -q "Error" || return 1
  echo "$section" | grep -q "Boundary" || return 1
}

# --- CC2: Exception references "architect" and "Completion Conditions" ---

check_exception_references_architect_and_completion_conditions() {
  # Extract the Test Writing Rules section
  section=$(sed -n '/^## Test Writing Rules$/,/^## /p' "$TESTER_PERSONA" | sed '1d;$d')
  echo "$section" | grep -q "architect" || return 1
  echo "$section" | grep -q "Completion Conditions" || return 1
}

Describe 'Tester YAGNI category exception (0066 Task 4)'
  It 'Test Writing Rules section contains YAGNI, Error, and Boundary keywords'
    When call check_yagni_section_has_error_and_boundary
    The status should be success
  End

  It 'Exception description references architect and Completion Conditions'
    When call check_exception_references_architect_and_completion_conditions
    The status should be success
  End
End
