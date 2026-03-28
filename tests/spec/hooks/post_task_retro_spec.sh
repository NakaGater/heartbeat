Describe 'Post-task retrospective hook integration'
  setup() {
    export HEARTBEAT_RETRO_LOG=$(mktemp)
    export HEARTBEAT_INSIGHTS=$(mktemp)
  }
  cleanup() {
    rm -f "$HEARTBEAT_RETRO_LOG" "$HEARTBEAT_INSIGHTS"
  }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'End-to-end retrospective flow'
    It 'records a retrospective and then aggregates insights'
      # Step 1: Record a retrospective entry
      Data '{"agent":"tester","xp_check":{"simplicity":{"score":"green","note":"ok"}}}'
      When call ./core/scripts/retrospective-record.sh
      The status should be success
      The contents of file "$HEARTBEAT_RETRO_LOG" should include '"agent":"tester"'
    End

    It 'aggregates insights after multiple retrospectives are recorded'
      # Record multiple entries
      echo '{"agent":"tester","xp_check":{"simplicity":{"score":"green","note":"ok"}},"timestamp":"2026-03-28T10:00:00Z"}' > "$HEARTBEAT_RETRO_LOG"
      echo '{"agent":"implementer","xp_check":{"feedback":{"score":"yellow","note":"edge cases missed"}},"timestamp":"2026-03-28T11:00:00Z"}' >> "$HEARTBEAT_RETRO_LOG"

      # Step 2: Aggregate insights
      When call ./core/scripts/insights-aggregate.sh
      The status should be success
      The contents of file "$HEARTBEAT_INSIGHTS" should include 'Heartbeat Learning Insights'
      The contents of file "$HEARTBEAT_INSIGHTS" should include 'Agent Trends'
    End
  End
End
