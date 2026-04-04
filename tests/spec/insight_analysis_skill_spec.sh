Describe '/heartbeat:insight-analysis Skill定義'
  SKILL_DIR="adapters/claude-code/skills/insight-analysis"

  It 'Skillディレクトリが存在すること'
    The path "$SKILL_DIR" should be directory
  End

  It 'エントリポイントファイル SKILL.md が存在すること'
    The path "$SKILL_DIR/SKILL.md" should be file
  End

  It 'SKILL.md に --files 引数仕様が記載されていること'
    Skip if "SKILL.md が存在しない" [ ! -f "$SKILL_DIR/SKILL.md" ]
    When run grep -q '\-\-files' "$SKILL_DIR/SKILL.md"
    The status should be success
  End

  It 'SKILL.md に --figma 引数仕様が記載されていること'
    Skip if "SKILL.md が存在しない" [ ! -f "$SKILL_DIR/SKILL.md" ]
    When run grep -q '\-\-figma' "$SKILL_DIR/SKILL.md"
    The status should be success
  End

  It 'SKILL.md に insight-analysis の名前が定義されていること'
    Skip if "SKILL.md が存在しない" [ ! -f "$SKILL_DIR/SKILL.md" ]
    When run grep -qi 'insight-analysis' "$SKILL_DIR/SKILL.md"
    The status should be success
  End
End
