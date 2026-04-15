# Verify conventions.md specifies max 4 choices (not max 5)
# Story 0057: AskUserQuestion tool supports max 4 choices in practice

CONVENTIONS_FILE=".heartbeat/knowledge/conventions.md"

check_max_4_choices() {
  # conventions.md must contain "4個以下" (max 4 in Japanese)
  if ! grep -q '4個以下' "$CONVENTIONS_FILE"; then
    printf "conventions.md does not contain '4個以下' for choices limit\n" >&2
    return 1
  fi

  # Must NOT contain the old "5個以下" (max 5 in Japanese)
  if grep -q '5個以下' "$CONVENTIONS_FILE"; then
    printf "conventions.md still contains old '5個以下' limit\n" >&2
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
