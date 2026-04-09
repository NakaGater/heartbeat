Describe 'dashboard.html: HTML Structure Bento Grid Layout (Task 2)'
  TEMPLATE="core/templates/dashboard.html"

  # ── 完了条件1: サイドバーナビゲーション ──

  It 'contains nav class="sidebar" with sidebar-icon'
    The contents of file "$TEMPLATE" should include '<nav class="sidebar">'
  End

  It 'contains 6 sidebar-icons'
    extract_sidebar_icons() {
      grep -o 'class="sidebar-icon[^"]*"' "$TEMPLATE" | wc -l | tr -d ' '
    }
    When call extract_sidebar_icons
    The output should equal "6"
  End

  # ── 完了条件2: div#app に bento-grid クラスが付与されている ──

  It 'assigns class="bento-grid" to div id="app"'
    The contents of file "$TEMPLATE" should include 'id="app" class="bento-grid"'
  End

  # ── 完了条件3: hero-metrics ヘッダーが存在し metric-card を4つ含む ──

  It 'contains header class="hero-metrics"'
    The contents of file "$TEMPLATE" should include 'class="hero-metrics"'
  End

  It 'contains 4 metric-cards'
    count_metric_cards() {
      grep -o 'class="metric-card[^"]*"' "$TEMPLATE" | wc -l | tr -d ' '
    }
    When call count_metric_cards
    The output should equal "4"
  End

  # ── 完了条件4: 各 metric-card に metric-value と metric-label が含まれる ──

  It 'contains metric-value elements'
    The contents of file "$TEMPLATE" should include 'class="metric-value"'
  End

  It 'contains metric-label elements'
    The contents of file "$TEMPLATE" should include 'class="metric-label"'
  End

  # ── 完了条件5: metric-progress 内に SVG metric-ring がある ──

  It 'contains svg class="metric-ring" inside metric-progress'
    The contents of file "$TEMPLATE" should include 'id="metric-progress"'
  End

  It 'contains metric-ring SVG'
    The contents of file "$TEMPLATE" should include 'class="metric-ring"'
  End

  # ── 完了条件6: #backlog-board と #velocity-chart が統合 bento-card card-backlog-velocity 内にある ──

  It 'contains bento-card card-backlog-velocity'
    The contents of file "$TEMPLATE" should include 'class="bento-card card-backlog-velocity"'
  End

  It 'places #backlog-board inside bento-card card-backlog-velocity'
    check_backlog_in_bento() {
      awk '/class="bento-card card-backlog-velocity"/{found=1} found && /id="backlog-board"/{print "ok"; exit}' "$TEMPLATE"
    }
    When call check_backlog_in_bento
    The output should equal "ok"
  End

  It 'places #velocity-chart inside bento-card card-backlog-velocity'
    check_velocity_in_bento() {
      awk '/class="bento-card card-backlog-velocity"/{found=1} found && /id="velocity-chart"/{print "ok"; exit}' "$TEMPLATE"
    }
    When call check_velocity_in_bento
    The output should equal "ok"
  End

  # ── 完了条件7: card-split で2カラムレイアウト ──

  It 'contains card-split inside card-backlog-velocity'
    check_card_split() {
      awk '/class="bento-card card-backlog-velocity"/{found=1} found && /class="card-split"/{print "ok"; exit}' "$TEMPLATE"
    }
    When call check_card_split
    The output should equal "ok"
  End

  # ── 完了条件8: #gantt-chart と #task-list が統合 bento-card card-story 内にある ──

  It 'contains bento-card card-story'
    The contents of file "$TEMPLATE" should include 'class="bento-card card-story"'
  End

  It 'places #gantt-chart inside bento-card card-story'
    check_gantt_in_bento() {
      awk '/class="bento-card card-story"/{found=1} found && /id="gantt-chart"/{print "ok"; exit}' "$TEMPLATE"
    }
    When call check_gantt_in_bento
    The output should equal "ok"
  End

  It 'places #task-list inside bento-card card-story'
    check_tasklist_in_bento() {
      awk '/class="bento-card card-story"/{found=1} found && /id="task-list"/{print "ok"; exit}' "$TEMPLATE"
    }
    When call check_tasklist_in_bento
    The output should equal "ok"
  End

  It 'contains story-divider separator inside card-story'
    check_story_divider() {
      awk '/class="bento-card card-story"/{found=1} found && /class="story-divider"/{print "ok"; exit}' "$TEMPLATE"
    }
    When call check_story_divider
    The output should equal "ok"
  End

  # ── 完了条件9: #agent-messages が bento-card card-messages 内にある ──

  It 'contains bento-card card-messages'
    The contents of file "$TEMPLATE" should include 'class="bento-card card-messages"'
  End

  It 'places #agent-messages inside bento-card card-messages'
    check_messages_in_bento() {
      awk '/class="bento-card card-messages"/{found=1} found && /id="agent-messages"/{print "ok"; exit}' "$TEMPLATE"
    }
    When call check_messages_in_bento
    The output should equal "ok"
  End

  # ── 完了条件10: #insights-panel が bento-card card-insights 内にある ──

  It 'contains bento-card card-insights'
    The contents of file "$TEMPLATE" should include 'class="bento-card card-insights"'
  End

  It 'places #insights-panel inside bento-card card-insights'
    check_insights_in_bento() {
      awk '/class="bento-card card-insights"/{found=1} found && /id="insights-panel"/{print "ok"; exit}' "$TEMPLATE"
    }
    When call check_insights_in_bento
    The output should equal "ok"
  End

  # ── 完了条件11: 既存IDが全て維持されている ──

  It 'preserves existing ID #backlog-board'
    The contents of file "$TEMPLATE" should include 'id="backlog-board"'
  End

  It 'preserves existing ID #velocity-chart'
    The contents of file "$TEMPLATE" should include 'id="velocity-chart"'
  End

  It 'preserves existing ID #gantt-chart'
    The contents of file "$TEMPLATE" should include 'id="gantt-chart"'
  End

  It 'preserves existing ID #task-list'
    The contents of file "$TEMPLATE" should include 'id="task-list"'
  End

  It 'preserves existing ID #insights-panel'
    The contents of file "$TEMPLATE" should include 'id="insights-panel"'
  End

  It 'preserves existing ID #agent-messages'
    The contents of file "$TEMPLATE" should include 'id="agent-messages"'
  End

  It 'preserves existing ID #story-select'
    The contents of file "$TEMPLATE" should include 'id="story-select"'
  End

  It 'preserves existing ID #app'
    The contents of file "$TEMPLATE" should include 'id="app"'
  End

  # ── 完了条件12: テンプレートプレースホルダーが維持されている ──

  It 'preserves placeholder {{BACKLOG_DATA}}'
    The contents of file "$TEMPLATE" should include '{{BACKLOG_DATA}}'
  End

  It 'preserves placeholder {{STORIES_DATA}}'
    The contents of file "$TEMPLATE" should include '{{STORIES_DATA}}'
  End

  It 'preserves placeholder {{AGENT_COLORS}}'
    The contents of file "$TEMPLATE" should include '{{AGENT_COLORS}}'
  End

  It 'preserves placeholder {{INSIGHTS_DATA}}'
    The contents of file "$TEMPLATE" should include '{{INSIGHTS_DATA}}'
  End
End
