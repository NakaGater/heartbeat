# Verify conventions.md specifies max 4 choices (not max 5)
# Story 0057: AskUserQuestion tool supports max 4 choices in practice

CONVENTIONS_FILE=".heartbeat/knowledge/conventions.md"

check_max_4_choices() {
  # conventions.md must contain max 4 rule (Japanese text)
  if ! grep -q '4個以下' "$CONVENTIONS_FILE"; then
    printf "conventions.md does not contain max 4 choices rule\n" >&2
    return 1
  fi

  # Must NOT contain the old max 5 rule
  if grep -q '5個以下' "$CONVENTIONS_FILE"; then
    printf "conventions.md still contains old max 5 limit\n" >&2
    return 1
  fi
}

Describe 'conventions.md question choices limit'
  It 'specifies max 4 choices instead of max 5'
    When call check_max_4_choices
    The status should be success
    The stderr should be blank
  End
End
