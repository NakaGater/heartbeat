# Consolidated i18n structure tests for SKILL.md
# Story: 0042-test-cleanup / Task 2 (AC-1)
#
# Merged from:
#   - skill_i18n_fullcheck_spec.sh (2 It)
#   - skill_i18n_question_style_spec.sh (4 It)
#   - skill_i18n_request_optimization_spec.sh (4 It)
#   - skill_language_detection_spec.sh (3 It)
# Total: 13 It blocks
#
# has_japanese() is provided by tests/helpers/common.sh (argument-based interface)

Include "$SHELLSPEC_PROJECT_ROOT/tests/helpers/common.sh"

CORE_SKILL="core/skills/heartbeat/SKILL.md"
COPILOT_SKILL="adapters/copilot/skills/heartbeat/SKILL.md"

# --- Helpers (specific to i18n tests, not in common.sh) ---

# Precise Japanese detection using perl Unicode properties.
# Unlike has_japanese() in common.sh (grep-based, may false-positive on arrows/emojis),
# this uses \p{Hiragana}, \p{Katakana}, \p{Han} for exact detection.
# Used by fullcheck tests that scan entire SKILL.md files where arrows/emojis are present.
has_japanese_precise() {
  printf '%s' "$1" | perl -e 'use open ":std", ":encoding(UTF-8)";
    my $found = 0;
    while (<STDIN>) {
      if (/\p{Hiragana}|\p{Katakana}|\p{Han}/) {
        $found = 1;
        last;
      }
    }
    exit($found ? 0 : 1);'
}

# Diagnostic: show lines containing Japanese characters with line numbers
show_japanese_lines() {
  perl -e 'use open ":std", ":encoding(UTF-8)";
    my $n = 0;
    while (<STDIN>) {
      $n++;
      print "$n: $_" if /\p{Hiragana}|\p{Katakana}|\p{Han}/;
    }'
}

# Extract Question Style Guidelines section
extract_question_style_section() {
  file="$1"
  sed -n '/^## Question Style Guidelines$/,/^## /{ /^## Question Style Guidelines$/d; /^## /d; p; }' "$file"
}

# Extract Request Optimization section (copilot only)
extract_request_optimization_section() {
  sed -n '/^## Copilot-Specific: Request Optimization$/,/^## /{ /^## Copilot-Specific: Request Optimization$/d; /^## /d; p; }' "$COPILOT_SKILL"
}

# Extract Rule 1 table from Request Optimization section
extract_rule1_table() {
  section=$(extract_request_optimization_section)
  echo "$section" | sed -n '/^|/,/^[^|]/{/^|/p;}'
}

# --- Fullcheck checks ---

