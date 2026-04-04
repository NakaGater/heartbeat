Describe 'dashboard.html: デザイントークン体系（タスク1 - AC1）'
  TEMPLATE="core/templates/dashboard.html"

  It ':root ブロックにスペーシングトークン --space-1 が定義されている'
    The contents of file "$TEMPLATE" should include '--space-1:'
  End

  It ':root ブロックにスペーシングトークン --space-2 が定義されている'
    The contents of file "$TEMPLATE" should include '--space-2:'
  End

  It ':root ブロックにスペーシングトークン --space-3 が定義されている'
    The contents of file "$TEMPLATE" should include '--space-3:'
  End

  It ':root ブロックにスペーシングトークン --space-4 が定義されている'
    The contents of file "$TEMPLATE" should include '--space-4:'
  End

  It ':root ブロックにスペーシングトークン --space-5 が定義されている'
    The contents of file "$TEMPLATE" should include '--space-5:'
  End

  It ':root ブロックにスペーシングトークン --space-6 が定義されている'
    The contents of file "$TEMPLATE" should include '--space-6:'
  End

  It ':root ブロックにスペーシングトークン --space-7 が定義されている'
    The contents of file "$TEMPLATE" should include '--space-7:'
  End

  It ':root ブロックにスペーシングトークン --space-8 が定義されている'
    The contents of file "$TEMPLATE" should include '--space-8:'
  End

  It ':root ブロックにシャドウトークン --shadow-xs が定義されている'
    The contents of file "$TEMPLATE" should include '--shadow-xs:'
  End

  It ':root ブロックにシャドウトークン --shadow-sm が定義されている'
    The contents of file "$TEMPLATE" should include '--shadow-sm:'
  End

  It ':root ブロックにシャドウトークン --shadow-md が定義されている'
    The contents of file "$TEMPLATE" should include '--shadow-md:'
  End

  It ':root ブロックにシャドウトークン --shadow-lg が定義されている'
    The contents of file "$TEMPLATE" should include '--shadow-lg:'
  End

  It ':root ブロックにシャドウトークン --shadow-2xl が定義されている'
    The contents of file "$TEMPLATE" should include '--shadow-2xl:'
  End

  It ':root ブロックにボーダー半径トークン --radius-sm が定義されている'
    The contents of file "$TEMPLATE" should include '--radius-sm:'
  End

  It ':root ブロックにボーダー半径トークン --radius-md が定義されている'
    The contents of file "$TEMPLATE" should include '--radius-md:'
  End

  It ':root ブロックにボーダー半径トークン --radius-lg が定義されている'
    The contents of file "$TEMPLATE" should include '--radius-lg:'
  End

  It ':root ブロックにボーダー半径トークン --radius-xl が定義されている'
    The contents of file "$TEMPLATE" should include '--radius-xl:'
  End

  It ':root ブロックにボーダー半径トークン --radius-full が定義されている'
    The contents of file "$TEMPLATE" should include '--radius-full:'
  End

  It 'ダークモード内でシャドウトークンが再定義されている'
    # prefers-color-scheme: dark 内に --shadow-sm が存在することを確認
    # ダークモード用に独立した値が必要（design.md仕様）
    dark_section() {
      sed -n '/prefers-color-scheme: dark/,/^[[:space:]]*}/p' "$TEMPLATE"
    }
    When call dark_section
    The output should include '--shadow-sm:'
  End

  It 'ダークモード内でスペーシングトークンが利用可能（:root定義で両モード共通）'
    # スペーシングトークンは :root で定義されダーク/ライト共通で利用可能
    # :root 内に --space-1 が存在すること
    root_section() {
      sed -n '/:root/,/^}/p' "$TEMPLATE"
    }
    When call root_section
    The output should include '--space-1:'
  End
End
