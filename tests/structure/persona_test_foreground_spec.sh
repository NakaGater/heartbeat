## テスト: tester.md にテスト実行フォアグラウンドルールが定義されていること
## ストーリー: 0049-subagent-test-foreground / タスク 1

# ヘルパー: 指定ペルソナファイルから "## Test Execution Rule" セクションを抽出する。
# "## Test Execution Rule" 見出しと次の "##" 見出しの間を返す。
extract_test_execution_rule_section() {
  persona_file="$1"
  [ -f "$persona_file" ] || return 1
  sed -n '/^## Test Execution Rule$/,/^## /{ /^## Test Execution Rule$/d; /^## /d; p; }' "$persona_file"
}

# 条件1: tester.md に「## Test Execution Rule」セクションが存在すること
check_tester_has_test_execution_rule_section() {
  grep -q "^## Test Execution Rule$" "core/agent-personas/tester.md" || return 1
}

# 条件2: フォアグラウンド（同期）実行の指示が含まれること
check_tester_has_foreground_instruction() {
  section=$(extract_test_execution_rule_section "core/agent-personas/tester.md")
  [ -n "$section" ] || return 1
  echo "$section" | grep -qi "ALWAYS run test commands.*foreground.*(synchronously)" || return 1
}

# 条件3: run_in_background 禁止の指示が含まれること
check_tester_has_run_in_background_prohibition() {
  section=$(extract_test_execution_rule_section "core/agent-personas/tester.md")
  [ -n "$section" ] || return 1
  echo "$section" | grep -q "NEVER use.*run_in_background.*true.*for test execution" || return 1
}

# 条件4: テスト出力を確認してから Red/Green 判定を行う指示が含まれること
check_tester_has_verify_output_instruction() {
  section=$(extract_test_execution_rule_section "core/agent-personas/tester.md")
  [ -n "$section" ] || return 1
  echo "$section" | grep -qi "verify the test output before making any Red/Green judgment" || return 1
}

# 条件5a: 既存の「Test Writing Rules」セクションが維持されていること
check_tester_has_test_writing_rules() {
  grep -q "^## Test Writing Rules$" "core/agent-personas/tester.md" || return 1
}

# 条件5b: 既存の「Per-Test TDD Cycle」セクションが維持されていること
check_tester_has_per_test_tdd_cycle() {
  grep -q "^## Per-Test TDD Cycle$" "core/agent-personas/tester.md" || return 1
}

Describe 'tester.md テスト実行フォアグラウンドルール — セクション存在'
  It 'tester.md に「## Test Execution Rule」セクションが存在する'
    When call check_tester_has_test_execution_rule_section
    The status should be success
  End
End

Describe 'tester.md テスト実行フォアグラウンドルール — 必須指示'
  It 'フォアグラウンド（同期）実行の指示が含まれる'
    When call check_tester_has_foreground_instruction
    The status should be success
  End

  It 'run_in_background 禁止の指示が含まれる'
    When call check_tester_has_run_in_background_prohibition
    The status should be success
  End

  It 'テスト出力を確認してから Red/Green 判定を行う指示が含まれる'
    When call check_tester_has_verify_output_instruction
    The status should be success
  End
End

Describe 'tester.md テスト実行フォアグラウンドルール — 既存セクション維持'
  It '既存の「Test Writing Rules」セクションが維持されている'
    When call check_tester_has_test_writing_rules
    The status should be success
  End

  It '既存の「Per-Test TDD Cycle」セクションが維持されている'
    When call check_tester_has_per_test_tdd_cycle
    The status should be success
  End
End

## テスト: implementer.md にテスト実行フォアグラウンドルールが定義されていること
## ストーリー: 0049-subagent-test-foreground / タスク 2

# 条件1: implementer.md に「## Test Execution Rule」セクションが存在すること
check_implementer_has_test_execution_rule_section() {
  grep -q "^## Test Execution Rule$" "core/agent-personas/implementer.md" || return 1
}

# 条件2a: フォアグラウンド（同期）実行の指示が含まれること
check_implementer_has_foreground_instruction() {
  section=$(extract_test_execution_rule_section "core/agent-personas/implementer.md")
  [ -n "$section" ] || return 1
  echo "$section" | grep -qi "ALWAYS run test commands.*foreground.*(synchronously)" || return 1
}

# 条件2b: run_in_background 禁止の指示が含まれること
check_implementer_has_run_in_background_prohibition() {
  section=$(extract_test_execution_rule_section "core/agent-personas/implementer.md")
  [ -n "$section" ] || return 1
  echo "$section" | grep -q "NEVER use.*run_in_background.*true.*for test execution" || return 1
}

# 条件2c: テスト出力を確認してから Red/Green 判定を行う指示が含まれること
check_implementer_has_verify_output_instruction() {
  section=$(extract_test_execution_rule_section "core/agent-personas/implementer.md")
  [ -n "$section" ] || return 1
  echo "$section" | grep -qi "verify the test output before making any Red/Green judgment" || return 1
}

# 条件3: 既存の「Implementation Rules」セクションが維持されていること
check_implementer_has_implementation_rules() {
  grep -q "^## Implementation Rules$" "core/agent-personas/implementer.md" || return 1
}

Describe 'implementer.md テスト実行フォアグラウンドルール — セクション存在'
  It 'implementer.md に「## Test Execution Rule」セクションが存在する'
    When call check_implementer_has_test_execution_rule_section
    The status should be success
  End
End

Describe 'implementer.md テスト実行フォアグラウンドルール — 必須指示'
  It 'フォアグラウンド（同期）実行の指示が含まれる'
    When call check_implementer_has_foreground_instruction
    The status should be success
  End

  It 'run_in_background 禁止の指示が含まれる'
    When call check_implementer_has_run_in_background_prohibition
    The status should be success
  End

  It 'テスト出力を確認してから Red/Green 判定を行う指示が含まれる'
    When call check_implementer_has_verify_output_instruction
    The status should be success
  End
End

Describe 'implementer.md テスト実行フォアグラウンドルール — 既存セクション維持'
  It '既存の「Implementation Rules」セクションが維持されている'
    When call check_implementer_has_implementation_rules
    The status should be success
  End
End
