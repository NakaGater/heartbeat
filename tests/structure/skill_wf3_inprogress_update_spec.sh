CORE_SKILL="core/skills/heartbeat/SKILL.md"
ADAPTER_SKILL="adapters/claude-code/skills/heartbeat/SKILL.md"

# Task 1 完了条件:
# SKILL.md の Workflow 3 セクションに in_progress ステータス更新指示が含まれること
# SKILL.md の Workflow 3 セクションに generate-dashboard.sh 呼び出し指示が含まれること
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

# Workflow 3 セクションに generate-dashboard.sh の呼び出し指示が存在する
check_wf3_has_generate_dashboard() {
  section=$(extract_wf3_section "$1")
  [ -z "$section" ] && return 1
  echo "$section" | grep -q 'generate-dashboard.sh' || return 1
}

# generate-dashboard.sh が in_progress 更新の後に呼ばれること
check_dashboard_after_inprogress() {
  section=$(extract_wf3_section "$1")
  [ -z "$section" ] && return 1
  inprogress_line=$(echo "$section" | grep -n 'in_progress' | head -1 | cut -d: -f1)
  dashboard_line=$(echo "$section" | grep -n 'generate-dashboard.sh' | head -1 | cut -d: -f1)
  [ -n "$inprogress_line" ] && [ -n "$dashboard_line" ] && [ "$inprogress_line" -lt "$dashboard_line" ]
}

Describe 'SKILL.md Workflow 3 に明示的な in_progress 更新指示が存在する'
  Describe 'core/skills/heartbeat/SKILL.md'
    It 'Workflow 3 セクションに status in_progress 更新指示が含まれる'
      When call check_wf3_has_inprogress_update "$CORE_SKILL"
      The status should be success
    End

    It 'Workflow 3 セクションに generate-dashboard.sh 呼び出し指示が含まれる'
      When call check_wf3_has_generate_dashboard "$CORE_SKILL"
      The status should be success
    End

    It 'generate-dashboard.sh が in_progress 更新より後に記述されている'
      When call check_dashboard_after_inprogress "$CORE_SKILL"
      The status should be success
    End
  End

  Describe 'adapters/claude-code/skills/heartbeat/SKILL.md'
    It 'Workflow 3 セクションに status in_progress 更新指示が含まれる'
      When call check_wf3_has_inprogress_update "$ADAPTER_SKILL"
      The status should be success
    End

    It 'Workflow 3 セクションに generate-dashboard.sh 呼び出し指示が含まれる'
      When call check_wf3_has_generate_dashboard "$ADAPTER_SKILL"
      The status should be success
    End

    It 'generate-dashboard.sh が in_progress 更新より後に記述されている'
      When call check_dashboard_after_inprogress "$ADAPTER_SKILL"
      The status should be success
    End
  End
End
