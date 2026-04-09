# Tests for pdm.md 3pt return handling (point-criteria story, Task 3)

PDM="core/agent-personas/pdm.md"

# --- CC1: When PdM receives split_story/rework, persona documents three response options ---

check_handling_3pt_returns_section() {
  grep -q "## Handling 3pt Returns" "$PDM" || return 1
}

check_response_option_split() {
  grep -qi "Split.*break.*stories\|Split.*sub-stories\|Split.*smaller" "$PDM" || return 1
}

check_response_option_redefine() {
  grep -qi "Redefine.*narrow.*scope\|Redefine.*reduce.*uncertainty" "$PDM" || return 1
}

check_response_option_spike() {
  grep -qi "Spike.*research\|Spike.*time-boxed\|Spike.*gather.*information" "$PDM" || return 1
}

# --- CC2: After rework, story must reach 1pt or 2pt before proceeding ---

check_re_estimation_requirement() {
  grep -qi "must reach 1pt or 2pt\|must.*1pt or 2pt.*before\|reach 1pt or 2pt" "$PDM" || return 1
}

# --- CC3: Human override escape hatch documented ---

check_escape_hatch() {
  grep -qi "escape hatch\|human.*override\|human can override" "$PDM" || return 1
}

Describe 'PdM 3pt return handling (Task 3)'
  It 'contains a Handling 3pt Returns section'
    When call check_handling_3pt_returns_section
    The status should be success
  End

  It 'documents Split as a response option'
    When call check_response_option_split
    The status should be success
  End

  It 'documents Redefine as a response option'
    When call check_response_option_redefine
    The status should be success
  End

  It 'documents Spike as a response option'
    When call check_response_option_spike
    The status should be success
  End

  It 'requires re-estimation at 1pt or 2pt before proceeding'
    When call check_re_estimation_requirement
    The status should be success
  End

  It 'documents the human override escape hatch'
    When call check_escape_hatch
    The status should be success
  End
End
