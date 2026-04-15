# Structure test: adapters/claude-code SKILL.md is synced with core SKILL.md
# Story: 0057-worktree-workflow-visibility, Task 3
# Verifies that the claude-code adapter has the same Choices conditional
# display logic and max 4 guidelines as core SKILL.md.

Describe 'adapters/claude-code SKILL.md sync with core'
  ADAPTER_SKILL="adapters/claude-code/skills/heartbeat/SKILL.md"

  # CC1: Choices section has Always shown slots 1-3 and Conditional slot 4
  check_conditional_display() {
    local choices_section
    choices_section=$(sed -n '/^### Choices/,/^### /p' "$ADAPTER_SKILL")

    echo "$choices_section" | grep -q 'Always shown' &&
    echo "$choices_section" | grep -q 'Conditional slot 4' &&
    echo "$choices_section" | grep -q 'Create a story' &&
    echo "$choices_section" | grep -q 'Implement a story' &&
    echo "$choices_section" | grep -q 'Create and implement a story' &&
    echo "$choices_section" | grep -q 'Continue in-progress story' &&
    echo "$choices_section" | grep -q 'Implement in parallel (worktree)'
  }

  # CC2: Workflow 5 is removed from Choices and /heartbeat-backlog is referenced
  check_workflow5_removed() {
    local choices_section
    choices_section=$(sed -n '/^### Choices/,/^### /p' "$ADAPTER_SKILL")

    ! echo "$choices_section" | grep -q '^\s*[0-9]\+\.\s*\*\*Manage backlog\*\*' &&
    echo "$choices_section" | grep -q '/heartbeat-backlog'
  }

  # CC3: Question Style Guidelines says "max 4 choices per question"
  check_guidelines_max4() {
    sed -n '/## Question Style Guidelines/,/^## /p' "$ADAPTER_SKILL" \
      | grep -q 'max 4 choices per question'
  }

  # CC4: Strict Rules says "max 4"
  check_strict_rules_max4() {
    sed -n '/## Strict Rules/,/^## /p' "$ADAPTER_SKILL" \
      | grep -q 'max 4'
  }

  It 'has conditional display logic (Always shown + Conditional slot 4)'
    When call check_conditional_display
    The status should be success
  End

  It 'removes Workflow 5 and references /heartbeat-backlog'
    When call check_workflow5_removed
    The status should be success
  End

  It 'specifies max 4 choices per question in Question Style Guidelines'
    When call check_guidelines_max4
    The status should be success
  End

  It 'specifies max 4 in Strict Rules'
    When call check_strict_rules_max4
    The status should be success
  End
End
