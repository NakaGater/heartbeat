CLAUDE_SETTINGS="adapters/claude-code/hooks/settings.json"

# --- Helper functions ---

check_subagent_stop_has_timeline_record() {
  jq -e '.hooks.SubagentStop[].hooks[] | select(.command | contains("timeline-record.sh"))' \
    "$CLAUDE_SETTINGS" >/dev/null 2>&1
}

check_timeline_record_before_board_stamp() {
  timeline_idx=$(jq '[.hooks.SubagentStop[0].hooks[] | .command] | to_entries[] | select(.value | contains("timeline-record.sh")) | .key' "$CLAUDE_SETTINGS" 2>/dev/null)
  stamp_idx=$(jq '[.hooks.SubagentStop[0].hooks[] | .command] | to_entries[] | select(.value | contains("board-stamp.sh")) | .key' "$CLAUDE_SETTINGS" 2>/dev/null)
  [ -n "$timeline_idx" ] && [ -n "$stamp_idx" ] && [ "$timeline_idx" -lt "$stamp_idx" ]
}

check_timeline_record_is_first_in_subagent_stop() {
  first_cmd=$(jq -r '.hooks.SubagentStop[0].hooks[0].command' "$CLAUDE_SETTINGS" 2>/dev/null)
  echo "$first_cmd" | grep -q 'timeline-record.sh'
}

check_existing_hooks_order_preserved() {
  # board-stamp -> retrospective-record -> generate-dashboard -> auto-commit の順序が維持されていること
  stamp_idx=$(jq '[.hooks.SubagentStop[0].hooks[] | .command] | to_entries[] | select(.value | contains("board-stamp.sh")) | .key' "$CLAUDE_SETTINGS" 2>/dev/null)
  retro_idx=$(jq '[.hooks.SubagentStop[0].hooks[] | .command] | to_entries[] | select(.value | contains("retrospective-record.sh")) | .key' "$CLAUDE_SETTINGS" 2>/dev/null)
  dash_idx=$(jq '[.hooks.SubagentStop[0].hooks[] | .command] | to_entries[] | select(.value | contains("generate-dashboard.sh")) | .key' "$CLAUDE_SETTINGS" 2>/dev/null)
  commit_idx=$(jq '[.hooks.SubagentStop[0].hooks[] | .command] | to_entries[] | select(.value | contains("auto-commit.sh")) | .key' "$CLAUDE_SETTINGS" 2>/dev/null)
  [ -n "$stamp_idx" ] && [ -n "$retro_idx" ] && [ -n "$dash_idx" ] && [ -n "$commit_idx" ] && \
  [ "$stamp_idx" -lt "$retro_idx" ] && [ "$retro_idx" -lt "$dash_idx" ] && [ "$dash_idx" -lt "$commit_idx" ]
}

Describe 'SubagentStop hook wiring for timeline-record.sh'
  It 'settings.json の SubagentStop フックに timeline-record.sh が登録されていること'
    When call check_subagent_stop_has_timeline_record
    The status should be success
  End

  It 'settings.json で timeline-record.sh が SubagentStop フックの先頭（インデックス 0）であること'
    When call check_timeline_record_is_first_in_subagent_stop
    The status should be success
  End

  It 'timeline-record.sh が board-stamp.sh の前に配置されていること'
    When call check_timeline_record_before_board_stamp
    The status should be success
  End

  It '既存4フック（board-stamp -> retrospective-record -> generate-dashboard -> auto-commit）の相対順序が維持されていること'
    When call check_existing_hooks_order_preserved
    The status should be success
  End
End
