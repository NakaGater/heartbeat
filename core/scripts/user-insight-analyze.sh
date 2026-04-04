#!/bin/bash
# user-insight-analyze.sh — UCD 4層JSONL操作スクリプト
# 使用方法: user-insight-analyze.sh <layer> <json_entry> [insights_dir]
# layer: raw | findings | insights | opportunities
# json_entry: JSON文字列、または "-" でstdinから読み取り
# insights_dir: 出力先ディレクトリ（デフォルト: .heartbeat/insights）
# 依存: jq のみ

set -euo pipefail

# --- ヘルプ表示 ---
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  cat <<'USAGE'
Usage: user-insight-analyze.sh <layer> <json_entry> [insights_dir]

Layers:
  raw            Raw（生データ層）       ID: RAW-NNN
  findings       Findings（事実抽出層）  ID: FND-NNN
  insights       Insights（インサイト層）ID: INS-NNN
  opportunities  Opportunities（機会層） ID: OPP-NNN

Arguments:
  json_entry     JSON文字列、または "-" でstdinから読み取り
  insights_dir   出力先ディレクトリ（デフォルト: .heartbeat/insights）

Examples:
  user-insight-analyze.sh raw '{"source_type":"interview","source_ref":"file.md","title":"タイトル","excerpt":"要約"}'
  echo '{"source_type":"survey",...}' | user-insight-analyze.sh raw - /path/to/insights
USAGE
  exit 0
fi

# --- 引数バリデーション ---
if [ $# -lt 2 ]; then
  echo "エラー: 引数が不足しています。'--help' で使用方法を確認してください。" >&2
  exit 1
fi

LAYER="$1"
JSON_INPUT="$2"
INSIGHTS_DIR="${3:-.heartbeat/insights}"

# --- レイヤー名バリデーション & ファイル名・IDプレフィックス設定 ---
case "$LAYER" in
  raw)            FILE="raw.jsonl";            PREFIX="RAW" ;;
  findings)       FILE="findings.jsonl";       PREFIX="FND" ;;
  insights)       FILE="insights.jsonl";       PREFIX="INS" ;;
  opportunities)  FILE="opportunities.jsonl";  PREFIX="OPP" ;;
  *)
    echo "エラー: 不正なレイヤー名 '${LAYER}'。有効な値: raw, findings, insights, opportunities" >&2
    exit 1
    ;;
esac

# --- JSON入力の取得 ---
if [ "$JSON_INPUT" = "-" ]; then
  JSON_INPUT=$(cat)
fi

# --- JSONバリデーション ---
if ! printf '%s' "$JSON_INPUT" | jq empty 2>/dev/null; then
  echo "エラー: 不正なJSON入力です。" >&2
  exit 1
fi

# --- ディレクトリ自動作成 ---
mkdir -p "$INSIGHTS_DIR"

TARGET="${INSIGHTS_DIR}/${FILE}"

# --- ID自動採番 ---
if [ -f "$TARGET" ] && [ -s "$TARGET" ]; then
  LAST_NUM=$(jq -r --arg pfx "$PREFIX" \
    '.id // "" | select(test("^" + $pfx + "-[0-9]{3}$")) | ltrimstr($pfx + "-") | tonumber' \
    "$TARGET" 2>/dev/null | sort -n | tail -1)
  NEXT_NUM=$(( ${LAST_NUM:-0} + 1 ))
else
  NEXT_NUM=1
fi

NEW_ID=$(printf "%s-%03d" "$PREFIX" "$NEXT_NUM")

# --- タイムスタンプ生成（UTC ISO 8601） ---
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# --- エントリにID・タイムスタンプを付与して追記 ---
ENTRY=$(printf '%s' "$JSON_INPUT" | jq -c --arg id "$NEW_ID" --arg ts "$TIMESTAMP" '. + {"id": $id, "timestamp": $ts}')

echo "$ENTRY" >> "$TARGET"

exit 0
