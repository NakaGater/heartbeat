Describe 'SKILL.md Workflow 1 ダッシュボード同期呼び出し'
  # T1: Workflow 1 の Result セクションで backlog.jsonl 登録後に
  #     generate-dashboard.sh が同期的に呼び出される指示が含まれることを検証する

  SKILL_FILE="core/skills/heartbeat/SKILL.md"

  It 'Workflow 1 の Result セクションに generate-dashboard.sh の同期実行指示が含まれる'
    # Result: 行と >>> STOP: Workflow 1 行の間に generate-dashboard.sh が存在すること
    extract_workflow1_result_section() {
      sed -n '/^Result:$/,/^>>> STOP.*Workflow 1/p' "$SKILL_FILE"
    }
    When call extract_workflow1_result_section
    The output should include 'generate-dashboard.sh'
  End

  It 'generate-dashboard.sh 呼び出しが backlog.jsonl 登録行より後に記載されている'
    # backlog.jsonl 登録行の行番号 < generate-dashboard.sh 行の行番号 であること
    check_order() {
      local backlog_line dashboard_line
      backlog_line=$(grep -n 'Register in backlog.jsonl' "$SKILL_FILE" | head -1 | cut -d: -f1)
      dashboard_line=$(grep -n 'generate-dashboard.sh' "$SKILL_FILE" | head -1 | cut -d: -f1)
      # dashboard_line が空の場合は失敗
      [ -n "$dashboard_line" ] || return 1
      # backlog 登録行より後にあること
      [ "$dashboard_line" -gt "$backlog_line" ]
    }
    When call check_order
    The status should be success
  End

  It 'generate-dashboard.sh 呼び出しが >>> STOP: Workflow 1 行より前に記載されている'
    check_before_stop() {
      local dashboard_line stop_line
      dashboard_line=$(grep -n 'generate-dashboard.sh' "$SKILL_FILE" | head -1 | cut -d: -f1)
      stop_line=$(grep -n '>>> STOP.*Workflow 1' "$SKILL_FILE" | head -1 | cut -d: -f1)
      # dashboard_line が空の場合は失敗
      [ -n "$dashboard_line" ] || return 1
      # STOP 行より前にあること
      [ "$dashboard_line" -lt "$stop_line" ]
    }
    When call check_before_stop
    The status should be success
  End
End
