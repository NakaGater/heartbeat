Describe 'SKILL.md Workflow 2 in_progress ステータス遷移'
  # Workflow 2 のストーリー選択直後に backlog.jsonl のステータスを in_progress に更新し、
  # generate-dashboard.sh を同期実行する指示が SKILL.md に含まれることを検証する

  SKILL_FILE="core/skills/heartbeat/SKILL.md"

  # Workflow 2 セクションのみを抽出するヘルパー
  extract_wf2_section() {
    local wf2_start wf2_end
    wf2_start=$(grep -n 'Workflow 2: Implement a Story' "$SKILL_FILE" | head -1 | cut -d: -f1)
    wf2_end=$(grep -n 'Workflow 3:' "$SKILL_FILE" | head -1 | cut -d: -f1)
    sed -n "${wf2_start},${wf2_end}p" "$SKILL_FILE"
  }

  It 'ストーリー選択直後に backlog.jsonl のステータスを in_progress に更新する指示が含まれる'
    # "User selects a story" の後に in_progress と backlog.jsonl を含む指示があること
    check_inprogress_after_selection() {
      local wf2_section selection_line
      wf2_section=$(extract_wf2_section)

      # "User selects a story" 行番号を取得
      selection_line=$(echo "$wf2_section" | grep -n 'User selects a story' | head -1 | cut -d: -f1)
      [ -n "$selection_line" ] || return 1

      # 選択行以降を抽出し、in_progress と backlog.jsonl が含まれることを確認
      echo "$wf2_section" | tail -n "+${selection_line}" | grep 'in_progress' | grep -q 'backlog.jsonl'
    }
    When call check_inprogress_after_selection
    The status should be success
  End

  It 'in_progress 更新直後に generate-dashboard.sh の同期実行指示が含まれる'
    # "User selects a story" の後、"Phase 2" の前に generate-dashboard.sh があること
    check_dashboard_after_inprogress() {
      local wf2_section selection_line phase2_line
      wf2_section=$(extract_wf2_section)

      selection_line=$(echo "$wf2_section" | grep -n 'User selects a story' | head -1 | cut -d: -f1)
      [ -n "$selection_line" ] || return 1

      phase2_line=$(echo "$wf2_section" | grep -n 'Phase 2' | head -1 | cut -d: -f1)
      [ -n "$phase2_line" ] || return 1

      # 選択行と Phase 2 の間に generate-dashboard.sh があること
      echo "$wf2_section" \
        | sed -n "${selection_line},${phase2_line}p" \
        | grep -q 'generate-dashboard.sh'
    }
    When call check_dashboard_after_inprogress
    The status should be success
  End
End
