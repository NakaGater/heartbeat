SETTINGS_TEMPLATE="adapters/claude-code/hooks/settings.json"

# --- Helper functions ---

# Check SubagentStart has open-dashboard.sh registered
check_subagent_start_has_open_dashboard() {
  jq -e '.hooks.SubagentStart[].hooks[] | select(.command | contains("open-dashboard.sh"))' \
    "$SETTINGS_TEMPLATE" >/dev/null 2>&1
}

Describe 'SubagentStart open-dashboard.sh Hook Registration'
  It 'SubagentStart has open-dashboard.sh registered in settings.json'
    When call check_subagent_start_has_open_dashboard
    The status should be success
  End
End
