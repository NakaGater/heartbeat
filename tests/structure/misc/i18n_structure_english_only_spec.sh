# Verify that all structure test files use English only in Describe/It titles and comments

STRUCTURE_DIR="tests/structure"

# Japanese character range: U+3000 (ideographic space) through U+9FFF (CJK unified ideographs)
# Using literal Unicode range bracket expression compatible with macOS grep
JAPANESE_PATTERN='[、-龥]'

check_no_japanese_in_describe_it() {
  # Scan all .sh files for Japanese characters in Describe/It lines
  # Exclude this spec file itself to avoid false positives from the pattern definition
  found=$(grep -rn '^\s*\(Describe\|It\) ' "$STRUCTURE_DIR"/*.sh \
    | grep -v 'i18n_structure_english_only_spec\.sh' \
    | grep "$JAPANESE_PATTERN" || true)
  if [ -n "$found" ]; then
    printf "Japanese found in Describe/It lines:\n%s\n" "$found" >&2
    return 1
  fi
}

check_no_japanese_in_comments() {
  # Scan all .sh files for Japanese characters in comment lines
  # Exclude this spec file itself to avoid false positives from the pattern definition
  found=$(grep -rn '^\s*#' "$STRUCTURE_DIR"/*.sh \
    | grep -v 'i18n_structure_english_only_spec\.sh' \
    | grep "$JAPANESE_PATTERN" || true)
  if [ -n "$found" ]; then
    printf "Japanese found in comment lines:\n%s\n" "$found" >&2
    return 1
  fi
}

Describe 'Structure tests i18n compliance'
  It 'has no Japanese characters in Describe/It titles'
    When call check_no_japanese_in_describe_it
    The status should be success
    The stderr should be blank
  End

  It 'has no Japanese characters in comment lines'
    When call check_no_japanese_in_comments
    The status should be success
    The stderr should be blank
  End
End
