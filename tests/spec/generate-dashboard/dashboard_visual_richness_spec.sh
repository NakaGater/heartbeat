Describe 'dashboard.html: Visual Richness and Depth (Task 5)'
  TEMPLATE="core/templates/dashboard.html"

  # --- Glassmorphism effect (header) ---
  It 'applies backdrop-filter to header (token or literal)'
    check_header_backdrop() {
      awk '/^header[ \t]*\{/{found=1} found && /[^-]backdrop-filter[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call check_header_backdrop
    The output should equal "ok"
  End

  It 'applies -webkit-backdrop-filter (vendor prefix) to header'
    check_header_webkit_backdrop() {
      awk '/^header[ \t]*\{/{found=1} found && /-webkit-backdrop-filter[ \t]*:/{print "ok"; exit} found && /\}/{found=0}' "$TEMPLATE"
    }
    When call check_header_webkit_backdrop
    The output should equal "ok"
  End

  # --- Subtle gradient background (changed to mesh gradient in Task 4) ---
  It 'applies gradient-mesh as background-image on body'
    The contents of file "$TEMPLATE" should include 'background-image: var(--gradient-mesh)'
  End

  # --- Panel shadow token application ---
  It 'uses --shadow-sm token for default box-shadow on .panel'
    # design.md: Common panel shadow is var(--shadow-sm)
    The contents of file "$TEMPLATE" should match pattern '*.panel {*box-shadow: var(--shadow-sm)*'
  End

  # --- Panel border-radius improvement ---
  It 'uses --radius-lg token for border-radius on .panel'
    # design.md: Common panel border-radius is var(--radius-lg) = 14px
    The contents of file "$TEMPLATE" should match pattern '*.panel {*border-radius: var(--radius-lg)*'
  End

  # --- Header glassmorphism background (semi-transparent) ---
  It 'changes header background to semi-transparent rgba'
    The contents of file "$TEMPLATE" should include 'background: rgba('
  End
End
