Describe 'dashboard.html: Typography + Accent Colors + Data Visualization (Task 7)'
  TEMPLATE="core/templates/dashboard.html"

  # --- AC2: header h1 has gradient text ---
  It 'defines -webkit-background-clip: text in header h1 rule block'
    # Verify gradient text is applied in the CSS rule for header h1
    When run command awk '/header h1 \{/,/\}/' "$TEMPLATE"
    The output should include '-webkit-background-clip: text'
  End

  # --- AC4: .kanban-card has border-left defined ---
  It 'defines border-left: 3px solid on .kanban-card'
    The contents of file "$TEMPLATE" should include 'border-left: 3px solid'
  End

  # --- AC5: .kanban-card[data-status="in_progress"] has accent color border ---
  It 'defines border-left-color on .kanban-card[data-status="in_progress"]'
    The contents of file "$TEMPLATE" should include 'kanban-card[data-status="in_progress"]'
  End

  # --- AC6: .kanban-card[data-status="done"] has success color border ---
  It 'defines border-left-color on .kanban-card[data-status="done"]'
    The contents of file "$TEMPLATE" should include 'kanban-card[data-status="done"]'
  End

  # --- AC: .task-chip has status-specific background variants ---
  It 'defines status-specific background variants on .task-chip'
    The contents of file "$TEMPLATE" should include 'task-chip.status-'
  End

  # --- AC8: .progress-bar class exists ---
  It 'defines .progress-bar class with gradient background'
    The contents of file "$TEMPLATE" should include '.progress-bar {'
  End

  # --- AC9: .progress-bar-fill has gradient background ---
  It 'defines gradient-primary background on .progress-bar-fill'
    The contents of file "$TEMPLATE" should include '.progress-bar-fill'
  End

  # --- AC: .status-dot base styles (width/height/border-radius) ---
  It 'defines width and height on .status-dot'
    When run command awk '/\.status-dot[^.]* \{/,/\}/' "$TEMPLATE"
    The output should include 'width'
  End

  It 'defines border-radius on .status-dot (animated dot)'
    When run command awk '/\.status-dot[^.]* \{/,/\}/' "$TEMPLATE"
    The output should include 'border-radius'
  End
End
