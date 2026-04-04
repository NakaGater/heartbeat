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

# --- extract_skill_section() tests ---
# Story: 0042-test-cleanup / Task 1 (AC-5)
# Completion condition: extract_skill_section() が SKILL.md からセクションを抽出できる

Describe 'extract_skill_section() helper'
  setup() {
    TEST_MD=$(mktemp)
    cat > "$TEST_MD" <<'FIXTURE'
# Main Title

## Section Alpha

Alpha content line 1.
Alpha content line 2.

## Section Beta

Beta content line 1.

### Beta subsection

Beta sub content.

## Section Gamma

Gamma content.
FIXTURE
  }

  cleanup() {
    rm -f "$TEST_MD"
  }

  Before 'setup'
  After 'cleanup'

  It 'extracts content of a named section'
    When call extract_skill_section "$TEST_MD" "Section Alpha"
    The output should include "Alpha content line 1."
    The output should include "Alpha content line 2."
    The status should be success
  End

  It 'does not include content from other sections'
    When call extract_skill_section "$TEST_MD" "Section Alpha"
    The output should not include "Beta content"
    The output should not include "Gamma content"
  End

  It 'extracts a section that contains subsections'
    When call extract_skill_section "$TEST_MD" "Section Beta"
    The output should include "Beta content line 1."
    The output should include "### Beta subsection"
    The output should include "Beta sub content."
  End

  It 'extracts the last section (no trailing heading)'
    When call extract_skill_section "$TEST_MD" "Section Gamma"
    The output should include "Gamma content."
    The status should be success
  End

  It 'returns failure for a non-existent section'
    When call extract_skill_section "$TEST_MD" "No Such Section"
    The status should be failure
  End

  It 'returns failure when file does not exist'
    When call extract_skill_section "/tmp/nonexistent_file_xxxxx.md" "Section Alpha"
    The status should be failure
  End
End
