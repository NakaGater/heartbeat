# Usage Guide

## `/heartbeat` — Main Workflow

The primary entry point. Launches the agent team and presents options:

1. **Create a story** — Define a user story with acceptance criteria (adds to backlog, no implementation)
2. **Implement a story** — Pick an existing story and run the full TDD cycle
3. **Create and implement** — End-to-end from story creation through implementation and verification
4. **Continue in-progress** — Resume an interrupted story from where it left off
5. **Manage backlog** — Adjust story points, priorities, or iteration assignments

Example session:

```
> /heartbeat

📋 Iteration 1 (Total 8pt / Done 3pt / 37%)
  ✅ login: Login feature (3pt) Done
  🔄 dnd: D&D reorder (5pt) In progress - implementer on task 2

📋 Unassigned
  📝 oauth: Google login (points not set)

What would you like to do?
1. Create a story
2. Implement a story
3. Create and implement a story
4. Continue in-progress story
5. Manage backlog
```

## `/heartbeat-backlog` — Backlog Management

Manage stories without running the full workflow:

```
> /heartbeat-backlog Change login points to 5
> /heartbeat-backlog Put oauth in iteration 2
> /heartbeat-backlog Show backlog
```

## `/xp-values` — XP Reference

Get contextual guidance on XP values and practices for your current situation:

```
> /xp-values How should I handle this design disagreement?
```

## `/xp-retro` — Retrospective Insights

Aggregate patterns from past retrospectives and surface trends:

```
> /xp-retro

📊 Heartbeat Learning Insights

## Patterns Requiring Attention
- simplicity (yellow): Could simplify validation logic — 3 occurrences
- feedback (red): Edge case tests insufficient — 2 occurrences

## Recommendations
1. Add boundary condition tests before next implementation
2. Extract validation into a shared utility
```

## `/browser-testing` — Ad-hoc QA

Launch browser verification outside the normal story workflow:

```
> /browser-testing Check if the login page renders correctly on mobile
```

Requires Playwright MCP (auto-configured by the plugin).
