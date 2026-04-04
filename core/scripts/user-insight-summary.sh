#!/bin/bash
# user-insight-summary.sh — UCD 4層横断Markdownサマリー生成
# 使用方法: user-insight-summary.sh [insights_dir]
# insights_dir: 入力ディレクトリ（デフォルト: .heartbeat/insights）
# 依存: jq のみ

set -euo pipefail

# --- ヘルプ表示 ---
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  cat <<'USAGE'
Usage: user-insight-summary.sh [insights_dir]

Arguments:
  insights_dir   入力ディレクトリ（デフォルト: .heartbeat/insights）

Output:
  insights_dir/summary.md   UCD 4層横断Markdownサマリー

Sections:
  概要             各層のエントリ数
  カテゴリ別集計   Insights層のcategory × severity
  主要な改善機会   impact: high のOpportunities
  トレーサビリティ Opportunity → Insight → Finding → Raw の根拠チェーン
USAGE
  exit 0
fi

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
    # 全層データを一括読み込みし、jq単体で根拠チェーンを構築
    INSIGHTS_JSON="[]"
    FINDINGS_JSON="[]"
    if [ -f "$INSIGHTS_FILE" ] && [ -s "$INSIGHTS_FILE" ]; then
      INSIGHTS_JSON=$(jq -s '.' "$INSIGHTS_FILE" 2>/dev/null || echo "[]")
    fi
    if [ -f "$FINDINGS_FILE" ] && [ -s "$FINDINGS_FILE" ]; then
      FINDINGS_JSON=$(jq -s '.' "$FINDINGS_FILE" 2>/dev/null || echo "[]")
    fi

    jq -rs --argjson ins "$INSIGHTS_JSON" --argjson fnd "$FINDINGS_JSON" '
      .[] | . as $opp |
      "### \(.id): \(.title)\n",
      if (.source_insights // []) | length > 0 then
        (.source_insights // [])[] | . as $ins_id |
        ($ins | map(select(.id == $ins_id)) | .[0]) as $ins_entry |
        if ($ins_entry | .source_findings // []) | length > 0 then
          ($ins_entry | .source_findings // [])[] | . as $fnd_id |
          ($fnd | map(select(.id == $fnd_id)) | .[0]) as $fnd_entry |
          "- \($opp.id) <- \($ins_id) <- \($fnd_id) <- \($fnd_entry.source_raw // "不明")"
        else
          "- \($opp.id) <- \($ins_id)"
        end
      else
        "- \($opp.id): 参照なし"
      end,
      ""
    ' "$OPPORTUNITIES_FILE" 2>/dev/null || echo "データなし"
  else
    echo "データなし"
    echo ""
  fi
} > "$SUMMARY_FILE"

exit 0
