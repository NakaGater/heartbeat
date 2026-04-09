Describe 'lib/commit-message.sh Extraction (AC-4)'
  # Task 4, CC1: core/scripts/lib/commit-message.sh が存在し source で読み込み可能
  # Task 4, CC3: auto-commit.sh が source で lib/commit-message.sh を読み込んでいる
  # Task 4, CC4-CC5: 主要関数が lib/commit-message.sh に定義されている

  Describe 'CC1: lib/commit-message.sh Existence and Sourceability'
    It 'verifies that core/scripts/lib/commit-message.sh exists'
      Path commit_message_lib="./core/scripts/lib/commit-message.sh"
      The path commit_message_lib should be exist
    End

    It 'loads via source without syntax errors'
      When run bash -c 'source ./core/scripts/lib/common.sh && source ./core/scripts/lib/commit-message.sh'
      The status should be success
    End
  End

  Describe 'CC2: Key Function Availability'
    It 'makes generate_commit_message (= format_commit_message) available'
      When run bash -c 'source ./core/scripts/lib/common.sh && source ./core/scripts/lib/commit-message.sh && type format_commit_message >/dev/null 2>&1 && echo "available"'
      The output should equal "available"
      The status should be success
    End

    It 'makes get_agent_name available'
      When run bash -c 'source ./core/scripts/lib/common.sh && source ./core/scripts/lib/commit-message.sh && type get_agent_name >/dev/null 2>&1 && echo "available"'
      The output should equal "available"
      The status should be success
    End

    It 'makes map_agent_to_type available'
      When run bash -c 'source ./core/scripts/lib/common.sh && source ./core/scripts/lib/commit-message.sh && type map_agent_to_type >/dev/null 2>&1 && echo "available"'
      The output should equal "available"
      The status should be success
    End
  End

  Describe 'CC3: auto-commit.sh Sources lib/commit-message.sh'
    It 'contains a source line for lib/commit-message.sh in auto-commit.sh'
      When run bash -c 'grep -q "source.*lib/commit-message.sh" ./core/scripts/auto-commit.sh && echo "found"'
      The output should equal "found"
      The status should be success
    End
  End
End
