SETTINGS_TEMPLATE="adapters/claude-code/hooks/settings.json"

# --- Helper functions ---

# Check SSoT template exists
check_settings_template_exists() {
  [ -f "$SETTINGS_TEMPLATE" ]
}

# Check PostToolUse has board-stamp.sh registered
check_post_tool_use_has_board_stamp() {
  jq -e '.hooks.PostToolUse[].hooks[] | select(.command | contains("board-stamp.sh"))' \
    "$SETTINGS_TEMPLATE" >/dev/null 2>&1
}

# Check PostToolUse execution order is correct
# board-stamp.sh -> retrospective-record.sh
check_post_tool_use_order() {
  stamp_idx=$(jq '[.hooks.PostToolUse[0].hooks[] | .command] | to_entries[] | select(.value | contains("board-stamp.sh")) | .key' "$SETTINGS_TEMPLATE" 2>/dev/null)
  retro_idx=$(jq '[.hooks.PostToolUse[0].hooks[] | .command] | to_entries[] | select(.value | contains("retrospective-record.sh")) | .key' "$SETTINGS_TEMPLATE" 2>/dev/null)
  [ -n "$stamp_idx" ] && [ -n "$retro_idx" ] \
    && [ "$stamp_idx" -lt "$retro_idx" ]
}

# Check SubagentStop has board-stamp.sh registered
check_subagent_stop_has_board_stamp() {
  jq -e '.hooks.SubagentStop[].hooks[] | select(.command | contains("board-stamp.sh"))' \
    "$SETTINGS_TEMPLATE" >/dev/null 2>&1
}

# Check SubagentStop has generate-dashboard.sh registered with synchronous execution
check_subagent_stop_has_generate_dashboard_sync() {
  jq -e '.hooks.SubagentStop[].hooks[] | select(.command | contains("generate-dashboard.sh"))' \
    "$SETTINGS_TEMPLATE" >/dev/null 2>&1 \
  && ! jq -e '.hooks.SubagentStop[].hooks[] | select(.command | contains("generate-dashboard.sh")) | select(.async)' \
    "$SETTINGS_TEMPLATE" >/dev/null 2>&1
}

# Check SubagentStop has retrospective-record.sh registered
check_subagent_stop_has_retrospective_record() {
  jq -e '.hooks.SubagentStop[].hooks[] | select(.command | contains("retrospective-record.sh"))' \
    "$SETTINGS_TEMPLATE" >/dev/null 2>&1
}

Describe 'SSoT Template Hook Registration (AC-1)'
  Describe 'File Existence'
    It 'SSoT template exists'
      When call check_settings_template_exists
      The status should be success
    End
  End

  Describe 'PostToolUse Hook Registration'
    It 'PostToolUse has board-stamp.sh registered'
      When call check_post_tool_use_has_board_stamp
      The status should be success
    End

    It 'PostToolUse execution order is board-stamp.sh -> retrospective-record.sh'
      When call check_post_tool_use_order
      The status should be success
    End
  End

  Describe 'SubagentStop Hook Registration'
    It 'SubagentStop has board-stamp.sh registered'
      When call check_subagent_stop_has_board_stamp
      The status should be success
    End

    It 'SubagentStop has generate-dashboard.sh registered with synchronous execution'
      When call check_subagent_stop_has_generate_dashboard_sync
      The status should be success
    End

    It 'SubagentStop has retrospective-record.sh registered'
      When call check_subagent_stop_has_retrospective_record
      The status should be success
    End
  End
End
