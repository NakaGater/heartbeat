# Tests for architect.md parallel group criteria (0056 Task 4)

ARCHITECT="core/agent-personas/architect.md"

# --- CC1: Parallel group criteria section exists in architect.md ---

check_parallel_group_criteria_section() {
  grep -qi "並列グループ判定基準\|Parallel Group.*Criteria" "$ARCHITECT" || return 1
}

# --- CC2: Same-file Modify rule is documented ---

check_same_file_modify_rule() {
  grep -qi "同じファイルを.*Modify.*同一グループ不可\|Modify.*same file.*cannot.*same group" "$ARCHITECT" || return 1
}

# --- CC3: Parallel execution group section in tasks.md template ---

check_tasks_md_template_parallel_section() {
  grep -qi "並列実行グループ\|Parallel.*Execution.*Group" "$ARCHITECT" || return 1
}

# --- CC4: tasks.jsonl schema defines parallel_group and depends_on ---

check_tasks_jsonl_schema_parallel_group() {
  grep -q "parallel_group" "$ARCHITECT" || return 1
}

check_tasks_jsonl_schema_depends_on() {
  grep -q "depends_on" "$ARCHITECT" || return 1
}

# --- CC5: Backward compatibility with sequential fallback documented ---

check_backward_compat_sequential_fallback() {
  grep -qi "逐次実行\|sequential.*fallback\|後方互換\|backward.*compat" "$ARCHITECT" || return 1
}

Describe 'Architect parallel group criteria (Task 4)'
  It 'contains a parallel group criteria section'
    When call check_parallel_group_criteria_section
    The status should be success
  End

  It 'states that tasks modifying the same file cannot be in the same group'
    When call check_same_file_modify_rule
    The status should be success
  End

  It 'includes a parallel execution group section in tasks.md template'
    When call check_tasks_md_template_parallel_section
    The status should be success
  End

  It 'defines parallel_group field in tasks.jsonl schema'
    When call check_tasks_jsonl_schema_parallel_group
    The status should be success
  End

  It 'defines depends_on field in tasks.jsonl schema'
    When call check_tasks_jsonl_schema_depends_on
    The status should be success
  End

  It 'documents backward compatibility with sequential fallback when parallel_group is unset'
    When call check_backward_compat_sequential_fallback
    The status should be success
  End
End
