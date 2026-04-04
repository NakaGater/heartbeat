Describe 'dashboard.html: マイクロインタラクションとアニメーション（タスク4）'
  TEMPLATE="core/templates/dashboard.html"

  # --- @keyframes 定義 ---
  It '@keyframes fadeSlideIn が定義されている'
    The contents of file "$TEMPLATE" should include '@keyframes fadeSlideIn'
  End

  # --- パネル入場アニメーション ---
  It '.panel に animation: fadeSlideIn が適用されている'
    The contents of file "$TEMPLATE" should include 'animation: fadeSlideIn'
  End

  # --- stagger animation-delay ---
  It 'パネル stagger 用の animation-delay が定義されている'
    The contents of file "$TEMPLATE" should include 'animation-delay:'
  End

  # --- ホバー状態トランジション ---
  It '.panel に transition プロパティ（box-shadow, transform）が定義されている'
    The contents of file "$TEMPLATE" should include 'transition: box-shadow'
  End

  It '.panel:hover で transform: translateY(-2px) が定義されている'
    The contents of file "$TEMPLATE" should include 'translateY(-2px)'
  End

  # --- prefers-reduced-motion サポート ---
  It 'prefers-reduced-motion: reduce メディアクエリが定義されている'
    The contents of file "$TEMPLATE" should include 'prefers-reduced-motion: reduce'
  End

  It 'reduced-motion で animation-duration が無効化されている'
    The contents of file "$TEMPLATE" should include 'animation-duration: 0.01ms !important'
  End

  It 'reduced-motion で transition-duration が無効化されている'
    The contents of file "$TEMPLATE" should include 'transition-duration: 0.01ms !important'
  End
End
