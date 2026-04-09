# Verify that tests/CONVENTIONS.md mandates English for ALL tests (not just new ones)

CONVENTIONS_FILE="tests/CONVENTIONS.md"

check_english_mandatory_rule() {
  # The Existing Tests section must state that all tests require English
  # It should NOT contain language allowing Japanese to remain
  if grep -q 'do.*not.*need to be rewritten' "$CONVENTIONS_FILE"; then
    printf "CONVENTIONS.md still allows Japanese in existing tests\n" >&2
    return 1
  fi

  # Must contain a rule stating all test titles and comments must be in English
  if ! grep -qi 'all.*test.*english\|must.*be.*written.*in.*english\|english.*required' "$CONVENTIONS_FILE"; then
    printf "CONVENTIONS.md does not contain an all-English mandate for tests\n" >&2
    return 1
  fi
}

Describe 'tests/CONVENTIONS.md English-only rule'
  It 'mandates English for all test titles and comments including existing tests'
    When call check_english_mandatory_rule
    The status should be success
    The stderr should be blank
  End
End
