# Verify that all spec test files use English only in comment lines

SPEC_DIR="tests/spec"

# Japanese character range: U+3000 (ideographic space) through U+9FFF (CJK unified ideographs)
JAPANESE_PATTERN='[、-龥]'

check_no_japanese_in_spec_comments() {
  # Scan all .sh files under tests/spec/ for Japanese characters in comment lines
  found=$(grep -rn --include='*.sh' '^\s*#' "$SPEC_DIR" \
    | grep "$JAPANESE_PATTERN" || true)
  if [ -n "$found" ]; then
    printf "Japanese found in comment lines under tests/spec/:\n%s\n" "$found" >&2
    return 1
  fi
}

Describe 'Spec tests i18n compliance (comment lines)'
  It 'has no Japanese characters in comment lines under tests/spec/'
    When call check_no_japanese_in_spec_comments
    The status should be success
    The stderr should be blank
  End
End
