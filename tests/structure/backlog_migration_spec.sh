# Tests for backlog.jsonl migration (point-criteria story, Task 7)
# CC1: All stories with status "ready" have point values of 1, 2, or 3
# CC2: All stories with status "done" retain their original point values
# CC3: parallel-stories (previously 13pt) has been re-estimated to a value in the 1-3 range

BACKLOG=".heartbeat/backlog.jsonl"

# --- CC1: All ready stories have points of 1, 2, or 3 ---

check_ready_stories_have_valid_points() {
  # Extract points for all stories with status "ready"
  # Each must be 1, 2, or 3 (not null, not > 3, not 0 or negative)
  ready_points=$(jq -r 'select(.status == "ready") | .points' "$BACKLOG" 2>/dev/null)
  # No ready stories is a valid state (all implemented or none created yet)
  [ -n "$ready_points" ] || return 0
  for pts in $ready_points; do
    case "$pts" in
      1|2|3) ;;
      *) return 1 ;;
    esac
  done
  return 0
}

check_no_ready_story_exceeds_3pt() {
  # No ready story should have points > 3
  over_3=$(jq -r 'select(.status == "ready" and .points != null and .points > 3) | .story_id' "$BACKLOG" 2>/dev/null)
  [ -z "$over_3" ] || return 1
}

# --- CC2: All done stories retain their original point values ---

# Point values after story 0055 re-estimation (current 1-3pt criteria).
# Updated from original values by 0055-backlog-points-reestimate.
check_done_stories_retain_original_points() {
  check_done_story_points "0001-tdd-workflow" 2 || return 1
  check_done_story_points "0002-i18n-docs" 2 || return 1
  check_done_story_points "0003-auto-commit-fix" 2 || return 1
  check_done_story_points "0004-dashboard-fix" 2 || return 1
  check_done_story_points "0005-workflow-fix" 1 || return 1
  check_done_story_points "0006-workflow-boundary" 1 || return 1
  check_done_story_points "0008-copilot-hooks" 1 || return 1
  check_done_story_points "0009-board-cleanup" 2 || return 1
  check_done_story_points "0011-copilot-tools" 2 || return 1
}

check_done_story_points() {
  local story_id="$1"
  local expected_points="$2"
  actual=$(jq -r "select(.story_id == \"$story_id\" and .status == \"done\") | .points" "$BACKLOG" 2>/dev/null)
  [ "$actual" = "$expected_points" ] || return 1
}

# --- CC3: parallel-stories re-estimated to 1-3 range ---

check_parallel_stories_re_estimated() {
  pts=$(jq -r 'select(.story_id == "0007-parallel-stories") | .points' "$BACKLOG" 2>/dev/null)
  case "$pts" in
    1|2|3) return 0 ;;
    *) return 1 ;;
  esac
}

Describe 'Backlog migration to new point scale (Task 7)'

  Describe 'All ready stories have valid points 1, 2, or 3 (CC1)'
    It 'every ready story has points of 1, 2, or 3'
      When call check_ready_stories_have_valid_points
      The status should be success
    End

    It 'no ready story has points greater than 3'
      When call check_no_ready_story_exceeds_3pt
      The status should be success
    End
  End

  Describe 'Done stories retain original point values (CC2)'
    It 'all done stories keep their historical point values unchanged'
      When call check_done_stories_retain_original_points
      The status should be success
    End
  End

  Describe 'parallel-stories re-estimated to 1-3 range (CC3)'
    It 'parallel-stories has a point value in the 1-3 range'
      When call check_parallel_stories_re_estimated
      The status should be success
    End
  End

End
