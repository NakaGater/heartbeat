Describe 'dashboard.html: Micro-interactions and Animations (Task 4)'
  TEMPLATE="core/templates/dashboard.html"

  # --- @keyframes 定義 (v2: fadeScaleIn に更新) ---
  It 'defines @keyframes fadeScaleIn'
    The contents of file "$TEMPLATE" should include '@keyframes fadeScaleIn'
  End

  # --- パネル入場アニメーション (v2: fadeScaleIn に更新) ---
  It 'applies animation: fadeScaleIn to .panel'
    The contents of file "$TEMPLATE" should include 'animation: fadeScaleIn'
  End

  # --- stagger animation-delay ---
  It 'defines animation-delay for panel stagger'
    The contents of file "$TEMPLATE" should include 'animation-delay:'
  End

  # --- ホバー状態トランジション ---
  It 'defines transition properties (box-shadow, transform) on .panel'
    The contents of file "$TEMPLATE" should include 'transition: box-shadow'
  End

  It 'defines transform: translateY(-2px) on .panel:hover'
    The contents of file "$TEMPLATE" should include 'translateY(-2px)'
  End

  # --- prefers-reduced-motion サポート ---
  It 'defines prefers-reduced-motion: reduce media query'
    The contents of file "$TEMPLATE" should include 'prefers-reduced-motion: reduce'
  End

  It 'disables animation-duration in reduced-motion'
    The contents of file "$TEMPLATE" should include 'animation-duration: 0.01ms !important'
  End

  It 'disables transition-duration in reduced-motion'
    The contents of file "$TEMPLATE" should include 'transition-duration: 0.01ms !important'
  End
End
