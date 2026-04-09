Describe 'SKILL.md Draft Stop Option (Task 1: Claude Code)'
  # After PdM hearing in Workflow 1, before context-manager,
  # verify that "Continue to planning / Stop at draft" options are presented

  SKILL_FILE="core/skills/heartbeat/SKILL.md"

  # Helper: Extract the entire Workflow 1 section
  extract_wf1() {
    local wf1_start wf1_stop
    wf1_start=$(grep -n 'Workflow 1: Create a Story' "$SKILL_FILE" | head -1 | cut -d: -f1)
    wf1_stop=$(grep -n 'END OF WORKFLOW 1' "$SKILL_FILE" | head -1 | cut -d: -f1)
    sed -n "${wf1_start},${wf1_stop}p" "$SKILL_FILE"
  }

  It 'contains a "Stop at draft" text option after PdM hearing'
    # Between the pdm (hearing) line and the context-manager line
    # "Stop at draft" should be present
    check_stop_at_draft_text() {
      local wf1_section
      wf1_section=$(extract_wf1)

      local hearing_line context_line
      hearing_line=$(echo "$wf1_section" | grep -n 'pdm.*hearing\|hearing.*brief' | head -1 | cut -d: -f1)
      [ -n "$hearing_line" ] || return 1

      context_line=$(echo "$wf1_section" | grep -n 'context-manager' | head -1 | cut -d: -f1)
      [ -n "$context_line" ] || return 1

      # "Stop at draft" should be between pdm (hearing) and context-manager lines
      echo "$wf1_section" \
        | sed -n "${hearing_line},${context_line}p" \
        | grep -qi 'stop at draft'
    }
    When call check_stop_at_draft_text
    The status should be success
  End

  It 'contains a draft stop choice block after PdM hearing and before context-manager'
    # Between pdm (hearing) and context-manager, a choice block containing
    # both "Continue to planning" and "Stop at draft" should exist
    check_draft_stop_choice_block() {
      local wf1_section
      wf1_section=$(extract_wf1)

      local hearing_line context_line between
      hearing_line=$(echo "$wf1_section" | grep -n 'pdm.*hearing\|hearing.*brief' | head -1 | cut -d: -f1)
      [ -n "$hearing_line" ] || return 1

      context_line=$(echo "$wf1_section" | grep -n 'context-manager' | head -1 | cut -d: -f1)
      [ -n "$context_line" ] || return 1

      between=$(echo "$wf1_section" | sed -n "${hearing_line},${context_line}p")

      # both "Continue to planning" and "Stop at draft" should exist
      echo "$between" | grep -qi 'continue to planning' || return 1
      echo "$between" | grep -qi 'stop at draft' || return 1
    }
    When call check_draft_stop_choice_block
    The status should be success
  End

  It 'contains a note about skipping the draft stop option in Workflow 3'
    # Workflow 3 section contains a NOTE about skipping the draft stop option
    check_wf3_skip_draft_stop() {
      local wf3_start wf3_end wf3_section
      wf3_start=$(grep -n 'Workflow 3: Create and Implement' "$SKILL_FILE" | head -1 | cut -d: -f1)
      [ -n "$wf3_start" ] || return 1

      # Workflow 3 ends at the next "## Workflow" or "## " section
      wf3_end=$(tail -n +"$((wf3_start + 1))" "$SKILL_FILE" | grep -n '^## ' | head -1 | cut -d: -f1)
      if [ -n "$wf3_end" ]; then
        wf3_end=$((wf3_start + wf3_end))
      else
        wf3_end=$(wc -l < "$SKILL_FILE")
      fi

      wf3_section=$(sed -n "${wf3_start},${wf3_end}p" "$SKILL_FILE")

      # Should contain a description about skipping the draft stop option
      # "draft" and "skip" (or IGNORE) should appear in the same NOTE/context
      echo "$wf3_section" | grep -qi 'draft.*skip\|skip.*draft\|IGNORE.*draft.*stop\|draft.*stop.*IGNORE\|draft.*choice.*skip\|skip.*draft.*choice'
    }
    When call check_wf3_skip_draft_stop
    The status should be success
  End

  It 'contains a STOP directive in the draft stop path'
    # A STOP directive should exist for when "Stop at draft" is selected
    check_draft_stop_directive() {
      local wf1_section
      wf1_section=$(extract_wf1)

      local hearing_line context_line between
      hearing_line=$(echo "$wf1_section" | grep -n 'pdm.*hearing\|hearing.*brief' | head -1 | cut -d: -f1)
      [ -n "$hearing_line" ] || return 1

      context_line=$(echo "$wf1_section" | grep -n 'context-manager' | head -1 | cut -d: -f1)
      [ -n "$context_line" ] || return 1

      between=$(echo "$wf1_section" | sed -n "${hearing_line},${context_line}p")

      # A workflow termination directive like STOP, "Return control", or "end"
      # should be present in the draft stop path
      echo "$between" | grep -qiE 'STOP|return control|end of workflow|workflow complete'
    }
    When call check_draft_stop_directive
    The status should be success
  End
