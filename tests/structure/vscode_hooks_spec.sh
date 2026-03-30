VSCODE_HOOKS=".github/hooks/heartbeat.json"

# --- Test 1: .github/hooks/heartbeat.json exists with PascalCase events ---

check_vscode_hooks_exists() {
  [ -f "$VSCODE_HOOKS" ]
}

check_vscode_uses_pascal_case_events() {
  jq -e '.hooks.PostToolUse' "$VSCODE_HOOKS" >/dev/null 2>&1 &&
  jq -e '.hooks.Stop' "$VSCODE_HOOKS" >/dev/null 2>&1
}

check_vscode_uses_command_key() {
  # All entries should use "command" key, not "bash"
  local bash_count
  bash_count=$(jq '[.hooks[][] | .bash // empty] | length' "$VSCODE_HOOKS" 2>/dev/null)
  [ "$bash_count" = "0" ] &&
  jq -e '.hooks.PostToolUse[0].command' "$VSCODE_HOOKS" >/dev/null 2>&1
}

# --- Test 2: Stop event contains auto-commit.sh ---

check_vscode_stop_has_auto_commit() {
  jq -e '.hooks.Stop[] | select(.command == "./core/scripts/auto-commit.sh")' \
    "$VSCODE_HOOKS" >/dev/null 2>&1
}

# --- Test 3: PostToolUse has 3 scripts in correct order ---

check_vscode_post_tool_use_count() {
  jq -e '.hooks.PostToolUse | length == 3' "$VSCODE_HOOKS" >/dev/null 2>&1
}

check_vscode_board_stamp_before_dashboard() {
  local stamp_idx dash_idx
  stamp_idx=$(jq '[.hooks.PostToolUse[] | .command] | to_entries[] | select(.value == "./core/scripts/board-stamp.sh") | .key' "$VSCODE_HOOKS" 2>/dev/null)
  dash_idx=$(jq '[.hooks.PostToolUse[] | .command] | to_entries[] | select(.value == "./core/scripts/generate-dashboard.sh") | .key' "$VSCODE_HOOKS" 2>/dev/null)
  [ -n "$stamp_idx" ] && [ -n "$dash_idx" ] && [ "$stamp_idx" -lt "$dash_idx" ]
}

# --- Test 4: board-stamp.sh handles camelCase filePath ---

check_board_stamp_handles_camel_case() {
  # board-stamp.sh must extract filePath (camelCase) in addition to file_path (snake_case)
  grep -q 'filePath' core/scripts/board-stamp.sh
}

Describe 'VS Code hooks (.github/hooks/heartbeat.json)'
  Describe 'Hook file structure'
    It 'heartbeat.json exists in .github/hooks/'
      When call check_vscode_hooks_exists
      The status should be success
    End

    It 'uses PascalCase event names (PostToolUse, Stop)'
      When call check_vscode_uses_pascal_case_events
      The status should be success
    End

    It 'uses command key instead of bash key'
      When call check_vscode_uses_command_key
      The status should be success
    End
  End

  Describe 'Stop event (session end)'
    It 'Stop contains auto-commit.sh'
      When call check_vscode_stop_has_auto_commit
      The status should be success
    End
  End

  Describe 'PostToolUse event'
    It 'has 3 hook entries'
      When call check_vscode_post_tool_use_count
      The status should be success
    End

    It 'board-stamp.sh appears before generate-dashboard.sh'
      When call check_vscode_board_stamp_before_dashboard
      The status should be success
    End
  End

  Describe 'board-stamp.sh compatibility'
    It 'handles camelCase filePath property'
      When call check_board_stamp_handles_camel_case
      The status should be success
    End
  End
End
