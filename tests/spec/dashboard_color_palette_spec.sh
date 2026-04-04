Describe 'dashboard.html: プレミアムカラーパレット（タスク2 - AC2）'
  TEMPLATE="core/templates/dashboard.html"

  # --- アクセントカラースケール（インディゴ系） ---
  It 'アクセントカラー --accent-hover が定義されている'
    The contents of file "$TEMPLATE" should include '--accent-hover:'
  End

  It 'アクセントカラー --accent-subtle が定義されている'
    The contents of file "$TEMPLATE" should include '--accent-subtle:'
  End

  It 'アクセントカラー --accent-muted が定義されている'
    The contents of file "$TEMPLATE" should include '--accent-muted:'
  End

  # --- セカンダリアクセント ---
  It 'セカンダリカラー --secondary が定義されている'
    The contents of file "$TEMPLATE" should include '--secondary:'
  End

  It 'セカンダリカラー --secondary-subtle が定義されている'
    The contents of file "$TEMPLATE" should include '--secondary-subtle:'
  End

  # --- セマンティックカラー ---
  It 'セマンティックカラー --success が定義されている'
    The contents of file "$TEMPLATE" should include '--success:'
  End

  It 'セマンティックカラー --warning が定義されている'
    The contents of file "$TEMPLATE" should include '--warning:'
  End

  It 'セマンティックカラー --error が定義されている'
    The contents of file "$TEMPLATE" should include '--error:'
  End

  It 'セマンティックカラー --info が定義されている'
    The contents of file "$TEMPLATE" should include '--info:'
  End

  It 'セマンティックカラー --success-subtle が定義されている'
    The contents of file "$TEMPLATE" should include '--success-subtle:'
  End

  It 'セマンティックカラー --warning-subtle が定義されている'
    The contents of file "$TEMPLATE" should include '--warning-subtle:'
  End

  It 'セマンティックカラー --error-subtle が定義されている'
    The contents of file "$TEMPLATE" should include '--error-subtle:'
  End

  It 'セマンティックカラー --info-subtle が定義されている'
    The contents of file "$TEMPLATE" should include '--info-subtle:'
  End

  # --- グラデーション定義 ---
  It 'グラデーション変数 --gradient-primary が定義されている'
    The contents of file "$TEMPLATE" should include '--gradient-primary:'
  End

  It 'グラデーション変数 --gradient-header が定義されている'
    The contents of file "$TEMPLATE" should include '--gradient-header:'
  End

  It 'グラデーション変数 --gradient-surface が定義されている'
    The contents of file "$TEMPLATE" should include '--gradient-surface:'
  End

  # --- ダークモード独立カラー定義 (v2: ダークファースト = :root が既定ダーク) ---
  It 'ダークモード(:root)にアクセントカラーが独立定義されている'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }
    When call root_block
    The output should include '--accent:'
  End

  It 'ダークモード(:root)にセマンティックカラー --success が独立定義されている'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }
    When call root_block
    The output should include '--success:'
  End

  It 'ダークモード(:root)にグラデーション --gradient-primary が独立定義されている'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }
    When call root_block
    The output should include '--gradient-primary:'
  End
End
