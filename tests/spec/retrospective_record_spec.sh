Include "$SHELLSPEC_PROJECT_ROOT/tests/helpers/common.sh"

Describe 'retrospective-record.sh'
  BeforeEach 'setup_retro_env'
  AfterEach 'cleanup_retro_env'

  Describe 'Normal cases'
    It 'appends valid JSON to JSONL'
      Data '{"agent":"tester","xp_check":{"simplicity":"green"}}'
      When call ./core/scripts/retrospective-record.sh
      The status should be success
      The contents of file "$HEARTBEAT_RETRO_LOG" should include '"agent":"tester"'
    End

    It 'auto-adds timestamp'
      Data '{"agent":"implementer"}'
      When call ./core/scripts/retrospective-record.sh
      The contents of file "$HEARTBEAT_RETRO_LOG" should include '"timestamp"'
    End
  End

  Describe 'Error cases'
    It 'rejects invalid JSON with exit 1'
      Data 'this is not json'
      When run ./core/scripts/retrospective-record.sh
      The status should be failure
      The stderr should include 'invalid JSON'
    End

    It 'rejects empty input'
      Data ''
      When run ./core/scripts/retrospective-record.sh
      The status should be failure
      The stderr should include 'empty input'
    End

    It 'rejects JSON without agent field'
      Data '{"foo":"bar"}'
      When run ./core/scripts/retrospective-record.sh
      The status should be failure
      The stderr should include 'agent field required'
    End
  End
End
