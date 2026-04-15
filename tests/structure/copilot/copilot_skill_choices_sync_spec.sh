# Structure test: Copilot SKILL.md mirrors core conditional-display Choices
# and max-4 updates (story 0057, task 4)
#
# Verifies that adapters/copilot/skills/heartbeat/SKILL.md has:
#   - Conditional display logic (Always shown slots 1-3, Conditional slot 4)
#   - Workflow 5 removed from choices; /heartbeat-backlog referenced
#   - "max 4" in Question Style Guidelines, Strict Rules, Request Optimization
#   - Copilot-specific worktree annotation preserved

COPILOT_SKILL="adapters/copilot/skills/heartbeat/SKILL.md"

# --- Choices section: conditional display ---

choices_section() {
  sed -n '/^### Choices/,/^### /p' "$COPILOT_SKILL"
}

check_always_shown_slots() {
  choices_section | grep -q 'Always shown' &&
  choices_section | grep -q 'Create a story' &&
  choices_section | grep -q 'Implement a story' &&
  choices_section | grep -q 'Create and implement a story'
}

check_conditional_slot_4() {
  choices_section | grep -q 'Conditional slot 4' &&
  choices_section | grep -q 'in_progress' &&
  choices_section | grep -q 'Continue in-progress story' &&
  choices_section | grep -q 'Implement in parallel (worktree)'
}

check_workflow5_removed() {
  # Workflow 5 "Manage backlog" must NOT appear as a numbered choice
  ! choices_section | grep -q '^\s*[0-9]\+\.\s*\*\*Manage backlog\*\*' &&
  # But a note about /heartbeat-backlog must exist
  choices_section | grep -q '/heartbeat-backlog'
}

check_max_4_in_choices() {
  choices_section | grep -qi 'never exceed 4\|4 choices\|max.*4'
}

# --- Question Style Guidelines: max 4 ---

check_guidelines_max4() {
  sed -n '/## Question Style Guidelines/,/^## /p' "$COPILOT_SKILL" \
    | grep -q 'max 4 choices per question'
}

# --- Strict Rules: max 4 ---

check_strict_rules_max4() {
  sed -n '/## Strict Rules/,/^## /p' "$COPILOT_SKILL" \
    | grep -q 'max 4'
}

# --- Copilot-specific: Request Optimization table max 4 ---

check_request_optimization_max4() {
  sed -n '/## Copilot-Specific: Request Optimization/,/^## /p' "$COPILOT_SKILL" \
    | grep -q 'max 4 choices'
}

check_workflow_selection_4_choices() {
  sed -n '/## Copilot-Specific: Request Optimization/,/^## /p' "$COPILOT_SKILL" \
    | grep -i 'workflow selection' \
    | grep -q '4 choices'
}

# --- Copilot-specific annotation preserved ---

check_copilot_worktree_annotation() {
  grep -q 'Copilot.*requires manual.*git worktree' "$COPILOT_SKILL" ||
  grep -q 'Copilot.*worktree.*manual' "$COPILOT_SKILL"
}

# ========================================
Describe 'Copilot SKILL.md Choices conditional display (0057 task 4)'
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

  It 'enforces a maximum of 4 choices in Choices section'
    When call check_max_4_in_choices
    The status should be success
  End
End

Describe 'Copilot SKILL.md max 4 sync (0057 task 4)'
  It 'has "max 4 choices per question" in Question Style Guidelines'
    When call check_guidelines_max4
    The status should be success
  End

  It 'has "max 4" in Strict Rules'
    When call check_strict_rules_max4
    The status should be success
  End

  It 'has "max 4 choices" in Request Optimization table'
    When call check_request_optimization_max4
    The status should be success
  End

  It 'shows "4 choices" for Workflow selection in Request Optimization'
    When call check_workflow_selection_4_choices
    The status should be success
  End
End

Describe 'Copilot SKILL.md preserves Copilot-specific annotations (0057 task 4)'
  It 'preserves the Copilot worktree manual annotation'
    When call check_copilot_worktree_annotation
    The status should be success
  End
End
