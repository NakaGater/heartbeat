Describe 'dashboard.html: Glassmorphism + Mesh Gradient Background (Task 4)'
  TEMPLATE="core/templates/dashboard.html"

  # -- AC1: body has background-image: var(--gradient-mesh) --

  It 'applies var(--gradient-mesh) as background-image on body'
    extract_body_bg_image() {
      awk '/^body[ \t]*\{/{found=1} found && /background-image[ \t]*:.*var\(--gradient-mesh\)/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_body_bg_image
    The output should equal "ok"
  End

  # -- AC2: body has background-attachment: fixed --

  It 'defines background-attachment: fixed on body'
    extract_body_bg_attachment() {
      awk '/^body[ \t]*\{/{found=1} found && /background-attachment[ \t]*:[ \t]*fixed/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_body_bg_attachment
    The output should equal "ok"
  End

  # -- AC3: .bento-card has backdrop-filter: blur(16px) saturate(180%) --

  It 'defines backdrop-filter on .bento-card (token or literal)'
    extract_bento_backdrop() {
      awk '/\.bento-card[ \t]*\{/{found=1} found && /[^-]backdrop-filter[ \t]*:.*((blur\(16px\).*saturate\(180%\))|(var\(--glass-blur\)))/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_bento_backdrop
    The output should equal "ok"
  End

  # -- AC4: .bento-card has -webkit-backdrop-filter --

  It 'defines -webkit-backdrop-filter on .bento-card'
    extract_bento_webkit_backdrop() {
      awk '/\.bento-card[ \t]*\{/{found=1} found && /-webkit-backdrop-filter[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_bento_webkit_backdrop
    The output should equal "ok"
  End

  # -- AC5: .bento-card:hover changes border-color and box-shadow --

  It 'changes border-color on .bento-card:hover'
    extract_bento_hover_border() {
      awk '/\.bento-card:hover[ \t]*\{/{found=1} found && /border-color[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_bento_hover_border
    The output should equal "ok"
  End

  It 'changes box-shadow on .bento-card:hover'
    extract_bento_hover_shadow() {
      awk '/\.bento-card:hover[ \t]*\{/{found=1} found && /box-shadow[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_bento_hover_shadow
    The output should equal "ok"
  End

  # -- AC6: .bento-card:hover has transform: translateY(-2px) --

  It 'defines transform: translateY(-2px) on .bento-card:hover'
    extract_bento_hover_translate() {
      awk '/\.bento-card:hover[ \t]*\{/{found=1} found && /transform[ \t]*:.*translateY\(-2px\)/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_bento_hover_translate
    The output should equal "ok"
  End

  # -- AC7: .bento-card::before has accent line with opacity change on hover --

  It 'defines .bento-card::before pseudo-element'
    check_bento_before() {
      grep -q '\.bento-card::before' "$TEMPLATE" && echo "ok"
    }
    When call check_bento_before
    The output should equal "ok"
  End

  It 'changes opacity on .bento-card:hover::before'
    check_bento_hover_before_opacity() {
      grep -q '\.bento-card:hover::before' "$TEMPLATE" && echo "ok"
    }
    When call check_bento_hover_before_opacity
    The output should equal "ok"
  End

  # -- Additional: .panel has backdrop-filter (glassmorphism applied globally) --

  It 'defines backdrop-filter: blur on .panel'
    extract_panel_backdrop() {
      awk '/^\.panel[ \t]*\{/{found=1} found && /[^-]backdrop-filter[ \t]*:.*blur/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_panel_backdrop
    The output should equal "ok"
  End

  It 'defines -webkit-backdrop-filter on .panel'
    extract_panel_webkit_backdrop() {
      awk '/^\.panel[ \t]*\{/{found=1} found && /-webkit-backdrop-filter[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_panel_webkit_backdrop
    The output should equal "ok"
  End

  # -- Additional: .panel has semi-transparent background (rgba) --

  It 'uses semi-transparent value for .panel background (token or literal)'
    extract_panel_rgba_bg() {
      awk '/^\.panel[ \t]*\{/{found=1} found && /background[ \t]*:.*((rgba\()|(var\(--glass-bg\)))/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_panel_rgba_bg
    The output should equal "ok"
  End
End
