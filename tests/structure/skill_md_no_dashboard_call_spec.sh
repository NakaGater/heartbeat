CORE_SKILL="core/skills/heartbeat/SKILL.md"
CLAUDE_SKILL="adapters/claude-code/skills/heartbeat/SKILL.md"
COPILOT_SKILL="adapters/copilot/skills/heartbeat/SKILL.md"
BACKLOG_SKILL="core/skills/heartbeat-backlog/SKILL.md"

check_core_skill_no_dashboard() {
  ! grep -q 'generate-dashboard\.sh' "$CORE_SKILL"
}

check_claude_skill_no_dashboard() {
  ! grep -q 'generate-dashboard\.sh' "$CLAUDE_SKILL"
}

check_copilot_skill_no_dashboard() {
  ! grep -q 'generate-dashboard\.sh' "$COPILOT_SKILL"
}

check_backlog_skill_no_dashboard_sync_section() {
  ! grep -q 'Dashboard Sync' "$BACKLOG_SKILL"
}

Describe 'SKILL.md から generate-dashboard.sh の明示的呼び出しが削除されている (Task 3)'
  Describe 'core/skills/heartbeat/SKILL.md'
    It 'generate-dashboard.sh の文字列が存在しない'
      When call check_core_skill_no_dashboard
      The status should be success
    End
  End

  Describe 'adapters/claude-code/skills/heartbeat/SKILL.md'
    It 'generate-dashboard.sh の文字列が存在しない'
      When call check_claude_skill_no_dashboard
      The status should be success
    End
  End

  Describe 'adapters/copilot/skills/heartbeat/SKILL.md'
    It 'generate-dashboard.sh の文字列が存在しない'
      When call check_copilot_skill_no_dashboard
      The status should be success
    End
  End

  Describe 'core/skills/heartbeat-backlog/SKILL.md'
    It 'Dashboard Sync セクションが存在しない'
      When call check_backlog_skill_no_dashboard_sync_section
      The status should be success
    End
  End
End
