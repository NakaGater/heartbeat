# Tests for architect.md 3pt gate rule (point-criteria story, Task 2)

ARCHITECT="core/agent-personas/architect.md"

# --- CC1: When estimate is 3pt, persona instructs returning to PdM with split_story/rework ---

check_3pt_gate_subsection() {
  grep -q "### 3pt Gate Rule" "$ARCHITECT" || return 1
}

check_3pt_returns_to_pdm() {
  grep -q "split_story" "$ARCHITECT" || return 1
  grep -q "rework" "$ARCHITECT" || return 1
}

# --- CC2: Board protocol rules contain 3pt-specific entry ---

check_board_protocol_3pt_entry() {
  # Must have a board protocol entry with to: "pdm", action: "split_story"
  grep -q 'to:.*"pdm".*action:.*"split_story"' "$ARCHITECT" || \
  grep -q 'to: "pdm", action: "split_story"' "$ARCHITECT" || return 1
}

check_board_protocol_3pt_status() {
  # The 3pt board protocol entry must include status: "rework"
  grep -q 'to: "pdm".*status: "rework"' "$ARCHITECT" || \
  grep -q '"to": "pdm".*"status": "rework"' "$ARCHITECT" || return 1
}

# --- CC3: When 3pt gate is triggered, do NOT output tasks.md ---

check_no_tasks_output_on_3pt() {
  # The file must instruct NOT to output tasks.md when estimate is 3pt
  grep -qi "3pt.*NOT.*tasks\.md\|do NOT output tasks\.md\|NOT proceed.*tasks" "$ARCHITECT" || return 1
}

Describe 'Architect 3pt gate rule (Task 2)'
  It 'contains a 3pt Gate Rule subsection'
    When call check_3pt_gate_subsection
    The status should be success
  End

  It 'instructs returning to PdM with split_story and rework when estimate is 3pt'
    When call check_3pt_returns_to_pdm
    The status should be success
  End

  It 'has a board protocol entry with to pdm and action split_story'
    When call check_board_protocol_3pt_entry
    The status should be success
  End

  It 'has a board protocol entry with status rework for 3pt'
    When call check_board_protocol_3pt_status
    The status should be success
  End

  It 'instructs NOT to output tasks.md when estimate is 3pt'
    When call check_no_tasks_output_on_3pt
    The status should be success
  End
End
