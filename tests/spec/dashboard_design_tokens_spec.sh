Describe 'dashboard.html: ダークファースト デザイントークン体系 v2（タスク1）'
  TEMPLATE="core/templates/dashboard.html"

  # --- AC1: :root に背景トークンが定義されている ---
  Describe 'AC1: :root ダーク既定の背景トークン'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It ':root に --bg が定義されている（ダーク既定 #080c19）'
      When call root_block
      The output should include '--bg: #080c19'
    End

    It ':root に --bg-panel が定義されている'
      When call root_block
      The output should include '--bg-panel:'
    End

    It ':root に --bg-card が定義されている'
      When call root_block
      The output should include '--bg-card:'
    End

    It ':root に --bg-elevated が定義されている'
      When call root_block
      The output should include '--bg-elevated:'
    End
  End

  # --- AC2: :root にアクセントカラースケールが定義されている ---
  Describe 'AC2: :root アクセントカラースケール'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It ':root に --accent が定義されている'
      When call root_block
      The output should include '--accent:'
    End

    It ':root に --accent-hover が定義されている'
      When call root_block
      The output should include '--accent-hover:'
    End

    It ':root に --accent-subtle が定義されている'
      When call root_block
      The output should include '--accent-subtle:'
    End

    It ':root に --accent-muted が定義されている'
      When call root_block
      The output should include '--accent-muted:'
    End

    It ':root に --accent-glow が定義されている'
      When call root_block
      The output should include '--accent-glow:'
    End
  End

  # --- AC3: :root にセマンティックカラーと -subtle バリアントが定義されている ---
  Describe 'AC3: :root セマンティックカラー + subtle バリアント'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It ':root に --secondary と --secondary-subtle が定義されている'
      When call root_block
      The output should include '--secondary:'
      The output should include '--secondary-subtle:'
    End

    It ':root に --tertiary と --tertiary-subtle が定義されている'
      When call root_block
      The output should include '--tertiary:'
      The output should include '--tertiary-subtle:'
    End

    It ':root に --success と --success-subtle が定義されている'
      When call root_block
      The output should include '--success:'
      The output should include '--success-subtle:'
    End

    It ':root に --warning と --warning-subtle が定義されている'
      When call root_block
      The output should include '--warning:'
      The output should include '--warning-subtle:'
    End

    It ':root に --error と --error-subtle が定義されている'
      When call root_block
      The output should include '--error:'
      The output should include '--error-subtle:'
    End

    It ':root に --info と --info-subtle が定義されている'
      When call root_block
      The output should include '--info:'
      The output should include '--info-subtle:'
    End
  End

  # --- AC4: :root にグラデーショントークンが定義されている ---
  Describe 'AC4: :root グラデーショントークン'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It ':root に --gradient-primary が定義されている'
      When call root_block
      The output should include '--gradient-primary:'
    End

    It ':root に --gradient-hero が定義されている'
      When call root_block
      The output should include '--gradient-hero:'
    End

    It ':root に --gradient-surface が定義されている'
      When call root_block
      The output should include '--gradient-surface:'
    End

    It ':root に --gradient-mesh（メッシュグラデーション）が定義されている'
      When call root_block
      The output should include '--gradient-mesh:'
    End

    It ':root に --gradient-header が定義されている'
      When call root_block
      The output should include '--gradient-header:'
    End
  End

  # --- AC5: :root に 4px 基準スペーシング --space-1〜8 が定義されている ---
  Describe 'AC5: :root スペーシングトークン（4px 基準）'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It ':root に --space-1: 4px が定義されている'
      When call root_block
      The output should include '--space-1: 4px'
    End

    It ':root に --space-2: 8px が定義されている'
      When call root_block
      The output should include '--space-2: 8px'
    End

    It ':root に --space-3: 12px が定義されている'
      When call root_block
      The output should include '--space-3: 12px'
    End

    It ':root に --space-4: 16px が定義されている'
      When call root_block
      The output should include '--space-4: 16px'
    End

    It ':root に --space-5: 24px が定義されている'
      When call root_block
      The output should include '--space-5: 24px'
    End

    It ':root に --space-6: 32px が定義されている'
      When call root_block
      The output should include '--space-6: 32px'
    End

    It ':root に --space-7: 48px が定義されている'
      When call root_block
      The output should include '--space-7: 48px'
    End

    It ':root に --space-8: 64px が定義されている'
      When call root_block
      The output should include '--space-8: 64px'
    End
  End

  # --- AC6: :root にシャドウトークンが定義されている ---
  Describe 'AC6: :root シャドウトークン'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It ':root に --shadow-xs が定義されている'
      When call root_block
      The output should include '--shadow-xs:'
    End

    It ':root に --shadow-sm が定義されている'
      When call root_block
      The output should include '--shadow-sm:'
    End

    It ':root に --shadow-md が定義されている'
      When call root_block
      The output should include '--shadow-md:'
    End

    It ':root に --shadow-lg が定義されている'
      When call root_block
      The output should include '--shadow-lg:'
    End

    It ':root に --shadow-2xl が定義されている'
      When call root_block
      The output should include '--shadow-2xl:'
    End

    It ':root に --shadow-glow が定義されている'
      When call root_block
      The output should include '--shadow-glow:'
    End
  End

  # --- AC7: :root にボーダー半径トークンが定義されている ---
  Describe 'AC7: :root ボーダー半径トークン'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It ':root に --radius-sm が定義されている'
      When call root_block
      The output should include '--radius-sm:'
    End

    It ':root に --radius-md が定義されている'
      When call root_block
      The output should include '--radius-md:'
    End

    It ':root に --radius-lg が定義されている'
      When call root_block
      The output should include '--radius-lg:'
    End

    It ':root に --radius-xl が定義されている'
      When call root_block
      The output should include '--radius-xl:'
    End

    It ':root に --radius-full が定義されている'
      When call root_block
      The output should include '--radius-full:'
    End
  End

  # --- AC8: :root にタイプスケール --text-2xs〜--text-4xl が定義されている ---
  Describe 'AC8: :root タイプスケール'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It ':root に --text-2xs が定義されている'
      When call root_block
      The output should include '--text-2xs:'
    End

    It ':root に --text-xs が定義されている'
      When call root_block
      The output should include '--text-xs:'
    End

    It ':root に --text-sm が定義されている'
      When call root_block
      The output should include '--text-sm:'
    End

    It ':root に --text-md が定義されている'
      When call root_block
      The output should include '--text-md:'
    End

    It ':root に --text-base が定義されている'
      When call root_block
      The output should include '--text-base:'
    End

    It ':root に --text-lg が定義されている'
      When call root_block
      The output should include '--text-lg:'
    End

    It ':root に --text-xl が定義されている'
      When call root_block
      The output should include '--text-xl:'
    End

    It ':root に --text-2xl が定義されている'
      When call root_block
      The output should include '--text-2xl:'
    End

    It ':root に --text-3xl が定義されている'
      When call root_block
      The output should include '--text-3xl:'
    End

    It ':root に --text-4xl が定義されている'
      When call root_block
      The output should include '--text-4xl:'
    End
  End

  # --- AC9: prefers-color-scheme: light でライトモード変数がオーバーライドされている ---
  Describe 'AC9: ライトモード（prefers-color-scheme: light）オーバーライド'
    light_block() {
      sed -n '/prefers-color-scheme:[[:space:]]*light/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It 'prefers-color-scheme: light メディアクエリが存在する'
      The contents of file "$TEMPLATE" should include 'prefers-color-scheme: light'
    End

    It 'ライトモードで --bg がオーバーライドされている'
      When call light_block
      The output should include '--bg:'
    End

    It 'ライトモードで --text がオーバーライドされている'
      When call light_block
      The output should include '--text:'
    End

    It 'ライトモードで --accent がオーバーライドされている'
      When call light_block
      The output should include '--accent:'
    End

    It 'ライトモードで --shadow-sm がオーバーライドされている'
      When call light_block
      The output should include '--shadow-sm:'
    End

    It 'ライトモードで --gradient-primary がオーバーライドされている'
      When call light_block
      The output should include '--gradient-primary:'
    End

    It 'ライトモードで --gradient-mesh がオーバーライドされている'
      When call light_block
      The output should include '--gradient-mesh:'
    End
  End

  # --- AC10: ライトモードのカラー値がダークの単純反転ではなく独立最適化されている ---
  Describe 'AC10: ライトモードのカラー値が独立最適化されている'
    light_block() {
      sed -n '/prefers-color-scheme:[[:space:]]*light/,/^[[:space:]]*}/p' "$TEMPLATE"
    }

    It 'ライトモードの --bg は明るい値（#080c19 ではない）'
      When call light_block
      The output should not include '--bg: #080c19'
    End

    It 'ライトモードの --accent はダークの #7c6aef とは異なる値'
      When call light_block
      The output should include '--accent:'
      The output should not include '--accent: #7c6aef'
    End

    It 'ライトモードの --shadow-sm はダークより軽い不透明度を使用している'
      When call light_block
      The output should include '--shadow-sm:'
      # ダークモードは rgba(0,0,0,0.3) だがライトモードはそれより小さい値であるべき
      The output should not include 'rgba(0, 0, 0, 0.3)'
    End
  End
End
