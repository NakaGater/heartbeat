Describe 'dashboard.html: HTML構造のBentoグリッド化（タスク2）'
  TEMPLATE="core/templates/dashboard.html"

  # ── 完了条件1: サイドバーナビゲーション ──

  It 'nav class="sidebar" が存在し sidebar-icon を含む'
    The contents of file "$TEMPLATE" should include '<nav class="sidebar">'
  End

  It 'sidebar-icon が6つ存在する'
    extract_sidebar_icons() {
      grep -o 'class="sidebar-icon[^"]*"' "$TEMPLATE" | wc -l | tr -d ' '
    }
    When call extract_sidebar_icons
    The output should equal "6"
  End

  # ── 完了条件2: div#app に bento-grid クラスが付与されている ──

  It 'div id="app" に class="bento-grid" が付与されている'
    The contents of file "$TEMPLATE" should include 'id="app" class="bento-grid"'
  End

  # ── 完了条件3: hero-metrics ヘッダーが存在し metric-card を4つ含む ──

  It 'header class="hero-metrics" が存在する'
    The contents of file "$TEMPLATE" should include '<header class="hero-metrics"'
  End

  It 'metric-card が4つ存在する'
    count_metric_cards() {
      grep -o 'class="metric-card"' "$TEMPLATE" | wc -l | tr -d ' '
    }
    When call count_metric_cards
    The output should equal "4"
  End

  # ── 完了条件4: 各 metric-card に metric-value と metric-label が含まれる ──

  It 'metric-value 要素が存在する'
    The contents of file "$TEMPLATE" should include 'class="metric-value"'
  End

  It 'metric-label 要素が存在する'
    The contents of file "$TEMPLATE" should include 'class="metric-label"'
  End

  # ── 完了条件5: metric-progress 内に SVG metric-ring がある ──

  It 'metric-progress 内に svg class="metric-ring" が存在する'
    The contents of file "$TEMPLATE" should include 'id="metric-progress"'
  End

  It 'metric-ring SVG が存在する'
    The contents of file "$TEMPLATE" should include 'class="metric-ring"'
  End

  # ── 完了条件6: #backlog-board が bento-card card-backlog 内にある ──

  It 'bento-card card-backlog が存在する'
    The contents of file "$TEMPLATE" should include 'class="bento-card card-backlog"'
  End

  It '#backlog-board が bento-card card-backlog の中に存在する'
    check_backlog_in_bento() {
      awk '/class="bento-card card-backlog"/{found=1} found && /id="backlog-board"/{print "ok"; exit}' "$TEMPLATE"
    }
    When call check_backlog_in_bento
    The output should equal "ok"
  End

  # ── 完了条件7: #velocity-chart が bento-card card-velocity 内にある ──

  It 'bento-card card-velocity が存在する'
    The contents of file "$TEMPLATE" should include 'class="bento-card card-velocity"'
  End

  It '#velocity-chart が bento-card card-velocity の中に存在する'
    check_velocity_in_bento() {
      awk '/class="bento-card card-velocity"/{found=1} found && /id="velocity-chart"/{print "ok"; exit}' "$TEMPLATE"
    }
    When call check_velocity_in_bento
    The output should equal "ok"
  End

  # ── 完了条件8: #gantt-chart と #task-list が bento-card card-story 内にある ──

  It 'bento-card card-story が存在する'
    The contents of file "$TEMPLATE" should include 'class="bento-card card-story"'
  End

  It '#gantt-chart が bento-card card-story の中に存在する'
    check_gantt_in_bento() {
      awk '/class="bento-card card-story"/{found=1} found && /id="gantt-chart"/{print "ok"; exit}' "$TEMPLATE"
    }
    When call check_gantt_in_bento
    The output should equal "ok"
  End

  It '#task-list が bento-card card-story の中に存在する'
    check_tasklist_in_bento() {
      awk '/class="bento-card card-story"/{found=1} found && /id="task-list"/{print "ok"; exit}' "$TEMPLATE"
    }
    When call check_tasklist_in_bento
    The output should equal "ok"
  End

  # ── 完了条件9: #agent-messages が bento-card card-messages 内にある ──

  It 'bento-card card-messages が存在する'
    The contents of file "$TEMPLATE" should include 'class="bento-card card-messages"'
  End

  It '#agent-messages が bento-card card-messages の中に存在する'
    check_messages_in_bento() {
      awk '/class="bento-card card-messages"/{found=1} found && /id="agent-messages"/{print "ok"; exit}' "$TEMPLATE"
    }
    When call check_messages_in_bento
    The output should equal "ok"
  End

  # ── 完了条件10: #insights-panel が bento-card card-insights 内にある ──

  It 'bento-card card-insights が存在する'
    The contents of file "$TEMPLATE" should include 'class="bento-card card-insights"'
  End

  It '#insights-panel が bento-card card-insights の中に存在する'
    check_insights_in_bento() {
      awk '/class="bento-card card-insights"/{found=1} found && /id="insights-panel"/{print "ok"; exit}' "$TEMPLATE"
    }
    When call check_insights_in_bento
    The output should equal "ok"
  End

  # ── 完了条件11: 既存IDが全て維持されている ──

  It '既存ID #backlog-board が維持されている'
    The contents of file "$TEMPLATE" should include 'id="backlog-board"'
  End

  It '既存ID #velocity-chart が維持されている'
    The contents of file "$TEMPLATE" should include 'id="velocity-chart"'
  End

  It '既存ID #gantt-chart が維持されている'
    The contents of file "$TEMPLATE" should include 'id="gantt-chart"'
  End

  It '既存ID #task-list が維持されている'
    The contents of file "$TEMPLATE" should include 'id="task-list"'
  End

  It '既存ID #insights-panel が維持されている'
    The contents of file "$TEMPLATE" should include 'id="insights-panel"'
  End

  It '既存ID #agent-messages が維持されている'
    The contents of file "$TEMPLATE" should include 'id="agent-messages"'
  End

  It '既存ID #story-select が維持されている'
    The contents of file "$TEMPLATE" should include 'id="story-select"'
  End

  It '既存ID #app が維持されている'
    The contents of file "$TEMPLATE" should include 'id="app"'
  End

  # ── 完了条件12: テンプレートプレースホルダーが維持されている ──

  It 'プレースホルダー {{BACKLOG_DATA}} が維持されている'
    The contents of file "$TEMPLATE" should include '{{BACKLOG_DATA}}'
  End

  It 'プレースホルダー {{STORIES_DATA}} が維持されている'
    The contents of file "$TEMPLATE" should include '{{STORIES_DATA}}'
  End

  It 'プレースホルダー {{AGENT_COLORS}} が維持されている'
    The contents of file "$TEMPLATE" should include '{{AGENT_COLORS}}'
  End

  It 'プレースホルダー {{INSIGHTS_DATA}} が維持されている'
    The contents of file "$TEMPLATE" should include '{{INSIGHTS_DATA}}'
  End
End
