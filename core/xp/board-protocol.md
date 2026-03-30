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
  "timestamp": "ISO 8601 UTC datetime (agent writes current time; hook may overwrite)"
}
```

## Timestamp Hybrid Injection

Agents MUST write the current UTC time in ISO 8601 format when appending to
board.jsonl (e.g. "2026-03-30T12:00:00Z"). Do not leave empty or use a
placeholder. The PostToolUse hook (`core/scripts/board-stamp.sh`) may overwrite
the timestamp with the system time if it fires, but agents must not rely on
the hook — it does not fire for all write methods (e.g. shell echo).

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
