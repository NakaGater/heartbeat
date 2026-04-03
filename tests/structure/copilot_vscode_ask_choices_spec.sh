# 構造テスト: Copilot SKILL.md に vscode_askQuestions の選択肢パラメータ指針が記載されているか検証する
# タスク4: Copilot SKILL.md への選択式ガイドライン反映

COPILOT_SKILL="adapters/copilot/skills/heartbeat/SKILL.md"

# Rule 1: AP1 の選択肢が vscode_askQuestions と共に明示されている
check_rule1_ap1_choices() {
  # Rule 1 セクション内で AP1 の選択肢リストが明示されていること
  grep -A 20 'Rule 1' "$COPILOT_SKILL" | grep -q 'Approve.*Reject'
}

# Rule 1: AP3 の選択肢が vscode_askQuestions と共に明示されている
check_rule1_ap3_choices() {
  # Rule 1 セクション内で AP3 の選択肢リストが明示されていること
  grep -A 20 'Rule 1' "$COPILOT_SKILL" | grep -q 'Pass.*Reject'
}

# Rule 1: 差し戻し理由の取得方法が記載されている
check_rule1_sendback_reason() {
  grep -A 30 'Rule 1' "$COPILOT_SKILL" | grep -q 'vscode_askQuestions.*reason'
}

# Rule 3: カテゴリ自動推定の記述がある
check_rule3_category_inference() {
  grep -A 20 'Rule 3' "$COPILOT_SKILL" | grep -qi 'auto.*infer.*category\|category.*infer'
}

# Rule 3: 推定不可時に vscode_askQuestions でカテゴリ選択肢を提示する記述がある
check_rule3_fallback_ask() {
  grep -A 20 'Rule 3' "$COPILOT_SKILL" | grep -q 'vscode_askQuestions.*category'
}

# --- Task 1: 8箇所の vscode_askQuestions 義務化 ---
# Rule 1 セクションのみを抽出するヘルパー関数
rule1_section() {
  sed -n '/### Rule 1/,/### Rule 2/p' "$COPILOT_SKILL"
}

# Rule 1: ワークフロー選択で vscode_askQuestions を使用する指示がある
check_rule1_workflow_selection() {
  rule1_section | grep -qi 'workflow selection'
}

# Rule 1: WF1 カテゴリ選択で vscode_askQuestions を使用する指示がある
check_rule1_wf1_category() {
  rule1_section | grep -qi 'category selection'
}

# Rule 1: WF1 詳細入力（自由記述）で vscode_askQuestions を使用する指示がある
check_rule1_wf1_detail_input() {
  rule1_section | grep -qi 'detail input'
}

# Rule 1: 3pt エスケープハッチで vscode_askQuestions を使用する指示がある
check_rule1_3pt_escape_hatch() {
  rule1_section | grep -qi 'escape hatch'
}

# Rule 1: WF2 ストーリー選択で vscode_askQuestions を使用する指示がある
check_rule1_wf2_story_selection() {
  rule1_section | grep -qi 'story selection'
}

# Rule 1: AP3 差し戻し先フェーズ選択で vscode_askQuestions を使用する指示がある
check_rule1_ap3_phase_selection() {
  rule1_section | grep -qi 'rejection target phase'
}

# Rule 1: ブロック報告時で vscode_askQuestions を使用する指示がある
check_rule1_blocked_report() {
  rule1_section | grep -qi 'block report'
}

# Rule 1: オーケストレーター不確実時で vscode_askQuestions を使用する指示がある
check_rule1_orchestrator_uncertainty() {
  rule1_section | grep -qi 'orchestrator uncertainty'
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

Describe 'Copilot SKILL.md Rule 1: 全ユーザー対話での vscode_askQuestions 義務化'
  It 'Rule 1 specifies vscode_askQuestions for workflow selection'
    When call check_rule1_workflow_selection
    The status should be success
  End

  It 'Rule 1 specifies vscode_askQuestions for WF1 category selection'
    When call check_rule1_wf1_category
    The status should be success
  End

  It 'Rule 1 specifies vscode_askQuestions for WF1 detail input (free text)'
    When call check_rule1_wf1_detail_input
    The status should be success
  End

  It 'Rule 1 specifies vscode_askQuestions for 3pt escape hatch'
    When call check_rule1_3pt_escape_hatch
    The status should be success
  End

  It 'Rule 1 specifies vscode_askQuestions for WF2 story selection'
    When call check_rule1_wf2_story_selection
    The status should be success
  End

  It 'Rule 1 specifies vscode_askQuestions for AP3 phase selection after sendback'
    When call check_rule1_ap3_phase_selection
    The status should be success
  End

  It 'Rule 1 specifies vscode_askQuestions for blocked report'
    When call check_rule1_blocked_report
    The status should be success
  End

  It 'Rule 1 specifies vscode_askQuestions for orchestrator uncertainty'
    When call check_rule1_orchestrator_uncertainty
    The status should be success
  End
End
