Describe 'dashboard.html: Bento Grid + Sidebar CSS Implementation (Task 3)'
  TEMPLATE="core/templates/dashboard.html"

  # -- AC1: .sidebar has position:fixed and width:48px --

  It 'defines position: fixed on .sidebar'
    extract_sidebar_position() {
      awk '/\.sidebar[ \t]*\{/{found=1} found && /position[ \t]*:[ \t]*fixed/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_sidebar_position
    The output should equal "ok"
  End

  It 'defines width: 48px on .sidebar'
    extract_sidebar_width() {
      awk '/\.sidebar[ \t]*\{/{found=1} found && /width[ \t]*:[ \t]*48px/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_sidebar_width
    The output should equal "ok"
  End

  # -- AC2: .sidebar has backdrop-filter and -webkit-backdrop-filter --

  It 'defines backdrop-filter on .sidebar'
    extract_sidebar_backdrop() {
      awk '/\.sidebar[ \t]*\{/{found=1} found && /[^-]backdrop-filter[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_sidebar_backdrop
    The output should equal "ok"
  End

  It 'defines -webkit-backdrop-filter on .sidebar'
    extract_sidebar_webkit_backdrop() {
      awk '/\.sidebar[ \t]*\{/{found=1} found && /-webkit-backdrop-filter[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_sidebar_webkit_backdrop
    The output should equal "ok"
  End

  # -- AC3: .bento-grid has display:grid and grid-template-columns:repeat(12,1fr) --

  It 'defines display: grid on .bento-grid'
    extract_bentogrid_display() {
      awk '/\.bento-grid[ \t]*\{/{found=1} found && /display[ \t]*:[ \t]*grid/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_bentogrid_display
    The output should equal "ok"
  End

  It 'defines grid-template-columns: repeat(12, 1fr) on .bento-grid'
    extract_bentogrid_columns() {
      awk '/\.bento-grid[ \t]*\{/{found=1} found && /grid-template-columns[ \t]*:.*repeat\(12/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_bentogrid_columns
    The output should equal "ok"
  End

  # -- AC4: .bento-grid has margin-left: 48px --

  It 'defines margin-left: 48px on .bento-grid'
    extract_bentogrid_margin() {
      awk '/\.bento-grid[ \t]*\{/{found=1} found && /margin-left[ \t]*:[ \t]*48px/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_bentogrid_margin
    The output should equal "ok"
  End

  # -- AC5: .bento-card.card-backlog-velocity has grid-column: 1 / -1 (unified card) --

  It 'defines grid-column: 1 / -1 on .bento-card.card-backlog-velocity'
    extract_backlog_velocity_col() {
      awk '/\.bento-card\.card-backlog-velocity|\.card-backlog-velocity/{found=1} found && /grid-column[ \t]*:.*1[ \t]*\/[ \t]*-1/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_backlog_velocity_col
    The output should equal "ok"
  End

  It 'defines grid-template-columns on .card-split inside .card-backlog-velocity'
    extract_card_split_columns() {
      awk '/\.card-backlog-velocity \.card-split|\.card-backlog-velocity.*\.card-split/{found=1} found && /grid-template-columns[ \t]*:.*7fr 5fr/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_card_split_columns
    The output should equal "ok"
  End

  # -- AC6: .bento-card.card-story has grid-column: 1 / -1 --

  It 'defines grid-column: 1 / -1 on .bento-card.card-story'
    extract_story_col() {
      awk '/\.bento-card\.card-story|\.card-story/{found=1} found && /grid-column[ \t]*:.*1[ \t]*\/[ \t]*-1/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_story_col
    The output should equal "ok"
  End

  # -- AC7: .bento-card.card-messages has grid-column: 1 / -1 --

  It 'defines grid-column: 1 / -1 on .bento-card.card-messages'
    extract_messages_full_width() {
      awk '/\.bento-card\.card-messages|\.card-messages/{found=1} found && /grid-column[ \t]*:.*1[ \t]*\/[ \t]*-1/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_messages_full_width
    The output should equal "ok"
  End

  # -- AC8: .sidebar-icon has transition + style change on :hover --

  It 'defines transition on .sidebar-icon'
    extract_sidebar_icon_transition() {
      awk '/\.sidebar-icon[ \t]*\{/{found=1} found && /transition[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_sidebar_icon_transition
    The output should equal "ok"
  End

  It 'changes styles on .sidebar-icon:hover'
    check_sidebar_icon_hover() {
      grep -q '\.sidebar-icon:hover' "$TEMPLATE" && echo "ok"
    }
    When call check_sidebar_icon_hover
    The output should equal "ok"
  End

  # -- AC9: .sidebar-icon.active::before has a pseudo-element --

  It 'defines a pseudo-element on .sidebar-icon.active::before'
    check_sidebar_active_before() {
      grep -q '\.sidebar-icon\.active::before' "$TEMPLATE" && echo "ok"
    }
    When call check_sidebar_active_before
    The output should equal "ok"
  End

  # -- Additional: .bento-card has overflow:hidden --

  It 'defines overflow: hidden on .bento-card'
    extract_bento_card_overflow() {
      awk '/\.bento-card[ \t]*\{/{found=1} found && /overflow[ \t]*:[ \t]*hidden/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_bento_card_overflow
    The output should equal "ok"
  End

  # -- Additional: .hero-metrics has display:flex or display:grid --

  It 'defines display: flex or grid on .hero-metrics'
    extract_hero_metrics_display() {
      awk '/\.hero-metrics[ \t]*\{/{found=1} found && /display[ \t]*:[ \t]*(flex|grid)/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_hero_metrics_display
    The output should equal "ok"
  End
End
