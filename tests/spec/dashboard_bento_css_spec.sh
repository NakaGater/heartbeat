Describe 'dashboard.html: Bentoグリッド + サイドバーのCSS実装（タスク3）'
  TEMPLATE="core/templates/dashboard.html"

  # ── 完了条件1: .sidebar に position:fixed と width:48px ──

  It '.sidebar に position: fixed が定義されている'
    extract_sidebar_position() {
      awk '/\.sidebar[ \t]*\{/{found=1} found && /position[ \t]*:[ \t]*fixed/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_sidebar_position
    The output should equal "ok"
  End

  It '.sidebar に width: 48px が定義されている'
    extract_sidebar_width() {
      awk '/\.sidebar[ \t]*\{/{found=1} found && /width[ \t]*:[ \t]*48px/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_sidebar_width
    The output should equal "ok"
  End

  # ── 完了条件2: .sidebar に backdrop-filter と -webkit-backdrop-filter ──

  It '.sidebar に backdrop-filter が定義されている'
    extract_sidebar_backdrop() {
      awk '/\.sidebar[ \t]*\{/{found=1} found && /[^-]backdrop-filter[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_sidebar_backdrop
    The output should equal "ok"
  End

  It '.sidebar に -webkit-backdrop-filter が定義されている'
    extract_sidebar_webkit_backdrop() {
      awk '/\.sidebar[ \t]*\{/{found=1} found && /-webkit-backdrop-filter[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_sidebar_webkit_backdrop
    The output should equal "ok"
  End

  # ── 完了条件3: .bento-grid に display:grid と grid-template-columns:repeat(12,1fr) ──

  It '.bento-grid に display: grid が定義されている'
    extract_bentogrid_display() {
      awk '/\.bento-grid[ \t]*\{/{found=1} found && /display[ \t]*:[ \t]*grid/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_bentogrid_display
    The output should equal "ok"
  End

  It '.bento-grid に grid-template-columns: repeat(12, 1fr) が定義されている'
    extract_bentogrid_columns() {
      awk '/\.bento-grid[ \t]*\{/{found=1} found && /grid-template-columns[ \t]*:.*repeat\(12/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_bentogrid_columns
    The output should equal "ok"
  End

  # ── 完了条件4: .bento-grid に margin-left: 48px ──

  It '.bento-grid に margin-left: 48px が定義されている'
    extract_bentogrid_margin() {
      awk '/\.bento-grid[ \t]*\{/{found=1} found && /margin-left[ \t]*:[ \t]*48px/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_bentogrid_margin
    The output should equal "ok"
  End

  # ── 完了条件5: .bento-card.card-backlog-velocity に grid-column: 1 / -1 (統合カード) ──

  It '.bento-card.card-backlog-velocity に grid-column: 1 / -1 が定義されている'
    extract_backlog_velocity_col() {
      awk '/\.bento-card\.card-backlog-velocity|\.card-backlog-velocity/{found=1} found && /grid-column[ \t]*:.*1[ \t]*\/[ \t]*-1/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_backlog_velocity_col
    The output should equal "ok"
  End

  It '.card-backlog-velocity 内の .card-split に grid-template-columns が定義されている'
    extract_card_split_columns() {
      awk '/\.card-backlog-velocity \.card-split|\.card-backlog-velocity.*\.card-split/{found=1} found && /grid-template-columns[ \t]*:.*7fr 5fr/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_card_split_columns
    The output should equal "ok"
  End

  # ── 完了条件6: .bento-card.card-gantt と .bento-card.card-tasks に grid-column: 1 / -1 ──

  It '.bento-card.card-gantt に grid-column: 1 / -1 が定義されている'
    extract_gantt_col() {
      awk '/\.bento-card\.card-gantt|\.card-gantt/{found=1} found && /grid-column[ \t]*:.*1[ \t]*\/[ \t]*-1/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_gantt_col
    The output should equal "ok"
  End

  It '.bento-card.card-tasks に grid-column: 1 / -1 が定義されている'
    extract_tasks_col() {
      awk '/\.bento-card\.card-tasks|\.card-tasks/{found=1} found && /grid-column[ \t]*:.*1[ \t]*\/[ \t]*-1/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_tasks_col
    The output should equal "ok"
  End

  # ── 完了条件7: .bento-card.card-messages に grid-column: 1 / -1 ──

  It '.bento-card.card-messages に grid-column: 1 / -1 が定義されている'
    extract_messages_full_width() {
      awk '/\.bento-card\.card-messages|\.card-messages/{found=1} found && /grid-column[ \t]*:.*1[ \t]*\/[ \t]*-1/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_messages_full_width
    The output should equal "ok"
  End

  # ── 完了条件8: .sidebar-icon に transition + :hover でスタイル変化 ──

  It '.sidebar-icon に transition が定義されている'
    extract_sidebar_icon_transition() {
      awk '/\.sidebar-icon[ \t]*\{/{found=1} found && /transition[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_sidebar_icon_transition
    The output should equal "ok"
  End

  It '.sidebar-icon:hover でスタイルが変化する'
    check_sidebar_icon_hover() {
      grep -q '\.sidebar-icon:hover' "$TEMPLATE" && echo "ok"
    }
    When call check_sidebar_icon_hover
    The output should equal "ok"
  End

  # ── 完了条件9: .sidebar-icon.active::before に擬似要素がある ──

  It '.sidebar-icon.active::before に擬似要素が定義されている'
    check_sidebar_active_before() {
      grep -q '\.sidebar-icon\.active::before' "$TEMPLATE" && echo "ok"
    }
    When call check_sidebar_active_before
    The output should equal "ok"
  End

  # ── 追加検証: .bento-card に overflow:hidden ──

  It '.bento-card に overflow: hidden が定義されている'
    extract_bento_card_overflow() {
      awk '/\.bento-card[ \t]*\{/{found=1} found && /overflow[ \t]*:[ \t]*hidden/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_bento_card_overflow
    The output should equal "ok"
  End

  # ── 追加検証: .hero-metrics に display:flex または display:grid ──

  It '.hero-metrics に display: flex または grid が定義されている'
    extract_hero_metrics_display() {
      awk '/\.hero-metrics[ \t]*\{/{found=1} found && /display[ \t]*:[ \t]*(flex|grid)/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_hero_metrics_display
    The output should equal "ok"
  End
End
