DASHBOARD="core/templates/dashboard.html"

# Task 1 completion condition 1 & 2:
# populateStorySelect() searches BACKLOG_DATA for in_progress story
check_backlog_in_progress_lookup() {
  grep -A 30 "function populateStorySelect" "$DASHBOARD" \
    | grep -q "BACKLOG_DATA" || return 1
  grep -A 30 "function populateStorySelect" "$DASHBOARD" \
    | grep -q "in_progress" || return 1
}

# Task 1 completion condition 1:
# populateStorySelect() sets sel.value to auto-select the in_progress story
check_sel_value_assignment() {
  grep -A 30 "function populateStorySelect" "$DASHBOARD" \
    | grep -q "sel\.value" || return 1
}

# Task 1 completion condition 3 & 4:
# BACKLOG_DATA is accessed with defensive fallback pattern (|| [])
check_backlog_defensive_pattern() {
  grep -A 30 "function populateStorySelect" "$DASHBOARD" \
    | grep -q "BACKLOG_DATA || \[\]" || return 1
}

# Task 1 completion condition 2:
# Uses filter()[0] pattern (ES5 compatible) to get first in_progress entry
check_filter_first_pattern() {
  grep -A 30 "function populateStorySelect" "$DASHBOARD" \
    | grep -q "filter(" || return 1
}

Describe 'dashboard.html populateStorySelect() in_progress auto-selection'
  It 'references BACKLOG_DATA and in_progress status'
    When call check_backlog_in_progress_lookup
    The status should be success
  End

  It 'sets sel.value to auto-select the found story'
    When call check_sel_value_assignment
    The status should be success
  End

  It 'uses defensive BACKLOG_DATA || [] pattern'
    When call check_backlog_defensive_pattern
    The status should be success
  End

  It 'uses filter() pattern for ES5-compatible in_progress lookup'
    When call check_filter_first_pattern
    The status should be success
  End
End

# Task 2: change event handler non-regression verification

# Task 2 completion condition 2:
# story-select has onchange="renderStoryDetail()" attribute (unchanged)
check_onchange_attribute() {
  grep -q 'id="story-select".*onchange="renderStoryDetail()"' "$DASHBOARD" || return 1
}

# Task 2 completion condition 2:
# renderStoryDetail() calls renderGantt, renderTasks, renderMessages (unchanged)
check_render_story_detail_body() {
  grep -A 5 "window.renderStoryDetail = function" "$DASHBOARD" \
    | grep -q "renderGantt()" || return 1
  grep -A 5 "window.renderStoryDetail = function" "$DASHBOARD" \
    | grep -q "renderTasks()" || return 1
  grep -A 5 "window.renderStoryDetail = function" "$DASHBOARD" \
    | grep -q "renderMessages()" || return 1
}

# Task 2 completion condition 1:
# getSelectedStory() exists and reads from story-select (supports manual selection)
check_get_selected_story() {
  grep -q "function getSelectedStory" "$DASHBOARD" || return 1
  grep -A 3 "function getSelectedStory" "$DASHBOARD" \
    | grep -q 'story-select' || return 1
}

Describe 'dashboard.html change event handler non-regression (Task 2)'
  It 'has onchange="renderStoryDetail()" on story-select element'
    When call check_onchange_attribute
    The status should be success
  End

  It 'renderStoryDetail() calls renderGantt, renderTasks, renderMessages unchanged'
    When call check_render_story_detail_body
    The status should be success
  End

  It 'getSelectedStory() exists and reads from story-select dropdown'
    When call check_get_selected_story
    The status should be success
  End
End