End

Describe 'SKILL.md Draft Stop Option (Task 2: Copilot)'
  # In the Copilot version SKILL.md, after PdM hearing and before context-manager,
  # verify that the draft stop option is correctly positioned

  COPILOT_SKILL_FILE="adapters/copilot/skills/heartbeat/SKILL.md"

  # Helper: Extract the entire Workflow 1 section
  extract_copilot_wf1() {
    local wf1_start wf1_stop
    wf1_start=$(grep -n 'Workflow 1: Create a Story' "$COPILOT_SKILL_FILE" | head -1 | cut -d: -f1)
    wf1_stop=$(grep -n 'END OF WORKFLOW 1' "$COPILOT_SKILL_FILE" | head -1 | cut -d: -f1)
    sed -n "${wf1_start},${wf1_stop}p" "$COPILOT_SKILL_FILE"
  }

  It 'contains Phase 0 section (draft registration) in Copilot version'
    # Workflow 1 should contain a Phase 0 description with draft registration content
    check_copilot_phase0() {
      local wf1_section
      wf1_section=$(extract_copilot_wf1)

      # Phase 0 heading should exist
      echo "$wf1_section" | grep -qi 'Phase 0' || return 1

      # draft-related content should exist near Phase 0
      echo "$wf1_section" | grep -qi 'draft' || return 1
    }
    When call check_copilot_phase0
    The status should be success
  End

  It 'presents a "Stop at draft" option after PdM hearing'
    # "Stop at draft" should be between pdm (hearing) and context-manager
    check_copilot_stop_at_draft() {
      local wf1_section
      wf1_section=$(extract_copilot_wf1)

      local hearing_line context_line between
      hearing_line=$(echo "$wf1_section" | grep -n 'pdm.*hearing\|hearing.*brief' | head -1 | cut -d: -f1)
      [ -n "$hearing_line" ] || return 1

      context_line=$(echo "$wf1_section" | grep -n 'context-manager' | head -1 | cut -d: -f1)
      [ -n "$context_line" ] || return 1

      between=$(echo "$wf1_section" | sed -n "${hearing_line},${context_line}p")

      # both "Continue to planning" and "Stop at draft" should exist
      echo "$between" | grep -qi 'continue to planning' || return 1
      echo "$between" | grep -qi 'stop at draft' || return 1
    }
    When call check_copilot_stop_at_draft
    The status should be success
  End

  It 'contains a note about skipping the draft stop option in Workflow 3'
    # Copilot Workflow 3 section should contain a skip note for the draft stop option
    check_copilot_wf3_skip_draft_stop() {
      local wf3_start wf3_end wf3_section
      wf3_start=$(grep -n 'Workflow 3: Create and Implement' "$COPILOT_SKILL_FILE" | head -1 | cut -d: -f1)
      [ -n "$wf3_start" ] || return 1

      # Workflow 3 ends at the next "## " section
      wf3_end=$(tail -n +"$((wf3_start + 1))" "$COPILOT_SKILL_FILE" | grep -n '^## ' | head -1 | cut -d: -f1)
      if [ -n "$wf3_end" ]; then
        wf3_end=$((wf3_start + wf3_end))
      else
        wf3_end=$(wc -l < "$COPILOT_SKILL_FILE")
      fi

      wf3_section=$(sed -n "${wf3_start},${wf3_end}p" "$COPILOT_SKILL_FILE")

      # Should contain a description about skipping the draft stop option
      echo "$wf3_section" | grep -qi 'draft.*skip\|skip.*draft\|IGNORE.*draft.*stop\|draft.*stop.*IGNORE\|draft.*choice.*skip\|skip.*draft.*choice'
    }
    When call check_copilot_wf3_skip_draft_stop
    The status should be success
  End

  It 'contains a STOP directive in the draft stop path'
    # A STOP directive should exist for when "Stop at draft" is selected
    check_copilot_draft_stop_directive() {
      local wf1_section
      wf1_section=$(extract_copilot_wf1)

      local hearing_line context_line between
      hearing_line=$(echo "$wf1_section" | grep -n 'pdm.*hearing\|hearing.*brief' | head -1 | cut -d: -f1)
      [ -n "$hearing_line" ] || return 1

      context_line=$(echo "$wf1_section" | grep -n 'context-manager' | head -1 | cut -d: -f1)
      [ -n "$context_line" ] || return 1

      between=$(echo "$wf1_section" | sed -n "${hearing_line},${context_line}p")

      # A workflow termination directive like STOP or "Return control"
      # should be present in the draft stop path
      echo "$between" | grep -qiE 'STOP|return control|end of workflow|workflow complete'
    }
    When call check_copilot_draft_stop_directive
    The status should be success
  End
End
