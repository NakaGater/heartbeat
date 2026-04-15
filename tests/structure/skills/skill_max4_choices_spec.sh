# Structure test: Question Style Guidelines and Strict Rules specify max 4
# Story: 0057-worktree-workflow-visibility, Task 2
# CC1/2: Question Style Guidelines contains "max 4 choices per question"

SKILL_MD="core/skills/heartbeat/SKILL.md"

# Question Style Guidelines section contains "max 4"
check_guidelines_max4() {
  sed -n '/## Question Style Guidelines/,/^## /p' "$SKILL_MD" \
    | grep -q 'max 4 choices per question'
}

# Strict Rules section contains "max 4"
check_strict_rules_max4() {
  sed -n '/## Strict Rules/,/^## /p' "$SKILL_MD" \
    | grep -q 'max 4'
}

Describe 'SKILL.md specifies max 4 as the choices limit'
  It 'has "max 4 choices per question" in Question Style Guidelines'
    When call check_guidelines_max4
    The status should be success
  End

  It 'has "max 4" in Strict Rules'
    When call check_strict_rules_max4
    The status should be success
  End
End
