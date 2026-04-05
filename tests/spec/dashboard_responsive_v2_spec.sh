Describe 'dashboard.html: レスポンシブ対応 v2（タスク8: 3ブレークポイント + タッチターゲット48px）'
  TEMPLATE="core/templates/dashboard.html"

  # --- 1024px ブレークポイント: グリッド調整 ---
  It '1024px メディアクエリ内で .bento-grid が 6カラムグリッドに変更される'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 1024px)*.bento-grid*grid-template-columns: repeat(6, 1fr)*'
  End

  # --- 768px ブレークポイント: サイドバー非表示 ---
  It '768px メディアクエリ内で .sidebar が display: none になる'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 768px)*.sidebar*display: none*'
  End

  It '768px メディアクエリ内で .bento-grid の margin-left が 0 になる'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 768px)*.bento-grid*margin-left: 0*'
  End

  It '768px メディアクエリ内で .bento-grid が 1カラムグリッドになる'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 768px)*.bento-grid*grid-template-columns: 1fr*'
  End

  It '768px メディアクエリ内で .metric-value のフォントサイズが縮小される'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 768px)*.metric-value*font-size:*'
  End

  # --- 480px ブレークポイント: シングルカラム ---
  It '480px メディアクエリ内で .kanban が 1カラムになる'
    The contents of file "$TEMPLATE" should match pattern '*@media (max-width: 480px)*.kanban*grid-template-columns: 1fr*'
  End

  # --- タッチターゲット 48px（v2仕様: 44px ではなく 48px） ---
  It 'タッチターゲット要素に min-height: 48px が設定されている'
    The contents of file "$TEMPLATE" should include 'min-height: 48px'
  End

  It '.sidebar-icon に min-height: 48px が設定されている'
    The contents of file "$TEMPLATE" should match pattern '*.sidebar-icon*min-height: 48px*'
  End
End
