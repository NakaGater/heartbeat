Describe 'dashboard.html: Hero Metrics Section CSS (Task 5)'
  TEMPLATE="core/templates/dashboard.html"

  # ── 完了条件1: .hero-metrics に display: grid ──

  It 'defines display: grid on .hero-metrics'
    extract_hero_display() {
      awk '/\.hero-metrics[ \t]*\{/{found=1} found && /display[ \t]*:[ \t]*grid/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_hero_display
    The output should equal "ok"
  End

  # ── 完了条件2: .metric-card に border-radius と padding ──

  It 'defines border-radius on .metric-card'
    extract_metric_card_radius() {
      awk '/\.metric-card[ \t]*\{/{found=1} found && /border-radius[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_metric_card_radius
    The output should equal "ok"
  End

  It 'defines padding on .metric-card'
    extract_metric_card_padding() {
      awk '/\.metric-card[ \t]*\{/{found=1} found && /padding[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_metric_card_padding
    The output should equal "ok"
  End

  # ── 完了条件3: .metric-card:hover で transform: translateY(-2px) ──

  It 'defines transform: translateY(-2px) on .metric-card:hover'
    extract_metric_card_hover() {
      awk '/\.metric-card:hover[ \t]*\{/{found=1} found && /transform[ \t]*:.*translateY\(-2px\)/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_metric_card_hover
    The output should equal "ok"
  End

  # ── 完了条件4: .metric-value に font-size: 3rem と font-weight: 800 ──

  It 'defines font-size on .metric-value'
    extract_metric_value_font_size() {
      awk '/\.metric-value[ \t]*\{/{found=1} found && /font-size[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_metric_value_font_size
    The output should equal "ok"
  End

  It 'defines font-weight: 800 on .metric-value'
    extract_metric_value_font_weight() {
      awk '/\.metric-value[ \t]*\{/{found=1} found && /font-weight[ \t]*:[ \t]*800/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_metric_value_font_weight
    The output should equal "ok"
  End

  # ── 完了条件5: .metric-value にグラデーションテキスト ──

  It 'defines -webkit-background-clip: text on .metric-value'
    extract_metric_value_bg_clip() {
      awk '/\.metric-value[ \t]*\{/{found=1} found && /-webkit-background-clip[ \t]*:[ \t]*text/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_metric_value_bg_clip
    The output should equal "ok"
  End

  It 'defines -webkit-text-fill-color: transparent on .metric-value'
    extract_metric_value_fill_color() {
      awk '/\.metric-value[ \t]*\{/{found=1} found && /-webkit-text-fill-color[ \t]*:[ \t]*transparent/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_metric_value_fill_color
    The output should equal "ok"
  End

  # ── 完了条件6: .metric-label に text-transform: uppercase と letter-spacing ──

  It 'defines text-transform: uppercase on .metric-label'
    extract_metric_label_transform() {
      awk '/\.metric-label[ \t]*\{/{found=1} found && /text-transform[ \t]*:[ \t]*uppercase/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_metric_label_transform
    The output should equal "ok"
  End

  It 'defines letter-spacing: 0.1em on .metric-label'
    extract_metric_label_spacing() {
      awk '/\.metric-label[ \t]*\{/{found=1} found && /letter-spacing[ \t]*:[ \t]*0\.1em/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_metric_label_spacing
    The output should equal "ok"
  End

  # ── 完了条件7: .metric-ring circle.progress に stroke-linecap: round ──

  It 'defines stroke-linecap: round on .metric-ring circle.progress'
    extract_metric_ring_stroke() {
      awk '/\.metric-ring[ \t]+circle\.progress[ \t]*\{/{found=1} found && /stroke-linecap[ \t]*:[ \t]*round/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_metric_ring_stroke
    The output should equal "ok"
  End
End
