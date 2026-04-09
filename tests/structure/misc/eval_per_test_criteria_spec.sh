# Tests for per-test TDD eval criteria in tester.yaml (tdd-workflow story, Task 6)

TESTER_EVAL="tests/evals/tester.yaml"
IMPLEMENTER_EVAL="tests/evals/implementer.yaml"

# --- Helper: extract a named case block from a YAML eval file ---
# Args: $1=file path, $2=case name
extract_eval_case_block() {
  _file="$1"
  _case_name="$2"
  _block=$(sed -n "/name:.*\"${_case_name}\"/,/^  - name:/p" "$_file" | sed '$d')
  if [ -z "$_block" ]; then
    _block=$(sed -n "/name:.*\"${_case_name}\"/,\$p" "$_file")
  fi
  echo "$_block"
}

# --- CC1: tester.yaml contains "Per-test TDD cycle" case with one-test-per-cycle criteria ---

check_tester_eval_has_per_test_tdd_cycle_case() {
  grep -q 'name:.*"Per-test TDD cycle"' "$TESTER_EVAL" || return 1
}

check_tester_eval_per_test_cycle_criteria() {
  case_block=$(extract_eval_case_block "$TESTER_EVAL" "Per-test TDD cycle")
  echo "$case_block" | grep -iq "one test.*per cycle\|single test.*per cycle\|one test at a time\|not.*batch\|not.*multiple tests" || return 1
}

Describe 'Tester eval per-test TDD cycle criteria'
  It 'tester.yaml contains a case named "Per-test TDD cycle"'
    When call check_tester_eval_has_per_test_tdd_cycle_case
    The status should be success
  End

  It 'the "Per-test TDD cycle" case has criteria verifying one test per cycle'
    When call check_tester_eval_per_test_cycle_criteria
    The status should be success
  End
End

# --- CC2: implementer.yaml contains "Single test Green" case with per-test criteria ---

check_implementer_eval_has_single_test_green_case() {
  grep -q 'name:.*"Single test Green"' "$IMPLEMENTER_EVAL" || return 1
}

check_implementer_eval_single_test_green_criteria() {
  case_block=$(extract_eval_case_block "$IMPLEMENTER_EVAL" "Single test Green")
  echo "$case_block" | grep -iq "one.*failing test\|single.*failing test\|one.*new.*test" || return 1
  echo "$case_block" | grep -iq "existing.*green\|existing.*pass\|other.*test.*pass\|other.*test.*green\|no.*regression" || return 1
}

Describe 'Implementer eval single test Green criteria'
  It 'implementer.yaml contains a case named "Single test Green"'
    When call check_implementer_eval_has_single_test_green_case
    The status should be success
  End

  It 'the "Single test Green" case has criteria verifying only one new failing test passes and existing tests stay Green'
    When call check_implementer_eval_single_test_green_criteria
    The status should be success
  End
End

# --- CC3: Verify existing eval cases are preserved ---

check_tester_eval_has_one_test_per_behavior_case() {
  grep -q 'name:.*"One test per behavior"' "$TESTER_EVAL" || return 1
}

check_tester_eval_one_test_per_behavior_criteria() {
  case_block=$(extract_eval_case_block "$TESTER_EVAL" "One test per behavior")
  echo "$case_block" | grep -q "Each test function verifies exactly one behavior" || return 1
}

check_tester_eval_has_yagni_compliance_case() {
  grep -q 'name:.*"YAGNI compliance"' "$TESTER_EVAL" || return 1
}

check_tester_eval_yagni_compliance_criteria() {
  case_block=$(extract_eval_case_block "$TESTER_EVAL" "YAGNI compliance")
  echo "$case_block" | grep -q "Does not write tests for features not yet requested" || return 1
}

check_implementer_eval_has_minimal_implementation_case() {
  grep -q 'name:.*"Minimal implementation principle"' "$IMPLEMENTER_EVAL" || return 1
}

check_implementer_eval_minimal_implementation_criteria() {
  case_block=$(extract_eval_case_block "$IMPLEMENTER_EVAL" "Minimal implementation principle")
  echo "$case_block" | grep -q "Only minimum code needed to pass tests is written" || return 1
}

Describe 'Existing Eval Case Preservation'
  It 'tester.yaml has a "One test per behavior" case'
    When call check_tester_eval_has_one_test_per_behavior_case
    The status should be success
  End

  It '"One test per behavior" criteria includes "Each test function verifies exactly one behavior"'
    When call check_tester_eval_one_test_per_behavior_criteria
    The status should be success
  End

  It 'tester.yaml has a "YAGNI compliance" case'
    When call check_tester_eval_has_yagni_compliance_case
    The status should be success
  End

  It '"YAGNI compliance" criteria includes "Does not write tests for features not yet requested"'
    When call check_tester_eval_yagni_compliance_criteria
    The status should be success
  End

  It 'implementer.yaml has a "Minimal implementation principle" case'
    When call check_implementer_eval_has_minimal_implementation_case
    The status should be success
  End

  It '"Minimal implementation principle" criteria includes "Only minimum code needed to pass tests is written"'
    When call check_implementer_eval_minimal_implementation_criteria
    The status should be success
  End
End
