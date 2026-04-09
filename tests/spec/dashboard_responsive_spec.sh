Describe 'dashboard.html: Responsive Improvements (Task 6)'
  TEMPLATE="core/templates/dashboard.html"

  # --- タッチターゲット 44px 確保 ---
  It 'sets min-height: 48px on .refresh-btn'
    The contents of file "$TEMPLATE" should include 'min-height: 48px'
  End

  It 'sets min-height: 48px on .done-toggle-btn'
    # design.md: 全インタラクティブ要素のタッチターゲットは 44px 以上
    The contents of file "$TEMPLATE" should match pattern '*.done-toggle-btn*min-height: 48px*'
  End

  It 'sets min-height: 48px on .story-select'
    The contents of file "$TEMPLATE" should match pattern '*.story-select*min-height: 48px*'
  End

  # --- 768px ブレークポイントのフォントサイズ調整 ---
  It 'fixes header h1 font-size to --text-xl in 768px media query'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 768px)*font-size: var(--text-xl)*'
  End

  It 'sets #app padding to --space-3 in 768px media query'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 768px)*padding: var(--space-3)*'
  End

  # --- 480px ブレークポイントのフォントサイズ調整 ---
  It 'reduces header h1 font-size to --text-lg in 480px media query'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 480px)*font-size: var(--text-lg)*'
  End

  It 'sets #app padding to --space-2 in 480px media query'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 480px)*padding: var(--space-2)*'
  End
End
