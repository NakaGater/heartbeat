Describe 'SKILL.md (heartbeat-backlog) ダッシュボード同期呼び出し'
  # T3: heartbeat-backlog の SKILL.md に Dashboard Sync セクションが存在し、
  #     generate-dashboard.sh の同期実行指示が Important Notes の直前に
  #     記載されていることを検証する

  SKILL_FILE="core/skills/heartbeat-backlog/SKILL.md"

  It 'Dashboard Sync セクションに generate-dashboard.sh の同期実行指示が含まれる'
    # ## Dashboard Sync セクションと ## Important Notes セクションの間に
    # generate-dashboard.sh が存在すること
    extract_dashboard_sync_section() {
      sed -n '/^## Dashboard Sync$/,/^## Important Notes$/p' "$SKILL_FILE"
    }
    When call extract_dashboard_sync_section
    The output should include 'generate-dashboard.sh'
  End

  It 'Dashboard Sync セクションが Important Notes セクションより前に記載されている'
    check_section_order() {
      local sync_line notes_line
      sync_line=$(grep -n '^## Dashboard Sync$' "$SKILL_FILE" | head -1 | cut -d: -f1)
      notes_line=$(grep -n '^## Important Notes$' "$SKILL_FILE" | head -1 | cut -d: -f1)
      # sync_line が空の場合は失敗（セクションが存在しない）
      [ -n "$sync_line" ] || return 1
      # Important Notes より前にあること
      [ "$sync_line" -lt "$notes_line" ]
    }
    When call check_section_order
    The status should be success
  End

  It '同期実行であることが明示されている（synchronous の記述がある）'
    check_synchronous_instruction() {
      local section
      section=$(sed -n '/^## Dashboard Sync$/,/^## Important Notes$/p' "$SKILL_FILE")
      echo "$section" | grep -qi 'synchronous'
    }
    When call check_synchronous_instruction
    The status should be success
  End
End
