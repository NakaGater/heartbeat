Describe 'SKILL.md Draft Stop Option (Task 1: Claude Code)'
  # Workflow 1 の PdM ヒアリング後・context-manager 前に
  # 「計画に進む / ドラフトで止める」の選択肢が提示されることを検証する

  SKILL_FILE="core/skills/heartbeat/SKILL.md"

  # ヘルパー: Workflow 1 セクション全体を抽出
  extract_wf1() {
    local wf1_start wf1_stop
    wf1_start=$(grep -n 'Workflow 1: Create a Story' "$SKILL_FILE" | head -1 | cut -d: -f1)
    wf1_stop=$(grep -n 'END OF WORKFLOW 1' "$SKILL_FILE" | head -1 | cut -d: -f1)
    sed -n "${wf1_start},${wf1_stop}p" "$SKILL_FILE"
  }

  It 'contains a "Stop at draft" text option after PdM hearing'
    # pdm (hearing) 行と context-manager 行の間に
    # "Stop at draft" が含まれること
    check_stop_at_draft_text() {
      local wf1_section
      wf1_section=$(extract_wf1)

      local hearing_line context_line
      hearing_line=$(echo "$wf1_section" | grep -n 'pdm.*hearing\|hearing.*brief' | head -1 | cut -d: -f1)
      [ -n "$hearing_line" ] || return 1

      context_line=$(echo "$wf1_section" | grep -n 'context-manager' | head -1 | cut -d: -f1)
      [ -n "$context_line" ] || return 1

      # pdm (hearing) 行と context-manager 行の間に "Stop at draft" があること
      echo "$wf1_section" \
        | sed -n "${hearing_line},${context_line}p" \
        | grep -qi 'stop at draft'
    }
    When call check_stop_at_draft_text
    The status should be success
  End

  It 'contains a draft stop choice block after PdM hearing and before context-manager'
    # pdm (hearing) と context-manager の間に選択肢提示パターンと
    # "Continue to planning" と "Stop at draft" の両方が含まれること
    check_draft_stop_choice_block() {
      local wf1_section
      wf1_section=$(extract_wf1)

      local hearing_line context_line between
      hearing_line=$(echo "$wf1_section" | grep -n 'pdm.*hearing\|hearing.*brief' | head -1 | cut -d: -f1)
      [ -n "$hearing_line" ] || return 1

      context_line=$(echo "$wf1_section" | grep -n 'context-manager' | head -1 | cut -d: -f1)
      [ -n "$context_line" ] || return 1

      between=$(echo "$wf1_section" | sed -n "${hearing_line},${context_line}p")

      # "Continue to planning" と "Stop at draft" の両方が存在すること
      echo "$between" | grep -qi 'continue to planning' || return 1
      echo "$between" | grep -qi 'stop at draft' || return 1
    }
    When call check_draft_stop_choice_block
    The status should be success
  End

  It 'contains a note about skipping the draft stop option in Workflow 3'
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

  It 'contains a STOP directive in the draft stop path'
    # "Stop at draft" を選択した場合にワークフローが終了する STOP 指示があること
    check_draft_stop_directive() {
      local wf1_section
      wf1_section=$(extract_wf1)

      local hearing_line context_line between
      hearing_line=$(echo "$wf1_section" | grep -n 'pdm.*hearing\|hearing.*brief' | head -1 | cut -d: -f1)
      [ -n "$hearing_line" ] || return 1

      context_line=$(echo "$wf1_section" | grep -n 'context-manager' | head -1 | cut -d: -f1)
      [ -n "$context_line" ] || return 1

      between=$(echo "$wf1_section" | sed -n "${hearing_line},${context_line}p")

      # STOP または "Return control" や "end" のようなワークフロー終了指示が
      # ドラフト停止パスに含まれること
      echo "$between" | grep -qiE 'STOP|return control|end of workflow|workflow complete'
    }
    When call check_draft_stop_directive
    The status should be success
  End
End

