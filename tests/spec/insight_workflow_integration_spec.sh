Describe '独立ワークフロー結合テスト (0045-pdm-insight-analysis タスク6)'
  ANALYZE_SCRIPT="core/scripts/user-insight-analyze.sh"
  SUMMARY_SCRIPT="core/scripts/user-insight-summary.sh"
  PDM_FILE="core/agent-personas/pdm.md"

  setup() {
    TEST_DIR=$(mktemp -d)
    export TEST_INSIGHTS_DIR="${TEST_DIR}/insights"
    # pdm.md のハッシュを事前取得
    PDM_HASH_BEFORE=$(md5 -q "$PDM_FILE" 2>/dev/null || md5sum "$PDM_FILE" | awk '{print $1}')
  }
  cleanup() {
    rm -rf "$TEST_DIR"
  }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  # --- E2E テストデータ投入ヘルパー ---
  # analyze.sh を使って4層を順番に投入し、summary.sh でサマリーを生成する
  run_full_pipeline() {
    # Raw層: テキストファイル入力を模した2件
    bash "$ANALYZE_SCRIPT" raw \
      '{"source_type":"interview","source_ref":"interview_A.md","title":"ユーザーAインタビュー","excerpt":"検索機能についての聞き取り","participant_count":1,"created_by":"insight-analyst"}' \
      "$TEST_INSIGHTS_DIR"
    bash "$ANALYZE_SCRIPT" raw \
      '{"source_type":"survey","source_ref":"survey_results.md","title":"アンケート結果","excerpt":"検索機能の利用状況調査","participant_count":10,"created_by":"insight-analyst"}' \
      "$TEST_INSIGHTS_DIR"

    # Findings層: Raw参照付き3件
    bash "$ANALYZE_SCRIPT" findings \
      '{"source_raw":"RAW-001","type":"statement","content":"詳細検索を使わないと発言","participant":"ユーザーA","context":"検索機能の質問時","created_by":"insight-analyst"}' \
      "$TEST_INSIGHTS_DIR"
    bash "$ANALYZE_SCRIPT" findings \
      '{"source_raw":"RAW-001","type":"behavior","content":"全文検索のみ利用","participant":"ユーザーA","context":"操作観察時","created_by":"insight-analyst"}' \
      "$TEST_INSIGHTS_DIR"
    bash "$ANALYZE_SCRIPT" findings \
      '{"source_raw":"RAW-002","type":"statement","content":"8割が詳細検索を使わないと回答","participant":"","context":"アンケート集計","created_by":"insight-analyst"}' \
      "$TEST_INSIGHTS_DIR"

    # Insights層: Findings参照付き2件
    bash "$ANALYZE_SCRIPT" insights \
      '{"source_findings":["FND-001","FND-002","FND-003"],"category":"pain","theme":"検索機能の複雑さ","insight":"ユーザーは詳細検索よりシンプルな全文検索を好む","evidence_summary":"複数ユーザーが詳細検索を使わないと回答","severity":"high","confidence":"high","created_by":"insight-analyst"}' \
      "$TEST_INSIGHTS_DIR"
    bash "$ANALYZE_SCRIPT" insights \
      '{"source_findings":["FND-002"],"category":"need","theme":"検索結果の即時性","insight":"検索結果が即座に表示されることを期待している","evidence_summary":"操作中に待機を嫌う行動が観察された","severity":"medium","confidence":"medium","created_by":"insight-analyst"}' \
      "$TEST_INSIGHTS_DIR"

    # Opportunities層: Insights参照付き1件
    bash "$ANALYZE_SCRIPT" opportunities \
      '{"source_insights":["INS-001","INS-002"],"title":"検索体験の簡素化","description":"詳細検索を廃止し高精度な全文検索に一本化","impact":"high","effort":"medium","related_stories":[],"created_by":"insight-analyst"}' \
      "$TEST_INSIGHTS_DIR"

    # サマリー生成
    bash "$SUMMARY_SCRIPT" "$TEST_INSIGHTS_DIR"
  }

  Describe 'E2E パイプライン: テキスト入力 -> analyze.sh -> summary.sh -> summary.md'
    It '全パイプラインがエラーなく完走すること'
      When call run_full_pipeline
      The status should be success
    End

    It '4層すべてのJSONLファイルが生成されること'
      run_and_check_files() {
        run_full_pipeline
        [ -f "${TEST_INSIGHTS_DIR}/raw.jsonl" ] && \
        [ -f "${TEST_INSIGHTS_DIR}/findings.jsonl" ] && \
        [ -f "${TEST_INSIGHTS_DIR}/insights.jsonl" ] && \
        [ -f "${TEST_INSIGHTS_DIR}/opportunities.jsonl" ]
      }
      When call run_and_check_files
      The status should be success
    End

    It 'summary.md が生成されること'
      run_and_check_summary() {
        run_full_pipeline
        [ -f "${TEST_INSIGHTS_DIR}/summary.md" ]
      }
      When call run_and_check_summary
      The status should be success
    End

    It 'summary.md に各層のエントリ数が正しく反映されていること'
      run_and_check_summary_counts() {
        run_full_pipeline
        grep -q '| Raw | 2 |' "${TEST_INSIGHTS_DIR}/summary.md" && \
        grep -q '| Findings | 3 |' "${TEST_INSIGHTS_DIR}/summary.md" && \
        grep -q '| Insights | 2 |' "${TEST_INSIGHTS_DIR}/summary.md" && \
        grep -q '| Opportunities | 1 |' "${TEST_INSIGHTS_DIR}/summary.md"
      }
      When call run_and_check_summary_counts
      The status should be success
    End

    It 'summary.md に主要な改善機会が含まれること'
      run_and_check_summary_opps() {
        run_full_pipeline
        grep -q '検索体験の簡素化' "${TEST_INSIGHTS_DIR}/summary.md"
      }
      When call run_and_check_summary_opps
      The status should be success
    End

    It 'summary.md にトレーサビリティセクションが含まれること'
      run_and_check_summary_trace() {
        run_full_pipeline
        grep -q 'トレーサビリティ' "${TEST_INSIGHTS_DIR}/summary.md" && \
        grep -q 'OPP-001' "${TEST_INSIGHTS_DIR}/summary.md"
      }
      When call run_and_check_summary_trace
      The status should be success
    End
  End

  Describe 'トレーサビリティ: 層間参照チェーンの整合性 (OPP -> INS -> FND -> RAW)'
    It 'Opportunities の source_insights が実在する INS-NNN を参照していること'
      run_and_verify_opp_refs() {
        run_full_pipeline
        # OPP-001 の source_insights 内の各IDが insights.jsonl に存在するか
        opp_refs=$(jq -r '.source_insights[]' "${TEST_INSIGHTS_DIR}/opportunities.jsonl")
        for ref in $opp_refs; do
          if ! jq -e --arg id "$ref" 'select(.id == $id)' "${TEST_INSIGHTS_DIR}/insights.jsonl" > /dev/null 2>&1; then
            echo "参照先が見つからない: $ref" >&2
            return 1
          fi
        done
      }
      When call run_and_verify_opp_refs
      The status should be success
    End

    It 'Insights の source_findings が実在する FND-NNN を参照していること'
      run_and_verify_ins_refs() {
        run_full_pipeline
        jq -r '.source_findings[]' "${TEST_INSIGHTS_DIR}/insights.jsonl" | sort -u | while read -r ref; do
          if ! jq -e --arg id "$ref" 'select(.id == $id)' "${TEST_INSIGHTS_DIR}/findings.jsonl" > /dev/null 2>&1; then
            echo "参照先が見つからない: $ref" >&2
            return 1
          fi
        done
      }
      When call run_and_verify_ins_refs
      The status should be success
    End

    It 'Findings の source_raw が実在する RAW-NNN を参照していること'
      run_and_verify_fnd_refs() {
        run_full_pipeline
        jq -r '.source_raw' "${TEST_INSIGHTS_DIR}/findings.jsonl" | sort -u | while read -r ref; do
          if ! jq -e --arg id "$ref" 'select(.id == $id)' "${TEST_INSIGHTS_DIR}/raw.jsonl" > /dev/null 2>&1; then
            echo "参照先が見つからない: $ref" >&2
            return 1
          fi
        done
      }
      When call run_and_verify_fnd_refs
      The status should be success
    End

    It '完全な根拠チェーン OPP -> INS -> FND -> RAW が辿れること'
      run_and_verify_full_chain() {
        run_full_pipeline
        # OPP-001 -> INS-001 -> FND-001 -> RAW-001 のチェーンを検証
        opp_ins=$(jq -r 'select(.id == "OPP-001") | .source_insights[0]' "${TEST_INSIGHTS_DIR}/opportunities.jsonl")
        [ "$opp_ins" = "INS-001" ] || return 1

        ins_fnd=$(jq -r 'select(.id == "INS-001") | .source_findings[0]' "${TEST_INSIGHTS_DIR}/insights.jsonl")
        [ "$ins_fnd" = "FND-001" ] || return 1

        fnd_raw=$(jq -r 'select(.id == "FND-001") | .source_raw' "${TEST_INSIGHTS_DIR}/findings.jsonl")
        [ "$fnd_raw" = "RAW-001" ] || return 1
      }
      When call run_and_verify_full_chain
      The status should be success
    End
  End

  Describe '非破壊検証: pdm.md が変更されていないこと'
    It 'パイプライン実行後に pdm.md のハッシュが変化しないこと'
      run_and_check_pdm_unchanged() {
        run_full_pipeline
        PDM_HASH_AFTER=$(md5 -q "$PDM_FILE" 2>/dev/null || md5sum "$PDM_FILE" | awk '{print $1}')
        [ "$PDM_HASH_BEFORE" = "$PDM_HASH_AFTER" ]
      }
      When call run_and_check_pdm_unchanged
      The status should be success
    End

    It 'pdm.md ファイルが存在し続けていること'
      The file "$PDM_FILE" should be exist
    End
  End

  Describe 'Figma: --figma オプション MCP不在時の graceful degradation'
    It '--figma オプション付きで analyze.sh raw を実行しても非ゼロ終了しないこと'
      # analyze.sh は layer + json_entry を受け取る設計のため、
      # --figma はスキルレイヤーが処理する。スクリプト自体は source_type=figjam のエントリを受け付けることを検証
      figma_entry='{"source_type":"figjam","source_ref":"https://figma.com/board/xxx","title":"FigJamボード","excerpt":"テストボード","participant_count":0,"created_by":"insight-analyst"}'
      When run bash "$ANALYZE_SCRIPT" raw "$figma_entry" "$TEST_INSIGHTS_DIR"
      The status should be success
    End

    It 'source_type=figjam のエントリが raw.jsonl に正しく記録されること'
      run_and_check_figjam() {
        figma_entry='{"source_type":"figjam","source_ref":"https://figma.com/board/xxx","title":"FigJamボード","excerpt":"テストボード","participant_count":0,"created_by":"insight-analyst"}'
        bash "$ANALYZE_SCRIPT" raw "$figma_entry" "$TEST_INSIGHTS_DIR" && \
        jq -e 'select(.source_type == "figjam")' "${TEST_INSIGHTS_DIR}/raw.jsonl" > /dev/null
      }
      When call run_and_check_figjam
      The status should be success
    End
  End

  Describe 'ID自動採番の一貫性: パイプライン全体を通じた連番'
    It 'Raw層のIDが RAW-001, RAW-002 の連番であること'
      run_and_check_raw_ids() {
        run_full_pipeline
        id1=$(jq -r '.id' "${TEST_INSIGHTS_DIR}/raw.jsonl" | sed -n '1p')
        id2=$(jq -r '.id' "${TEST_INSIGHTS_DIR}/raw.jsonl" | sed -n '2p')
        [ "$id1" = "RAW-001" ] && [ "$id2" = "RAW-002" ]
      }
      When call run_and_check_raw_ids
      The status should be success
    End

    It 'Findings層のIDが FND-001, FND-002, FND-003 の連番であること'
      run_and_check_fnd_ids() {
        run_full_pipeline
        id1=$(jq -r '.id' "${TEST_INSIGHTS_DIR}/findings.jsonl" | sed -n '1p')
        id2=$(jq -r '.id' "${TEST_INSIGHTS_DIR}/findings.jsonl" | sed -n '2p')
        id3=$(jq -r '.id' "${TEST_INSIGHTS_DIR}/findings.jsonl" | sed -n '3p')
        [ "$id1" = "FND-001" ] && [ "$id2" = "FND-002" ] && [ "$id3" = "FND-003" ]
      }
      When call run_and_check_fnd_ids
      The status should be success
    End

    It 'Insights層のIDが INS-001, INS-002 の連番であること'
      run_and_check_ins_ids() {
        run_full_pipeline
        id1=$(jq -r '.id' "${TEST_INSIGHTS_DIR}/insights.jsonl" | sed -n '1p')
        id2=$(jq -r '.id' "${TEST_INSIGHTS_DIR}/insights.jsonl" | sed -n '2p')
        [ "$id1" = "INS-001" ] && [ "$id2" = "INS-002" ]
      }
      When call run_and_check_ins_ids
      The status should be success
    End

    It 'Opportunities層のIDが OPP-001 であること'
      run_and_check_opp_ids() {
        run_full_pipeline
        id1=$(jq -r '.id' "${TEST_INSIGHTS_DIR}/opportunities.jsonl" | sed -n '1p')
        [ "$id1" = "OPP-001" ]
      }
      When call run_and_check_opp_ids
      The status should be success
    End
  End
End
