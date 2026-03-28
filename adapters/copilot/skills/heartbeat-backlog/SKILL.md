---
name: heartbeat-backlog
description: >
  Manage the backlog. Change story points, priorities,
  or iteration assignments.
  Triggers on: "points", "priority", "backlog", "iteration"
---

## Your Role
Perform backlog management operations.
Directly update backlog.jsonl.

## Supported Commands

### Change Points
User: "Change login points to 5"
→ Update points for the target story in backlog.jsonl

### Assign Iteration
User: "Put reset in iteration 2"
→ Update iteration for the target story in backlog.jsonl

### Change Priority
User: "Make oauth higher priority than reset"
→ Adjust priority values in backlog.jsonl

### List View
User: "Show backlog"
→ Display grouped by iteration with point totals

### Create Iteration
User: "Create iteration 3 with reset and oauth"
→ Update iteration for target stories

## Display Format

Group by iteration, show point totals:

```
📋 Iteration 1 (Total 8pt / Done 3pt)
  ✅ login: Login feature (3pt) Done
  🔄 dnd: D&D reorder (5pt) In progress

📋 Iteration 2 (Total 8pt / Done 0pt)
  ⬜ reset: Password reset (3pt) Not started
  ⬜ oauth: Google login (5pt) Not started

📋 Unassigned
  📝 search: Search feature (points not set)
```

## Important Notes
- Respect human judgment for points. Agents do not change points on their own.
- Use "iteration" (XP term), not "sprint" (Scrum term).
- Completed story points can be adjusted as actuals.
