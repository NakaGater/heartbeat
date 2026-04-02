# 構造テスト: Copilot SKILL.md ワークフローセクション内の vscode_askQuestions インライン参照
# ストーリー: ask-user-tool-fix
# タスク 1: ワークフローセクション内への vscode_askQuestions 指示の直接埋め込み
# タスク 2: ワークフロー完了時の継続プロンプト追加
# タスク 3: 構造テストの追加（本ファイル自体 + 既存テストの回帰確認）

COPILOT_SKILL="adapters/copilot/skills/heartbeat/SKILL.md"

# ===== Helper functions: セクション抽出 =====

# Startup Behavior セクション (## Startup Behavior 〜 ## Workflow 1)
startup_section() {
  sed -n '/^## Startup Behavior/,/^## Workflow 1/p' "$COPILOT_SKILL"
}

# Workflow 1 セクション (## Workflow 1 〜 ## Workflow 2)
workflow1_section() {
  sed -n '/^## Workflow 1/,/^## Workflow 2/p' "$COPILOT_SKILL"
}

# Workflow 2 セクション (## Workflow 2 〜 ## Post-Completion)
workflow2_section() {
  sed -n '/^## Workflow 2/,/^## Post-Completion/p' "$COPILOT_SKILL"
}

# Workflow 3 セクション (## Workflow 3 〜 ## Agent Startup Method)
workflow3_section() {
  sed -n '/^## Workflow 3/,/^## Agent Startup Method/p' "$COPILOT_SKILL"
}

# Strict Rules セクション (## Strict Rules 〜 ## Copilot-Specific)
strict_rules_section() {
  sed -n '/^## Strict Rules/,/^## Copilot-Specific/p' "$COPILOT_SKILL"
}

# ===== Test group 1: インライン vscode_askQuestions 参照 (Task 1) =====

check_startup_has_vscode_ask() {
  startup_section | grep -q 'vscode_askQuestions'
}

check_wf1_has_vscode_ask() {
  workflow1_section | grep -q 'vscode_askQuestions'
}

check_wf2_has_vscode_ask() {
  workflow2_section | grep -q 'vscode_askQuestions'
}

check_strict_rules_has_vscode_ask() {
  strict_rules_section | grep -q 'vscode_askQuestions'
}

# ===== Test group 2: 継続プロンプト (Task 2) =====

# WF1 STOP 前に vscode_askQuestions の継続プロンプトがある
check_wf1_continuation_prompt() {
  workflow1_section | grep -B 30 '>>> STOP' | grep -q 'vscode_askQuestions'
}

# WF2 STOP 前に vscode_askQuestions の継続プロンプトがある
check_wf2_continuation_prompt() {
  workflow2_section | grep -B 30 '>>> STOP' | grep -q 'vscode_askQuestions'
}

# WF3 STOP 前に vscode_askQuestions の継続プロンプトがある
check_wf3_continuation_prompt() {
  workflow3_section | grep -B 30 '>>> STOP' | grep -q 'vscode_askQuestions'
}

# 継続プロンプトに "Exit" (終了する) の選択肢がある
check_continuation_has_exit_choice() {
  grep -B 30 '>>> STOP' "$COPILOT_SKILL" | grep -q 'Exit'
}

# ===== テスト定義 =====

Describe 'Copilot SKILL.md workflow inline vscode_askQuestions references'
  It 'Startup Behavior section contains vscode_askQuestions reference'
    When call check_startup_has_vscode_ask
    The status should be success
  End

  It 'Workflow 1 section contains vscode_askQuestions reference'
    When call check_wf1_has_vscode_ask
    The status should be success
  End

  It 'Workflow 2 section contains vscode_askQuestions reference'
    When call check_wf2_has_vscode_ask
    The status should be success
  End

  It 'Strict Rules section contains vscode_askQuestions reference'
    When call check_strict_rules_has_vscode_ask
    The status should be success
  End
End

Describe 'Copilot SKILL.md continuation prompts at STOP points'
  It 'Before Workflow 1 STOP, there is a continuation prompt with vscode_askQuestions'
    When call check_wf1_continuation_prompt
    The status should be success
  End

  It 'Before Workflow 2 STOP, there is a continuation prompt with vscode_askQuestions'
    When call check_wf2_continuation_prompt
    The status should be success
  End

  It 'Before Workflow 3 STOP, there is a continuation prompt with vscode_askQuestions'
    When call check_wf3_continuation_prompt
    The status should be success
  End

  It 'Continuation prompts include Exit as a choice option'
    When call check_continuation_has_exit_choice
    The status should be success
  End
End