check_core_no_japanese_excluding_examples() {
  filtered=$(awk '
    /^Example:$/ { skip_example=1; next }
    skip_example && /^```$/ && !in_block { in_block=1; next }
    skip_example && in_block && /^```$/ { skip_example=0; in_block=0; next }
    skip_example && in_block { next }
    /AskUserQuestion\(/ { skip_ask=1; next }
    skip_ask { if (/\)/) skip_ask=0; next }
    /Display:/ { next }
    /selects "/ { next }
    { skip_example=0; print }
  ' "$CORE_SKILL")
  if has_japanese_precise "$filtered"; then
    echo "Japanese text found in core SKILL.md (excluding AskUserQuestion examples):"
    echo "$filtered" | show_japanese_lines
    return 1
  fi
  return 0
}

check_copilot_no_japanese_full() {
  content=$(cat "$COPILOT_SKILL")
  if has_japanese_precise "$content"; then
    echo "Japanese text found in copilot SKILL.md:"
    show_japanese_lines < "$COPILOT_SKILL"
    return 1
  fi
  return 0
}

# --- Question Style checks ---

check_core_question_style_no_japanese() {
  section=$(extract_question_style_section "$CORE_SKILL")
  if has_japanese "$section"; then
    return 1
  fi
  return 0
}

check_copilot_question_style_no_japanese() {
  section=$(extract_question_style_section "$COPILOT_SKILL")
  if has_japanese "$section"; then
    return 1
  fi
  return 0
}

check_core_english_content() {
  section=$(extract_question_style_section "$CORE_SKILL")
  [ -n "$section" ] || return 1
  echo "$section" | grep -qi 'questions.*users.*choices' || return 1
  echo "$section" | grep -q '### Principles' || return 1
  echo "$section" | grep -qi 'choices.*5\|5.*choices' || return 1
  echo "$section" | grep -qi 'verb.first' || return 1
  echo "$section" | grep -qi 'other.*free.*text.*last\|last.*option' || return 1
  echo "$section" | grep -q 'output-language-rule' || return 1
  echo "$section" | grep -qi 'two steps\|2 steps' || return 1
}

check_copilot_english_content() {
  section=$(extract_question_style_section "$COPILOT_SKILL")
  [ -n "$section" ] || return 1
  echo "$section" | grep -qi 'questions.*users.*choices' || return 1
  echo "$section" | grep -q '### Principles' || return 1
  echo "$section" | grep -qi 'choices.*5\|5.*choices' || return 1
  echo "$section" | grep -qi 'verb.first' || return 1
  echo "$section" | grep -qi 'other.*free.*text.*last\|last.*option' || return 1
  echo "$section" | grep -q 'output-language-rule' || return 1
  echo "$section" | grep -qi 'two steps\|2 steps' || return 1
}

# --- Request Optimization checks ---

check_no_japanese_in_request_optimization() {
  section=$(extract_request_optimization_section)
  if [ -z "$section" ]; then
    return 1
  fi
  if has_japanese "$section"; then
    return 1
  fi
  return 0
}

check_rule1_table_headers_english() {
  table=$(extract_rule1_table)
  if [ -z "$table" ]; then
    return 1
  fi
  header=$(echo "$table" | head -1)
  echo "$header" | grep -qi 'Interaction Point' || return 1
  echo "$header" | grep -qi 'Question Type' || return 1
  echo "$header" | grep -qi 'Choices' || return 1
  return 0
}

check_rule1_table_cells_no_japanese() {
  table=$(extract_rule1_table)
  if [ -z "$table" ]; then
    return 1
  fi
  if has_japanese "$table"; then
    return 1
  fi
  return 0
}

check_english_content_matches_context() {
  section=$(extract_request_optimization_section)
  [ -n "$section" ] || return 1
  echo "$section" | grep -qi 'premium request' || return 1
  echo "$section" | grep -qi 'minimize' || return 1
  echo "$section" | grep -q 'vscode_askQuestions' || return 1
  echo "$section" | grep -qi 'all.*user.*interaction\|all.*question.*input' || return 1
  echo "$section" | grep -qi 'never.*normal.*response\|never.*user.*input.*normal' || return 1
  echo "$section" | grep -qi 'auto.*approve\|auto-approve' || return 1
  echo "$section" | grep -qi 'skip.*AP2\|AP2.*skip' || return 1
  echo "$section" | grep -qi 'Phase 3' || return 1
  echo "$section" | grep -qi 'workflow 3\|workflow.*3' || return 1
  echo "$section" | grep -qi 'category.*infer\|auto.*infer.*category\|infer.*category' || return 1
  echo "$section" | grep -q 'vscode_askQuestions' || return 1
}

# --- Language Detection checks ---

check_claude_code_skill_has_language_detection_step() {
  skill_file="adapters/claude-code/skills/heartbeat/SKILL.md"
  [ -f "$skill_file" ] || return 1
  grep -q "Language directive" "$skill_file" || return 1
}

check_claude_code_skill_steps_are_sequential_1_to_7() {
  skill_file="adapters/claude-code/skills/heartbeat/SKILL.md"
  [ -f "$skill_file" ] || return 1
  section=$(sed -n '/^## Agent Startup Method$/,/^## /{ /^## /d; p; }' "$skill_file")
  step_numbers=$(echo "$section" | grep -E '^[0-9]+\.' | sed 's/^\([0-9]*\)\..*/\1/')
  expected="1
2
3
4
5
6
7
8"
  [ "$step_numbers" = "$expected" ] || return 1
}

check_copilot_skill_has_subagent_dispatch() {
  copilot_file="adapters/copilot/skills/heartbeat/SKILL.md"
  [ -f "$copilot_file" ] || return 1
  grep -q "Use the .* agent as a subagent" "$copilot_file" || return 1
  grep -q "Subagent responsibilities" "$copilot_file" || return 1
  grep -q "Orchestrator responsibilities" "$copilot_file" || return 1
}

# ============================================================
# Describe blocks (13 It blocks total)
# ============================================================

# From: skill_i18n_fullcheck_spec.sh (2 It)
Describe 'SKILL.md full Japanese residue check (Task 3: overall verification)'
  It 'core SKILL.md has no Japanese LLM-instruction text (AskUserQuestion output examples excluded)'
    When call check_core_no_japanese_excluding_examples
    The status should be success
  End

  It 'copilot SKILL.md has no Japanese characters at all'
    When call check_copilot_no_japanese_full
    The status should be success
  End
End

# From: skill_i18n_question_style_spec.sh (4 It)
Describe 'SKILL.md Question Style Guidelines has no Japanese (core)'
  It 'contains no Japanese characters (hiragana, katakana, kanji) in core SKILL.md'
    When call check_core_question_style_no_japanese
    The status should be success
  End

  It 'contains expected English translation key phrases in core SKILL.md'
    When call check_core_english_content
    The status should be success
  End
End

Describe 'SKILL.md Question Style Guidelines has no Japanese (copilot)'
  It 'contains no Japanese characters (hiragana, katakana, kanji) in copilot SKILL.md'
    When call check_copilot_question_style_no_japanese
    The status should be success
  End

  It 'contains expected English translation key phrases in copilot SKILL.md'
    When call check_copilot_english_content
    The status should be success
  End
End

# From: skill_i18n_request_optimization_spec.sh (4 It)
Describe 'SKILL.md Request Optimization has no Japanese (copilot)'
  It 'contains no Japanese characters in Request Optimization section'
    When call check_no_japanese_in_request_optimization
    The status should be success
  End

  It 'Rule 1 table headers are in English'
    When call check_rule1_table_headers_english
    The status should be success
  End

  It 'Rule 1 table data cells contain no Japanese characters'
    When call check_rule1_table_cells_no_japanese
    The status should be success
  End

  It 'contains expected English translation key phrases matching context.md'
    When call check_english_content_matches_context
    The status should be success
  End
End

# From: skill_language_detection_spec.sh (3 It)
Describe 'SKILL.md language detection step'
  It 'claude-code SKILL.md Agent Startup Method contains a language detection step between step 2 and step 3'
    When call check_claude_code_skill_has_language_detection_step
    The status should be success
  End

  It 'copilot SKILL.md Agent Startup Method uses subagent dispatch pattern'
    When call check_copilot_skill_has_subagent_dispatch
    The status should be success
  End

  It 'when checking step numbers in claude-code SKILL.md Agent Startup Method, should be sequential 1 through 8'
    When call check_claude_code_skill_steps_are_sequential_1_to_7
    The status should be success
  End
End
