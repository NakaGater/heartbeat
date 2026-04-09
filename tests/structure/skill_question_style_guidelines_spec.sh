# Structure test: Verify SKILL.md has Question Style Guidelines section
# with all required principles
# Task 5: Add Question Style Guidelines section (core SKILL.md)

SKILL_MD="core/skills/heartbeat/SKILL.md"

# Guidelines section heading exists
check_section_exists() {
  grep -q '## Question Style Guidelines' "$SKILL_MD"
}

# Max choices rule (max 5) is documented
check_max_choices_rule() {
  grep -q '5' "$SKILL_MD" | grep -qi 'choice\|選択' "$SKILL_MD"
  # Max 5 constraint exists within Question Style Guidelines section
  sed -n '/## Question Style Guidelines/,/^## /p' "$SKILL_MD" | grep -q '5'
}

# Verb-first choice text rule is documented
check_verb_first_rule() {
  sed -n '/## Question Style Guidelines/,/^## /p' "$SKILL_MD" | grep -qi 'verb'
}

# "Other (free text)" must always be placed last rule is documented
check_other_last_rule() {
  sed -n '/## Question Style Guidelines/,/^## /p' "$SKILL_MD" | grep -qi 'other.*last\|last.*other'
}

# Match user language rule is documented
check_language_rule() {
  sed -n '/## Question Style Guidelines/,/^## /p' "$SKILL_MD" | grep -qi 'output-language-rule\|language'
}

Describe 'SKILL.md has Question Style Guidelines section with required elements'
  It 'has a Question Style Guidelines section heading'
    When call check_section_exists
    The status should be success
  End

  It 'specifies max 5 choices per question'
    When call check_max_choices_rule
    The status should be success
  End

  It 'requires verb-first choice text'
    When call check_verb_first_rule
    The status should be success
  End

  It 'requires Other (free text) as the last option'
    When call check_other_last_rule
    The status should be success
  End

  It 'references output-language-rule for user language matching'
    When call check_language_rule
    The status should be success
  End
End
