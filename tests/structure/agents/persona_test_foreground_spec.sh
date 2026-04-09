## Test: tester.md defines test execution foreground rule
## Story: 0049-subagent-test-foreground / Task 1

# Helper: extract "## Test Execution Rule" section from specified persona file.
# Returns content between "## Test Execution Rule" heading and the next "##" heading.
extract_test_execution_rule_section() {
  persona_file="$1"
  [ -f "$persona_file" ] || return 1
  sed -n '/^## Test Execution Rule$/,/^## /{ /^## Test Execution Rule$/d; /^## /d; p; }' "$persona_file"
}

# Condition 1: tester.md has "## Test Execution Rule" section
check_tester_has_test_execution_rule_section() {
  grep -q "^## Test Execution Rule$" "core/agent-personas/tester.md" || return 1
}

# Condition 2: contains foreground (synchronous) execution instruction
check_tester_has_foreground_instruction() {
  section=$(extract_test_execution_rule_section "core/agent-personas/tester.md")
  [ -n "$section" ] || return 1
  echo "$section" | grep -qi "ALWAYS run test commands.*foreground.*(synchronously)" || return 1
}

# Condition 3: contains run_in_background prohibition instruction
check_tester_has_run_in_background_prohibition() {
  section=$(extract_test_execution_rule_section "core/agent-personas/tester.md")
  [ -n "$section" ] || return 1
  echo "$section" | grep -q "NEVER use.*run_in_background.*true.*for test execution" || return 1
}

# Condition 4: contains instruction to verify test output before Red/Green judgment
check_tester_has_verify_output_instruction() {
  section=$(extract_test_execution_rule_section "core/agent-personas/tester.md")
  [ -n "$section" ] || return 1
  echo "$section" | grep -qi "verify the test output before making any Red/Green judgment" || return 1
}

# Condition 5a: existing "Test Writing Rules" section is preserved
check_tester_has_test_writing_rules() {
  grep -q "^## Test Writing Rules$" "core/agent-personas/tester.md" || return 1
}

# Condition 5b: existing "Per-Test TDD Cycle" section is preserved
check_tester_has_per_test_tdd_cycle() {
  grep -q "^## Per-Test TDD Cycle$" "core/agent-personas/tester.md" || return 1
}

Describe 'tester.md Test Execution Foreground Rule -- Section Existence'
  It 'tester.md has a "## Test Execution Rule" section'
    When call check_tester_has_test_execution_rule_section
    The status should be success
  End
End

Describe 'tester.md Test Execution Foreground Rule -- Required Instructions'
  It 'contains foreground (synchronous) execution instruction'
    When call check_tester_has_foreground_instruction
    The status should be success
  End

  It 'contains run_in_background prohibition instruction'
    When call check_tester_has_run_in_background_prohibition
    The status should be success
  End

  It 'contains instruction to verify test output before Red/Green judgment'
    When call check_tester_has_verify_output_instruction
    The status should be success
  End
End

Describe 'tester.md Test Execution Foreground Rule -- Existing Sections Preserved'
  It 'existing "Test Writing Rules" section is preserved'
    When call check_tester_has_test_writing_rules
    The status should be success
  End

  It 'existing "Per-Test TDD Cycle" section is preserved'
    When call check_tester_has_per_test_tdd_cycle
    The status should be success
  End
End

## Test: implementer.md defines test execution foreground rule
## Story: 0049-subagent-test-foreground / Task 2

# Condition 1: implementer.md has "## Test Execution Rule" section
check_implementer_has_test_execution_rule_section() {
  grep -q "^## Test Execution Rule$" "core/agent-personas/implementer.md" || return 1
}

# Condition 2a: contains foreground (synchronous) execution instruction
check_implementer_has_foreground_instruction() {
  section=$(extract_test_execution_rule_section "core/agent-personas/implementer.md")
  [ -n "$section" ] || return 1
  echo "$section" | grep -qi "ALWAYS run test commands.*foreground.*(synchronously)" || return 1
}

# Condition 2b: contains run_in_background prohibition instruction
check_implementer_has_run_in_background_prohibition() {
  section=$(extract_test_execution_rule_section "core/agent-personas/implementer.md")
  [ -n "$section" ] || return 1
  echo "$section" | grep -q "NEVER use.*run_in_background.*true.*for test execution" || return 1
}

# Condition 2c: contains instruction to verify test output before Red/Green judgment
check_implementer_has_verify_output_instruction() {
  section=$(extract_test_execution_rule_section "core/agent-personas/implementer.md")
  [ -n "$section" ] || return 1
  echo "$section" | grep -qi "verify the test output before making any Red/Green judgment" || return 1
}

