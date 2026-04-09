Describe 'dashboard.html: JavaScript Addition + Existing Asset Preservation (Task 9)'
  TEMPLATE="core/templates/dashboard.html"

  # -- AC1: function animateCounter is defined --

  It 'defines JS function animateCounter'
    The contents of file "$TEMPLATE" should include 'function animateCounter'
  End

  # -- AC2: function renderHeroMetrics is defined --

  It 'defines JS function renderHeroMetrics'
    The contents of file "$TEMPLATE" should include 'function renderHeroMetrics'
  End

  # -- AC3: function initSidebar is defined --

  It 'defines JS function initSidebar'
    The contents of file "$TEMPLATE" should include 'function initSidebar'
  End

  # -- AC4: ES5 compliant (no let, const, =>, class in JS) --

  It 'has no let declarations in script block (ES5 compliant)'
    extract_js_let() {
      sed -n '/<script>/,/<\/script>/p' "$TEMPLATE" | grep -cE '(^|[^a-zA-Z])let ' || true
    }
    When call extract_js_let
    The output should equal "0"
  End

  It 'has no const declarations in script block (ES5 compliant)'
    extract_js_const() {
      sed -n '/<script>/,/<\/script>/p' "$TEMPLATE" | grep -cE '(^|[^a-zA-Z])const ' || true
    }
    When call extract_js_const
    The output should equal "0"
  End

  It 'has no arrow functions => in script block (ES5 compliant)'
    extract_js_arrow() {
      sed -n '/<script>/,/<\/script>/p' "$TEMPLATE" | grep -cE '=>' || true
    }
    When call extract_js_arrow
    The output should equal "0"
  End

  It 'has no class declarations in script block (ES5 compliant)'
    extract_js_class() {
      sed -n '/<script>/,/<\/script>/p' "$TEMPLATE" | grep -cE '(^|[[:space:]])class [A-Z]' || true
    }
    When call extract_js_class
    The output should equal "0"
  End

  # -- AC5: All existing render functions are preserved --

  It 'preserves existing JS function renderBacklog'
    The contents of file "$TEMPLATE" should include 'function renderBacklog()'
  End

  It 'preserves existing JS function renderVelocity'
    The contents of file "$TEMPLATE" should include 'function renderVelocity()'
  End

  It 'preserves existing JS function renderStoryDetail'
    The contents of file "$TEMPLATE" should include 'renderStoryDetail'
  End

  It 'preserves existing JS function renderInsights'
    The contents of file "$TEMPLATE" should include 'function renderInsights()'
  End

  It 'preserves existing JS function renderMessages'
    The contents of file "$TEMPLATE" should include 'function renderMessages()'
  End

  # -- AC6: All template placeholders are preserved --

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

  # -- AC7: All HTML IDs are preserved --

  It 'preserves HTML ID #backlog-board'
    The contents of file "$TEMPLATE" should include 'id="backlog-board"'
  End

  It 'preserves HTML ID #velocity-chart'
    The contents of file "$TEMPLATE" should include 'id="velocity-chart"'
  End

  It 'preserves HTML ID #gantt-chart'
    The contents of file "$TEMPLATE" should include 'id="gantt-chart"'
  End

  It 'preserves HTML ID #task-list'
    The contents of file "$TEMPLATE" should include 'id="task-list"'
  End

  It 'preserves HTML ID #insights-panel'
    The contents of file "$TEMPLATE" should include 'id="insights-panel"'
  End

  It 'preserves HTML ID #agent-messages'
    The contents of file "$TEMPLATE" should include 'id="agent-messages"'
  End

  It 'preserves HTML ID #story-select'
    The contents of file "$TEMPLATE" should include 'id="story-select"'
  End

  It 'preserves HTML ID #app'
    The contents of file "$TEMPLATE" should include 'id="app"'
  End
End
