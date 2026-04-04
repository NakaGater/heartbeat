# Continuation Flow セクションが SKILL.md に正しく定義されていることを検証する

SKILL_MD="adapters/claude-code/skills/heartbeat/SKILL.md"

check_continuation_section_exists() {
  grep -q "## Continuation" "$SKILL_MD"
}

check_continuation_after_post_completion() {
  # Post-Completion Flow の行番号を取得
  post_line=$(grep -n "## Post-Completion Flow" "$SKILL_MD" | head -1 | cut -d: -f1)
  # Continuation セクションの行番号を取得
  cont_line=$(grep -n "## Continuation" "$SKILL_MD" | head -1 | cut -d: -f1)
  # 両方存在し、Continuation が Post-Completion Flow より後にあること
  [ -n "$post_line" ] && [ -n "$cont_line" ] && [ "$cont_line" -gt "$post_line" ]
}

check_continuation_has_choices() {
  # AskUserQuestion パターンに従った選択肢定義があること
  grep -q "次のストーリーを実装する" "$SKILL_MD" &&
  grep -q "終了する" "$SKILL_MD"
}

check_continuation_auto_stop_no_ready() {
  # Continuation セクション内に ready ストーリー0件時の自動終了（STOP）が明記されていること
  # セクションの範囲を抽出して検証する
  cont_line=$(grep -n "## Continuation" "$SKILL_MD" | head -1 | cut -d: -f1)
  [ -z "$cont_line" ] && return 1
  # Continuation セクション以降を取得し、次の ## セクションまでを対象とする
  tail -n +"$cont_line" "$SKILL_MD" | sed -n '2,/^## /p' > /tmp/continuation_section.tmp
  grep -q 'no.*"ready"\|"ready".*exist\|ready.*ない\|No.*ready' /tmp/continuation_section.tmp &&
  grep -q "STOP" /tmp/continuation_section.tmp
}

Describe 'SKILL.md Continuation Flow セクション'
  It 'Continuation セクションが存在する'
    When call check_continuation_section_exists
    The status should be success
  End

  It 'Continuation セクションが Post-Completion Flow の後に定義されている'
    When call check_continuation_after_post_completion
    The status should be success
  End

  It 'AskUserQuestion パターンに従った選択肢定義がある'
    When call check_continuation_has_choices
    The status should be success
  End

  It 'ready ストーリー0件時の自動終了が明記されている'
    When call check_continuation_auto_stop_no_ready
    The status should be success
  End
End
