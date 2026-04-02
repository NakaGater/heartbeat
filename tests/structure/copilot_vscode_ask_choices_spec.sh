# 構造テスト: Copilot SKILL.md に vscode_askQuestions の選択肢パラメータ指針が記載されているか検証する
# タスク4: Copilot SKILL.md への選択式ガイドライン反映

COPILOT_SKILL="adapters/copilot/skills/heartbeat/SKILL.md"

# Rule 1: AP1 の選択肢が vscode_askQuestions と共に明示されている
check_rule1_ap1_choices() {
  # Rule 1 セクション内で AP1 の選択肢リストが明示されていること
  grep -A 20 'Rule 1' "$COPILOT_SKILL" | grep -q '承認する.*差し戻す'
}

# Rule 1: AP3 の選択肢が vscode_askQuestions と共に明示されている
check_rule1_ap3_choices() {
  # Rule 1 セクション内で AP3 の選択肢リストが明示されていること
  grep -A 20 'Rule 1' "$COPILOT_SKILL" | grep -q '合格.*差し戻す'
}

# Rule 1: 差し戻し理由の取得方法が記載されている
check_rule1_sendback_reason() {
  grep -A 20 'Rule 1' "$COPILOT_SKILL" | grep -q 'vscode_askQuestions.*理由'
}

# Rule 3: カテゴリ自動推定の記述がある
check_rule3_category_inference() {
  grep -A 20 'Rule 3' "$COPILOT_SKILL" | grep -q 'カテゴリ.*推定'
}

# Rule 3: 推定不可時に vscode_askQuestions でカテゴリ選択肢を提示する記述がある
check_rule3_fallback_ask() {
  grep -A 20 'Rule 3' "$COPILOT_SKILL" | grep -q 'vscode_askQuestions.*カテゴリ'
}

Describe 'Copilot SKILL.md vscode_askQuestions choice parameter guidance'
  It 'Rule 1 specifies AP1 choices for vscode_askQuestions'
    When call check_rule1_ap1_choices
    The status should be success
  End

  It 'Rule 1 specifies AP3 choices for vscode_askQuestions'
    When call check_rule1_ap3_choices
    The status should be success
  End

  It 'Rule 1 describes sendback reason retrieval via vscode_askQuestions'
    When call check_rule1_sendback_reason
    The status should be success
  End

  It 'Rule 3 describes category auto-inference from user input'
    When call check_rule3_category_inference
    The status should be success
  End

  It 'Rule 3 describes vscode_askQuestions fallback for category selection'
    When call check_rule3_fallback_ask
    The status should be success
  End
End
