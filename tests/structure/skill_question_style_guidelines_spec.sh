# 構造テスト: SKILL.md に選択式質問ガイドラインセクションが存在し、
# 必要な原則がすべて含まれていることを検証する
# タスク5: 選択式質問ガイドラインセクションの追加 (core SKILL.md)

SKILL_MD="core/skills/heartbeat/SKILL.md"

# ガイドラインセクション見出しが存在する
check_section_exists() {
  grep -q '## Question Style Guidelines' "$SKILL_MD"
}

# 選択肢数の上限ルール（最大5個）が記載されている
check_max_choices_rule() {
  grep -q '5' "$SKILL_MD" | grep -qi 'choice\|選択' "$SKILL_MD"
  # 5個以下の制約が Question Style Guidelines セクション内に存在する
  sed -n '/## Question Style Guidelines/,/^## /p' "$SKILL_MD" | grep -q '5'
}

# 動詞始まりで統一するルールが記載されている
check_verb_first_rule() {
  sed -n '/## Question Style Guidelines/,/^## /p' "$SKILL_MD" | grep -qi 'verb'
}

# 「その他（自由記述）」は常に最後に配置するルールが記載されている
check_other_last_rule() {
  sed -n '/## Question Style Guidelines/,/^## /p' "$SKILL_MD" | grep -qi 'other.*last\|last.*other'
}

# ユーザーの言語に合わせるルールが記載されている
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
