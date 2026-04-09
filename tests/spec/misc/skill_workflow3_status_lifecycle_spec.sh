Describe 'SKILL.md Workflow 3 Status Lifecycle'
  # Verify that the Workflow 3 section contains a NOTE indicating that
  # the draft -> ready -> in_progress -> done status lifecycle
  # is automatically inherited via Workflow 1 + 2

  SKILL_FILE="core/skills/heartbeat/SKILL.md"

  # Helper: extract only the Workflow 3 section
  extract_wf3_section() {
    local wf3_start wf3_end
    wf3_start=$(grep -n 'Workflow 3: Create and Implement' "$SKILL_FILE" | head -1 | cut -d: -f1)
    wf3_end=$(grep -n '^## ' "$SKILL_FILE" | awk -F: -v start="$wf3_start" '$1 > start {print $1; exit}')
    sed -n "${wf3_start},${wf3_end}p" "$SKILL_FILE"
  }

  It 'contains a description that status lifecycle (draft -> ready -> in_progress -> done) is inherited from Workflow 1 + 2'
    check_lifecycle_note() {
      local wf3_section
      wf3_section=$(extract_wf3_section)

      # All 4 statuses (draft, ready, in_progress, done) should be described
      echo "$wf3_section" | grep -q 'draft' || return 1
      echo "$wf3_section" | grep -q 'ready' || return 1
      echo "$wf3_section" | grep -q 'in_progress' || return 1
      echo "$wf3_section" | grep -q 'done' || return 1

      # Should explicitly state inheritance from Workflow 1 and Workflow 2
      echo "$wf3_section" | grep -i 'workflow 1' | grep -qi 'workflow 2' || \
        echo "$wf3_section" | grep -qi 'inherit' || \
        echo "$wf3_section" | grep -qi '継承' || return 1
    }
    When call check_lifecycle_note
    The status should be success
  End
End
