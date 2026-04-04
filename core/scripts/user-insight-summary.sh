#!/bin/bash
# user-insight-summary.sh — UCD 4層横断Markdownサマリー生成
# 使用方法: user-insight-summary.sh [insights_dir]
# insights_dir: 入力ディレクトリ（デフォルト: .heartbeat/insights）
# 依存: jq のみ

set -euo pipefail

INSIGHTS_DIR="${1:-.heartbeat/insights}"

# --- 各層ファイルパス ---
RAW_FILE="${INSIGHTS_DIR}/raw.jsonl"
FINDINGS_FILE="${INSIGHTS_DIR}/findings.jsonl"
INSIGHTS_FILE="${INSIGHTS_DIR}/insights.jsonl"
OPPORTUNITIES_FILE="${INSIGHTS_DIR}/opportunities.jsonl"
SUMMARY_FILE="${INSIGHTS_DIR}/summary.md"

# --- 安全なJSONL行数カウント ---
count_entries() {
  local file="$1"
  if [ -f "$file" ] && [ -s "$file" ]; then
    jq -s 'length' "$file" 2>/dev/null || echo "0"
  else
    echo "0"
  fi
}

# --- ディレクトリ作成 ---
mkdir -p "$INSIGHTS_DIR"

# --- エントリ数集計 ---
RAW_COUNT=$(count_entries "$RAW_FILE")
FINDINGS_COUNT=$(count_entries "$FINDINGS_FILE")
INSIGHTS_COUNT=$(count_entries "$INSIGHTS_FILE")
OPPORTUNITIES_COUNT=$(count_entries "$OPPORTUNITIES_FILE")

# --- サマリー生成開始 ---
{
  echo "# ユーザーインサイト分析サマリー"
  echo ""
  echo "## 概要"
  echo ""
  echo "| 層 | エントリ数 |"
  echo "|---|---|"
  echo "| Raw | ${RAW_COUNT} |"
  echo "| Findings | ${FINDINGS_COUNT} |"
  echo "| Insights | ${INSIGHTS_COUNT} |"
  echo "| Opportunities | ${OPPORTUNITIES_COUNT} |"
  echo ""

  # --- カテゴリ別集計 ---
  echo "## カテゴリ別集計"
  echo ""
  if [ -f "$INSIGHTS_FILE" ] && [ -s "$INSIGHTS_FILE" ]; then
    jq -rs '
      group_by(.category) |
      map({
        category: .[0].category,
        count: length,
        severities: (group_by(.severity) | map({severity: .[0].severity, count: length}))
      }) |
      .[] |
      "- **\(.category)**: \(.count)件 (\(.severities | map("\(.severity): \(.count)") | join(", ")))"
    ' "$INSIGHTS_FILE" 2>/dev/null || echo "データなし"
  else
    echo "データなし"
  fi
  echo ""

  # --- 主要な改善機会 ---
  echo "## 主要な改善機会"
  echo ""
  if [ -f "$OPPORTUNITIES_FILE" ] && [ -s "$OPPORTUNITIES_FILE" ]; then
    HIGH_OPPS=$(jq -r 'select(.impact == "high") | "- **\(.title)**: \(.description)"' "$OPPORTUNITIES_FILE" 2>/dev/null || true)
    if [ -n "$HIGH_OPPS" ]; then
      echo "$HIGH_OPPS"
    else
      echo "impact: high の機会はありません"
    fi
  else
    echo "データなし"
  fi
  echo ""

  # --- トレーサビリティ ---
  echo "## トレーサビリティ"
  echo ""
  if [ -f "$OPPORTUNITIES_FILE" ] && [ -s "$OPPORTUNITIES_FILE" ]; then
    # 各Opportunityの根拠チェーンを構築
    while IFS= read -r opp_line; do
      OPP_ID=$(printf '%s' "$opp_line" | jq -r '.id')
      OPP_TITLE=$(printf '%s' "$opp_line" | jq -r '.title')
      SOURCE_INSIGHTS=$(printf '%s' "$opp_line" | jq -r '.source_insights // [] | .[]')

      echo "### ${OPP_ID}: ${OPP_TITLE}"
      echo ""

      if [ -n "$SOURCE_INSIGHTS" ]; then
        for ins_id in $SOURCE_INSIGHTS; do
          # Insightの参照Findingsを取得
          SOURCE_FINDINGS=""
          if [ -f "$INSIGHTS_FILE" ] && [ -s "$INSIGHTS_FILE" ]; then
            SOURCE_FINDINGS=$(jq -r --arg id "$ins_id" 'select(.id == $id) | .source_findings // [] | .[]' "$INSIGHTS_FILE" 2>/dev/null || true)
          fi

          FINDINGS_RAW_REFS=""
          if [ -n "$SOURCE_FINDINGS" ]; then
            for fnd_id in $SOURCE_FINDINGS; do
              # Findingの参照Rawを取得
              if [ -f "$FINDINGS_FILE" ] && [ -s "$FINDINGS_FILE" ]; then
                RAW_REF=$(jq -r --arg id "$fnd_id" 'select(.id == $id) | .source_raw // ""' "$FINDINGS_FILE" 2>/dev/null || true)
                if [ -n "$RAW_REF" ]; then
                  FINDINGS_RAW_REFS="${FINDINGS_RAW_REFS} ${RAW_REF}"
                fi
              fi
              echo "- ${OPP_ID} <- ${ins_id} <- ${fnd_id} <- ${RAW_REF:-不明}"
            done
          else
            echo "- ${OPP_ID} <- ${ins_id}"
          fi
        done
      else
        echo "- ${OPP_ID}: 参照なし"
      fi
      echo ""
    done < <(jq -c '.' "$OPPORTUNITIES_FILE" 2>/dev/null)
  else
    echo "データなし"
    echo ""
  fi
} > "$SUMMARY_FILE"

exit 0
