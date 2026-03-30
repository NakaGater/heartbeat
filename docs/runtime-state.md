# Runtime State

Heartbeat generates state files in `.heartbeat/` as it works. All files are plain text — review diffs in Git, grep for insights, or process with standard tools.

## Directory Structure

```
.heartbeat/
├── board.jsonl              # Agent bulletin board (append-only)
├── backlog.jsonl            # Story backlog with status and points
├── knowledge/
│   ├── architecture.md      # Project architecture snapshot
│   ├── conventions.md       # Coding conventions
│   ├── dependencies.md      # Dependency information
│   ├── directory-map.md     # Directory structure map
│   ├── changelog.jsonl      # Change history
│   └── tech-decisions.jsonl # Technical decision log
├── stories/
│   └── {story-id}/
│       ├── brief.md         # User problem analysis
│       ├── story.md         # Story definition + acceptance criteria
│       ├── design.md        # UX specification
│       ├── tasks.md         # Task breakdown (human-readable)
│       ├── tasks.jsonl      # Task progress (machine-readable)
│       ├── review.md        # Code review results
│       ├── qa-report.md     # Browser verification results
│       └── verdict.md       # PdM acceptance judgment
├── retrospectives/
│   ├── log.jsonl            # Raw retrospective records
│   └── insights.md          # Aggregated improvement insights
└── dashboard.html           # Auto-generated progress dashboard
```

## File Formats

- **JSONL** — Append-only logs (backlog, board, retrospectives, knowledge). Each line is a self-contained JSON object with a timestamp.
- **Markdown** — Human-readable specs and outputs. Designed to be reviewed in Git diffs.
- **HTML** — Self-contained dashboard with inlined data (no build step required).
