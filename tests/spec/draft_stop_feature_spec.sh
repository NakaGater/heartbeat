Describe 'SKILL.md ドラフト停止選択肢（Task 1: Claude Code 版）'
  # Workflow 1 の Phase 0 完了後・Phase 1 開始前に
  # 「計画に進む / ドラフトで止める」の選択肢が提示されることを検証する

  SKILL_FILE="core/skills/heartbeat/SKILL.md"

  # ヘルパー: Workflow 1 セクション全体を抽出
  extract_wf1() {
    local wf1_start wf1_stop
    wf1_start=$(grep -n 'Workflow 1: Create a Story' "$SKILL_FILE" | head -1 | cut -d: -f1)
    wf1_stop=$(grep -n 'END OF WORKFLOW 1' "$SKILL_FILE" | head -1 | cut -d: -f1)
    sed -n "${wf1_start},${wf1_stop}p" "$SKILL_FILE"
  }

  It 'Phase 0 完了後に "Stop at draft" テキストを含む選択肢が存在する'
    # Phase 0 の generate-dashboard.sh 行と Phase 1 開始行の間に
    # "Stop at draft" が含まれること
    check_stop_at_draft_text() {
      local wf1_section
      wf1_section=$(extract_wf1)

      local dashboard_line phase1_line
      dashboard_line=$(echo "$wf1_section" | grep -n 'generate-dashboard.sh' | head -1 | cut -d: -f1)
      [ -n "$dashboard_line" ] || return 1

      phase1_line=$(echo "$wf1_section" | grep -n 'Phase 1 - Planning' | head -1 | cut -d: -f1)
      [ -n "$phase1_line" ] || return 1

      # Phase 0 の dashboard 行と Phase 1 の間に "Stop at draft" があること
      echo "$wf1_section" \
        | sed -n "${dashboard_line},${phase1_line}p" \
        | grep -qi 'stop at draft'
    }
    When call check_stop_at_draft_text
    The status should be success
  End

  It 'Phase 0 完了後・Phase 1 開始前にドラフト停止の選択肢ブロックが存在する'
    # Phase 0 と Phase 1 の間に選択肢提示パターン（Present choices または choices）と
    # "Continue to planning" と "Stop at draft" の両方が含まれること
    check_draft_stop_choice_block() {
      local wf1_section
      wf1_section=$(extract_wf1)

      local dashboard_line phase1_line between
      dashboard_line=$(echo "$wf1_section" | grep -n 'generate-dashboard.sh' | head -1 | cut -d: -f1)
      [ -n "$dashboard_line" ] || return 1

      phase1_line=$(echo "$wf1_section" | grep -n 'Phase 1 - Planning' | head -1 | cut -d: -f1)
      [ -n "$phase1_line" ] || return 1

      between=$(echo "$wf1_section" | sed -n "${dashboard_line},${phase1_line}p")

      # "Continue to planning" と "Stop at draft" の両方が存在すること
      echo "$between" | grep -qi 'continue to planning' || return 1
      echo "$between" | grep -qi 'stop at draft' || return 1
    }
    When call check_draft_stop_choice_block
    The status should be success
  End

  It 'Workflow 3 にドラフト停止選択肢をスキップする旨の注記がある'
    # Workflow 3 セクション内に draft-stop の選択肢をスキップする NOTE がある
    check_wf3_skip_draft_stop() {
      local wf3_start wf3_end wf3_section
      wf3_start=$(grep -n 'Workflow 3: Create and Implement' "$SKILL_FILE" | head -1 | cut -d: -f1)
      [ -n "$wf3_start" ] || return 1

      # Workflow 3 の終了は次の "## Workflow" か "## " セクション
      wf3_end=$(tail -n +"$((wf3_start + 1))" "$SKILL_FILE" | grep -n '^## ' | head -1 | cut -d: -f1)
      if [ -n "$wf3_end" ]; then
        wf3_end=$((wf3_start + wf3_end))
      else
        wf3_end=$(wc -l < "$SKILL_FILE")
      fi

      wf3_section=$(sed -n "${wf3_start},${wf3_end}p" "$SKILL_FILE")

      # ドラフト停止選択肢のスキップに関する記述があること
      # "draft" と "skip" (または IGNORE) が同じ NOTE/文脈に含まれること
      echo "$wf3_section" | grep -qi 'draft.*skip\|skip.*draft\|IGNORE.*draft.*stop\|draft.*stop.*IGNORE\|draft.*choice.*skip\|skip.*draft.*choice'
    }
    When call check_wf3_skip_draft_stop
    The status should be success
  End

  It 'ドラフト停止パスに STOP ディレクティブが存在する'
    # "Stop at draft" を選択した場合にワークフローが終了する STOP 指示があること
    check_draft_stop_directive() {
      local wf1_section
      wf1_section=$(extract_wf1)

      local dashboard_line phase1_line between
      dashboard_line=$(echo "$wf1_section" | grep -n 'generate-dashboard.sh' | head -1 | cut -d: -f1)
      [ -n "$dashboard_line" ] || return 1

      phase1_line=$(echo "$wf1_section" | grep -n 'Phase 1 - Planning' | head -1 | cut -d: -f1)
      [ -n "$phase1_line" ] || return 1

      between=$(echo "$wf1_section" | sed -n "${dashboard_line},${phase1_line}p")

      # STOP または "Return control" や "end" のようなワークフロー終了指示が
      # ドラフト停止パスに含まれること
      echo "$between" | grep -qiE 'STOP|return control|end of workflow|workflow complete'
    }
    When call check_draft_stop_directive
    The status should be success
  End
End
