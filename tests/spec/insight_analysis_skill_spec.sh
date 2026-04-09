Describe '/heartbeat:insight-analysis Skill Definition'
  SKILL_DIR="adapters/claude-code/skills/insight-analysis"

  It 'verifies that the skill directory exists'
    The path "$SKILL_DIR" should be directory
  End

  It 'verifies that the entry point file SKILL.md exists'
    The path "$SKILL_DIR/SKILL.md" should be file
  End

  It 'documents --files argument specification in SKILL.md'
    Skip if "SKILL.md does not exist" [ ! -f "$SKILL_DIR/SKILL.md" ]
    When run grep -q '\-\-files' "$SKILL_DIR/SKILL.md"
    The status should be success
  End

  It 'documents --figma argument specification in SKILL.md'
    Skip if "SKILL.md does not exist" [ ! -f "$SKILL_DIR/SKILL.md" ]
    When run grep -q '\-\-figma' "$SKILL_DIR/SKILL.md"
    The status should be success
  End

  It 'defines insight-analysis name in SKILL.md'
    Skip if "SKILL.md does not exist" [ ! -f "$SKILL_DIR/SKILL.md" ]
    When run grep -qi 'insight-analysis' "$SKILL_DIR/SKILL.md"
    The status should be success
  End
End
