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

# --- タスク2: Workflow 2 の STOP ディレクティブが Continuation Flow 呼び出しに置換されていること ---

check_wf2_no_stop_directive() {
  # Workflow 2 セクション (## Workflow 2 から次の ## セクションまで) を抽出
  wf2_start=$(grep -n "## Workflow 2:" "$SKILL_MD" | head -1 | cut -d: -f1)
  [ -z "$wf2_start" ] && return 1
  # 次の ## セクション行を特定（Workflow 2 の後）
  wf2_end=$(tail -n +"$((wf2_start + 1))" "$SKILL_MD" | grep -n "^## " | head -1 | cut -d: -f1)
  [ -z "$wf2_end" ] && return 1
  wf2_end=$((wf2_start + wf2_end))
  # Workflow 2 セクション内を抽出
  sed -n "${wf2_start},${wf2_end}p" "$SKILL_MD" > /tmp/wf2_section.tmp
  # 古い STOP ディレクティブが存在しないこと
  ! grep -q "STOP: Workflow 2 complete" /tmp/wf2_section.tmp
}

check_wf2_has_continuation_flow_ref() {
  # Workflow 2 セクション内に Continuation Flow への参照があること
  wf2_start=$(grep -n "## Workflow 2:" "$SKILL_MD" | head -1 | cut -d: -f1)
  [ -z "$wf2_start" ] && return 1
  wf2_end=$(tail -n +"$((wf2_start + 1))" "$SKILL_MD" | grep -n "^## " | head -1 | cut -d: -f1)
  [ -z "$wf2_end" ] && return 1
  wf2_end=$((wf2_start + wf2_end))
  sed -n "${wf2_start},${wf2_end}p" "$SKILL_MD" > /tmp/wf2_section.tmp
  # Continuation Flow への参照が存在すること
  grep -q "Continuation Flow" /tmp/wf2_section.tmp
}

check_wf2_post_completion_prerequisite() {
  # Workflow 2 セクション内で Post-Completion Flow の実行が前提条件として維持されていること
  wf2_start=$(grep -n "## Workflow 2:" "$SKILL_MD" | head -1 | cut -d: -f1)
  [ -z "$wf2_start" ] && return 1
  wf2_end=$(tail -n +"$((wf2_start + 1))" "$SKILL_MD" | grep -n "^## " | head -1 | cut -d: -f1)
  [ -z "$wf2_end" ] && return 1
  wf2_end=$((wf2_start + wf2_end))
  sed -n "${wf2_start},${wf2_end}p" "$SKILL_MD" > /tmp/wf2_section.tmp
  # Post-Completion Flow への参照が維持されていること
  grep -q "Post-Completion Flow" /tmp/wf2_section.tmp
}

Describe 'SKILL.md Workflow 2 STOP ディレクティブの置換（タスク2）'
  It 'Workflow 2 に旧 STOP ディレクティブが存在しない'
    When call check_wf2_no_stop_directive
    The status should be success
  End

  It 'Workflow 2 に Continuation Flow への参照が存在する'
    When call check_wf2_has_continuation_flow_ref
    The status should be success
  End

  It 'Workflow 2 で Post-Completion Flow の実行が前提条件として維持されている'
    When call check_wf2_post_completion_prerequisite
    The status should be success
  End
End

# --- タスク3: Workflow 3 の STOP ディレクティブが Continuation Flow 呼び出しに置換されていること ---

check_wf3_no_stop_directive() {
  # Workflow 3 セクション (## Workflow 3 から次の ## セクションまで) を抽出
  wf3_start=$(grep -n "## Workflow 3:" "$SKILL_MD" | head -1 | cut -d: -f1)
  [ -z "$wf3_start" ] && return 1
  # 次の ## セクション行を特定（Workflow 3 の後）
  wf3_end=$(tail -n +"$((wf3_start + 1))" "$SKILL_MD" | grep -n "^## " | head -1 | cut -d: -f1)
  if [ -z "$wf3_end" ]; then
    # 最後のセクションの場合、ファイル末尾まで
    wf3_end=$(wc -l < "$SKILL_MD")
  else
    wf3_end=$((wf3_start + wf3_end))
  fi
  # Workflow 3 セクション内を抽出
  sed -n "${wf3_start},${wf3_end}p" "$SKILL_MD" > /tmp/wf3_section.tmp
  # 古い STOP ディレクティブが存在しないこと
  ! grep -q "STOP: Workflow 3 complete" /tmp/wf3_section.tmp
}

check_wf3_has_continuation_flow_ref() {
  # Workflow 3 セクション内に Continuation Flow への参照があること
  wf3_start=$(grep -n "## Workflow 3:" "$SKILL_MD" | head -1 | cut -d: -f1)
  [ -z "$wf3_start" ] && return 1
  wf3_end=$(tail -n +"$((wf3_start + 1))" "$SKILL_MD" | grep -n "^## " | head -1 | cut -d: -f1)
  if [ -z "$wf3_end" ]; then
    wf3_end=$(wc -l < "$SKILL_MD")
  else
    wf3_end=$((wf3_start + wf3_end))
  fi
  sed -n "${wf3_start},${wf3_end}p" "$SKILL_MD" > /tmp/wf3_section.tmp
  # Continuation Flow への参照が存在すること
  grep -q "Continuation Flow" /tmp/wf3_section.tmp
}

Describe 'SKILL.md Workflow 3 STOP ディレクティブの置換（タスク3）'
  It 'Workflow 3 に旧 STOP ディレクティブが存在しない'
    When call check_wf3_no_stop_directive
    The status should be success
  End

  It 'Workflow 3 に Continuation Flow への参照が存在する'
    When call check_wf3_has_continuation_flow_ref
    The status should be success
  End
End
