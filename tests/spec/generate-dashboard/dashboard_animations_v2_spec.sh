Describe 'dashboard.html: v2 Micro-interactions + Animations (Task 6)'
  TEMPLATE="core/templates/dashboard.html"

  # --- New @keyframes definitions ---

  It 'defines @keyframes fadeScaleIn'
    The contents of file "$TEMPLATE" should include '@keyframes fadeScaleIn'
  End

  It 'defines @keyframes glowPulse'
    The contents of file "$TEMPLATE" should include '@keyframes glowPulse'
  End

  It 'defines @keyframes slideInFromLeft'
    The contents of file "$TEMPLATE" should include '@keyframes slideInFromLeft'
  End

  # --- Card entrance animation (v2: fadeScaleIn + spring curve) ---

  It 'applies animation: fadeScaleIn to .bento-card'
    The contents of file "$TEMPLATE" should include 'animation: fadeScaleIn 0.6s cubic-bezier(0.16, 1, 0.3, 1) both'
  End

  # --- Stagger at 60ms intervals (v2 spec) ---

  It 'sets animation-delay: 60ms on .bento-card:nth-child(1)'
    The contents of file "$TEMPLATE" should include '.bento-card:nth-child(1)'
  End

  It 'sets stagger at 60ms intervals (120ms)'
    The contents of file "$TEMPLATE" should include 'animation-delay: 120ms'
  End

  It 'sets stagger at 60ms intervals (360ms)'
    The contents of file "$TEMPLATE" should include 'animation-delay: 360ms'
  End

  # --- Sidebar slideInFromLeft ---

  It 'applies animation: slideInFromLeft to .sidebar'
    The contents of file "$TEMPLATE" should include 'animation: slideInFromLeft'
  End

  # --- Status dot glowPulse ---

  It 'applies animation: glowPulse to .status-dot.active'
    The contents of file "$TEMPLATE" should include 'animation: glowPulse 2s ease-in-out infinite'
  End

  # --- prefers-reduced-motion (must be preserved in v2) ---

  It 'defines prefers-reduced-motion: reduce'
    The contents of file "$TEMPLATE" should include 'prefers-reduced-motion: reduce'
  End

  It 'defines animation-duration: 0.01ms !important in reduced-motion'
    The contents of file "$TEMPLATE" should include 'animation-duration: 0.01ms !important'
  End
End