# Condition 3: existing "Implementation Rules" section is preserved
check_implementer_has_implementation_rules() {
  grep -q "^## Implementation Rules$" "core/agent-personas/implementer.md" || return 1
}

Describe 'implementer.md Test Execution Foreground Rule -- Section Existence'
  It 'implementer.md has a "## Test Execution Rule" section'
    When call check_implementer_has_test_execution_rule_section
    The status should be success
  End
End

Describe 'implementer.md Test Execution Foreground Rule -- Required Instructions'
  It 'contains foreground (synchronous) execution instruction'
    When call check_implementer_has_foreground_instruction
    The status should be success
  End

  It 'contains run_in_background prohibition instruction'
    When call check_implementer_has_run_in_background_prohibition
    The status should be success
  End

  It 'contains instruction to verify test output before Red/Green judgment'
    When call check_implementer_has_verify_output_instruction
    The status should be success
  End
End

Describe 'implementer.md Test Execution Foreground Rule -- Existing Sections Preserved'
  It 'existing "Implementation Rules" section is preserved'
    When call check_implementer_has_implementation_rules
    The status should be success
  End
End

## Test: refactor.md defines test execution foreground rule
## Story: 0049-subagent-test-foreground / Task 3

# Condition 1: refactor.md has "## Test Execution Rule" section
check_refactor_has_test_execution_rule_section() {
  grep -q "^## Test Execution Rule$" "core/agent-personas/refactor.md" || return 1
}

# Condition 2a: contains foreground (synchronous) execution instruction
check_refactor_has_foreground_instruction() {
  section=$(extract_test_execution_rule_section "core/agent-personas/refactor.md")
  [ -n "$section" ] || return 1
  echo "$section" | grep -qi "ALWAYS run test commands.*foreground.*(synchronously)" || return 1
}

# Condition 2b: contains run_in_background prohibition instruction
check_refactor_has_run_in_background_prohibition() {
  section=$(extract_test_execution_rule_section "core/agent-personas/refactor.md")
  [ -n "$section" ] || return 1
  echo "$section" | grep -q "NEVER use.*run_in_background.*true.*for test execution" || return 1
}

# Condition 2c: contains instruction to verify test output before Red/Green judgment
check_refactor_has_verify_output_instruction() {
  section=$(extract_test_execution_rule_section "core/agent-personas/refactor.md")
  [ -n "$section" ] || return 1
  echo "$section" | grep -qi "verify the test output before making any Red/Green judgment" || return 1
}

# Condition 3: existing "Refactoring Rules" section is preserved
check_refactor_has_refactoring_rules() {
  grep -q "^## Refactoring Rules$" "core/agent-personas/refactor.md" || return 1
}

Describe 'refactor.md Test Execution Foreground Rule -- Section Existence'
  It 'refactor.md has a "## Test Execution Rule" section'
    When call check_refactor_has_test_execution_rule_section
    The status should be success
  End
End

Describe 'refactor.md Test Execution Foreground Rule -- Required Instructions'
  It 'contains foreground (synchronous) execution instruction'
    When call check_refactor_has_foreground_instruction
    The status should be success
  End

  It 'contains run_in_background prohibition instruction'
    When call check_refactor_has_run_in_background_prohibition
    The status should be success
  End

  It 'contains instruction to verify test output before Red/Green judgment'
    When call check_refactor_has_verify_output_instruction
    The status should be success
  End
End

Describe 'refactor.md Test Execution Foreground Rule -- Existing Sections Preserved'
  It 'existing "Refactoring Rules" section is preserved'
    When call check_refactor_has_refactoring_rules
    The status should be success
  End
End

## Negative test: reviewer.md / qa.md must NOT have "Test Execution Rule" section
## Story: 0049-subagent-test-foreground / Task 4

# Condition 5: reviewer.md must NOT have "## Test Execution Rule" section
check_reviewer_does_not_have_test_execution_rule_section() {
  ! grep -q "^## Test Execution Rule$" "core/agent-personas/reviewer.md"
}

# Condition 6: qa.md must NOT have "## Test Execution Rule" section
check_qa_does_not_have_test_execution_rule_section() {
  ! grep -q "^## Test Execution Rule$" "core/agent-personas/qa.md"
}

Describe 'reviewer.md / qa.md -- Test Execution Rule Section Absent (Negative Test)'
  It 'reviewer.md does not have a "## Test Execution Rule" section'
    When call check_reviewer_does_not_have_test_execution_rule_section
    The status should be success
  End

  It 'qa.md does not have a "## Test Execution Rule" section'
    When call check_qa_does_not_have_test_execution_rule_section
    The status should be success
  End
End
