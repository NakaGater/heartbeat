SETTINGS_TEMPLATE="adapters/claude-code/hooks/settings.json"

# --- Helper functions ---

# Check SubagentStart has open-dashboard.sh registered
check_subagent_start_has_open_dashboard() {
  jq -e '.hooks.SubagentStart[].hooks[] | select(.command | contains("open-dashboard.sh"))' \
    "$SETTINGS_TEMPLATE" >/dev/null 2>&1
}

# Check open-dashboard.sh comes after timeline-record.sh in SubagentStart hooks array
check_open_dashboard_after_timeline_record() {
  timeline_idx=$(jq '[.hooks.SubagentStart[0].hooks[] | .command] | to_entries[] | select(.value | contains("timeline-record.sh")) | .key' "$SETTINGS_TEMPLATE")
  dashboard_idx=$(jq '[.hooks.SubagentStart[0].hooks[] | .command] | to_entries[] | select(.value | contains("open-dashboard.sh")) | .key' "$SETTINGS_TEMPLATE")
  [ "$dashboard_idx" -gt "$timeline_idx" ]
}

# Check settings.json is valid JSON
check_settings_valid_json() {
  jq . "$SETTINGS_TEMPLATE" >/dev/null 2>&1
}

# Check timeline-record.sh entry is still present and unchanged in SubagentStart
check_timeline_record_unchanged() {
  jq -e '.hooks.SubagentStart[0].hooks[0].command | contains("timeline-record.sh")' \
    "$SETTINGS_TEMPLATE" >/dev/null 2>&1
}

Describe 'SubagentStart open-dashboard.sh Hook Registration'
  It 'SubagentStart has open-dashboard.sh registered in settings.json'
    When call check_subagent_start_has_open_dashboard
    The status should be success
  End

  It 'open-dashboard.sh is placed after timeline-record.sh in SubagentStart hooks'
    When call check_open_dashboard_after_timeline_record
    The status should be success
  End

  It 'settings.json is valid JSON'
    When call check_settings_valid_json
    The status should be success
  End

  It 'existing timeline-record.sh entry in SubagentStart is still present and unchanged'
    When call check_timeline_record_unchanged
    The status should be success
  End
End
