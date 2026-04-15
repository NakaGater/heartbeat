# Tests for SKILL.md Phase 3 parallel-group-aware loop rewrite (0056 Task 6)

CLAUDE_SKILL="adapters/claude-code/skills/heartbeat/SKILL.md"

# Helper: extract Phase 3 section from Workflow 2 (from "Phase 3" to "Phase 4")
extract_phase3() {
  sed -n '/^  *Phase 3/,/^  *Phase 4/p' "$CLAUDE_SKILL" | sed '$d'
}

# --- CC1: Phase 3 defines parallel_group-based outer loop ---

check_phase3_has_parallel_group_outer_loop() {
  phase3=$(extract_phase3)
  # Must reference parallel_group as the grouping mechanism
  echo "$phase3" | grep -q "parallel_group" || return 1
  # Must define a group-based loop (for each group / group ascending)
  echo "$phase3" | grep -qi "for each group\|group.*ascending\|グループ.*ループ\|group.*loop" || return 1
}

# --- CC2: Sequential fallback when parallel_group is unset ---

check_phase3_has_sequential_fallback() {
  phase3=$(extract_phase3)
  # Must mention fallback to sequential execution when parallel_group is absent
  echo "$phase3" | grep -qi "parallel_group.*not exist\|parallel_group.*未設定\|sequential.*loop\|逐次.*ループ\|逐次実行\|sequential.*fallback" || return 1
}

# --- CC3: TDD cycle (tester -> implementer -> refactor) maintained inside each parallel task ---

check_phase3_maintains_tdd_cycle() {
  phase3=$(extract_phase3)
  # Must mention tester within the parallel task execution
  echo "$phase3" | grep -q "tester" || return 1
  # Must mention implementer within the parallel task execution
  echo "$phase3" | grep -q "implementer" || return 1
  # Must mention refactor within the parallel task execution
  echo "$phase3" | grep -q "refactor" || return 1
  # Must reference TDD cycle or Red/Green pattern
  echo "$phase3" | grep -qi "TDD\|Red.*Green\|tester.*implementer.*refactor" || return 1
}

# --- CC4: tasks.jsonl updates use tasks-update.sh ---

check_phase3_uses_tasks_update_sh() {
  phase3=$(extract_phase3)
  # Must reference tasks-update.sh for updating tasks.jsonl
  echo "$phase3" | grep -q "tasks-update\.sh" || return 1
}

# --- CC5: All tasks in group must complete before next group ---

check_phase3_has_group_completion_gate() {
  phase3=$(extract_phase3)
  # Must describe waiting for all subagents/tasks in a group to complete before proceeding
  echo "$phase3" | grep -qi "wait.*all.*complete\|全.*完了.*次.*グループ\|all subagents.*complete\|all.*group.*complete" || return 1
}

# --- CC6: Error handling for subagent failure ---

check_phase3_has_error_handling() {
  phase3=$(extract_phase3)
  # Must describe error handling when a subagent fails
  echo "$phase3" | grep -qi "error\|fail\|エラー\|失敗" || return 1
}

Describe 'SKILL.md Phase 3 parallel-group-aware loop (Task 6)'
  It 'defines parallel_group-based outer loop in Phase 3'
    When call check_phase3_has_parallel_group_outer_loop
    The status should be success
  End

  It 'documents sequential fallback when parallel_group is unset'
    When call check_phase3_has_sequential_fallback
    The status should be success
  End

  It 'maintains TDD cycle (tester -> implementer -> refactor) inside each parallel task'
    When call check_phase3_maintains_tdd_cycle
    The status should be success
  End

  It 'specifies tasks-update.sh for tasks.jsonl updates'
    When call check_phase3_uses_tasks_update_sh
    The status should be success
  End

  It 'requires all tasks in group to complete before proceeding to next group'
    When call check_phase3_has_group_completion_gate
    The status should be success
  End

  It 'describes error handling for subagent failure'
    When call check_phase3_has_error_handling
    The status should be success
  End
End
