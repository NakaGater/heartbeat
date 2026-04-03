check_persona_references_board_write_sh() {
  for agent in core/agent-personas/*.md; do
    grep -q "board-write\.sh" "$agent" || return 1
  done
}

check_skill_references_board_write_sh() {
  skill="core/skills/heartbeat/SKILL.md"
  grep -q "board-write\.sh" "$skill" || return 1
}

Describe '全エージェントペルソナと SKILL.md が board-write.sh を参照している'
  It '全9ペルソナが board-write.sh 経由での書き込みを指示している'
    When call check_persona_references_board_write_sh
    The status should be success
  End

  It 'heartbeat SKILL.md が board-write.sh を参照している'
    When call check_skill_references_board_write_sh
    The status should be success
  End
End
