# Structure test: SKILL.md Choices section uses conditional display logic
# Story: 0057-worktree-workflow-visibility, Task 1
# Completion condition 1: Workflow 1, 2, 3 are always listed;
#   slot 4 is conditional (Workflow 4 or 6)

Describe 'SKILL.md Choices section conditional display'
  SKILL_MD="core/skills/heartbeat/SKILL.md"

  # Verify that Choices section contains "Always shown" block with Workflows 1-3
  # and a "Conditional slot 4" block for Workflow 4/6 switching
  check_always_shown_slots() {
    local choices_section
    choices_section=$(sed -n '/^### Choices/,/^### /p' "$SKILL_MD")

    echo "$choices_section" | grep -q 'Always shown' &&
    echo "$choices_section" | grep -q 'Create a story' &&
    echo "$choices_section" | grep -q 'Implement a story' &&
    echo "$choices_section" | grep -q 'Create and implement a story'
  }

  check_conditional_slot_4() {
    local choices_section
    choices_section=$(sed -n '/^### Choices/,/^### /p' "$SKILL_MD")

    echo "$choices_section" | grep -q 'Conditional slot 4' &&
    echo "$choices_section" | grep -q 'in_progress' &&
    echo "$choices_section" | grep -q 'Continue in-progress story' &&
    echo "$choices_section" | grep -q 'Implement in parallel (worktree)'
  }

  check_workflow5_removed() {
    local choices_section
    choices_section=$(sed -n '/^### Choices/,/^### /p' "$SKILL_MD")

    # Workflow 5 "Manage backlog" must NOT appear as a numbered choice
    ! echo "$choices_section" | grep -q '^\s*[0-9]\+\.\s*\*\*Manage backlog\*\*' &&
    # But a note about /heartbeat-backlog must exist
    echo "$choices_section" | grep -q '/heartbeat-backlog'
  }

  check_max_4_choices_rule() {
    local choices_section
    choices_section=$(sed -n '/^### Choices/,/^### /p' "$SKILL_MD")

    echo "$choices_section" | grep -qi 'never exceed 4\|4 choices\|max.*4'
  }

  It 'has always-shown slots 1-3 with Workflows 1, 2, 3'
    When call check_always_shown_slots
    The status should be success
  End

  It 'has conditional slot 4 switching between Workflow 4 and 6'
    When call check_conditional_slot_4
    The status should be success
  End

  It 'removes Workflow 5 from choices and references /heartbeat-backlog'
    When call check_workflow5_removed
    The status should be success
  End

  It 'enforces a maximum of 4 choices'
    When call check_max_4_choices_rule
    The status should be success
  End
End
