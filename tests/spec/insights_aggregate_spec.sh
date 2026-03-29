Include "$SHELLSPEC_PROJECT_ROOT/tests/helpers/common.sh"

Describe 'insights-aggregate.sh'
  BeforeEach 'setup_retro_env'
  AfterEach 'cleanup_retro_env'

  Describe 'Normal cases'
    It 'generates insights markdown from retrospective log'
      echo '{"agent":"tester","xp_check":{"simplicity":{"score":"green","note":"ok"}}}' > "$HEARTBEAT_RETRO_LOG"
      echo '{"agent":"implementer","xp_check":{"simplicity":{"score":"yellow","note":"could simplify"}}}' >> "$HEARTBEAT_RETRO_LOG"
      When call ./core/scripts/insights-aggregate.sh
      The status should be success
      The contents of file "$HEARTBEAT_INSIGHTS" should include 'Heartbeat Learning Insights'
    End

    It 'includes generation timestamp'
      echo '{"agent":"tester"}' > "$HEARTBEAT_RETRO_LOG"
      When call ./core/scripts/insights-aggregate.sh
      The status should be success
      The contents of file "$HEARTBEAT_INSIGHTS" should include 'Generated:'
    End

    It 'reports patterns requiring attention for yellow/red scores'
      echo '{"agent":"tester","xp_check":{"simplicity":{"score":"yellow","note":"needs work"}}}' > "$HEARTBEAT_RETRO_LOG"
      When call ./core/scripts/insights-aggregate.sh
      The status should be success
      The contents of file "$HEARTBEAT_INSIGHTS" should include 'Patterns Requiring Attention'
    End

    It 'shows agent trends with retrospective counts'
      echo '{"agent":"tester"}' > "$HEARTBEAT_RETRO_LOG"
      echo '{"agent":"tester"}' >> "$HEARTBEAT_RETRO_LOG"
      echo '{"agent":"implementer"}' >> "$HEARTBEAT_RETRO_LOG"
      When call ./core/scripts/insights-aggregate.sh
      The status should be success
      The contents of file "$HEARTBEAT_INSIGHTS" should include 'Agent Trends'
      The contents of file "$HEARTBEAT_INSIGHTS" should include 'tester'
    End
  End

  Describe 'Error cases'
    It 'fails when no retrospective log exists'
      rm -f "$HEARTBEAT_RETRO_LOG"
      When run ./core/scripts/insights-aggregate.sh
      The status should be failure
      The stderr should include 'No retrospective log found'
    End
  End
End
