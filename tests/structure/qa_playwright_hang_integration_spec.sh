# qa-playwright-hang ストーリー統合検証 (AC1-AC3)
# T1-T3の個別テストを横断的に検証する統合テスト

QA_AGENT="adapters/claude-code/agents/qa.agent.md"
MCP_JSON=".mcp.json"
QA_PERSONA="core/agent-personas/qa.md"

Describe 'qa-playwright-hang 統合検証: 全AC横断確認'

  Describe 'AC1: .mcp.json ヘッドレスモード設定'
    It 'Playwright MCP の args に --headless フラグが含まれている'
      When run jq -e '.mcpServers.playwright.args | index("--headless")' "$MCP_JSON"
      The output should not be blank
      The status should be success
    End
  End

  Describe 'AC2: QA ペルソナのフォールバック・タイムアウトガイダンス'
    It 'タイムアウト目安（30秒）が記載されている'
      When call grep -q '30.*second\|30 seconds\|30秒' "$QA_PERSONA"
      The status should be success
    End

    It '段階的フォールバック戦略が定義されている（Fallback Strategy セクション）'
      When call grep -q 'Fallback Strategy' "$QA_PERSONA"
      The status should be success
    End

    It 'browser_close の必須呼び出し指示が検証ステップに含まれている'
      When call grep -q 'browser_close' "$QA_PERSONA"
      The status should be success
    End
  End

  Describe 'AC3: qa.agent.md の allowed-tools プレフィックス'
    It 'allowed-tools に正しいプレフィックス mcp__plugin_heartbeat_playwright__ が含まれている'
      When call grep -q 'mcp__plugin_heartbeat_playwright__' "$QA_AGENT"
      The status should be success
    End
  End

  Describe '3ファイル整合性: 全変更対象が存在しアクセス可能'
    It '.mcp.json が存在する'
      The file "$MCP_JSON" should be exist
    End

    It 'qa.agent.md が存在する'
      The file "$QA_AGENT" should be exist
    End

    It 'core/agent-personas/qa.md が存在する'
      The file "$QA_PERSONA" should be exist
    End
  End
End
