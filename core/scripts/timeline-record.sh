#!/bin/bash
# Record agent start/stop timestamps to timeline.jsonl.
# Called by both SubagentStart and SubagentStop hooks.
# Must exit 0 on all paths.  Dependency: jq
set +e

# --- Load shared libraries ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

main() {
  local input
  input=$(cat)

  # 空入力 -- 何もしない
  [ -z "$input" ] && exit 0

  # hook_event_name の取得とイベント種別マッピング
  local hook_event event
  hook_event=$(echo "$input" | jq -r '.hook_event_name // empty' 2>/dev/null)
  case "$hook_event" in
    SubagentStart) event="agent-start" ;;
    SubagentStop)  event="agent-stop" ;;
    *)             exit 0 ;;  # 想定外のイベント -- 無視
  esac

  # agent_type からエージェント名を抽出
  # "heartbeat:tester" -> "tester", 空なら "unknown"
  local agent_type agent
  agent_type=$(echo "$input" | jq -r '.agent_type // empty' 2>/dev/null)
  if [ -n "$agent_type" ]; then
    agent="${agent_type##*:}"  # コロン以降を抽出
    [ -z "$agent" ] && agent="unknown"
  else
    agent="unknown"
  fi

  # ストーリーディレクトリの特定
  local board_path story_dir timeline_path
  board_path=$(find_board_jsonl)
  [ -z "$board_path" ] && exit 0

  story_dir=$(dirname "$board_path")
  timeline_path="$story_dir/timeline.jsonl"

  # タイムスタンプ生成と書き込み
  local ts
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  echo "{\"event\":\"$event\",\"agent\":\"$agent\",\"timestamp\":\"$ts\"}" \
    | jq -c '.' >> "$timeline_path"

  exit 0
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi
