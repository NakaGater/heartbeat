check_skill_platform_sync() {
  grep -q "Copilot-Specific" adapters/copilot/skills/heartbeat/SKILL.md
}

check_skill_initialization_flow() {
  grep -q "Initialize if needed" adapters/claude-code/skills/heartbeat/SKILL.md
}

check_skill_retro_verification() {
  grep -q "Verify retro.jsonl" adapters/claude-code/skills/heartbeat/SKILL.md
}

check_skill_post_completion_flow() {
  grep -q "Post-Completion Flow" adapters/claude-code/skills/heartbeat/SKILL.md
}

check_skill_retrospective_record_ref() {
  grep -q "retrospective-record.sh" adapters/claude-code/skills/heartbeat/SKILL.md
}

check_skill_insights_aggregate_ref() {
  grep -q "insights-aggregate.sh" adapters/claude-code/skills/heartbeat/SKILL.md
}

check_skill_accumulation_mode_ref() {
  grep -q "accumulation mode" adapters/claude-code/skills/heartbeat/SKILL.md
}

check_skill_retro_checkpoint() {
  grep -q "checkpoint" adapters/claude-code/skills/heartbeat/SKILL.md &&
  grep -q "retro-transfer" adapters/claude-code/skills/heartbeat/SKILL.md
}

check_skill_knowledge_checkpoint() {
  grep -q "checkpoint" adapters/claude-code/skills/heartbeat/SKILL.md &&
  grep -q "knowledge-update" adapters/claude-code/skills/heartbeat/SKILL.md
}

check_skill_verification_gate() {
  grep -q "Verification gate" adapters/claude-code/skills/heartbeat/SKILL.md &&
  grep -q "do not proceed" adapters/claude-code/skills/heartbeat/SKILL.md
}

check_copilot_ask_questions() {
  grep -q "vscode_askQuestions" adapters/copilot/skills/heartbeat/SKILL.md
}

check_copilot_auto_approve_task_decomposition() {
  grep -q "AP2" adapters/copilot/skills/heartbeat/SKILL.md &&
  grep -q "Phase 3" adapters/copilot/skills/heartbeat/SKILL.md &&
  grep -q "自動" adapters/copilot/skills/heartbeat/SKILL.md
}

check_copilot_workflow3_input_merge() {
  grep -q "Workflow 3" adapters/copilot/skills/heartbeat/SKILL.md &&
  grep -q "入力統合\|入力で受け取" adapters/copilot/skills/heartbeat/SKILL.md
}

Describe 'SKILL.md workflow completeness'
  It 'copilot SKILL.md has Copilot-Specific section'
    When call check_skill_platform_sync
    The status should be success
  End

  It 'SKILL.md contains initialization flow'
    When call check_skill_initialization_flow
    The status should be success
  End

  It 'SKILL.md contains retro verification step'
    When call check_skill_retro_verification
    The status should be success
  End

  It 'SKILL.md contains Post-Completion Flow section'
    When call check_skill_post_completion_flow
    The status should be success
  End

  It 'SKILL.md references retrospective-record.sh'
    When call check_skill_retrospective_record_ref
    The status should be success
  End

  It 'SKILL.md references insights-aggregate.sh'
    When call check_skill_insights_aggregate_ref
    The status should be success
  End

  It 'SKILL.md references accumulation mode'
    When call check_skill_accumulation_mode_ref
    The status should be success
  End

  It 'SKILL.md contains retro-transfer checkpoint'
    When call check_skill_retro_checkpoint
    The status should be success
  End

  It 'SKILL.md contains knowledge-update checkpoint'
    When call check_skill_knowledge_checkpoint
    The status should be success
  End

  It 'SKILL.md contains verification gate for finalize step'
    When call check_skill_verification_gate
    The status should be success
  End

  It 'copilot SKILL.md references vscode_askQuestions for approval'
    When call check_copilot_ask_questions
    The status should be success
  End

  It 'copilot SKILL.md auto-approves task decomposition'
    When call check_copilot_auto_approve_task_decomposition
    The status should be success
  End

  It 'copilot SKILL.md merges workflow 3 input points'
    When call check_copilot_workflow3_input_merge
    The status should be success
  End
End
