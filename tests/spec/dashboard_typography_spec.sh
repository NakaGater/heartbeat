Describe 'dashboard.html: タイポグラフィの洗練（タスク3 - AC5）'
  TEMPLATE="core/templates/dashboard.html"

  # --- システムフォントスタック ---
  It 'body に SF Pro を含むシステムフォントスタックが定義されている'
    The contents of file "$TEMPLATE" should include "SF Pro"
  End

  It 'アンチエイリアスレンダリング -webkit-font-smoothing: antialiased が定義されている'
    The contents of file "$TEMPLATE" should include '-webkit-font-smoothing: antialiased'
  End

  # --- タイプスケールトークン ---
  It 'タイプスケールトークン --text-xs が :root に定義されている'
    The contents of file "$TEMPLATE" should include '--text-xs:'
  End

  It 'タイプスケールトークン --text-sm が :root に定義されている'
    The contents of file "$TEMPLATE" should include '--text-sm:'
  End

  It 'タイプスケールトークン --text-base が :root に定義されている'
    The contents of file "$TEMPLATE" should include '--text-base:'
  End

  It 'タイプスケールトークン --text-lg が :root に定義されている'
    The contents of file "$TEMPLATE" should include '--text-lg:'
  End

  It 'タイプスケールトークン --text-xl が :root に定義されている'
    The contents of file "$TEMPLATE" should include '--text-xl:'
  End

  It 'タイプスケールトークン --text-2xl が :root に定義されている'
    The contents of file "$TEMPLATE" should include '--text-2xl:'
  End

  # --- Fluid Typography（h1 に clamp() 使用） ---
  It 'h1 に clamp() を使用した fluid font-size が定義されている'
    The contents of file "$TEMPLATE" should include 'clamp('
  End

  # --- フォントウェイト階層（4段階の使い分け） ---
  It 'フォントウェイト 700（Bold）が使用されている'
    The contents of file "$TEMPLATE" should include 'font-weight: 700'
  End

  It 'フォントウェイト 600（Semibold）が使用されている'
    The contents of file "$TEMPLATE" should include 'font-weight: 600'
  End

  It 'フォントウェイト 500（Medium）が使用されている'
    The contents of file "$TEMPLATE" should include 'font-weight: 500'
  End

  # --- Letter-spacing の差別化 ---
  It '見出し用のタイトな letter-spacing（負値）が定義されている'
    The contents of file "$TEMPLATE" should include 'letter-spacing: -0.025em'
  End

  It 'ラベル用のワイドな letter-spacing（正値 0.05em）が定義されている'
    The contents of file "$TEMPLATE" should include 'letter-spacing: 0.05em'
  End

  It '本文用の letter-spacing（0.01em）が定義されている'
    The contents of file "$TEMPLATE" should include 'letter-spacing: 0.01em'
  End
End
