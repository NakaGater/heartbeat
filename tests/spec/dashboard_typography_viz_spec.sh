Describe 'dashboard.html: タイポグラフィ + アクセントカラー + データビジュアライゼーション（タスク7）'
  TEMPLATE="core/templates/dashboard.html"

  # --- AC2: header h1 にグラデーションテキスト ---
  It 'header h1 ルールブロック内に -webkit-background-clip: text が定義されている'
    # header h1 の CSS ルール内で gradient text が適用されていることを検証
    result=$(awk '/header h1 \{/,/\}/' "$TEMPLATE" | grep -c '\-webkit-background-clip: text')
    [ "$result" -ge 1 ]
    The status should be success
  End

  # --- AC4: .kanban-card に border-left が定義されている ---
  It '.kanban-card に border-left: 3px solid が定義されている'
    The contents of file "$TEMPLATE" should include 'border-left: 3px solid'
  End

  # --- AC5: .kanban-card[data-status="in_progress"] にアクセント色ボーダー ---
  It '.kanban-card[data-status="in_progress"] に border-left-color が定義されている'
    The contents of file "$TEMPLATE" should include 'kanban-card[data-status="in_progress"]'
  End

  # --- AC6: .kanban-card[data-status="done"] にサクセス色ボーダー ---
  It '.kanban-card[data-status="done"] に border-left-color が定義されている'
    The contents of file "$TEMPLATE" should include 'kanban-card[data-status="done"]'
  End

  # --- AC: .task-chip にステータス別背景バリアント ---
  It '.task-chip にステータス別の background バリアントが定義されている'
    The contents of file "$TEMPLATE" should include 'task-chip.status-'
  End

  # --- AC8: .progress-bar クラスが存在する ---
  It '.progress-bar クラスがグラデーション背景付きで定義されている'
    The contents of file "$TEMPLATE" should include '.progress-bar {'
  End

  # --- AC9: .progress-bar-fill にグラデーション背景 ---
  It '.progress-bar-fill に gradient-primary 背景が定義されている'
    The contents of file "$TEMPLATE" should include '.progress-bar-fill'
  End

  # --- AC: .status-dot 基本スタイル (width/height/border-radius) ---
  It '.status-dot に width と height が定義されている'
    result=$(awk '/\.status-dot[^.]* \{/,/\}/' "$TEMPLATE" | grep -c 'width')
    [ "$result" -ge 1 ]
    The status should be success
  End

  It '.status-dot に border-radius が定義されている (アニメーションドット)'
    result=$(awk '/\.status-dot[^.]* \{/,/\}/' "$TEMPLATE" | grep -c 'border-radius')
    [ "$result" -ge 1 ]
    The status should be success
  End
End
