# Bulletin Board Protocol

## Overview
Each agent appends one line to .heartbeat/stories/{id}/board.jsonl upon
work completion. The orchestrator reads the last line to determine the next action.

## Format

```json
{
  "from": "agent name",
  "to": "next agent name",
  "action": "what the next agent should do",
  "input": "input file name",
  "output": "file this agent created",
  "status": "done | waiting | blocked | rework",
  "note": "handoff notes (optional)",
  "timestamp": ""
}
```

## board.jsonl への書き込み方法

エージェントは `board-write.sh` を使って board.jsonl に書き込まなければならない。
`board-write.sh` はパイプ経由で JSON を受け取り、正確な UTC タイムスタンプを自動注入して追記する。
そのため、エージェントは `timestamp` フィールドを自分で設定する必要がない。

### パイプ呼び出しパターン

```bash
echo '{"from":"implementer","to":"refactor","action":"make_green","status":"done"}' \
  | bash core/scripts/board-write.sh .heartbeat/stories/{id}/board.jsonl
```

上記の通り、JSON を標準入力で `board-write.sh` にパイプし、引数に board.jsonl のパスを渡す。
`board-write.sh` が `timestamp` を ISO 8601 UTC 形式で自動付与するため、
エージェントが `timestamp` を手動で指定する必要はない。

### board-stamp.sh（安全ネット）

`board-stamp.sh` は PostToolUse フックとして動作し、
万が一 `board-write.sh` 以外の方法で書き込まれた場合でも、
空の `timestamp` フィールドを検出して正確な値を補填する安全ネットとして機能する。

## Status Definitions
- `done`: Complete. Proceed to the next agent.
- `waiting`: Awaiting human approval. Set to="human".
- `blocked`: Cannot proceed. Describe reason in note.
- `rework`: Sending back. Set to=target agent for rework.

## Special Values for "to"
- `human`: Request human judgment
- `done`: Entire workflow complete

## Orchestrator Behavior
1. Read the last line of .heartbeat/stories/{id}/board.jsonl
2. If status is "done" → start the "to" agent
3. If status is "waiting" → ask human for approval
4. If status is "blocked" → report reason to human
5. If status is "rework" → start the "to" agent (rework)
