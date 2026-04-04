Describe 'dashboard.html: v2 マイクロインタラクション + アニメーション (タスク6)'
  TEMPLATE="core/templates/dashboard.html"

  # --- 新規 @keyframes 定義 ---

  It '@keyframes fadeScaleIn が定義されている'
    The contents of file "$TEMPLATE" should include '@keyframes fadeScaleIn'
  End

  It '@keyframes glowPulse が定義されている'
    The contents of file "$TEMPLATE" should include '@keyframes glowPulse'
  End

  It '@keyframes slideInFromLeft が定義されている'
    The contents of file "$TEMPLATE" should include '@keyframes slideInFromLeft'
  End

  # --- カード入場アニメーション (v2: fadeScaleIn + spring curve) ---

  It '.bento-card に animation: fadeScaleIn が適用されている'
    The contents of file "$TEMPLATE" should include 'animation: fadeScaleIn 0.6s cubic-bezier(0.16, 1, 0.3, 1) both'
  End

  # --- stagger 60ms 間隔 (v2 仕様) ---

  It '.bento-card:nth-child(1) に animation-delay: 60ms が設定されている'
    The contents of file "$TEMPLATE" should include '.bento-card:nth-child(1)'
  End

  It 'stagger が 60ms 間隔で設定されている (120ms)'
    The contents of file "$TEMPLATE" should include 'animation-delay: 120ms'
  End

  It 'stagger が 60ms 間隔で設定されている (360ms)'
    The contents of file "$TEMPLATE" should include 'animation-delay: 360ms'
  End

  # --- サイドバー slideInFromLeft ---

  It '.sidebar に animation: slideInFromLeft が適用されている'
    The contents of file "$TEMPLATE" should include 'animation: slideInFromLeft'
  End

  # --- ステータスドット glowPulse ---

  It '.status-dot.active に animation: glowPulse が適用されている'
    The contents of file "$TEMPLATE" should include 'animation: glowPulse 2s ease-in-out infinite'
  End

  # --- prefers-reduced-motion (v2 でも維持されていること) ---

  It 'prefers-reduced-motion: reduce が定義されている'
    The contents of file "$TEMPLATE" should include 'prefers-reduced-motion: reduce'
  End

  It 'reduced-motion で animation-duration: 0.01ms !important が定義されている'
    The contents of file "$TEMPLATE" should include 'animation-duration: 0.01ms !important'
  End
End
