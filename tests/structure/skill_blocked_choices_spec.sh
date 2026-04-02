# 構造テスト: blocked/判断不能時に選択式の選択肢が記載されているか検証する
# タスク3: blocked/判断不能時の選択式変換 (core SKILL.md)

SKILL_MD="core/skills/heartbeat/SKILL.md"

# blocked転送時の選択肢テンプレートが記載されている
check_blocked_has_choices() {
  grep -q 'Clarify the spec' "$SKILL_MD" &&
  grep -q 'Mark as out of scope' "$SKILL_MD" &&
  grep -q 'Have the agent reconsider' "$SKILL_MD" &&
  grep -q 'Other (free text)' "$SKILL_MD"
}

# 判断不能時の選択肢生成ガイドラインが記載されている
check_uncertainty_has_choices() {
  grep -q 'orchestrator uncertainty' "$SKILL_MD" &&
  grep -q 'situation-specific choices' "$SKILL_MD"
}

Describe 'SKILL.md blocked/uncertainty situations have explicit choices'
  It 'blocked reports forwarded to human present resolution choices'
    When call check_blocked_has_choices
    The status should be success
  End

  It 'orchestrator uncertainty presents situation-specific choices'
    When call check_uncertainty_has_choices
    The status should be success
  End
End
