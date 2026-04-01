# 構造テスト: WF1/WF3 の自由記述質問がハイブリッド方式（カテゴリ選択 + 自由記述）に変換されているか検証する
# タスク2: 自由記述質問2箇所のハイブリッド方式変換 (core SKILL.md)

SKILL_MD="core/skills/heartbeat/SKILL.md"

# WF1: ハイブリッド方式の2段階質問が記載されている
check_wf1_has_hybrid() {
  grep -q '2-step hybrid' "$SKILL_MD" &&
  grep -A 20 'Workflow 1' "$SKILL_MD" | grep -q 'Category selection'
}

# WF1: カテゴリ選択肢が記載されている
check_wf1_has_categories() {
  grep -A 20 'Workflow 1' "$SKILL_MD" | grep -q 'Bug fix'
}

# WF3: ハイブリッド方式の2段階質問が記載されている
check_wf3_has_hybrid() {
  grep -A 20 'Workflow 3' "$SKILL_MD" | grep -q 'Category selection'
}

# WF1/WF3: 「その他」の自由記述フォールバックが記載されている
check_has_other_fallback() {
  grep -q 'Other' "$SKILL_MD" &&
  grep -A 30 'Workflow 1' "$SKILL_MD" | grep -q 'Detail input'
}

Describe 'SKILL.md WF1/WF3 free-text questions use hybrid format'
  It 'WF1 question uses 2-step hybrid format'
    When call check_wf1_has_hybrid
    The status should be success
  End

  It 'WF1 presents category choices including Bug fix'
    When call check_wf1_has_categories
    The status should be success
  End

  It 'WF3 presents category selection step'
    When call check_wf3_has_hybrid
    The status should be success
  End

  It 'hybrid format includes Detail input as fallback step'
    When call check_has_other_fallback
    The status should be success
  End
End
