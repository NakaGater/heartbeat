# Tests for SKILL.md tasks.jsonl schema extension with parallel fields (0056 Task 5)

CLAUDE_SKILL="adapters/claude-code/skills/heartbeat/SKILL.md"

# --- CC1: tasks.jsonl schema defines parallel_group field ---

check_skill_tasks_schema_has_parallel_group() {
  # Extract tasks.jsonl schema section: from "### tasks.jsonl" up to the next "###" heading
  tasks_section=$(sed -n '/^### tasks\.jsonl/,/^### /p' "$CLAUDE_SKILL" | sed '$d')
  # Must contain parallel_group field definition
  echo "$tasks_section" | grep -q "parallel_group" || return 1
}

# --- CC2: tasks.jsonl schema defines depends_on field ---

check_skill_tasks_schema_has_depends_on() {
  # Extract tasks.jsonl schema section
  tasks_section=$(sed -n '/^### tasks\.jsonl/,/^### /p' "$CLAUDE_SKILL" | sed '$d')
  # Must contain depends_on field definition
  echo "$tasks_section" | grep -q "depends_on" || return 1
}

# --- CC3: Sequential fallback when parallel_group is unset ---

check_skill_tasks_sequential_fallback() {
  # Extract tasks.jsonl schema section
  tasks_section=$(sed -n '/^### tasks\.jsonl/,/^### /p' "$CLAUDE_SKILL" | sed '$d')
  # Must mention sequential/fallback behavior for unset parallel_group
  echo "$tasks_section" | grep -qi "逐次実行\|sequential.*fallback\|フォールバック" || return 1
}

Describe 'SKILL.md tasks.jsonl parallel schema extension'
  It 'defines parallel_group field in tasks.jsonl schema'
    When call check_skill_tasks_schema_has_parallel_group
    The status should be success
  End

  It 'defines depends_on field in tasks.jsonl schema'
    When call check_skill_tasks_schema_has_depends_on
    The status should be success
  End

  It 'documents sequential fallback when parallel_group is unset'
    When call check_skill_tasks_sequential_fallback
    The status should be success
  End
End
