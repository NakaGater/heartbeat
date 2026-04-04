Describe 'lib/commit-message.sh の分離 (AC-4)'
  # Task 4, CC1: core/scripts/lib/commit-message.sh が存在し source で読み込み可能
  # Task 4, CC3: auto-commit.sh が source で lib/commit-message.sh を読み込んでいる
  # Task 4, CC4-CC5: 主要関数が lib/commit-message.sh に定義されている

  Describe 'CC1: lib/commit-message.sh の存在と source 可能性'
    It 'core/scripts/lib/commit-message.sh が存在する'
      Path commit_message_lib="./core/scripts/lib/commit-message.sh"
      The path commit_message_lib should be exist
    End

    It 'source で読み込んでも構文エラーが発生しない'
      When run bash -c 'source ./core/scripts/lib/common.sh && source ./core/scripts/lib/commit-message.sh'
      The status should be success
    End
  End

  Describe 'CC2: 主要関数の利用可能性'
    It 'generate_commit_message (= format_commit_message) が利用可能になる'
      When run bash -c 'source ./core/scripts/lib/common.sh && source ./core/scripts/lib/commit-message.sh && type format_commit_message >/dev/null 2>&1 && echo "available"'
      The output should equal "available"
      The status should be success
    End

    It 'get_agent_name が利用可能になる'
      When run bash -c 'source ./core/scripts/lib/common.sh && source ./core/scripts/lib/commit-message.sh && type get_agent_name >/dev/null 2>&1 && echo "available"'
      The output should equal "available"
      The status should be success
    End

    It 'map_agent_to_type が利用可能になる'
      When run bash -c 'source ./core/scripts/lib/common.sh && source ./core/scripts/lib/commit-message.sh && type map_agent_to_type >/dev/null 2>&1 && echo "available"'
      The output should equal "available"
      The status should be success
    End
  End

  Describe 'CC3: auto-commit.sh が lib/commit-message.sh を source している'
    It 'auto-commit.sh に lib/commit-message.sh の source 行が存在する'
      When run bash -c 'grep -q "source.*lib/commit-message.sh" ./core/scripts/auto-commit.sh && echo "found"'
      The output should equal "found"
      The status should be success
    End
  End
End
