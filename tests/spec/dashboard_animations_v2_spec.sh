Describe 'dashboard.html: v2 Micro-interactions + Animations (Task 6)'
  TEMPLATE="core/templates/dashboard.html"

  # --- 新規 @keyframes 定義 ---

  It 'defines @keyframes fadeScaleIn'
    The contents of file "$TEMPLATE" should include '@keyframes fadeScaleIn'
  End

  It 'defines @keyframes glowPulse'
    The contents of file "$TEMPLATE" should include '@keyframes glowPulse'
  End

  It 'defines @keyframes slideInFromLeft'
    The contents of file "$TEMPLATE" should include '@keyframes slideInFromLeft'
  End

  # --- カード入場アニメーション (v2: fadeScaleIn + spring curve) ---

  It 'applies animation: fadeScaleIn to .bento-card'
    The contents of file "$TEMPLATE" should include 'animation: fadeScaleIn 0.6s cubic-bezier(0.16, 1, 0.3, 1) both'
  End

  # --- stagger 60ms 間隔 (v2 仕様) ---

  It 'sets animation-delay: 60ms on .bento-card:nth-child(1)'
    The contents of file "$TEMPLATE" should include '.bento-card:nth-child(1)'
  End

  It 'sets stagger at 60ms intervals (120ms)'
    The contents of file "$TEMPLATE" should include 'animation-delay: 120ms'
  End

  It 'sets stagger at 60ms intervals (360ms)'
    The contents of file "$TEMPLATE" should include 'animation-delay: 360ms'
  End

  # --- サイドバー slideInFromLeft ---

  It 'applies animation: slideInFromLeft to .sidebar'
    The contents of file "$TEMPLATE" should include 'animation: slideInFromLeft'
  End

  # --- ステータスドット glowPulse ---

  It 'applies animation: glowPulse to .status-dot.active'
    The contents of file "$TEMPLATE" should include 'animation: glowPulse 2s ease-in-out infinite'
  End

  # --- prefers-reduced-motion (v2 でも維持されていること) ---

  It 'defines prefers-reduced-motion: reduce'
    The contents of file "$TEMPLATE" should include 'prefers-reduced-motion: reduce'
  End

  It 'defines animation-duration: 0.01ms !important in reduced-motion'
    The contents of file "$TEMPLATE" should include 'animation-duration: 0.01ms !important'
  End
End
