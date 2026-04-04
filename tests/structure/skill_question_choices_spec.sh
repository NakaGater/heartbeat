# Structure test: SKILL.md question/choice patterns
# Consolidated from:
#   skill_approval_choices_spec.sh (4 It)
#   skill_blocked_choices_spec.sh (2 It)
#   skill_hybrid_questions_spec.sh (4 It)
# Story: 0042-test-cleanup, Task 4 (AC-3)

Describe 'SKILL.md question and choice patterns'
  # Shared file path
  SKILL_MD="core/skills/heartbeat/SKILL.md"

  # --- Approval-type choices (4 It) ---

  check_ap1_has_choices() {
    grep -q 'Present choices:.*Approve.*Send back' "$SKILL_MD"
  }

  check_ap2_has_choices() {
    grep -q 'Present choices:.*Approve.*Request changes' "$SKILL_MD"
  }

  check_ap3_has_choices() {
    grep -q 'Present choices:.*Pass.*Send back' "$SKILL_MD"
  }

  check_3pt_escape_has_choices() {
    grep -q 'Present choices:.*Continue with 3pt.*Split the story' "$SKILL_MD"
  }

  It 'AP1 (story approval) presents explicit choices'
    When call check_ap1_has_choices
    The status should be success
  End

  It 'AP2 (task decomposition approval) presents explicit choices'
    When call check_ap2_has_choices
    The status should be success
  End

  It 'AP3 (final result report) presents explicit choices'
    When call check_ap3_has_choices
    The status should be success
  End

  It '3pt escape hatch presents explicit choices'
    When call check_3pt_escape_has_choices
    The status should be success
  End

  # --- Blocked/uncertainty choices (2 It) ---

  check_blocked_has_choices() {
    grep -q 'Clarify the spec' "$SKILL_MD" &&
    grep -q 'Mark as out of scope' "$SKILL_MD" &&
    grep -q 'Have the agent reconsider' "$SKILL_MD" &&
    grep -q 'Other (free text)' "$SKILL_MD"
  }

  check_uncertainty_has_choices() {
    grep -q 'orchestrator uncertainty' "$SKILL_MD" &&
    grep -q 'situation-specific choices' "$SKILL_MD"
  }

  It 'blocked reports forwarded to human present resolution choices'
    When call check_blocked_has_choices
    The status should be success
  End

  It 'orchestrator uncertainty presents situation-specific choices'
    When call check_uncertainty_has_choices
    The status should be success
  End

  # --- Hybrid question format (4 It) ---

  check_wf1_has_hybrid() {
    grep -q '2-step hybrid' "$SKILL_MD" &&
    grep -A 20 'Workflow 1' "$SKILL_MD" | grep -q 'Category selection'
  }

  check_wf1_has_categories() {
    grep -A 20 'Workflow 1' "$SKILL_MD" | grep -q 'Bug fix'
  }

  check_wf3_has_hybrid() {
    grep -A 20 'Workflow 3' "$SKILL_MD" | grep -q 'Category selection'
  }

  check_has_other_fallback() {
    grep -q 'Other' "$SKILL_MD" &&
    grep -A 30 'Workflow 1' "$SKILL_MD" | grep -q 'Detail input'
  }

  It 'WF1 question uses 2-step hybrid format'
    When call check_wf1_has_hybrid
    The status should be success
  End

  It 'WF1 presents category choices including Bug fix'
    When call check_wf1_has_categories
    The status should be success
  End

  It 'WF3 presents category selection step'
    When call check_wf3_has_hybrid
    The status should be success
  End

  It 'hybrid format includes Detail input as fallback step'
    When call check_has_other_fallback
    The status should be success
  End
End
