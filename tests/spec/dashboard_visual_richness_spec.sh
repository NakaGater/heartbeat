Describe 'dashboard.html: ビジュアルリッチさと深度表現（タスク5）'
  TEMPLATE="core/templates/dashboard.html"

  # --- グラスモーフィズム効果（ヘッダー） ---
  It 'header に backdrop-filter が適用されている（トークンまたはリテラル）'
    check_header_backdrop() {
      awk '/^header[ \t]*\{/{found=1} found && /[^-]backdrop-filter[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call check_header_backdrop
    The output should equal "ok"
  End

  It 'header に -webkit-backdrop-filter（ベンダープレフィックス）が適用されている'
    check_header_webkit_backdrop() {
      awk '/^header[ \t]*\{/{found=1} found && /-webkit-backdrop-filter[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call check_header_webkit_backdrop
    The output should equal "ok"
  End

  # --- サブテルグラデーション背景 (タスク4でメッシュグラデーションに変更) ---
  It 'body に background-image として gradient-mesh が適用されている'
    The contents of file "$TEMPLATE" should include 'background-image: var(--gradient-mesh)'
  End

  # --- パネルのシャドウトークン適用 ---
  It '.panel のデフォルト box-shadow に --shadow-sm トークンが使用されている'
    # design.md: パネル共通の shadow は var(--shadow-sm)
    The contents of file "$TEMPLATE" should match pattern '*.panel {*box-shadow: var(--shadow-sm)*'
  End

  # --- パネルの border-radius 改善 ---
  It '.panel の border-radius に --radius-lg トークンが使用されている'
    # design.md: パネル共通の border-radius は var(--radius-lg) = 14px
    The contents of file "$TEMPLATE" should match pattern '*.panel {*border-radius: var(--radius-lg)*'
  End

  # --- ヘッダーのグラスモーフィズム背景（半透明） ---
  It 'header の background が半透明 rgba に変更されている'
    The contents of file "$TEMPLATE" should include 'background: rgba('
  End
End
