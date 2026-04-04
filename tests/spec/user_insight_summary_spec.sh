Describe 'user-insight-summary.sh UCD 4層横断Markdownサマリー生成'
  SCRIPT="core/scripts/user-insight-summary.sh"

  setup() {
    TEST_DIR=$(mktemp -d)
    export TEST_INSIGHTS_DIR="${TEST_DIR}/insights"
    mkdir -p "$TEST_INSIGHTS_DIR"
  }
  cleanup() {
    rm -rf "$TEST_DIR"
  }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  # --- テストデータ生成ヘルパー ---
  create_full_test_data() {
    # Raw層
    echo '{"id":"RAW-001","source_type":"interview","source_ref":"interview_A.md","title":"ユーザーAインタビュー","excerpt":"検索機能についての聞き取り","participant_count":1,"created_by":"insight-analyst","timestamp":"2026-04-04T10:00:00Z"}' >> "${TEST_INSIGHTS_DIR}/raw.jsonl"
    echo '{"id":"RAW-002","source_type":"survey","source_ref":"survey_results.md","title":"アンケート結果","excerpt":"検索機能の利用状況調査","participant_count":10,"created_by":"insight-analyst","timestamp":"2026-04-04T10:01:00Z"}' >> "${TEST_INSIGHTS_DIR}/raw.jsonl"

    # Findings層
    echo '{"id":"FND-001","source_raw":"RAW-001","type":"statement","content":"詳細検索を使わないと発言","participant":"ユーザーA","context":"検索機能の質問時","created_by":"insight-analyst","timestamp":"2026-04-04T10:10:00Z"}' >> "${TEST_INSIGHTS_DIR}/findings.jsonl"
    echo '{"id":"FND-002","source_raw":"RAW-001","type":"behavior","content":"全文検索のみ利用","participant":"ユーザーA","context":"操作観察時","created_by":"insight-analyst","timestamp":"2026-04-04T10:11:00Z"}' >> "${TEST_INSIGHTS_DIR}/findings.jsonl"
    echo '{"id":"FND-003","source_raw":"RAW-002","type":"statement","content":"8割が詳細検索を使わないと回答","participant":"","context":"アンケート集計","created_by":"insight-analyst","timestamp":"2026-04-04T10:12:00Z"}' >> "${TEST_INSIGHTS_DIR}/findings.jsonl"

    # Insights層
    echo '{"id":"INS-001","source_findings":["FND-001","FND-002","FND-003"],"category":"pain","theme":"検索機能の複雑さ","insight":"ユーザーは詳細検索よりシンプルな全文検索を好む","evidence_summary":"複数ユーザーが詳細検索を使わないと回答","severity":"high","confidence":"high","created_by":"insight-analyst","timestamp":"2026-04-04T10:20:00Z"}' >> "${TEST_INSIGHTS_DIR}/insights.jsonl"
    echo '{"id":"INS-002","source_findings":["FND-002"],"category":"need","theme":"検索結果の即時性","insight":"検索結果が即座に表示されることを期待している","evidence_summary":"操作中に待機を嫌う行動が観察された","severity":"medium","confidence":"medium","created_by":"insight-analyst","timestamp":"2026-04-04T10:21:00Z"}' >> "${TEST_INSIGHTS_DIR}/insights.jsonl"

    # Opportunities層
    echo '{"id":"OPP-001","source_insights":["INS-001","INS-002"],"title":"検索体験の簡素化","description":"詳細検索を廃止し高精度な全文検索に一本化","impact":"high","effort":"medium","related_stories":[],"created_by":"insight-analyst","timestamp":"2026-04-04T10:30:00Z"}' >> "${TEST_INSIGHTS_DIR}/opportunities.jsonl"
    echo '{"id":"OPP-002","source_insights":["INS-002"],"title":"検索速度の改善","description":"検索応答時間を500ms以内に短縮","impact":"low","effort":"high","related_stories":[],"created_by":"insight-analyst","timestamp":"2026-04-04T10:31:00Z"}' >> "${TEST_INSIGHTS_DIR}/opportunities.jsonl"
  }

  Describe 'スクリプト基本要件'
    It 'スクリプトファイルが存在すること'
      The file "$SCRIPT" should be exist
    End

    It 'スクリプトに実行権限があること'
      The file "$SCRIPT" should be executable
    End
  End

  Describe 'サマリー生成: 正常系'
    It '4層のJSONLからsummary.mdが生成されること'
      create_full_test_data
      When run bash "$SCRIPT" "$TEST_INSIGHTS_DIR"
      The status should be success
      The file "${TEST_INSIGHTS_DIR}/summary.md" should be exist
    End

    It 'サマリーにタイトル見出しが含まれること'
      run_and_check_title() {
        create_full_test_data
        bash "$SCRIPT" "$TEST_INSIGHTS_DIR" && \
        grep -q '# ユーザーインサイト分析サマリー' "${TEST_INSIGHTS_DIR}/summary.md"
      }
      When call run_and_check_title
      The status should be success
    End

    It '概要セクションに各層のエントリ数が含まれること'
      run_and_check_counts() {
        create_full_test_data
        bash "$SCRIPT" "$TEST_INSIGHTS_DIR" && \
        grep -q 'Raw' "${TEST_INSIGHTS_DIR}/summary.md" && \
        grep -q '2' "${TEST_INSIGHTS_DIR}/summary.md" && \
        grep -q 'Findings' "${TEST_INSIGHTS_DIR}/summary.md" && \
        grep -q '3' "${TEST_INSIGHTS_DIR}/summary.md" && \
        grep -q 'Insights' "${TEST_INSIGHTS_DIR}/summary.md" && \
        grep -q 'Opportunities' "${TEST_INSIGHTS_DIR}/summary.md"
      }
      When call run_and_check_counts
      The status should be success
    End

    It 'インサイトカテゴリ別集計セクションが含まれること'
      run_and_check_category() {
        create_full_test_data
        bash "$SCRIPT" "$TEST_INSIGHTS_DIR" && \
        grep -q 'カテゴリ別集計' "${TEST_INSIGHTS_DIR}/summary.md" && \
        grep -q 'pain' "${TEST_INSIGHTS_DIR}/summary.md" && \
        grep -q 'need' "${TEST_INSIGHTS_DIR}/summary.md"
      }
      When call run_and_check_category
      The status should be success
    End

    It 'カテゴリ別集計にseverity内訳が含まれること'
      run_and_check_severity() {
        create_full_test_data
        bash "$SCRIPT" "$TEST_INSIGHTS_DIR" && \
        grep -q 'high' "${TEST_INSIGHTS_DIR}/summary.md" && \
        grep -q 'medium' "${TEST_INSIGHTS_DIR}/summary.md"
      }
      When call run_and_check_severity
      The status should be success
    End
  End

  Describe '主要な改善機会セクション'
    It 'impact:high のOpportunitiesが「主要な改善機会」セクションに含まれること'
      run_and_check_high_impact() {
        create_full_test_data
        bash "$SCRIPT" "$TEST_INSIGHTS_DIR" && \
        grep -q '主要な改善機会' "${TEST_INSIGHTS_DIR}/summary.md" && \
        grep -q '検索体験の簡素化' "${TEST_INSIGHTS_DIR}/summary.md"
      }
      When call run_and_check_high_impact
      The status should be success
    End

    It 'impact:low のOpportunitiesが「主要な改善機会」セクションに含まれないこと'
      run_and_check_low_excluded() {
        create_full_test_data
        bash "$SCRIPT" "$TEST_INSIGHTS_DIR" && \
        section=$(sed -n '/主要な改善機会/,/^## /p' "${TEST_INSIGHTS_DIR}/summary.md") && \
        ! echo "$section" | grep -q '検索速度の改善'
      }
      When call run_and_check_low_excluded
      The status should be success
    End
  End

  Describe 'トレーサビリティ'
    It 'トレーサビリティセクションにOpportunityの根拠チェーンが含まれること'
      run_and_check_trace() {
        create_full_test_data
        bash "$SCRIPT" "$TEST_INSIGHTS_DIR" && \
        grep -q 'トレーサビリティ' "${TEST_INSIGHTS_DIR}/summary.md" && \
        grep -q 'OPP-001' "${TEST_INSIGHTS_DIR}/summary.md" && \
        grep -q 'INS-001' "${TEST_INSIGHTS_DIR}/summary.md" && \
        grep -q 'FND-001' "${TEST_INSIGHTS_DIR}/summary.md" && \
        grep -q 'RAW-001' "${TEST_INSIGHTS_DIR}/summary.md"
      }
      When call run_and_check_trace
      The status should be success
    End
  End

  Describe '空ファイル・欠損ファイルの処理'
    It '全てのJSONLが存在しない場合でもエラーにならず空サマリーが生成されること'
      run_and_check_empty() {
        rm -f "${TEST_INSIGHTS_DIR}"/*.jsonl
        bash "$SCRIPT" "$TEST_INSIGHTS_DIR" && \
        [ -f "${TEST_INSIGHTS_DIR}/summary.md" ]
      }
      When call run_and_check_empty
      The status should be success
    End

    It '空のJSONLファイルがある場合でもエラーにならないこと'
      run_and_check_empty_files() {
        touch "${TEST_INSIGHTS_DIR}/raw.jsonl"
        touch "${TEST_INSIGHTS_DIR}/findings.jsonl"
        touch "${TEST_INSIGHTS_DIR}/insights.jsonl"
        touch "${TEST_INSIGHTS_DIR}/opportunities.jsonl"
        bash "$SCRIPT" "$TEST_INSIGHTS_DIR" && \
        [ -f "${TEST_INSIGHTS_DIR}/summary.md" ]
      }
      When call run_and_check_empty_files
      The status should be success
    End

    It '一部の層のみにデータがある場合でもエラーにならないこと'
      run_and_check_partial() {
        echo '{"id":"RAW-001","source_type":"interview","source_ref":"file.md","title":"テスト","excerpt":"要約","created_by":"insight-analyst","timestamp":"2026-04-04T10:00:00Z"}' > "${TEST_INSIGHTS_DIR}/raw.jsonl"
        bash "$SCRIPT" "$TEST_INSIGHTS_DIR" && \
        [ -f "${TEST_INSIGHTS_DIR}/summary.md" ]
      }
      When call run_and_check_partial
      The status should be success
    End
  End
End
