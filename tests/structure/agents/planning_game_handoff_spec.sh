# Tests for practices.md and handoff-protocol.md updates (point-criteria story, Task 4)

PRACTICES="core/xp/practices.md"
HANDOFF="core/xp/handoff-protocol.md"

# --- CC1: Planning Game defines "too large" as 3pt under complexity/uncertainty scale ---

check_planning_game_3pt_too_large() {
  grep -qi "3pt.*too large\|too large.*3pt\|estimated at 3pt\|3pt.*must not proceed\|3pt.*not proceed" "$PRACTICES" || return 1
}

check_planning_game_complexity_uncertainty() {
  grep -qi "complexity.*uncertainty\|complexity/uncertainty" "$PRACTICES" || return 1
}

check_planning_game_3_level_scale() {
  grep -qi "Clear.*Challenging.*Uncertain\|1pt.*2pt.*3pt" "$PRACTICES" || return 1
}

# --- CC2: Architect section in handoff-protocol.md includes 3pt handoff rule ---

check_handoff_architect_3pt_to_pdm() {
  grep -q 'to="pdm"' "$HANDOFF" || return 1
}

check_handoff_architect_3pt_split_story() {
  grep -q 'action="split_story"' "$HANDOFF" || return 1
}

check_handoff_architect_3pt_rework() {
  grep -q 'status="rework"' "$HANDOFF" || return 1
}

# --- CC3: Handoff Flow diagram shows 3pt branch ---

check_flow_diagram_3pt_branch() {
  grep -qi "3pt.*pdm\|if 3pt\|\[if 3pt\]" "$HANDOFF" || return 1
}

Describe 'Planning Game practice and handoff protocol (Task 4)'

  Describe 'practices.md Planning Game update'
    It 'defines too large as 3pt'
      When call check_planning_game_3pt_too_large
      The status should be success
    End

    It 'references complexity/uncertainty as the basis for estimation'
      When call check_planning_game_complexity_uncertainty
      The status should be success
    End

    It 'mentions the 3-level scale (Clear, Challenging, Uncertain)'
      When call check_planning_game_3_level_scale
      The status should be success
    End
  End

  Describe 'handoff-protocol.md Architect 3pt handoff rule'
    It 'includes a handoff rule with to=pdm'
      When call check_handoff_architect_3pt_to_pdm
      The status should be success
    End

    It 'includes a handoff rule with action=split_story'
      When call check_handoff_architect_3pt_split_story
      The status should be success
    End

    It 'includes a handoff rule with status=rework'
      When call check_handoff_architect_3pt_rework
      The status should be success
    End
  End

  Describe 'handoff-protocol.md flow diagram 3pt branch'
    It 'shows a 3pt branch in the flow diagram'
      When call check_flow_diagram_3pt_branch
      The status should be success
    End
  End

End
