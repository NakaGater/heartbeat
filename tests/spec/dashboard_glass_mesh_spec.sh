Describe 'dashboard.html: グラスモーフィズム全面適用 + メッシュグラデーション背景（タスク4）'
  TEMPLATE="core/templates/dashboard.html"

  # ── 完了条件1: body に background-image: var(--gradient-mesh) ──

  It 'body に background-image として var(--gradient-mesh) が適用されている'
    extract_body_bg_image() {
      awk '/^body[ \t]*\{/{found=1} found && /background-image[ \t]*:.*var\(--gradient-mesh\)/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_body_bg_image
    The output should equal "ok"
  End

  # ── 完了条件2: body に background-attachment: fixed ──

  It 'body に background-attachment: fixed が定義されている'
    extract_body_bg_attachment() {
      awk '/^body[ \t]*\{/{found=1} found && /background-attachment[ \t]*:[ \t]*fixed/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_body_bg_attachment
    The output should equal "ok"
  End

  # ── 完了条件3: .bento-card に backdrop-filter: blur(16px) saturate(180%) ──

  It '.bento-card に backdrop-filter: blur(16px) saturate(180%) が定義されている'
    extract_bento_backdrop() {
      awk '/\.bento-card[ \t]*\{/{found=1} found && /[^-]backdrop-filter[ \t]*:.*blur\(16px\).*saturate\(180%\)/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_bento_backdrop
    The output should equal "ok"
  End

  # ── 完了条件4: .bento-card に -webkit-backdrop-filter ──

  It '.bento-card に -webkit-backdrop-filter が定義されている'
    extract_bento_webkit_backdrop() {
      awk '/\.bento-card[ \t]*\{/{found=1} found && /-webkit-backdrop-filter[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_bento_webkit_backdrop
    The output should equal "ok"
  End

  # ── 完了条件5: .bento-card:hover で border-color と box-shadow が変化 ──

  It '.bento-card:hover で border-color が変化する'
    extract_bento_hover_border() {
      awk '/\.bento-card:hover[ \t]*\{/{found=1} found && /border-color[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_bento_hover_border
    The output should equal "ok"
  End

  It '.bento-card:hover で box-shadow が変化する'
    extract_bento_hover_shadow() {
      awk '/\.bento-card:hover[ \t]*\{/{found=1} found && /box-shadow[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_bento_hover_shadow
    The output should equal "ok"
  End

  # ── 完了条件6: .bento-card:hover で transform: translateY(-2px) ──

  It '.bento-card:hover で transform: translateY(-2px) が定義されている'
    extract_bento_hover_translate() {
      awk '/\.bento-card:hover[ \t]*\{/{found=1} found && /transform[ \t]*:.*translateY\(-2px\)/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_bento_hover_translate
    The output should equal "ok"
  End

  # ── 完了条件7: .bento-card::before にホバーで opacity 変化するアクセントライン ──

  It '.bento-card::before 擬似要素が定義されている'
    check_bento_before() {
      grep -q '\.bento-card::before' "$TEMPLATE" && echo "ok"
    }
    When call check_bento_before
    The output should equal "ok"
  End

  It '.bento-card:hover::before で opacity が変化する'
    check_bento_hover_before_opacity() {
      grep -q '\.bento-card:hover::before' "$TEMPLATE" && echo "ok"
    }
    When call check_bento_hover_before_opacity
    The output should equal "ok"
  End

  # ── 追加検証: .panel に backdrop-filter（グラスモーフィズム全面適用） ──

  It '.panel に backdrop-filter: blur が定義されている'
    extract_panel_backdrop() {
      awk '/^\.panel[ \t]*\{/{found=1} found && /[^-]backdrop-filter[ \t]*:.*blur/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_panel_backdrop
    The output should equal "ok"
  End

  It '.panel に -webkit-backdrop-filter が定義されている'
    extract_panel_webkit_backdrop() {
      awk '/^\.panel[ \t]*\{/{found=1} found && /-webkit-backdrop-filter[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_panel_webkit_backdrop
    The output should equal "ok"
  End

  # ── 追加検証: .panel に半透明背景（rgba） ──

  It '.panel の background に rgba が使用されている'
    extract_panel_rgba_bg() {
      awk '/^\.panel[ \t]*\{/{found=1} found && /background[ \t]*:.*rgba\(/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call extract_panel_rgba_bg
    The output should equal "ok"
  End
End
