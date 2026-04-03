SKILL="core/skills/heartbeat/SKILL.md"

# Task 3 完了条件:
# 受け入れ基準の検証 — 既存4箇所への無影響確認 + 全遷移ポイントの網羅確認
#
# Task 1 テスト (skill_orchestrator_dashboard_update_spec.sh) は
#   Orchestrator responsibilities セクション内の配置・順序・同期実行を検証済み。
# Task 2 テスト (skill_phase3_dashboard_coverage_spec.sh) は
#   Phase 3 エージェントの Agent tool dispatch と無条件適用を検証済み。
#
# 本テストは以下の未検証項目をカバーする:
#   1. 既存4箇所の generate-dashboard.sh 呼び出しが依然として存在すること
#   2. SKILL.md 全体の generate-dashboard.sh 呼び出し総数が 5 であること

check_draft_registration_dashboard_call() {
  # Phase 0 draft 登録後の generate-dashboard.sh 呼び出しが存在する
  section=$(sed -n '/^Phase 0 - Draft registration/,/^Phase 1/p' "$SKILL")
  [ -z "$section" ] && return 1
  echo "$section" | grep -q "generate-dashboard.sh" || return 1
}

check_ready_transition_dashboard_call() {
  # Result ready 遷移後の generate-dashboard.sh 呼び出しが存在する
  # "Result:" セクションから STOP 行までの間を抽出
  section=$(sed -n '/^Result:$/,/^>>>/p' "$SKILL")
  [ -z "$section" ] && return 1
  echo "$section" | grep -q "generate-dashboard.sh" || return 1
}

check_in_progress_transition_dashboard_call() {
  # Workflow 2 開始時 in_progress 遷移後の generate-dashboard.sh 呼び出しが存在する
  # "in_progress" と "generate-dashboard.sh" が Workflow 2 冒頭に存在する
  section=$(sed -n '/^## Workflow 2: Implement a Story/,/^Phase 2/p' "$SKILL")
  [ -z "$section" ] && return 1
  echo "$section" | grep -q "in_progress" || return 1
  echo "$section" | grep -q "generate-dashboard.sh" || return 1
}

check_done_transition_dashboard_call() {
  # Post-Completion done 遷移後の generate-dashboard.sh 呼び出しが存在する
  # "done" ステータス更新と generate-dashboard.sh が近接している
  section=$(sed -n '/^Update backlog.jsonl:$/,/^## Workflow 3/p' "$SKILL")
  [ -z "$section" ] && return 1
  echo "$section" | grep -q '"done"' || return 1
  echo "$section" | grep -q "generate-dashboard.sh" || return 1
}

check_total_dashboard_invocations_is_six() {
  # SKILL.md 全体で generate-dashboard.sh の呼び出しが正確に 6 箇所であること
  # (既存4箇所 + Orchestrator responsibilities 1箇所 + Workflow 3 in_progress 遷移1箇所)
  count=$(grep -c "generate-dashboard.sh" "$SKILL")
  [ "$count" -eq 6 ]
}

Describe '受け入れ基準: 既存4箇所の generate-dashboard.sh 呼び出しへの無影響確認'
  It 'Phase 0 draft 登録後に generate-dashboard.sh が呼ばれる'
    When call check_draft_registration_dashboard_call
    The status should be success
  End

  It 'Result ready 遷移後に generate-dashboard.sh が呼ばれる'
    When call check_ready_transition_dashboard_call
    The status should be success
  End

  It 'Workflow 2 開始時 in_progress 遷移後に generate-dashboard.sh が呼ばれる'
    When call check_in_progress_transition_dashboard_call
    The status should be success
  End

  It 'Post-Completion done 遷移後に generate-dashboard.sh が呼ばれる'
    When call check_done_transition_dashboard_call
    The status should be success
  End
End

Describe '受け入れ基準: 全遷移ポイントの網羅確認'
  It 'generate-dashboard.sh の呼び出し総数が 6 である (既存4 + Orchestrator責務1 + Workflow 3 in_progress 遷移1)'
    When call check_total_dashboard_invocations_is_six
    The status should be success
  End
End
