DASHBOARD="core/templates/dashboard.html"

# Task 1 completion condition 1:
# renderBacklog() Done列で done-hidden クラスを使って非表示にする
check_done_hidden_class() {
  grep -q "done-hidden" "$DASHBOARD" || return 1
}

# Task 1 completion condition 2:
# renderBacklog() Done列で display:none スタイルを付与して非表示にする
check_done_display_none() {
  grep -q 'style="display:none"' "$DASHBOARD" || return 1
}

Describe 'dashboard.html Done列の表示件数制限'
  It 'Done列に done-hidden クラスが存在する'
    When call check_done_hidden_class
    The status should be success
  End

  It 'Done列に display:none スタイルが存在する'
    When call check_done_display_none
    The status should be success
  End
End

# Task 2 completion condition 1:
# Toggleボタン用の関数またはイベントハンドラが存在する
check_done_toggle_function() {
  grep -q "done-toggle\|toggleDone\|toggle.*done" "$DASHBOARD" || return 1
}

# Task 2 completion condition 2:
# aria-expanded 属性が存在する（アクセシビリティ）
check_aria_expanded() {
  grep -q "aria-expanded" "$DASHBOARD" || return 1
}

Describe 'dashboard.html Done列 Toggleボタン'
  It 'toggle関数またはボタンが存在する'
    When call check_done_toggle_function
    The status should be success
  End

  It 'aria-expanded 属性が存在する'
    When call check_aria_expanded
    The status should be success
  End
End

# Task 3 completion condition 1:
# .done-toggle-btn CSSクラスのスタイル定義が存在する
check_done_toggle_btn_css() {
  grep -q "\.done-toggle-btn" "$DASHBOARD" || return 1
}

Describe 'dashboard.html Done Toggle ボタンCSS'
  It '.done-toggle-btn CSSスタイルが定義されている'
    When call check_done_toggle_btn_css
    The status should be success
  End
End
