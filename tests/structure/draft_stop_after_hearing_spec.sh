SKILL_FILE="core/skills/heartbeat/SKILL.md"

# ヘルパー: Workflow 1 セクション全体を抽出
extract_wf1() {
  local wf1_start wf1_stop
  wf1_start=$(grep -n 'Workflow 1: Create a Story' "$SKILL_FILE" | head -1 | cut -d: -f1)
  wf1_stop=$(grep -n 'END OF WORKFLOW 1' "$SKILL_FILE" | head -1 | cut -d: -f1)
  sed -n "${wf1_start},${wf1_stop}p" "$SKILL_FILE"
}

# Draft-stop choice が pdm (hearing) 行と context-manager 行の間に存在することを検証
check_draft_stop_between_hearing_and_context() {
  local wf1_section
  wf1_section=$(extract_wf1)

  # pdm (hearing) 行の行番号を取得
  local hearing_line
  hearing_line=$(echo "$wf1_section" | grep -n 'pdm.*hearing\|hearing.*brief' | head -1 | cut -d: -f1)
  [ -n "$hearing_line" ] || return 1

  # context-manager 行の行番号を取得
  local context_line
  context_line=$(echo "$wf1_section" | grep -n 'context-manager' | head -1 | cut -d: -f1)
  [ -n "$context_line" ] || return 1

  # pdm (hearing) と context-manager の間に "Draft-stop choice" または "Stop at draft" が存在すること
  local between
  between=$(echo "$wf1_section" | sed -n "${hearing_line},${context_line}p")

  echo "$between" | grep -qi 'draft.*stop\|stop.*draft'
}

Describe 'Draft-stop choice は PdM ヒアリング後・context-manager 前に配置される（0052 Task 1）'
  It 'pdm (hearing) と context-manager の間に Draft-stop choice が存在する'
    When call check_draft_stop_between_hearing_and_context
    The status should be success
  End
End
