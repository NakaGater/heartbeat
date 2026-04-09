DASHBOARD="core/templates/dashboard.html"

# Task 1 completion condition 1:
# renderBacklog() hides Done column items using the done-hidden class
check_done_hidden_class() {
  grep -q "done-hidden" "$DASHBOARD" || return 1
}

# Task 1 completion condition 2:
# renderBacklog() hides Done column items with display:none style
check_done_display_none() {
  grep -q 'style="display:none"' "$DASHBOARD" || return 1
}

Describe 'Dashboard Done Column Display Limit'
  It 'done-hidden class exists in the Done column'
    When call check_done_hidden_class
    The status should be success
  End

  It 'display:none style exists in the Done column'
    When call check_done_display_none
    The status should be success
  End
End

# Task 2 completion condition 1:
# Toggle button function or event handler exists
check_done_toggle_function() {
  grep -q "done-toggle\|toggleDone\|toggle.*done" "$DASHBOARD" || return 1
}

# Task 2 completion condition 2:
# aria-expanded attribute exists (accessibility)
check_aria_expanded() {
  grep -q "aria-expanded" "$DASHBOARD" || return 1
}

Describe 'Dashboard Done Column Toggle Button'
  It 'toggle function or button exists'
    When call check_done_toggle_function
    The status should be success
  End

  It 'aria-expanded attribute exists'
    When call check_aria_expanded
    The status should be success
  End
End

# Task 3 completion condition 1:
# .done-toggle-btn CSS class style definition exists
check_done_toggle_btn_css() {
  grep -q "\.done-toggle-btn" "$DASHBOARD" || return 1
}

Describe 'Dashboard Done Toggle Button CSS'
  It '.done-toggle-btn CSS style is defined'
    When call check_done_toggle_btn_css
    The status should be success
  End
End
