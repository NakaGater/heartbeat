# Structure test: Verify Copilot SKILL.md has vscode_askQuestions choice parameter guidance
# Task 4: Reflect choice-based guidelines in Copilot SKILL.md

COPILOT_SKILL="adapters/copilot/skills/heartbeat/SKILL.md"

# Rule 1: AP1 choices are explicitly listed with vscode_askQuestions
check_rule1_ap1_choices() {
  # Rule 1 section must explicitly list AP1 choice options
  grep -A 20 'Rule 1' "$COPILOT_SKILL" | grep -q 'Approve.*Reject'
}

# Rule 1: AP3 choices are explicitly listed with vscode_askQuestions
check_rule1_ap3_choices() {
  # Rule 1 section must explicitly list AP3 choice options
  grep -A 20 'Rule 1' "$COPILOT_SKILL" | grep -q 'Pass.*Reject'
}

# Rule 1: Sendback reason retrieval method is documented
check_rule1_sendback_reason() {
  grep -A 30 'Rule 1' "$COPILOT_SKILL" | grep -q 'vscode_askQuestions.*reason'
}

# Rule 3: Category auto-inference is documented
check_rule3_category_inference() {
  grep -A 20 'Rule 3' "$COPILOT_SKILL" | grep -qi 'auto.*infer.*category\|category.*infer'
}

# Rule 3: Fallback to vscode_askQuestions for category selection when inference fails
check_rule3_fallback_ask() {
  grep -A 20 'Rule 3' "$COPILOT_SKILL" | grep -q 'vscode_askQuestions.*category'
}

# --- Task 1: 8 mandatory vscode_askQuestions call sites ---
# Helper: extract Rule 1 section only
rule1_section() {
  sed -n '/### Rule 1/,/### Rule 2/p' "$COPILOT_SKILL"
}

# Rule 1: Workflow selection uses vscode_askQuestions
check_rule1_workflow_selection() {
  rule1_section | grep -qi 'workflow selection'
}

# Rule 1: WF1 category selection uses vscode_askQuestions
check_rule1_wf1_category() {
  rule1_section | grep -qi 'category selection'
}

# Rule 1: WF1 detail input (free text) uses vscode_askQuestions
check_rule1_wf1_detail_input() {
  rule1_section | grep -qi 'detail input'
}

# Rule 1: 3pt escape hatch uses vscode_askQuestions
check_rule1_3pt_escape_hatch() {
  rule1_section | grep -qi 'escape hatch'
}

# Rule 1: WF2 story selection uses vscode_askQuestions
check_rule1_wf2_story_selection() {
  rule1_section | grep -qi 'story selection'
}

# Rule 1: AP3 rejection target phase selection uses vscode_askQuestions
check_rule1_ap3_phase_selection() {
  rule1_section | grep -qi 'rejection target phase'
}

# Rule 1: Block report uses vscode_askQuestions
check_rule1_blocked_report() {
  rule1_section | grep -qi 'block report'
}

# Rule 1: Orchestrator uncertainty uses vscode_askQuestions
check_rule1_orchestrator_uncertainty() {
  rule1_section | grep -qi 'orchestrator uncertainty'
}

Describe 'Copilot SKILL.md vscode_askQuestions choice parameter guidance'
  It 'Rule 1 specifies AP1 choices for vscode_askQuestions'
    When call check_rule1_ap1_choices
    The status should be success
  End

  It 'Rule 1 specifies AP3 choices for vscode_askQuestions'
    When call check_rule1_ap3_choices
    The status should be success
  End

  It 'Rule 1 describes sendback reason retrieval via vscode_askQuestions'
    When call check_rule1_sendback_reason
    The status should be success
  End

  It 'Rule 3 describes category auto-inference from user input'
    When call check_rule3_category_inference
    The status should be success
  End

  It 'Rule 3 describes vscode_askQuestions fallback for category selection'
    When call check_rule3_fallback_ask
    The status should be success
  End
End

Describe 'Copilot SKILL.md Rule 1: Mandatory vscode_askQuestions for All User Interactions'
  It 'Rule 1 specifies vscode_askQuestions for workflow selection'
    When call check_rule1_workflow_selection
    The status should be success
  End

  It 'Rule 1 specifies vscode_askQuestions for WF1 category selection'
    When call check_rule1_wf1_category
    The status should be success
  End

  It 'Rule 1 specifies vscode_askQuestions for WF1 detail input (free text)'
    When call check_rule1_wf1_detail_input
    The status should be success
  End

  It 'Rule 1 specifies vscode_askQuestions for 3pt escape hatch'
    When call check_rule1_3pt_escape_hatch
    The status should be success
  End

  It 'Rule 1 specifies vscode_askQuestions for WF2 story selection'
    When call check_rule1_wf2_story_selection
    The status should be success
  End

  It 'Rule 1 specifies vscode_askQuestions for AP3 phase selection after sendback'
    When call check_rule1_ap3_phase_selection
    The status should be success
  End

  It 'Rule 1 specifies vscode_askQuestions for blocked report'
    When call check_rule1_blocked_report
    The status should be success
  End

  It 'Rule 1 specifies vscode_askQuestions for orchestrator uncertainty'
    When call check_rule1_orchestrator_uncertainty
    The status should be success
  End
End
