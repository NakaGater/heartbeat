# Structure test: Question Style Guidelines と Strict Rules で max 4 が使用されていること
# Story: 0057-worktree-workflow-visibility, Task 2
# 完了条件 1/2: Question Style Guidelines に "max 4 choices per question" が存在する

SKILL_MD="core/skills/heartbeat/SKILL.md"

# Question Style Guidelines セクション内に "max 4" が記載されている
check_guidelines_max4() {
  sed -n '/## Question Style Guidelines/,/^## /p' "$SKILL_MD" \
    | grep -q 'max 4 choices per question'
}

# Strict Rules セクション内に "max 4" が記載されている
check_strict_rules_max4() {
  sed -n '/## Strict Rules/,/^## /p' "$SKILL_MD" \
    | grep -q 'max 4'
}

Describe 'SKILL.md は選択肢上限を max 4 に指定している'
  It 'Question Style Guidelines セクションに "max 4 choices per question" がある'
    When call check_guidelines_max4
    The status should be success
  End

  It 'Strict Rules セクションに "max 4" がある'
    When call check_strict_rules_max4
    The status should be success
  End
End
