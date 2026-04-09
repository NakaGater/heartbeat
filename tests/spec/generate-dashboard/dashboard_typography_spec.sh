Describe 'dashboard.html: Typography Refinement (Task 3 - AC5)'
  TEMPLATE="core/templates/dashboard.html"

  # --- System font stack ---
  It 'defines a system font stack including SF Pro on body'
    The contents of file "$TEMPLATE" should include "SF Pro"
  End

  It 'defines anti-alias rendering -webkit-font-smoothing: antialiased'
    The contents of file "$TEMPLATE" should include '-webkit-font-smoothing: antialiased'
  End

  # --- Type scale tokens ---
  It 'defines type scale token --text-xs on :root'
    The contents of file "$TEMPLATE" should include '--text-xs:'
  End

  It 'defines type scale token --text-sm on :root'
    The contents of file "$TEMPLATE" should include '--text-sm:'
  End

  It 'defines type scale token --text-base on :root'
    The contents of file "$TEMPLATE" should include '--text-base:'
  End

  It 'defines type scale token --text-lg on :root'
    The contents of file "$TEMPLATE" should include '--text-lg:'
  End

  It 'defines type scale token --text-xl on :root'
    The contents of file "$TEMPLATE" should include '--text-xl:'
  End

  It 'defines type scale token --text-2xl on :root'
    The contents of file "$TEMPLATE" should include '--text-2xl:'
  End

  # --- Fluid Typography (h1 uses clamp()) ---
  It 'defines fluid font-size using clamp() on h1'
    The contents of file "$TEMPLATE" should include 'clamp('
  End

  # --- Font weight hierarchy (4 levels) ---
  It 'uses font-weight 700 (Bold)'
    The contents of file "$TEMPLATE" should include 'font-weight: 700'
  End

  It 'uses font-weight 600 (Semibold)'
    The contents of file "$TEMPLATE" should include 'font-weight: 600'
  End

  It 'uses font-weight 500 (Medium)'
    The contents of file "$TEMPLATE" should include 'font-weight: 500'
  End

  # --- Letter-spacing differentiation ---
  It 'defines tight letter-spacing (negative value) for headings'
    The contents of file "$TEMPLATE" should include 'letter-spacing: -0.025em'
  End

  It 'defines wide letter-spacing (positive 0.08em) for labels'
    The contents of file "$TEMPLATE" should include 'letter-spacing: 0.08em'
  End

  It 'defines letter-spacing (0.01em) for body text'
    The contents of file "$TEMPLATE" should include 'letter-spacing: 0.01em'
  End
End
