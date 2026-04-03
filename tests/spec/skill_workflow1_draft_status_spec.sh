Describe 'SKILL.md Workflow 1 draft ステータス登録'
  # Workflow 1 の Phase 1 開始前に backlog.jsonl へ draft エントリを登録し、
  # generate-dashboard.sh を同期実行する指示が SKILL.md に含まれることを検証する

  SKILL_FILE="core/skills/heartbeat/SKILL.md"

  It 'Phase 1 開始前に backlog.jsonl へ draft ステータスでエントリを登録する指示が含まれる'
    # Workflow 1 セクション内の "User question" から "pdm (hearing)" の間に
    # draft 登録指示が存在すること
    extract_wf1_pre_phase1() {
      local wf1_start wf1_stop
      wf1_start=$(grep -n 'Workflow 1: Create a Story' "$SKILL_FILE" | head -1 | cut -d: -f1)
      wf1_stop=$(grep -n '>>> STOP.*Workflow 1' "$SKILL_FILE" | head -1 | cut -d: -f1)
      sed -n "${wf1_start},${wf1_stop}p" "$SKILL_FILE" \
        | sed -n '/User question/,/pdm (hearing)/p'
    }
    When call extract_wf1_pre_phase1
    The output should include 'draft'
    The output should include 'backlog.jsonl'
  End

  It 'draft 登録直後に generate-dashboard.sh の同期実行指示が含まれる'
    # Workflow 1 セクション内で draft+backlog.jsonl 行と pdm (hearing) 行の間に
    # generate-dashboard.sh があること
    check_draft_then_dashboard() {
      local wf1_start wf1_stop draft_line pdm_line

      wf1_start=$(grep -n 'Workflow 1: Create a Story' "$SKILL_FILE" | head -1 | cut -d: -f1)
      wf1_stop=$(grep -n '>>> STOP.*Workflow 1' "$SKILL_FILE" | head -1 | cut -d: -f1)

      # Workflow 1 セクションを抽出し、その中で行番号を振って検索
      local wf1_section
      wf1_section=$(sed -n "${wf1_start},${wf1_stop}p" "$SKILL_FILE")

      # draft + backlog.jsonl を含む行
      draft_line=$(echo "$wf1_section" | grep -n 'draft' | grep 'backlog.jsonl' | head -1 | cut -d: -f1)
      [ -n "$draft_line" ] || return 1

      # pdm (hearing) の行番号
      pdm_line=$(echo "$wf1_section" | grep -n 'pdm (hearing)' | head -1 | cut -d: -f1)
      [ -n "$pdm_line" ] || return 1

      # draft 行と pdm 行の間に generate-dashboard.sh があること
      echo "$wf1_section" \
        | sed -n "${draft_line},${pdm_line}p" \
        | grep -q 'generate-dashboard.sh'
    }
    When call check_draft_then_dashboard
    The status should be success
  End

  It 'Result セクションでは draft から ready への更新（Update）指示に変更されている'
    # Workflow 1 の Result セクション内に "Update" と "ready" が含まれること
    # （従来の "Register" ではなく "Update" であること）
    extract_wf1_result_section() {
      local wf1_start wf1_stop
      wf1_start=$(grep -n 'Workflow 1: Create a Story' "$SKILL_FILE" | head -1 | cut -d: -f1)
      wf1_stop=$(grep -n '>>> STOP.*Workflow 1' "$SKILL_FILE" | head -1 | cut -d: -f1)
      sed -n "${wf1_start},${wf1_stop}p" "$SKILL_FILE" \
        | sed -n '/^Result:$/,/^>>>/p'
    }
    When call extract_wf1_result_section
    The output should include 'Update'
    The output should include 'ready'
  End
End
