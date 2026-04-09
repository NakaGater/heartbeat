REDUNDANT_FILE="adapters/claude-code/hooks/settings.local.json"

# --- Helper functions ---

# Verify redundant file does not exist
check_redundant_file_absent() {
  [ ! -f "$REDUNDANT_FILE" ]
}

Describe 'Redundant File Removal (AC-4)'
  Describe 'adapters/claude-code/hooks/settings.local.json Removal'
    It 'settings.local.json does not exist'
      When call check_redundant_file_absent
      The status should be success
    End
  End
End
