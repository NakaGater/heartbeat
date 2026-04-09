CLAUDE_SETTINGS="adapters/claude-code/hooks/settings.json"

# --- Helper function ---

check_subagent_start_has_timeline_record() {
  jq -e '.hooks.SubagentStart[].hooks[] | select(.command | contains("timeline-record.sh"))' \
    "$CLAUDE_SETTINGS" >/dev/null 2>&1
}

Describe 'SubagentStart hook wiring for timeline-record.sh'
  It 'SubagentStart hooks contain timeline-record.sh entry'
    When call check_subagent_start_has_timeline_record
    The status should be success
  End
End
