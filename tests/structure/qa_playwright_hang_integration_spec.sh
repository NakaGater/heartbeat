# qa-playwright-hang story integration verification (AC1-AC3)
# Cross-cutting integration test verifying individual T1-T3 tests

QA_AGENT="adapters/claude-code/agents/qa.agent.md"
MCP_JSON=".mcp.json"
QA_PERSONA="core/agent-personas/qa.md"

Describe 'qa-playwright-hang Integration Verification: All ACs'

  Describe 'AC1: .mcp.json Headless Mode Configuration'
    It 'Playwright MCP args contain the --headless flag'
      When run jq -e '.mcpServers.playwright.args | index("--headless")' "$MCP_JSON"
      The output should not be blank
      The status should be success
    End
  End

  Describe 'AC2: QA Persona Fallback and Timeout Guidance'
    It 'timeout guidance (30 seconds) is documented'
      When call grep -q '30.*second\|30 seconds\|30秒' "$QA_PERSONA"
      The status should be success
    End

    It 'graduated fallback strategy is defined (Fallback Strategy section)'
      When call grep -q 'Fallback Strategy' "$QA_PERSONA"
      The status should be success
    End

    It 'browser_close mandatory call instruction is included in verification steps'
      When call grep -q 'browser_close' "$QA_PERSONA"
      The status should be success
    End
  End

  Describe 'AC3: qa.agent.md allowed-tools Prefix'
    It 'allowed-tools contains the correct prefix mcp__plugin_heartbeat_playwright__'
      When call grep -q 'mcp__plugin_heartbeat_playwright__' "$QA_AGENT"
      The status should be success
    End
  End

  Describe 'Three-file Consistency: All Modified Files Exist and Are Accessible'
    It '.mcp.json exists'
      The file "$MCP_JSON" should be exist
    End

    It 'qa.agent.md exists'
      The file "$QA_AGENT" should be exist
    End

    It 'core/agent-personas/qa.md exists'
      The file "$QA_PERSONA" should be exist
    End
  End
End
