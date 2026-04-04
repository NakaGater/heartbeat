#!/bin/bash
# 共通ユーティリティライブラリ
# source で読み込んで使用する。単体実行はしない。

# プロジェクトルートの解決
# 優先順位: HEARTBEAT_ROOT > CLAUDE_PROJECT_DIR > "."
_resolve_project_root() {
  echo "${HEARTBEAT_ROOT:-${CLAUDE_PROJECT_DIR:-.}}"
}

# board.jsonl の探索
# 引数: $1 (省略可) -- story-id
# 環境変数: HEARTBEAT_ACTIVE_STORY (story-id 未指定時のフォールバック)
# 出力: board.jsonl のパスまたは空文字列
find_board_jsonl() {
  local story_id="${1:-}"
  local project_root
  project_root="$(_resolve_project_root)"

  # HEARTBEAT_ACTIVE_STORY フォールバック
  if [ -z "$story_id" ] && [ -n "${HEARTBEAT_ACTIVE_STORY:-}" ]; then
    story_id="$HEARTBEAT_ACTIVE_STORY"
  fi

  if [ -n "$story_id" ]; then
    local path="$project_root/.heartbeat/stories/$story_id/board.jsonl"
    [ -f "$path" ] && echo "$path"
    return 0
  fi

  # フォールバック: 最新の board.jsonl
  ls -t "$project_root"/.heartbeat/stories/*/board.jsonl 2>/dev/null | head -1
}
