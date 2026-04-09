Describe 'dashboard.html: Responsive v2 (Task 8: 3 Breakpoints + 48px Touch Targets)'
  TEMPLATE="core/templates/dashboard.html"

  # --- 1024px breakpoint: grid adjustment ---
  It 'changes .bento-grid to 6-column grid in 1024px media query'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 1024px)*.bento-grid*grid-template-columns: repeat(6, 1fr)*'
  End

  # --- 768px breakpoint: sidebar hidden ---
  It 'sets .sidebar to display: none in 768px media query'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 768px)*.sidebar*display: none*'
  End

  It 'sets .bento-grid margin-left to 0 in 768px media query'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 768px)*.bento-grid*margin-left: 0*'
  End

  It 'changes .bento-grid to 1-column grid in 768px media query'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 768px)*.bento-grid*grid-template-columns: 1fr*'
  End

  It 'reduces .metric-value font-size in 768px media query'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 768px)*.metric-value*font-size:*'
  End

  # --- 480px breakpoint: single column ---
  It 'changes .kanban to 1-column in 480px media query'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 480px)*.kanban*grid-template-columns: 1fr*'
  End

  # --- Touch target 48px (v2 spec: 48px instead of 44px) ---
  It 'sets min-height: 48px on touch target elements'
    The contents of file "$TEMPLATE" should include 'min-height: 48px'
  End

  It 'sets min-height: 48px on .sidebar-icon'
    The contents of file "$TEMPLATE" should match pattern '*.sidebar-icon*min-height: 48px*'
  End
End
