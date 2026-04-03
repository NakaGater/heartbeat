QA_PERSONA="core/agent-personas/qa.md"

# タイムアウト目安（30秒）が記載されていることを検証
check_timeout_guidance() {
  grep -q '30' "$QA_PERSONA" && grep -iq 'timeout' "$QA_PERSONA"
}

# 段階的フォールバック戦略（retry / static / skip）が定義されていることを検証
check_fallback_strategy() {
  grep -iq 'fallback' "$QA_PERSONA" \
    && grep -iq 'retry' "$QA_PERSONA" \
    && grep -iq 'static' "$QA_PERSONA" \
    && grep -iq 'skip' "$QA_PERSONA"
}

# browser_close の必須呼び出し指示が含まれていることを検証
check_browser_close_instruction() {
  grep -q 'browser_close' "$QA_PERSONA"
}

Describe 'QA persona: Playwright MCPタイムアウト・フォールバックガイダンス'
  It 'タイムアウト目安（30秒）が記載されている'
    When call check_timeout_guidance
    The status should be success
  End

  It '段階的フォールバック戦略（retry / static / skip）が定義されている'
    When call check_fallback_strategy
    The status should be success
  End

  It 'browser_close の必須呼び出し指示が含まれている'
    When call check_browser_close_instruction
    The status should be success
  End
End
