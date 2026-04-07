REDUNDANT_FILE="adapters/claude-code/hooks/settings.local.json"

# --- ヘルパー関数 ---

# 冗長ファイルが存在しないこと
check_redundant_file_absent() {
  [ ! -f "$REDUNDANT_FILE" ]
}

Describe '冗長ファイルの削除 (AC-4)'
  Describe 'adapters/claude-code/hooks/settings.local.json の除去'
    It 'settings.local.json が存在しない'
      When call check_redundant_file_absent
      The status should be success
    End
  End
End
