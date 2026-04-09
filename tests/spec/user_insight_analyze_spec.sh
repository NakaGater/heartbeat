Describe 'user-insight-analyze.sh UCD 4-layer JSONL Operation Script'
  SCRIPT="core/scripts/user-insight-analyze.sh"

  setup() {
    TEST_DIR=$(mktemp -d)
    export TEST_INSIGHTS_DIR="${TEST_DIR}/insights"
  }
  cleanup() {
    rm -rf "$TEST_DIR"
  }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'Script Basic Requirements'
    It 'verifies that the script file exists'
      The file "$SCRIPT" should be exist
    End

    It 'verifies that the script has execute permission'
      The file "$SCRIPT" should be executable
    End

    It 'displays usage information with --help option'
      When run bash "$SCRIPT" --help
      The status should be success
      The output should include 'Usage'
    End

    It 'exits with error when run without arguments'
      When run bash "$SCRIPT"
      The status should be failure
      The stderr should not equal ""
    End

    It 'exits with error for invalid layer name'
      When run bash "$SCRIPT" invalid_layer '{"source_type":"interview"}' "$TEST_INSIGHTS_DIR"
      The status should be failure
      The stderr should not equal ""
    End
  End

  Describe 'Raw Layer: Appending Entries to raw.jsonl From Text File Input'
    It 'appends a valid JSON entry to the raw layer'
      json_entry='{"source_type":"interview","source_ref":"test_interview.md","title":"テストインタビュー","excerpt":"テスト用の要約"}'
      When run bash "$SCRIPT" raw "$json_entry" "$TEST_INSIGHTS_DIR"
      The status should be success
      The file "${TEST_INSIGHTS_DIR}/raw.jsonl" should be exist
    End

    It 'auto-assigns RAW-NNN format IDs to raw layer entries'
      json_entry='{"source_type":"interview","source_ref":"test_interview.md","title":"テストインタビュー","excerpt":"テスト用の要約"}'
      run_and_check_id() {
        bash "$SCRIPT" raw "$json_entry" "$TEST_INSIGHTS_DIR" && \
        jq -r '.id' "${TEST_INSIGHTS_DIR}/raw.jsonl" | grep -qE '^RAW-[0-9]{3}$'
      }
      When call run_and_check_id
      The status should be success
    End

    It 'assigns RAW-001 as the first entry ID'
      json_entry='{"source_type":"interview","source_ref":"test_interview.md","title":"テストインタビュー","excerpt":"テスト用の要約"}'
      run_and_get_id() {
        bash "$SCRIPT" raw "$json_entry" "$TEST_INSIGHTS_DIR" && \
        jq -r '.id' "${TEST_INSIGHTS_DIR}/raw.jsonl"
      }
      When call run_and_get_id
      The output should equal "RAW-001"
    End

    It 'assigns UTC ISO 8601 timestamp to raw layer entries'
      json_entry='{"source_type":"interview","source_ref":"test_interview.md","title":"テストインタビュー","excerpt":"テスト用の要約"}'
      run_and_check_timestamp() {
        bash "$SCRIPT" raw "$json_entry" "$TEST_INSIGHTS_DIR" && \
        jq -r '.timestamp' "${TEST_INSIGHTS_DIR}/raw.jsonl" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$'
      }
      When call run_and_check_timestamp
      The status should be success
    End

    It 'auto-creates insights directory when it does not exist'
      json_entry='{"source_type":"interview","source_ref":"test_interview.md","title":"テストインタビュー","excerpt":"テスト用の要約"}'
      run_and_check_dir() {
        bash "$SCRIPT" raw "$json_entry" "$TEST_INSIGHTS_DIR" && \
        [ -d "$TEST_INSIGHTS_DIR" ]
      }
      When call run_and_check_dir
      The status should be success
    End

    It 'reads JSON entry from stdin (pipeline support)'
      json_entry='{"source_type":"survey","source_ref":"survey_results.md","title":"アンケート結果","excerpt":"テスト用の要約"}'
      run_stdin() {
        echo "$json_entry" | bash "$SCRIPT" raw - "$TEST_INSIGHTS_DIR" && \
        jq -r '.source_type' "${TEST_INSIGHTS_DIR}/raw.jsonl"
      }
      When call run_stdin
      The output should equal "survey"
    End

    It 'does not duplicate IDs when existing entries are present'
      json_entry1='{"source_type":"interview","source_ref":"file1.md","title":"インタビュー1","excerpt":"要約1"}'
      json_entry2='{"source_type":"survey","source_ref":"file2.md","title":"アンケート2","excerpt":"要約2"}'
      run_and_check_no_dup() {
        bash "$SCRIPT" raw "$json_entry1" "$TEST_INSIGHTS_DIR" && \
        bash "$SCRIPT" raw "$json_entry2" "$TEST_INSIGHTS_DIR" && \
        id1=$(jq -r '.id' "${TEST_INSIGHTS_DIR}/raw.jsonl" | head -1) && \
        id2=$(jq -r '.id' "${TEST_INSIGHTS_DIR}/raw.jsonl" | tail -1) && \
        [ "$id1" = "RAW-001" ] && [ "$id2" = "RAW-002" ]
      }
      When call run_and_check_no_dup
      The status should be success
    End

    It 'exits with error for invalid JSON'
      When run bash "$SCRIPT" raw "not-valid-json" "$TEST_INSIGHTS_DIR"
      The status should be failure
      The stderr should not equal ""
    End
  End
End
