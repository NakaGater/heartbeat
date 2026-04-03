---
name: xp-retro
description: >
  Run a retrospective and display learning insights.
  Aggregates patterns from past retrospectives and shows trends.
  Triggers on: "retro", "retrospective", "insights", "learnings"
allowed-tools: Read, Bash, Grep, Glob
---

## Your Role
Help the user review retrospective data and extract actionable insights.

## What to Do

1. Run `./core/scripts/insights-aggregate.sh` to generate fresh insights
2. Read `.heartbeat/retrospectives/insights.md` and present the results
3. If the user asks about specific agents or values, filter accordingly
4. Highlight patterns requiring attention (yellow/red scores)

## Display Format

```
📊 Heartbeat Learning Insights

## Patterns Requiring Attention
- **simplicity** (yellow): Could simplify validation logic — 3 occurrences
- **feedback** (red): Edge case tests insufficient — 2 occurrences

## Agent Activity
- tester: 12 retrospectives
- implementer: 10 retrospectives
- refactor: 8 retrospectives

## Recommendations
Based on the patterns above:
1. {Actionable recommendation}
2. {Actionable recommendation}
```

## Reference Files
- `.heartbeat/retrospectives/log.jsonl` — Raw retrospective data
- `.heartbeat/retrospectives/insights.md` — Aggregated insights
- `core/scripts/insights-aggregate.sh` — Aggregation script
