#!/bin/bash
# board.jsonl への唯一の書き込みインターフェース
# パイプ経由で JSON エントリを受け取り、正確な UTC タイムスタンプを注入して追記する。
# 引数 $1: board.jsonl のファイルパス
# 依存: jq, date
# 常に exit 0 で終了する。
set +e

board_file="$1"

# 引数なし → 何もせず終了
[ -z "$board_file" ] && exit 0

# stdin から JSON を読み取る
input=$(cat)

# 入力が空 → 何もせず終了
[ -z "$input" ] && exit 0

# jq でタイムスタンプを注入（パース失敗時は空文字）
ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
result=$(echo "$input" | jq -c --arg ts "$ts" '. + {"timestamp": $ts}' 2>/dev/null)

# jq 失敗（不正 JSON など）→ 何もせず終了
[ -z "$result" ] && exit 0

# 追記
echo "$result" >> "$board_file"

exit 0
