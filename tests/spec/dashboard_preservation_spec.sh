Describe 'dashboard.html: Existing Asset Preservation Verification (Task 7)'
  TEMPLATE="core/templates/dashboard.html"

  # ── HTML ID の存在確認 ──

  It 'contains HTML ID #app'
    The contents of file "$TEMPLATE" should include 'id="app"'
  End

  It 'contains HTML ID #backlog-board'
    The contents of file "$TEMPLATE" should include 'id="backlog-board"'
  End

  It 'contains HTML ID #velocity-chart'
    The contents of file "$TEMPLATE" should include 'id="velocity-chart"'
  End

  It 'contains HTML ID #insights-panel'
    The contents of file "$TEMPLATE" should include 'id="insights-panel"'
  End

  It 'contains HTML ID #agent-messages'
    The contents of file "$TEMPLATE" should include 'id="agent-messages"'
  End

  It 'contains HTML ID #gantt-chart'
    The contents of file "$TEMPLATE" should include 'id="gantt-chart"'
  End

  It 'contains HTML ID #task-list'
    The contents of file "$TEMPLATE" should include 'id="task-list"'
  End

  It 'contains HTML ID #story-select'
    The contents of file "$TEMPLATE" should include 'id="story-select"'
  End

  # ── CSS クラス名の存在確認 ──

  It 'contains CSS class .panel'
    The contents of file "$TEMPLATE" should include '.panel'
  End

  It 'contains CSS class .kanban-card'
    The contents of file "$TEMPLATE" should include '.kanban-card'
  End

  It 'contains CSS class .msg-bubble'
    The contents of file "$TEMPLATE" should include '.msg-bubble'
  End

  It 'contains CSS class .kanban-col'
    The contents of file "$TEMPLATE" should include '.kanban-col'
  End

  It 'contains CSS class .panel-title'
    The contents of file "$TEMPLATE" should include '.panel-title'
  End

  It 'contains CSS class .task-chip'
    The contents of file "$TEMPLATE" should include '.task-chip'
  End

  It 'contains CSS class .chart-container'
    The contents of file "$TEMPLATE" should include '.chart-container'
  End

  It 'contains CSS class .refresh-btn'
    The contents of file "$TEMPLATE" should include '.refresh-btn'
  End

  It 'contains CSS class .msg-agent'
    The contents of file "$TEMPLATE" should include '.msg-agent'
  End

  It 'contains CSS class .msg-action'
    The contents of file "$TEMPLATE" should include '.msg-action'
  End

  It 'contains CSS class .msg-note'
    The contents of file "$TEMPLATE" should include '.msg-note'
  End

  It 'contains CSS class .msg-time'
    The contents of file "$TEMPLATE" should include '.msg-time'
  End

  # ── JS 関数宣言の存在確認 ──

  It 'declares JS function renderBacklog'
    The contents of file "$TEMPLATE" should include 'function renderBacklog()'
  End

  It 'declares JS function renderVelocity'
    The contents of file "$TEMPLATE" should include 'function renderVelocity()'
  End

  It 'defines JS function renderStoryDetail'
    The contents of file "$TEMPLATE" should include 'renderStoryDetail'
  End

  It 'declares JS function renderInsights'
    The contents of file "$TEMPLATE" should include 'function renderInsights()'
  End

  It 'declares JS function renderMessages'
    The contents of file "$TEMPLATE" should include 'function renderMessages()'
  End

  It 'declares JS function renderGantt'
    The contents of file "$TEMPLATE" should include 'function renderGantt()'
  End

  It 'declares JS function renderTasks'
    The contents of file "$TEMPLATE" should include 'function renderTasks()'
  End

  # ── テンプレートプレースホルダーの存在確認 ──

  It 'contains template placeholder {{BACKLOG_DATA}}'
    The contents of file "$TEMPLATE" should include '{{BACKLOG_DATA}}'
  End

  It 'contains template placeholder {{STORIES_DATA}}'
    The contents of file "$TEMPLATE" should include '{{STORIES_DATA}}'
  End

  It 'contains template placeholder {{AGENT_COLORS}}'
    The contents of file "$TEMPLATE" should include '{{AGENT_COLORS}}'
  End

  It 'contains template placeholder {{INSIGHTS_DATA}}'
    The contents of file "$TEMPLATE" should include '{{INSIGHTS_DATA}}'
  End
End
