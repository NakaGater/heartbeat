# Verify that all spec test files use English only in Describe/It titles

SPEC_DIR="tests/spec"

# Japanese character range: U+3000 (ideographic space) through U+9FFF (CJK unified ideographs)
JAPANESE_PATTERN='[、-龥]'

check_no_japanese_in_spec_describe_it() {
  # Scan all .sh files under tests/spec/ for Japanese characters in Describe/It lines
  found=$(grep -rn '^\s*\(Describe\|It\) ' "$SPEC_DIR"/*.sh \
    | grep "$JAPANESE_PATTERN" || true)
  if [ -n "$found" ]; then
    printf "Japanese found in Describe/It lines under tests/spec/:\n%s\n" "$found" >&2
    return 1
  fi
}

Describe 'Spec tests i18n compliance (Describe/It titles)'
  It 'has no Japanese characters in Describe/It titles under tests/spec/'
    When call check_no_japanese_in_spec_describe_it
    The status should be success
    The stderr should be blank
  End
End
