Describe 'dashboard.html: Premium Color Palette (Task 2 - AC2)'
  TEMPLATE="core/templates/dashboard.html"

  # --- Accent color scale (indigo) ---
  It 'defines accent color --accent-hover'
    The contents of file "$TEMPLATE" should include '--accent-hover:'
  End

  It 'defines accent color --accent-subtle'
    The contents of file "$TEMPLATE" should include '--accent-subtle:'
  End

  It 'defines accent color --accent-muted'
    The contents of file "$TEMPLATE" should include '--accent-muted:'
  End

  # --- Secondary accent ---
  It 'defines secondary color --secondary'
    The contents of file "$TEMPLATE" should include '--secondary:'
  End

  It 'defines secondary color --secondary-subtle'
    The contents of file "$TEMPLATE" should include '--secondary-subtle:'
  End

  # --- Semantic colors ---
  It 'defines semantic color --success'
    The contents of file "$TEMPLATE" should include '--success:'
  End

  It 'defines semantic color --warning'
    The contents of file "$TEMPLATE" should include '--warning:'
  End

  It 'defines semantic color --error'
    The contents of file "$TEMPLATE" should include '--error:'
  End

  It 'defines semantic color --info'
    The contents of file "$TEMPLATE" should include '--info:'
  End

  It 'defines semantic color --success-subtle'
    The contents of file "$TEMPLATE" should include '--success-subtle:'
  End

  It 'defines semantic color --warning-subtle'
    The contents of file "$TEMPLATE" should include '--warning-subtle:'
  End

  It 'defines semantic color --error-subtle'
    The contents of file "$TEMPLATE" should include '--error-subtle:'
  End

  It 'defines semantic color --info-subtle'
    The contents of file "$TEMPLATE" should include '--info-subtle:'
  End

  # --- Gradient definitions ---
  It 'defines gradient variable --gradient-primary'
    The contents of file "$TEMPLATE" should include '--gradient-primary:'
  End

  It 'defines gradient variable --gradient-header'
    The contents of file "$TEMPLATE" should include '--gradient-header:'
  End

  It 'defines gradient variable --gradient-surface'
    The contents of file "$TEMPLATE" should include '--gradient-surface:'
  End

  # --- Dark mode independent color definitions (v2: dark-first = :root is default dark) ---
  It 'defines accent colors independently in dark mode (:root)'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }
    When call root_block
    The output should include '--accent:'
  End

  It 'defines semantic color --success independently in dark mode (:root)'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }
    When call root_block
    The output should include '--success:'
  End

  It 'defines gradient --gradient-primary independently in dark mode (:root)'
    root_block() {
      sed -n '/:root[[:space:]]*{/,/^[[:space:]]*}/p' "$TEMPLATE"
    }
    When call root_block
    The output should include '--gradient-primary:'
  End
End
