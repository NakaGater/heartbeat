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

# --- ロック機構 (mkdir ベース) ---

# stale ロック判定（内部関数）
# 引数: $1 -- lock ディレクトリパス
# 戻り値: 0=stale, 1=not stale
_is_lock_stale() {
  local lock_dir="$1"
  local stale
  stale=$(find "$lock_dir" -maxdepth 0 -mmin +1 2>/dev/null)
  [ -n "$stale" ] && return 0
  return 1
}

# ロック取得
# 引数: $1 -- lock ディレクトリパス
#        $2 (省略可) -- 最大リトライ回数 (デフォルト: 10)
#        $3 (省略可) -- リトライ間隔秒数 (デフォルト: 1)
# 戻り値: 0=取得成功, 1=取得失敗
acquire_lock() {
  local lock_dir="$1"
  local max_retries="${2:-10}"
  local retry_interval="${3:-1}"
  local retries=0

  while [ "$retries" -lt "$max_retries" ]; do
    # stale ロックの検出と除去
    if [ -d "$lock_dir" ] && _is_lock_stale "$lock_dir"; then
      rm -rf "$lock_dir"
    fi

    if mkdir "$lock_dir" 2>/dev/null; then
      echo $$ > "$lock_dir/pid"
      return 0
    fi
    retries=$((retries + 1))
    sleep "$retry_interval"
  done
  echo "Error: Could not acquire lock after ${max_retries} retries: $lock_dir" >&2
  return 1
}

# ロック解放
# 引数: $1 -- lock ディレクトリパス
# PID が一致する場合のみ削除する
release_lock() {
  local lock_dir="$1"
  if [ -f "$lock_dir/pid" ] && [ "$(cat "$lock_dir/pid")" = "$$" ]; then
    rm -rf "$lock_dir"
  fi
}
