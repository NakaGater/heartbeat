Describe 'dashboard.html: renderHeroMetrics last-release date logic (T2)'
  TEMPLATE="core/templates/dashboard.html"

  # Extract the renderHeroMetrics function body for inspection
  extract_render_hero_metrics() {
    awk '/function renderHeroMetrics\(\)/{found=1} found{print} found && /^  \}$/{exit}' "$TEMPLATE"
  }

  # -- T2-AC1: renderHeroMetrics references metric-last-release element --

  It 'references metric-last-release element inside renderHeroMetrics'
    check_metric_last_release_ref() {
      extract_render_hero_metrics | grep -q 'metric-last-release'
    }
    When call check_metric_last_release_ref
    The status should be success
  End

  # -- T2-AC2: renderHeroMetrics computes latest completed date for last-release --

  It 'computes the latest completed date and assigns it to last-release element'
    check_latest_completed_for_release() {
      local body
      body=$(extract_render_hero_metrics)
      # Must contain logic that finds the max/latest completed date
      # AND connects it to the metric-last-release element
      echo "$body" | grep -q 'metric-last-release' || return 1
      echo "$body" | grep -q 'new Date' || return 1
    }
    When call check_latest_completed_for_release
    The status should be success
  End

  # -- T2-AC3: renderHeroMetrics formats date as yyyy/mm/dd --

  It 'uses toLocaleDateString with ja-JP locale for yyyy/mm/dd format'
    check_date_format_ja() {
      extract_render_hero_metrics | grep -q "toLocaleDateString.*ja-JP"
    }
    When call check_date_format_ja
    The status should be success
  End
End
