Describe 'SKILL.md Workflow 2 Post-Completion Flow ダッシュボード同期呼び出し'
  # T2: Post-Completion Flow の Step 3 で backlog.jsonl ステータス更新後に
  #     generate-dashboard.sh が同期的に呼び出される指示が含まれることを検証する

  SKILL_FILE="core/skills/heartbeat/SKILL.md"

  It 'Post-Completion Flow Step 3 に generate-dashboard.sh の同期実行指示が含まれる'
    # Step 3: Finalize story セクションから Workflow 3 セクションの間に
    # generate-dashboard.sh が存在すること
    extract_step3_section() {
      sed -n '/^### Step 3: Finalize story$/,/^## Workflow 3/p' "$SKILL_FILE"
    }
    When call extract_step3_section
    The output should include 'generate-dashboard.sh'
  End

  It 'generate-dashboard.sh 呼び出しが backlog.jsonl status 更新記述より後に記載されている'
    # "status → \"done\"" 行の行番号 < generate-dashboard.sh 行の行番号 であること
    # ただし Post-Completion Flow Step 3 セクション内のもののみ対象
    check_order() {
      local step3_start step3_end status_line dashboard_line
      step3_start=$(grep -n '^### Step 3: Finalize story$' "$SKILL_FILE" | head -1 | cut -d: -f1)
      step3_end=$(grep -n '^## Workflow 3' "$SKILL_FILE" | head -1 | cut -d: -f1)
      # Step 3 セクション内で status → "done" の行番号を取得
      status_line=$(sed -n "${step3_start},${step3_end}p" "$SKILL_FILE" | grep -n 'status.*done' | head -1 | cut -d: -f1)
      # Step 3 セクション内で generate-dashboard.sh の行番号を取得
      dashboard_line=$(sed -n "${step3_start},${step3_end}p" "$SKILL_FILE" | grep -n 'generate-dashboard.sh' | head -1 | cut -d: -f1)
      # dashboard_line が空の場合は失敗
      [ -n "$dashboard_line" ] || return 1
      # status 更新行より後にあること
      [ "$dashboard_line" -gt "$status_line" ]
    }
    When call check_order
    The status should be success
  End

  It 'generate-dashboard.sh 呼び出しが Workflow 3 セクションより前に記載されている'
    check_before_workflow3() {
      local dashboard_line workflow3_line
      # Post-Completion Flow Step 3 内の generate-dashboard.sh を探す
      # まず Step 3 の開始行を取得
      local step3_start
      step3_start=$(grep -n '^### Step 3: Finalize story$' "$SKILL_FILE" | head -1 | cut -d: -f1)
      # Step 3 以降で generate-dashboard.sh を探す
      dashboard_line=$(tail -n +"$step3_start" "$SKILL_FILE" | grep -n 'generate-dashboard.sh' | head -1 | cut -d: -f1)
      # dashboard_line が空の場合は失敗
      [ -n "$dashboard_line" ] || return 1
      # 絶対行番号に変換
      dashboard_line=$((step3_start + dashboard_line - 1))
      workflow3_line=$(grep -n '^## Workflow 3' "$SKILL_FILE" | head -1 | cut -d: -f1)
      # Workflow 3 セクションより前にあること
      [ "$dashboard_line" -lt "$workflow3_line" ]
    }
    When call check_before_workflow3
    The status should be success
  End
End
