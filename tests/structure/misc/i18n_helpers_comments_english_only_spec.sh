# Verify that all helper files use English only in comment lines

HELPERS_DIR="tests/helpers"

# Japanese character range: U+3000 (ideographic space) through U+9FFF (CJK unified ideographs)
# Using literal Unicode range bracket expression compatible with macOS grep
JAPANESE_PATTERN='[、-龥]'

check_no_japanese_in_helper_comments() {
  # Scan all .sh files under tests/helpers/ for Japanese characters in comment lines
  # Exclude this spec file itself to avoid false positives from the pattern definition
  found=$(grep -rn '^\s*#' "$HELPERS_DIR"/*.sh \
    | grep -v 'i18n_helpers_comments_english_only_spec\.sh' \
    | grep "$JAPANESE_PATTERN" || true)
  if [ -n "$found" ]; then
    printf "Japanese found in helper comment lines:\n%s\n" "$found" >&2
    return 1
  fi
}

Describe 'Helper files i18n compliance'
  It 'has no Japanese characters in comment lines'
    When call check_no_japanese_in_helper_comments
    The status should be success
    The stderr should be blank
  End
End
