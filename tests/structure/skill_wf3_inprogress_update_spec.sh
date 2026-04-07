CORE_SKILL="core/skills/heartbeat/SKILL.md"
ADAPTER_SKILL="adapters/claude-code/skills/heartbeat/SKILL.md"

# 完了条件:
# SKILL.md の Workflow 3 セクションに in_progress ステータス更新指示が含まれること
# 上記が core と adapters の両方に存在すること

extract_wf3_section() {
  sed -n '/^## Workflow 3: Create and Implement a Story/,/^## /p' "$1"
}

# Workflow 3 セクションに status -> "in_progress" の更新指示が存在する
check_wf3_has_inprogress_update() {
  section=$(extract_wf3_section "$1")
  [ -z "$section" ] && return 1
  echo "$section" | grep -q 'in_progress' || return 1
  echo "$section" | grep -q 'status' || return 1
}

Describe 'SKILL.md Workflow 3 に明示的な in_progress 更新指示が存在する'
  Describe 'core/skills/heartbeat/SKILL.md'
    It 'Workflow 3 セクションに status in_progress 更新指示が含まれる'
      When call check_wf3_has_inprogress_update "$CORE_SKILL"
      The status should be success
    End

  End

  Describe 'adapters/claude-code/skills/heartbeat/SKILL.md'
    It 'Workflow 3 セクションに status in_progress 更新指示が含まれる'
      When call check_wf3_has_inprogress_update "$ADAPTER_SKILL"
      The status should be success
    End
  End
End
