Describe 'find_board_jsonl() in lib/common.sh'
  # Task 2, CC1: find_board_jsonl function is defined in core/scripts/lib/common.sh,
  #              can be sourced without syntax errors
  # Task 2, CC2-CC4: Environment variable fallback chain
  # Design spec 8-9: story-id argument and HEARTBEAT_ACTIVE_STORY

  setup() {
    TEST_DIR=$(mktemp -d)
    mkdir -p "$TEST_DIR/.heartbeat/stories/0099-test-story"
    echo '{"from":"tester","timestamp":"2026-01-01T00:00:00Z"}' \
      > "$TEST_DIR/.heartbeat/stories/0099-test-story/board.jsonl"
  }
  cleanup() {
    rm -rf "$TEST_DIR"
  }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'Sourceability (CC1)'
    It 'loads via source without syntax errors'
      When run source ./core/scripts/lib/common.sh
      The status should be success
    End

    It 'makes find_board_jsonl function available'
      # Verify find_board_jsonl function is available via type check
      When run bash -c 'source ./core/scripts/lib/common.sh && type find_board_jsonl >/dev/null 2>&1 && echo "available"'
      The output should equal "available"
      The status should be success
    End
  End

  Describe 'When HEARTBEAT_ROOT Is Set (CC2)'
    It 'returns board.jsonl path under HEARTBEAT_ROOT'
      When run bash -c "source ./core/scripts/lib/common.sh && HEARTBEAT_ROOT='$TEST_DIR' find_board_jsonl '0099-test-story'"
      The output should equal "${TEST_DIR}/.heartbeat/stories/0099-test-story/board.jsonl"
      The status should be success
    End
  End

  Describe 'CLAUDE_PROJECT_DIR Fallback (CC3)'
    It 'returns board.jsonl under CLAUDE_PROJECT_DIR when HEARTBEAT_ROOT is unset'
      When run bash -c "unset HEARTBEAT_ROOT; source ./core/scripts/lib/common.sh && CLAUDE_PROJECT_DIR='$TEST_DIR' find_board_jsonl '0099-test-story'"
      The output should equal "${TEST_DIR}/.heartbeat/stories/0099-test-story/board.jsonl"
      The status should be success
    End
  End

  Describe 'Fallback When Both Are Unset (CC4)'
    It 'returns board.jsonl under the current directory'
      When run bash -c "unset HEARTBEAT_ROOT; unset CLAUDE_PROJECT_DIR; cd '$TEST_DIR' && source '$PWD/core/scripts/lib/common.sh' && find_board_jsonl '0099-test-story'"
      The output should include "0099-test-story/board.jsonl"
      The status should be success
    End
  End

  Describe 'HEARTBEAT_ACTIVE_STORY Fallback (Design Spec 9)'
    It 'uses HEARTBEAT_ACTIVE_STORY story-id when no argument is given'
      When run bash -c "source ./core/scripts/lib/common.sh && HEARTBEAT_ROOT='$TEST_DIR' HEARTBEAT_ACTIVE_STORY='0099-test-story' find_board_jsonl"
      The output should equal "${TEST_DIR}/.heartbeat/stories/0099-test-story/board.jsonl"
      The status should be success
    End
  End

  Describe 'Non-existent Story ID (Design Spec 8)'
    It 'returns an empty string for a non-existent story-id'
      When run bash -c "source ./core/scripts/lib/common.sh && HEARTBEAT_ROOT='$TEST_DIR' find_board_jsonl '9999-nonexistent'"
      The output should equal ""
      The status should be success
    End
  End
End
