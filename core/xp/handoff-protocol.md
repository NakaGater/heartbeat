# Handoff Protocol

## Overview
This document consolidates all agent handoff rules from individual persona definitions.
Each agent follows the Board Protocol (see board-protocol.md) and uses the specific
handoff patterns defined below.

## Handoff Flow

```
User Request
  → pdm (hearing) → brief.md
  → context-manager (investigation) → context.md
  → pdm (story definition) → story.md
  → [human approval]
  → designer → design.md
  → architect → tasks.md + tasks.jsonl
  → [human approval]
  → For each task (outer loop):
      tester → first test code (Red) → update tasks.jsonl to "in_progress"
      Per-test inner loop:
        implementer → minimal implementation (Green)
        refactor → refactored code
        If more completion conditions remain in this task:
          tester → next test code (Red)
          Continue inner loop
      → update tasks.jsonl to "done"
  → reviewer → review.md
  → qa → qa-report.md
  → pdm (acceptance judgment) → verdict.md
  → [Pass] context-manager (accumulation) → knowledge/ updated
  → [Return] rework to appropriate agent
```

## Agent-Specific Handoff Rules

### PdM
- After hearing: to="context-manager", action="investigate", output="brief.md"
- After story definition: to="human", action="approve", output="story.md", status="waiting"
- Acceptance Pass: to="done", action="complete", output="verdict.md"
- Acceptance Return: to="{target agent}", action="rework", output="verdict.md", status="rework"

### Context Manager
- After investigation: to="pdm", action="define_story", output="context.md"
- After accumulation: to="done", action="knowledge_updated"

### Designer
- After design: to="architect", action="decompose", output="design.md"
- If blocked: to="pdm", status="blocked", note="{unclear points}"

### Architect
- After task decomposition: to="human", action="approve", output="tasks.md", status="waiting"
- If blocked: to="designer", status="blocked", note="{technical concerns}"

### Tester
- After test creation: to="implementer", action="make_green", output="{test file}"
- If spec unclear: to="designer", status="blocked"
- If design concern: to="architect", status="blocked"

### Implementer
- After implementation (Green): to="refactor", action="refactor", output="{impl file}"
- If test unclear: to="tester", status="blocked"

### Refactor
- After refactoring (more tests remain in current task): to="tester", action="write_next_test", note="Continue task {task_id}: next completion condition"
- After refactoring (current task complete, more tasks remain): to="tester", action="write_test", note="Proceed to next task"
- After refactoring (all tasks complete): to="reviewer", action="review"
- If tests Red: to="implementer", status="rework", note="{what broke}"

### Reviewer
- Approve: to="qa", action="verify", output="review.md"
- Request Changes: to="implementer", status="rework", output="review.md"

### QA
- No issues: to="pdm", action="judge", output="qa-report.md"
- Issues found: to="designer" or "implementer", status="rework", output="qa-report.md"
