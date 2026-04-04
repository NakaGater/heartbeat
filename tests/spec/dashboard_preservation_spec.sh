Describe 'dashboard.html: 既存資産保全の検証（タスク7）'
  TEMPLATE="core/templates/dashboard.html"

  # ── HTML ID の存在確認 ──

  It 'HTML ID #app が存在する'
    The contents of file "$TEMPLATE" should include 'id="app"'
  End

  It 'HTML ID #backlog-board が存在する'
    The contents of file "$TEMPLATE" should include 'id="backlog-board"'
  End

  It 'HTML ID #velocity-chart が存在する'
    The contents of file "$TEMPLATE" should include 'id="velocity-chart"'
  End

  It 'HTML ID #insights-panel が存在する'
    The contents of file "$TEMPLATE" should include 'id="insights-panel"'
  End

  It 'HTML ID #agent-messages が存在する'
    The contents of file "$TEMPLATE" should include 'id="agent-messages"'
  End

  It 'HTML ID #gantt-chart が存在する'
    The contents of file "$TEMPLATE" should include 'id="gantt-chart"'
  End

  It 'HTML ID #task-list が存在する'
    The contents of file "$TEMPLATE" should include 'id="task-list"'
  End

  It 'HTML ID #story-select が存在する'
    The contents of file "$TEMPLATE" should include 'id="story-select"'
  End

  # ── CSS クラス名の存在確認 ──

  It 'CSS クラス .panel が存在する'
    The contents of file "$TEMPLATE" should include '.panel'
  End

  It 'CSS クラス .kanban-card が存在する'
    The contents of file "$TEMPLATE" should include '.kanban-card'
  End

  It 'CSS クラス .msg-bubble が存在する'
    The contents of file "$TEMPLATE" should include '.msg-bubble'
  End

  It 'CSS クラス .kanban-col が存在する'
    The contents of file "$TEMPLATE" should include '.kanban-col'
  End

  It 'CSS クラス .panel-title が存在する'
    The contents of file "$TEMPLATE" should include '.panel-title'
  End

  It 'CSS クラス .task-chip が存在する'
    The contents of file "$TEMPLATE" should include '.task-chip'
  End

  It 'CSS クラス .chart-container が存在する'
    The contents of file "$TEMPLATE" should include '.chart-container'
  End

  It 'CSS クラス .refresh-btn が存在する'
    The contents of file "$TEMPLATE" should include '.refresh-btn'
  End

  It 'CSS クラス .msg-agent が存在する'
    The contents of file "$TEMPLATE" should include '.msg-agent'
  End

  It 'CSS クラス .msg-action が存在する'
    The contents of file "$TEMPLATE" should include '.msg-action'
  End

  It 'CSS クラス .msg-note が存在する'
    The contents of file "$TEMPLATE" should include '.msg-note'
  End

  It 'CSS クラス .msg-time が存在する'
    The contents of file "$TEMPLATE" should include '.msg-time'
  End

  # ── JS 関数宣言の存在確認 ──

  It 'JS 関数 renderBacklog が宣言されている'
    The contents of file "$TEMPLATE" should include 'function renderBacklog()'
  End

  It 'JS 関数 renderVelocity が宣言されている'
    The contents of file "$TEMPLATE" should include 'function renderVelocity()'
  End

  It 'JS 関数 renderStoryDetail が定義されている'
    The contents of file "$TEMPLATE" should include 'renderStoryDetail'
  End

  It 'JS 関数 renderInsights が宣言されている'
    The contents of file "$TEMPLATE" should include 'function renderInsights()'
  End

  It 'JS 関数 renderMessages が宣言されている'
    The contents of file "$TEMPLATE" should include 'function renderMessages()'
  End

  It 'JS 関数 renderGantt が宣言されている'
    The contents of file "$TEMPLATE" should include 'function renderGantt()'
  End

  It 'JS 関数 renderTasks が宣言されている'
    The contents of file "$TEMPLATE" should include 'function renderTasks()'
  End

  # ── テンプレートプレースホルダーの存在確認 ──

  It 'テンプレートプレースホルダー {{BACKLOG_DATA}} が存在する'
    The contents of file "$TEMPLATE" should include '{{BACKLOG_DATA}}'
  End

  It 'テンプレートプレースホルダー {{STORIES_DATA}} が存在する'
    The contents of file "$TEMPLATE" should include '{{STORIES_DATA}}'
  End

  It 'テンプレートプレースホルダー {{AGENT_COLORS}} が存在する'
    The contents of file "$TEMPLATE" should include '{{AGENT_COLORS}}'
  End

  It 'テンプレートプレースホルダー {{INSIGHTS_DATA}} が存在する'
    The contents of file "$TEMPLATE" should include '{{INSIGHTS_DATA}}'
  End
End
