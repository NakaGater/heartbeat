SHELLSPEC_CONFIG=".shellspec"

# --- Helper functions ---

# --jobs 4 is present
check_jobs_option() {
  grep -q '^--jobs 4$' "$SHELLSPEC_CONFIG"
}

# --format is progress
check_format_progress() {
  grep -q '^--format progress$' "$SHELLSPEC_CONFIG"
}

# --require spec_helper is preserved
check_require_spec_helper() {
  grep -q '^--require spec_helper$' "$SHELLSPEC_CONFIG"
}

# --warning-as-failure is preserved
check_warning_as_failure() {
  grep -q '^--warning-as-failure$' "$SHELLSPEC_CONFIG"
}

Describe '.shellspec Parallel Execution Configuration (Task 1)'
  Describe 'Parallel Execution Options'
    It '.shellspec contains --jobs 4'
      When call check_jobs_option
      The status should be success
    End
  End

  Describe 'Output Format'
    It '.shellspec --format is progress'
      When call check_format_progress
      The status should be success
    End
  End

  Describe 'Existing Options Preservation'
    It '--require spec_helper is preserved'
      When call check_require_spec_helper
      The status should be success
    End

    It '--warning-as-failure is preserved'
      When call check_warning_as_failure
      The status should be success
    End
  End
End
