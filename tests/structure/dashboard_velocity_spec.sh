DASHBOARD="core/templates/dashboard.html"

# --- Common setup for node execution tests ---
# Extract getISOWeekNumber and renderVelocity from dashboard.html
extract_dashboard_functions() {
  local helper render
  helper=$(sed -n '/function getISOWeekNumber/,/^  }/p' "$DASHBOARD")
  render=$(sed -n '/function renderVelocity/,/^  }/p' "$DASHBOARD")
  [ -z "$helper" ] && return 1
  [ -z "$render" ] && return 1
  DASHBOARD_HELPER="$helper"
  DASHBOARD_RENDER="$render"
  return 0
}

# --- Week helper checks ---

check_get_iso_week_number_defined() {
  grep -q "function getISOWeekNumber" "$DASHBOARD" || return 1
}

check_helper_before_render_velocity() {
  local helper_line render_line
  helper_line=$(grep -n "function getISOWeekNumber" "$DASHBOARD" | head -1 | cut -d: -f1)
  render_line=$(grep -n "function renderVelocity" "$DASHBOARD" | head -1 | cut -d: -f1)
  [ -n "$helper_line" ] && [ -n "$render_line" ] && [ "$helper_line" -lt "$render_line" ] || return 1
}

check_week_number_jan1() {
  command -v node >/dev/null 2>&1 || return 1
  extract_dashboard_functions || return 1
  node -e "${DASHBOARD_HELPER}; var r = getISOWeekNumber('2026-01-01'); if (r !== 1) process.exit(1);"
  return $?
}

check_null_input_returns_null() {
  command -v node >/dev/null 2>&1 || return 1
  extract_dashboard_functions || return 1
  node -e "${DASHBOARD_HELPER}; var r = getISOWeekNumber(null); if (r !== null) process.exit(1);"
  return $?
}

check_iso_datetime_returns_week_number() {
  command -v node >/dev/null 2>&1 || return 1
  extract_dashboard_functions || return 1
  node -e "${DASHBOARD_HELPER}; var r = getISOWeekNumber('2026-03-29T00:00:00Z'); if (r === null || typeof r !== 'number') process.exit(1);"
  return $?
}

check_invalid_date_returns_null() {
  command -v node >/dev/null 2>&1 || return 1
  extract_dashboard_functions || return 1
  node -e "${DASHBOARD_HELPER}; var r = getISOWeekNumber('not-a-date'); if (r !== null) process.exit(1);"
  return $?
}

# --- Fallback logic check ---

check_weekmap_fallback_in_render_velocity() {
  local body
  body=$(sed -n '/function renderVelocity/,/^  }/p' "$DASHBOARD")
  [ -z "$body" ] && return 1
  echo "$body" | grep -q "weekMap" || return 1
  echo "$body" | grep -q "getISOWeekNumber" || return 1
}

# --- Labels and average line checks ---

check_week_labels_in_svg_output() {
  command -v node >/dev/null 2>&1 || return 1
  extract_dashboard_functions || return 1
  node -e "
    var _innerHTML = '';
    var document = {
      getElementById: function() {
        return { set innerHTML(v) { _innerHTML = v; }, get innerHTML() { return _innerHTML; } };
      }
    };
    var BACKLOG_DATA = [
      { story_id: 's1', iteration: null, status: 'done', points: 3, completed: '2026-01-05' },
      { story_id: 's2', iteration: null, status: 'done', points: 5, completed: '2026-01-12' },
      { story_id: 's3', iteration: null, status: 'done', points: 2, completed: '2026-01-05' }
    ];
    ${DASHBOARD_HELPER}
    ${DASHBOARD_RENDER}
    renderVelocity();
    var weekMatches = _innerHTML.match(/Week \d+/g);
    if (!weekMatches || weekMatches.length < 2) {
      console.error('FAIL: Expected at least 2 Week labels, got ' + (weekMatches ? weekMatches.length : 0));
      process.exit(1);
    }
    process.exit(0);
  " 2>&1
  return $?
}

check_avg_line_in_svg_output() {
  command -v node >/dev/null 2>&1 || return 1
  extract_dashboard_functions || return 1
  node -e "
    var _innerHTML = '';
    var document = {
      getElementById: function() {
        return { set innerHTML(v) { _innerHTML = v; }, get innerHTML() { return _innerHTML; } };
      }
    };
    var BACKLOG_DATA = [
      { story_id: 's1', iteration: null, status: 'done', points: 3, completed: '2026-01-05' },
      { story_id: 's2', iteration: null, status: 'done', points: 5, completed: '2026-01-12' }
    ];
    ${DASHBOARD_HELPER}
    ${DASHBOARD_RENDER}
    renderVelocity();
    if (!_innerHTML.match(/stroke-dasharray/)) {
      console.error('FAIL: stroke-dasharray not found');
      process.exit(1);
    }
    if (!_innerHTML.match(/avg 4\.0/)) {
      console.error('FAIL: avg 4.0 label not found');
      process.exit(1);
    }
    process.exit(0);
  " 2>&1
  return $?
}

check_svg_rendering_unified() {
  local body
  body=$(sed -n '/function renderVelocity/,/^  }/p' "$DASHBOARD")
  [ -z "$body" ] && return 1
  local count
  count=$(echo "$body" | grep -c '<svg viewBox')
  [ "$count" -eq 1 ] || return 1
}

# === Describe blocks ===

Describe 'dashboard.html getISOWeekNumber helper function'
  It 'defines getISOWeekNumber function'
    When call check_get_iso_week_number_defined
    The status should be success
  End

  It 'places getISOWeekNumber before renderVelocity'
    When call check_helper_before_render_velocity
    The status should be success
  End

  It 'returns week number 1 for "2026-01-01"'
    When call check_week_number_jan1
    The status should be success
  End

  It 'returns valid week number for ISO 8601 datetime "2026-03-29T00:00:00Z"'
    When call check_iso_datetime_returns_week_number
    The status should be success
  End

  It 'returns null for null input'
    When call check_null_input_returns_null
    The status should be success
  End

  It 'returns null for invalid date string'
    When call check_invalid_date_returns_null
    The status should be success
  End
End

Describe 'renderVelocity() fallback aggregation logic'
  It 'uses weekMap and getISOWeekNumber when iters.length===0'
    When call check_weekmap_fallback_in_render_velocity
    The status should be success
  End
End

Describe 'renderVelocity() fallback week labels and average line'
  It 'displays X-axis labels in Week N format during fallback'
    When call check_week_labels_in_svg_output
    The status should be success
  End

  It 'draws average velocity line with correct mean value during fallback'
    When call check_avg_line_in_svg_output
    The status should be success
  End

  It 'unifies SVG rendering code for iteration and week modes'
    When call check_svg_rendering_unified
    The status should be success
  End
End
