SKILL="core/skills/heartbeat/SKILL.md"

# Task 2 completion condition:
# Phase 3 TDDサイクルのエージェント (tester, implementer, refactor) が
# Agent tool 経由で起動されることを検証する。
# Agent tool 経由で起動されたサブエージェントは完了時にオーケストレーターに
# 制御が戻り、Orchestrator responsibilities (generate-dashboard.sh 含む) が適用される。

check_tester_uses_agent_tool_dispatch() {
  # tester が Agent tool invocation パターンで起動されていることを確認
  # これにより、完了時に Orchestrator responsibilities が適用される
  grep -q 'subagent_type:.*heartbeat:tester\.agent' "$SKILL" || return 1
}

check_implementer_uses_agent_tool_dispatch() {
  # implementer が Agent tool invocation パターンで起動されていることを確認
  grep -q 'subagent_type:.*heartbeat:implementer\.agent' "$SKILL" || return 1
}

check_refactor_uses_agent_tool_dispatch() {
  # refactor が Agent tool invocation パターンで起動されていることを確認
  grep -q 'subagent_type:.*heartbeat:refactor\.agent' "$SKILL" || return 1
}

check_phase3_agents_in_tdd_cycle_flow() {
  # Phase 3 の TDD サイクル記述に tester, implementer, refactor の全3エージェントが
  # 含まれていることを確認（= Orchestrator responsibilities の適用対象）
  phase3_section=$(sed -n '/^Phase 3 - Implementation/,/^Phase 4/p' "$SKILL")
  [ -z "$phase3_section" ] && return 1
  echo "$phase3_section" | grep -q "tester" || return 1
  echo "$phase3_section" | grep -q "implementer" || return 1
  echo "$phase3_section" | grep -q "refactor" || return 1
}

check_orchestrator_responsibilities_apply_unconditionally() {
  # Orchestrator responsibilities セクションがフェーズ条件なしで適用されることを確認
  # （"after subagent returns" = 全サブエージェント完了後に適用）
  # Phase 3 固有の条件分岐がないことで、Phase 3 にも確実に適用される
  section=$(sed -n '/^### Orchestrator responsibilities (after subagent returns)/,/^## /p' "$SKILL")
  [ -z "$section" ] && return 1
  # generate-dashboard.sh の呼び出しに Phase 固有の条件がないことを確認
  # （条件付きなら "If Phase" や "only" などの制約が付く）
  dashboard_context=$(echo "$section" | grep -B1 -A1 "generate-dashboard.sh")
  echo "$dashboard_context" | grep -qi "if phase\|only.*phase\|phase 2\|phase 4" && return 1
  return 0
}

Describe 'Phase 3 TDDサイクルエージェントへの dashboard 更新カバレッジ'
  It 'tester は Agent tool dispatch パターンで起動される'
    When call check_tester_uses_agent_tool_dispatch
    The status should be success
  End

  It 'implementer は Agent tool dispatch パターンで起動される'
    When call check_implementer_uses_agent_tool_dispatch
    The status should be success
  End

  It 'refactor は Agent tool dispatch パターンで起動される'
    When call check_refactor_uses_agent_tool_dispatch
    The status should be success
  End

  It 'Phase 3 TDDサイクルに tester/implementer/refactor の全エージェントが含まれる'
    When call check_phase3_agents_in_tdd_cycle_flow
    The status should be success
  End

  It 'Orchestrator responsibilities の dashboard 更新はフェーズ条件なしで全サブエージェントに適用される'
    When call check_orchestrator_responsibilities_apply_unconditionally
    The status should be success
  End
End
