# Tests for story.md scope exclusions and dependency declarations (0066, Task 5)
# Verifies AC4 (evals out-of-scope) and AC5 (0064 dependency) are properly documented.

STORY=".heartbeat/stories/0066-insufficient-tests/story.md"
BRIEF=".heartbeat/stories/0066-insufficient-tests/brief.md"

# --- CC1: evals layer is listed in the out-of-scope section of story.md ---

check_evals_in_scope_exclusion() {
  # Extract the out-of-scope section and verify "evals" appears there
  sed -n '/^## スコープ外/,/^## /p' "$STORY" | grep -q "evals" || return 1
}

# --- CC2: relationship with 0064 is documented in story.md ---

check_0064_dependency_documented() {
  grep -q "0064" "$STORY" || return 1
}

# --- AC4 supplement: brief.md records evals activation as a future concern ---
# AC4 requires: "将来の evals 層活性化に向けた課題として brief.md に記録が残っている"
# The mention must be about future activation, not just listing evals as a test layer.

check_evals_future_concern_in_brief() {
  # Must contain "evals" in a context about future work / activation
  grep -q "evals.*活性化\|evals.*将来\|evals.*今後\|evals.*future" "$BRIEF" || return 1
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

  It 'records evals layer activation as a future concern in brief.md'
    When call check_evals_future_concern_in_brief
    The status should be success
  End
End
