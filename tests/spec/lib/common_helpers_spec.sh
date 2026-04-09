# Test: has_japanese() helper function in tests/helpers/common.sh
# Story: 0042-test-cleanup / Task 1 (AC-5)
# Completion condition: has_japanese() exists in tests/helpers/common.sh and works correctly

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
# Completion condition: extract_skill_section() can extract sections from SKILL.md

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

# --- setup_dashboard_project() tests ---
# Story: 0042-test-cleanup / Task 1 (AC-5)
# Completion condition: setup_dashboard_project() builds a shared environment for dashboard tests

Describe 'setup_dashboard_project() helper'
  After 'cleanup_dashboard_project'

  It 'creates a temporary project directory'
    When call setup_dashboard_project
    The status should be success
    The variable DASHBOARD_PROJECT should be present
    The path "$DASHBOARD_PROJECT" should be directory
  End

  It 'creates .heartbeat directory structure'
    setup_dashboard_project
    When call test -d "$DASHBOARD_PROJECT/.heartbeat"
    The status should be success
  End

  It 'creates a story directory under .heartbeat/stories'
    setup_dashboard_project
    count_story_dirs() {
      find "$DASHBOARD_PROJECT/.heartbeat/stories" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' '
    }
    When call count_story_dirs
    The output should equal "1"
  End

  It 'places a valid backlog.jsonl file'
    setup_dashboard_project
    When call cat "$DASHBOARD_PROJECT/.heartbeat/backlog.jsonl"
    The status should be success
    The output should include '"story_id"'
    The output should include '"status"'
  End

  It 'places a valid board.jsonl inside the story directory'
    setup_dashboard_project
    check_board() {
      local story_dir
      story_dir=$(find "$DASHBOARD_PROJECT/.heartbeat/stories" -mindepth 1 -maxdepth 1 -type d | head -1)
      cat "$story_dir/board.jsonl"
    }
    When call check_board
    The status should be success
    The output should include '"from"'
    The output should include '"action"'
  End

  It 'creates files that are valid JSON (one object per line)'
    setup_dashboard_project
    validate_jsonl() {
      local backlog="$DASHBOARD_PROJECT/.heartbeat/backlog.jsonl"
      local story_dir
      story_dir=$(find "$DASHBOARD_PROJECT/.heartbeat/stories" -mindepth 1 -maxdepth 1 -type d | head -1)
      local board="$story_dir/board.jsonl"
      # Each line must be valid JSON - use jq to validate
      jq -e . "$backlog" >/dev/null 2>&1 && jq -e . "$board" >/dev/null 2>&1 && echo "VALID" || echo "INVALID"
    }
    When call validate_jsonl
    The output should equal "VALID"
  End
End
