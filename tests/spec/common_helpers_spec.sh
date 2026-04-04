# Test: has_japanese() helper function in tests/helpers/common.sh
# Story: 0042-test-cleanup / Task 1 (AC-5)
# Completion condition: has_japanese() が tests/helpers/common.sh に存在し正しく動作する

Include "$SHELLSPEC_PROJECT_ROOT/tests/helpers/common.sh"

Describe 'has_japanese() helper'
  It 'detects hiragana characters'
    When call has_japanese "これはテストです"
    The status should be success
  End

  It 'detects katakana characters'
    When call has_japanese "テスト"
    The status should be success
  End

  It 'detects kanji characters'
    When call has_japanese "漢字"
    The status should be success
  End

  It 'returns failure for ASCII-only text'
    When call has_japanese "hello world 123"
    The status should be failure
  End

  It 'returns failure for empty string'
    When call has_japanese ""
    The status should be failure
  End
End
