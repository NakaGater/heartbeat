CLAUDE_SETTINGS="adapters/claude-code/hooks/settings.json"
COPILOT_HOOKS="adapters/copilot/hooks/hooks.json"

# --- settings.json PostToolUse ---

check_settings_json_post_tool_use_no_dashboard() {
  ! jq -e '.hooks.PostToolUse[].hooks[] | select(.command | contains("generate-dashboard.sh"))' \
    "$CLAUDE_SETTINGS" >/dev/null 2>&1
}

check_settings_json_valid() {
  jq empty "$CLAUDE_SETTINGS" >/dev/null 2>&1
}

# --- settings.local.json PostToolUse ---
# Note: After story 0054 SSoT cleanup, settings.local.json no longer
# contains a hooks section. The check verifies that generate-dashboard.sh
# does not appear in PostToolUse regardless of whether the file exists.

check_settings_local_post_tool_use_no_dashboard() {
  local settings_local="adapters/claude-code/hooks/settings.local.json"
  # If file does not exist, condition is satisfied
  [ ! -f "$settings_local" ] && return 0
  # If file exists, PostToolUse must not contain generate-dashboard.sh
  ! jq -e '.hooks.PostToolUse[].hooks[] | select(.command | contains("generate-dashboard.sh"))' \
    "$settings_local" >/dev/null 2>&1
}

# --- hooks.json postToolUse ---

check_copilot_hooks_post_tool_use_no_dashboard() {
  ! jq -e '.hooks.postToolUse[] | select(.bash | contains("generate-dashboard.sh"))' \
    "$COPILOT_HOOKS" >/dev/null 2>&1
}

check_copilot_hooks_valid() {
  jq empty "$COPILOT_HOOKS" >/dev/null 2>&1
}

# --- settings.json SubagentStop (positive check) ---

check_subagent_stop_has_dashboard() {
  jq -e '.hooks.SubagentStop[].hooks[] | select(.command | contains("generate-dashboard.sh"))' \
    "$CLAUDE_SETTINGS" >/dev/null 2>&1
}

Describe 'generate-dashboard.sh Removed from PostToolUse (Task 2)'
  Describe 'settings.json'
    It 'PostToolUse array does not contain generate-dashboard.sh'
      When call check_settings_json_post_tool_use_no_dashboard
      The status should be success
    End

    It 'is valid JSON'
      When call check_settings_json_valid
      The status should be success
    End
  End

  Describe 'settings.local.json'
    It 'PostToolUse array does not contain generate-dashboard.sh'
      When call check_settings_local_post_tool_use_no_dashboard
      The status should be success
    End
  End

  Describe 'hooks.json'
    It 'postToolUse array does not contain generate-dashboard.sh'
      When call check_copilot_hooks_post_tool_use_no_dashboard
      The status should be success
    End

    It 'is valid JSON'
      When call check_copilot_hooks_valid
      The status should be success
    End
  End

  Describe 'SubagentStop (Unchanged Verification)'
    It 'SubagentStop array contains generate-dashboard.sh'
      When call check_subagent_stop_has_dashboard
      The status should be success
    End
  End
End
