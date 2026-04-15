# Tests for architect.md completion condition 3-category requirement (0066, Task 1)

ARCHITECT="core/agent-personas/architect.md"

# --- CC1: Three category labels exist in architect.md ---

check_happy_path_label() {
  grep -q "Happy path" "$ARCHITECT" || return 1
}

check_error_cases_label() {
  grep -q "Error / failure cases" "$ARCHITECT" || return 1
}

check_boundary_cases_label() {
  grep -q "Boundary / edge cases" "$ARCHITECT" || return 1
}

# --- CC2: Minimum count instruction exists ---

check_minimum_count_instruction() {
  grep -qi "at least 1" "$ARCHITECT" || return 1
}

Describe 'Architect completion condition 3-category requirement (0066 Task 1)'
  It 'contains Happy path category label'
    When call check_happy_path_label
    The status should be success
  End

  It 'contains Error / failure cases category label'
    When call check_error_cases_label
    The status should be success
  End

  It 'contains Boundary / edge cases category label'
    When call check_boundary_cases_label
    The status should be success
  End

  It 'contains minimum count instruction (at least 1)'
    When call check_minimum_count_instruction
    The status should be success
  End
End
