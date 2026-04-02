# 構造テスト: 承認式質問4箇所に明示的な選択肢が記載されているか検証する
# タスク1: 承認式質問4箇所の選択肢明示化 (core SKILL.md)

SKILL_MD="core/skills/heartbeat/SKILL.md"

# AP1: ストーリー承認に選択肢が明示されている
check_ap1_has_choices() {
  grep -q 'Present choices:.*Approve.*Send back' "$SKILL_MD"
}

# AP2: タスク分解承認に選択肢が明示されている
check_ap2_has_choices() {
  grep -q 'Present choices:.*Approve.*Request changes' "$SKILL_MD"
}

# AP3: 最終結果報告に選択肢が明示されている
check_ap3_has_choices() {
  grep -q 'Present choices:.*Pass.*Send back' "$SKILL_MD"
}

# 3pt エスケープハッチに選択肢が明示されている
check_3pt_escape_has_choices() {
  grep -q 'Present choices:.*Continue with 3pt.*Split the story' "$SKILL_MD"
}

Describe 'SKILL.md approval-type questions have explicit choices'
  It 'AP1 (story approval) presents explicit choices'
    When call check_ap1_has_choices
    The status should be success
  End

  It 'AP2 (task decomposition approval) presents explicit choices'
    When call check_ap2_has_choices
    The status should be success
  End

  It 'AP3 (final result report) presents explicit choices'
    When call check_ap3_has_choices
    The status should be success
  End

  It '3pt escape hatch presents explicit choices'
    When call check_3pt_escape_has_choices
    The status should be success
  End
End
