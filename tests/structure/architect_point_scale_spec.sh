# Tests for architect.md point estimation scale (point-criteria story, Task 1)

ARCHITECT="core/agent-personas/architect.md"

# --- CC1: File contains a section defining three point levels ---

check_point_estimation_scale_section() {
  grep -q "## Point Estimation Scale" "$ARCHITECT" || return 1
}

# --- CC1 (cont): Three levels with explicit criteria ---

check_three_point_levels() {
  grep -q "1pt.*Clear" "$ARCHITECT" || return 1
  grep -q "2pt.*Challenging" "$ARCHITECT" || return 1
  grep -q "3pt.*Uncertain" "$ARCHITECT" || return 1
}

# --- CC3: Each level has both "Criteria" and "What it means" ---

check_criteria_and_meaning() {
  grep -q "Criteria" "$ARCHITECT" || return 1
  grep -q "What it means" "$ARCHITECT" || return 1
}

# --- CC2: No workload-based estimation guidance exists ---

check_no_workload_language() {
  # The file must NOT contain workload/effort-based estimation language
  # in the estimation guidance. Grep returns 0 if found, so we invert.
  if grep -qi "workload" "$ARCHITECT"; then
    return 1
  fi
  if grep -qi "effort.based" "$ARCHITECT"; then
    return 1
  fi
  return 0
}

# --- CC1 (cont): Points measure complexity and uncertainty ---

check_complexity_uncertainty_basis() {
  grep -q "complexity and uncertainty" "$ARCHITECT" || \
  grep -q "complexity/uncertainty" "$ARCHITECT" || return 1
}

Describe 'Architect point estimation scale (Task 1)'
  It 'contains a Point Estimation Scale section'
    When call check_point_estimation_scale_section
    The status should be success
  End

  It 'defines three point levels: 1pt Clear, 2pt Challenging, 3pt Uncertain'
    When call check_three_point_levels
    The status should be success
  End

  It 'includes Criteria and What it means columns for each level'
    When call check_criteria_and_meaning
    The status should be success
  End

  It 'does not contain workload or effort-based estimation language'
    When call check_no_workload_language
    The status should be success
  End

  It 'states that points measure complexity and uncertainty'
    When call check_complexity_uncertainty_basis
    The status should be success
  End
End
