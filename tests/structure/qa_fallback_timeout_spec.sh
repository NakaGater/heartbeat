QA_PERSONA="core/agent-personas/qa.md"

# Verify timeout guidance (30 seconds) is documented
check_timeout_guidance() {
  grep -q '30' "$QA_PERSONA" && grep -iq 'timeout' "$QA_PERSONA"
}

# Verify graduated fallback strategy (retry / static / skip) is defined
check_fallback_strategy() {
  grep -iq 'fallback' "$QA_PERSONA" \
    && grep -iq 'retry' "$QA_PERSONA" \
    && grep -iq 'static' "$QA_PERSONA" \
    && grep -iq 'skip' "$QA_PERSONA"
}

# Verify browser_close mandatory call instruction is included
check_browser_close_instruction() {
  grep -q 'browser_close' "$QA_PERSONA"
}

Describe 'QA Persona: Playwright MCP Timeout and Fallback Guidance'
  It 'timeout guidance (30 seconds) is documented'
    When call check_timeout_guidance
    The status should be success
  End

  It 'graduated fallback strategy (retry / static / skip) is defined'
    When call check_fallback_strategy
    The status should be success
  End

  It 'browser_close mandatory call instruction is included'
    When call check_browser_close_instruction
    The status should be success
  End
End
