Describe 'dashboard.html: JavaScript追加 + 既存資産保全検証（タスク9）'
  TEMPLATE="core/templates/dashboard.html"

  # ── 完了条件1: function animateCounter が定義されていること ──

  It 'JS 関数 animateCounter が定義されている'
    The contents of file "$TEMPLATE" should include 'function animateCounter'
  End

  # ── 完了条件2: function renderHeroMetrics が定義されていること ──

  It 'JS 関数 renderHeroMetrics が定義されている'
    The contents of file "$TEMPLATE" should include 'function renderHeroMetrics'
  End

  # ── 完了条件3: function initSidebar が定義されていること ──

  It 'JS 関数 initSidebar が定義されている'
    The contents of file "$TEMPLATE" should include 'function initSidebar'
  End

  # ── 完了条件4: ES5準拠（let, const, =>, class をJS内で使用していないこと） ──

  It 'ES5準拠: let 宣言が script ブロック内に存在しない'
    extract_js_let() {
      sed -n '/<script>/,/<\/script>/p' "$TEMPLATE" | grep -cE '(^|[^a-zA-Z])let ' || true
    }
    When call extract_js_let
    The output should equal "0"
  End

  It 'ES5準拠: const 宣言が script ブロック内に存在しない'
    extract_js_const() {
      sed -n '/<script>/,/<\/script>/p' "$TEMPLATE" | grep -cE '(^|[^a-zA-Z])const ' || true
    }
    When call extract_js_const
    The output should equal "0"
  End

  It 'ES5準拠: アロー関数 => が script ブロック内に存在しない'
    extract_js_arrow() {
      sed -n '/<script>/,/<\/script>/p' "$TEMPLATE" | grep -cE '=>' || true
    }
    When call extract_js_arrow
    The output should equal "0"
  End

  It 'ES5準拠: class 宣言が script ブロック内に存在しない'
    extract_js_class() {
      sed -n '/<script>/,/<\/script>/p' "$TEMPLATE" | grep -cE '(^|[[:space:]])class [A-Z]' || true
    }
    When call extract_js_class
    The output should equal "0"
  End

  # ── 完了条件5: 既存 render 関数が全て維持されていること ──

  It '既存JS関数 renderBacklog が維持されている'
    The contents of file "$TEMPLATE" should include 'function renderBacklog()'
  End

  It '既存JS関数 renderVelocity が維持されている'
    The contents of file "$TEMPLATE" should include 'function renderVelocity()'
  End

  It '既存JS関数 renderStoryDetail が維持されている'
    The contents of file "$TEMPLATE" should include 'renderStoryDetail'
  End

  It '既存JS関数 renderInsights が維持されている'
    The contents of file "$TEMPLATE" should include 'function renderInsights()'
  End

  It '既存JS関数 renderMessages が維持されている'
    The contents of file "$TEMPLATE" should include 'function renderMessages()'
  End

  # ── 完了条件6: テンプレートプレースホルダーが全て維持されていること ──

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

  # ── 完了条件7: 全HTML IDが維持されていること ──

  It 'HTML ID #backlog-board が維持されている'
    The contents of file "$TEMPLATE" should include 'id="backlog-board"'
  End

  It 'HTML ID #velocity-chart が維持されている'
    The contents of file "$TEMPLATE" should include 'id="velocity-chart"'
  End

  It 'HTML ID #gantt-chart が維持されている'
    The contents of file "$TEMPLATE" should include 'id="gantt-chart"'
  End

  It 'HTML ID #task-list が維持されている'
    The contents of file "$TEMPLATE" should include 'id="task-list"'
  End

  It 'HTML ID #insights-panel が維持されている'
    The contents of file "$TEMPLATE" should include 'id="insights-panel"'
  End

  It 'HTML ID #agent-messages が維持されている'
    The contents of file "$TEMPLATE" should include 'id="agent-messages"'
  End

  It 'HTML ID #story-select が維持されている'
    The contents of file "$TEMPLATE" should include 'id="story-select"'
  End

  It 'HTML ID #app が維持されている'
    The contents of file "$TEMPLATE" should include 'id="app"'
  End
End
