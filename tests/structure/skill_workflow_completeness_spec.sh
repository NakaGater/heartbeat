check_skill_platform_sync() {
  diff adapters/claude-code/skills/heartbeat/SKILL.md \
       adapters/copilot/skills/heartbeat/SKILL.md >/dev/null 2>&1
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

Describe 'SKILL.md workflow completeness'
  It 'claude-code and copilot SKILL.md are identical'
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
End
