DASHBOARD="core/templates/dashboard.html"

# --- hero-metrics セクション内の Last Release メトリクスカード検証 ---

check_metric_last_release_id_exists() {
  grep -q 'id="metric-last-release"' "$DASHBOARD" || return 1
}

check_last_release_card_in_hero_metrics() {
  # hero-metrics セクション内に metric-last-release が存在することを確認
  local section
  section=$(sed -n '/id="hero-metrics"/,/<\/header>/p' "$DASHBOARD")
  [ -z "$section" ] && return 1
  echo "$section" | grep -q 'id="metric-last-release"' || return 1
}

check_last_release_label() {
  # hero-metrics セクション内に "Last Release" ラベルが存在することを確認
  local section
  section=$(sed -n '/id="hero-metrics"/,/<\/header>/p' "$DASHBOARD")
  [ -z "$section" ] && return 1
  echo "$section" | grep -q 'Last Release' || return 1
}

check_last_release_default_value() {
  # 初期値が "--" であることを確認
  local section
  section=$(sed -n '/id="hero-metrics"/,/<\/header>/p' "$DASHBOARD")
  [ -z "$section" ] && return 1
  echo "$section" | grep 'id="metric-last-release"' | grep -q '\-\-' || return 1
}

check_last_release_date_modifier_class() {
  # metric-value--date 修飾子クラスが適用されていることを確認
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
