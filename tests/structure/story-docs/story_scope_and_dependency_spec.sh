# Tests for story.md scope exclusions and dependency declarations (0066, Task 5)

STORY=".heartbeat/stories/0066-insufficient-tests/story.md"

# --- CC1: evals layer is listed in the out-of-scope section ---

check_evals_in_scope_exclusion() {
  # Extract the out-of-scope section and verify "evals" appears there
  sed -n '/^## スコープ外/,/^## /p' "$STORY" | grep -q "evals" || return 1
}

# --- CC2: relationship with 0064 is documented ---

check_0064_dependency_documented() {
  grep -q "0064" "$STORY" || return 1
}

Describe 'Story scope exclusions and dependency (Task 5)'
  It 'lists evals layer in the out-of-scope section'
    When call check_evals_in_scope_exclusion
    The status should be success
  End

  It 'documents the relationship with story 0064'
    When call check_0064_dependency_documented
    The status should be success
  End
End
