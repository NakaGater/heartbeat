DASHBOARD="core/templates/dashboard.html"

# --- Last Release metric card validation inside hero-metrics section ---

check_metric_last_release_id_exists() {
  grep -q 'id="metric-last-release"' "$DASHBOARD" || return 1
}

check_last_release_card_in_hero_metrics() {
  # Verify metric-last-release exists inside hero-metrics section
  local section
  section=$(sed -n '/id="hero-metrics"/,/<\/header>/p' "$DASHBOARD")
  [ -z "$section" ] && return 1
  echo "$section" | grep -q 'id="metric-last-release"' || return 1
}

check_last_release_label() {
  # Verify "Last Release" label exists inside hero-metrics section
  local section
  section=$(sed -n '/id="hero-metrics"/,/<\/header>/p' "$DASHBOARD")
  [ -z "$section" ] && return 1
  echo "$section" | grep -q 'Last Release' || return 1
}

check_last_release_default_value() {
  # Verify default value is "--"
  local section
  section=$(sed -n '/id="hero-metrics"/,/<\/header>/p' "$DASHBOARD")
  [ -z "$section" ] && return 1
  echo "$section" | grep 'id="metric-last-release"' | grep -q '\-\-' || return 1
}

check_last_release_date_modifier_class() {
  # Verify metric-value--date modifier class is applied
  local section
  section=$(sed -n '/id="hero-metrics"/,/<\/header>/p' "$DASHBOARD")
  [ -z "$section" ] && return 1
  echo "$section" | grep 'id="metric-last-release"' | grep -q 'metric-value--date' || return 1
}

# === Describe blocks ===

Describe 'dashboard.html Last Release metric card in hero-metrics'
  It 'has an element with id "metric-last-release"'
    When call check_metric_last_release_id_exists
    The status should be success
  End

  It 'places metric-last-release inside the hero-metrics section'
    When call check_last_release_card_in_hero_metrics
    The status should be success
  End

  It 'has a "Last Release" label in the hero-metrics section'
    When call check_last_release_label
    The status should be success
  End

  It 'shows "--" as the default value for last release'
    When call check_last_release_default_value
    The status should be success
  End

  It 'applies metric-value--date modifier class to the value element'
    When call check_last_release_date_modifier_class
    The status should be success
  End
End