Describe 'SKILL.md Draft Stop Option (Task 2: Copilot)'
  # Copilot 版 SKILL.md の PdM ヒアリング後・context-manager 前に
  # ドラフト停止選択肢が正しく配置されていることを検証する

  COPILOT_SKILL_FILE="adapters/copilot/skills/heartbeat/SKILL.md"

  # ヘルパー: Workflow 1 セクション全体を抽出
  extract_copilot_wf1() {
    local wf1_start wf1_stop
    wf1_start=$(grep -n 'Workflow 1: Create a Story' "$COPILOT_SKILL_FILE" | head -1 | cut -d: -f1)
    wf1_stop=$(grep -n 'END OF WORKFLOW 1' "$COPILOT_SKILL_FILE" | head -1 | cut -d: -f1)
    sed -n "${wf1_start},${wf1_stop}p" "$COPILOT_SKILL_FILE"
  }

  It 'contains Phase 0 section (draft registration) in Copilot version'
    # Workflow 1 内に Phase 0 の記述があり、draft 登録に関する内容を含むこと
    check_copilot_phase0() {
      local wf1_section
      wf1_section=$(extract_copilot_wf1)

      # Phase 0 の見出しが存在すること
      echo "$wf1_section" | grep -qi 'Phase 0' || return 1

      # draft に関する記述が Phase 0 付近にあること
      echo "$wf1_section" | grep -qi 'draft' || return 1
    }
    When call check_copilot_phase0
    The status should be success
  End

  It 'presents a "Stop at draft" option after PdM hearing'
    # pdm (hearing) と context-manager の間に "Stop at draft" が含まれること
    check_copilot_stop_at_draft() {
      local wf1_section
      wf1_section=$(extract_copilot_wf1)

      local hearing_line context_line between
      hearing_line=$(echo "$wf1_section" | grep -n 'pdm.*hearing\|hearing.*brief' | head -1 | cut -d: -f1)
      [ -n "$hearing_line" ] || return 1

      context_line=$(echo "$wf1_section" | grep -n 'context-manager' | head -1 | cut -d: -f1)
      [ -n "$context_line" ] || return 1

      between=$(echo "$wf1_section" | sed -n "${hearing_line},${context_line}p")

      # "Continue to planning" と "Stop at draft" の両方が存在すること
      echo "$between" | grep -qi 'continue to planning' || return 1
      echo "$between" | grep -qi 'stop at draft' || return 1
    }
    When call check_copilot_stop_at_draft
    The status should be success
  End

  It 'contains a note about skipping the draft stop option in Workflow 3'
    # Copilot 版 Workflow 3 セクション内に draft-stop 選択肢のスキップ注記があること
    check_copilot_wf3_skip_draft_stop() {
      local wf3_start wf3_end wf3_section
      wf3_start=$(grep -n 'Workflow 3: Create and Implement' "$COPILOT_SKILL_FILE" | head -1 | cut -d: -f1)
      [ -n "$wf3_start" ] || return 1

      # Workflow 3 の終了は次の "## " セクション
      wf3_end=$(tail -n +"$((wf3_start + 1))" "$COPILOT_SKILL_FILE" | grep -n '^## ' | head -1 | cut -d: -f1)
      if [ -n "$wf3_end" ]; then
        wf3_end=$((wf3_start + wf3_end))
      else
        wf3_end=$(wc -l < "$COPILOT_SKILL_FILE")
      fi

      wf3_section=$(sed -n "${wf3_start},${wf3_end}p" "$COPILOT_SKILL_FILE")

      # ドラフト停止選択肢のスキップに関する記述があること
      echo "$wf3_section" | grep -qi 'draft.*skip\|skip.*draft\|IGNORE.*draft.*stop\|draft.*stop.*IGNORE\|draft.*choice.*skip\|skip.*draft.*choice'
    }
    When call check_copilot_wf3_skip_draft_stop
    The status should be success
  End

  It 'contains a STOP directive in the draft stop path'
    # "Stop at draft" を選択した場合にワークフローが終了する STOP 指示があること
    check_copilot_draft_stop_directive() {
      local wf1_section
      wf1_section=$(extract_copilot_wf1)

      local hearing_line context_line between
      hearing_line=$(echo "$wf1_section" | grep -n 'pdm.*hearing\|hearing.*brief' | head -1 | cut -d: -f1)
      [ -n "$hearing_line" ] || return 1

      context_line=$(echo "$wf1_section" | grep -n 'context-manager' | head -1 | cut -d: -f1)
      [ -n "$context_line" ] || return 1

      between=$(echo "$wf1_section" | sed -n "${hearing_line},${context_line}p")

      # STOP または "Return control" のようなワークフロー終了指示が
      # ドラフト停止パスに含まれること
      echo "$between" | grep -qiE 'STOP|return control|end of workflow|workflow complete'
    }
    When call check_copilot_draft_stop_directive
    The status should be success
  End
End
