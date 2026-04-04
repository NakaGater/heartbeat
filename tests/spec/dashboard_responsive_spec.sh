Describe 'dashboard.html: レスポンシブ改善（タスク6）'
  TEMPLATE="core/templates/dashboard.html"

  # --- タッチターゲット 44px 確保 ---
  It '.refresh-btn に min-height: 44px が設定されている'
    The contents of file "$TEMPLATE" should include 'min-height: 44px'
  End

  It '.done-toggle-btn に min-height: 44px が設定されている'
    # design.md: 全インタラクティブ要素のタッチターゲットは 44px 以上
    The contents of file "$TEMPLATE" should match pattern '*.done-toggle-btn*min-height: 44px*'
  End

  It '.story-select に min-height: 44px が設定されている'
    The contents of file "$TEMPLATE" should match pattern '*.story-select*min-height: 44px*'
  End

  # --- 768px ブレークポイントのフォントサイズ調整 ---
  It '768px メディアクエリ内で header h1 のフォントサイズが --text-xl に固定されている'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 768px)*font-size: var(--text-xl)*'
  End

  It '768px メディアクエリ内で #app の padding が --space-3 に設定されている'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 768px)*padding: var(--space-3)*'
  End

  # --- 480px ブレークポイントのフォントサイズ調整 ---
  It '480px メディアクエリ内で header h1 のフォントサイズが --text-lg に縮小されている'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 480px)*font-size: var(--text-lg)*'
  End

  It '480px メディアクエリ内で #app の padding が --space-2 に設定されている'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 480px)*padding: var(--space-2)*'
  End
End
