SETTINGS_TEMPLATE="adapters/claude-code/hooks/settings.json"

# --- Helper functions ---

# Check SSoT template exists
check_template_exists() {
  [ -f "$SETTINGS_TEMPLATE" ]
}

# SubagentStart has exactly 1 timeline-record.sh defined
check_subagent_start_has_timeline_record() {
  count=$(jq '[.hooks.SubagentStart[0].hooks[] | select(.command | contains("timeline-record.sh"))] | length' "$SETTINGS_TEMPLATE" 2>/dev/null)
  [ "$count" = "1" ]
}

check_subagent_start_hook_count() {
  count=$(jq '[.hooks.SubagentStart[0].hooks[]] | length' "$SETTINGS_TEMPLATE" 2>/dev/null)
  [ "$count" = "2" ]
}

# PostToolUse (Write|Edit) has board-stamp.sh, retrospective-record.sh in order
check_post_tool_use_matcher() {
  jq -e '.hooks.PostToolUse[0].matcher == "Write|Edit"' "$SETTINGS_TEMPLATE" >/dev/null 2>&1
}

check_post_tool_use_order() {
  stamp_idx=$(jq '[.hooks.PostToolUse[0].hooks[] | .command] | to_entries[] | select(.value | contains("board-stamp.sh")) | .key' "$SETTINGS_TEMPLATE" 2>/dev/null)
  retro_idx=$(jq '[.hooks.PostToolUse[0].hooks[] | .command] | to_entries[] | select(.value | contains("retrospective-record.sh")) | .key' "$SETTINGS_TEMPLATE" 2>/dev/null)
  [ -n "$stamp_idx" ] && [ -n "$retro_idx" ] \
    && [ "$stamp_idx" -lt "$retro_idx" ]
}

check_post_tool_use_hook_count() {
  count=$(jq '[.hooks.PostToolUse[0].hooks[]] | length' "$SETTINGS_TEMPLATE" 2>/dev/null)
  [ "$count" = "2" ]
}

# WorktreeCreate has exactly 1 worktree-env-setup.sh defined
check_worktree_create_has_setup() {
  jq -e '.hooks.WorktreeCreate[0].hooks[] | select(.command | contains("worktree-env-setup.sh"))' "$SETTINGS_TEMPLATE" >/dev/null 2>&1
}

check_worktree_create_hook_count() {
  count=$(jq '[.hooks.WorktreeCreate[0].hooks[]] | length' "$SETTINGS_TEMPLATE" 2>/dev/null)
  [ "$count" = "1" ]
}

# SubagentStop has 5 hooks in correct order
check_subagent_stop_order() {
  scripts=$(jq -r '[.hooks.SubagentStop[0].hooks[] | .command | capture("(?<name>[^/]+\\.sh)$") | .name] | join(",")' "$SETTINGS_TEMPLATE" 2>/dev/null)
  [ "$scripts" = "timeline-record.sh,board-stamp.sh,retrospective-record.sh,generate-dashboard.sh,auto-commit.sh" ]
}

check_subagent_stop_hook_count() {
  count=$(jq '[.hooks.SubagentStop[0].hooks[]] | length' "$SETTINGS_TEMPLATE" 2>/dev/null)
  [ "$count" = "5" ]
}

# All script paths use bash ${CLAUDE_PLUGIN_ROOT}/core/scripts/... format
check_all_paths_use_plugin_root() {
  # Get all command fields and fail if any do not start with the expected prefix
  non_matching=$(jq -r '
    [.hooks[][].hooks[] | .command]
    | map(select(startswith("bash ${CLAUDE_PLUGIN_ROOT}/core/scripts/") | not))
    | length
  ' "$SETTINGS_TEMPLATE" 2>/dev/null)
  [ "$non_matching" = "0" ]
}

Describe 'SSoT Template hooks Definition (AC-1)'
  Describe 'File Existence'
    It 'SSoT template exists'
      When call check_template_exists
      The status should be success
    End
  End

  Describe 'SubagentStart Hook'
    It 'timeline-record.sh is defined with 1 entry'
      When call check_subagent_start_has_timeline_record
      The status should be success
    End

    It 'exactly 2 hooks are defined'
      When call check_subagent_start_hook_count
      The status should be success
    End
  End

  Describe 'PostToolUse Hook'
    It 'matcher is Write|Edit'
      When call check_post_tool_use_matcher
      The status should be success
    End

    It 'hooks are defined in order: board-stamp.sh -> retrospective-record.sh'
      When call check_post_tool_use_order
      The status should be success
    End

    It 'exactly 2 hooks are defined'
      When call check_post_tool_use_hook_count
      The status should be success
    End
  End

  Describe 'WorktreeCreate Hook'
    It 'worktree-env-setup.sh is defined'
      When call check_worktree_create_has_setup
      The status should be success
    End

    It 'exactly 1 hook is defined'
      When call check_worktree_create_hook_count
      The status should be success
    End
  End

  Describe 'SubagentStop Hook'
    It 'hooks are defined in order: timeline-record, board-stamp, retrospective-record, generate-dashboard, auto-commit'
      When call check_subagent_stop_order
      The status should be success
    End

    It 'exactly 5 hooks are defined'
      When call check_subagent_stop_hook_count
      The status should be success
    End
  End

  Describe 'Script Path Format'
    It 'all paths use bash ${CLAUDE_PLUGIN_ROOT}/core/scripts/... format'
      When call check_all_paths_use_plugin_root
      The status should be success
    End
  End
End
