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
  "timestamp": "ISO 8601 datetime (required)"
}
```

## Status Definitions
- `done`: Complete. Proceed to the next agent.
- `waiting`: Awaiting human approval. Set to="human".
- `blocked`: Cannot proceed. Describe reason in note.
- `rework`: Sending back. Set to=target agent for rework.

## Special Values for "to"
- `human`: Request human judgment
- `done`: Entire workflow complete

## Orchestrator Behavior
1. Read the last line of board.jsonl
2. If status is "done" → start the "to" agent
3. If status is "waiting" → ask human for approval
4. If status is "blocked" → report reason to human
5. If status is "rework" → start the "to" agent (rework)
