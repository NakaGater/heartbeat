# Heartbeat

**XP-driven AI agent team that builds software through TDD cycles.**

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Tests: 18 passing](https://img.shields.io/badge/Tests-18%20passing-brightgreen.svg)
![Platform: Copilot CLI / Claude Code](https://img.shields.io/badge/Platform-Copilot%20CLI%20%7C%20Claude%20Code-purple.svg)

Nine specialized agents collaborate through a file-based bulletin board, executing Red→Green→Refactor cycles grounded in Extreme Programming values. No database required — all state lives in JSONL and Markdown files tracked by Git.

## Features

- **9 Specialized AI Agents** — Autonomously execute TDD cycles from story definition to browser verification
- **XP-Driven** — Grounded in 5 values (Communication, Simplicity, Feedback, Courage, Respect) and 8 practices
- **Dual Platform** — Runs on both GitHub Copilot CLI and Claude Code
- **File-Based State** — JSONL + Markdown for all state management, fully Git-trackable, no database
- **Learning System** — Retrospective → Insight aggregation → Next iteration improvement, automated
- **Output Language Matching** — Generates documents in the user's input language

## How It Works

```
User Request
    │
    ▼
┌─────────┐   ┌─────────────────┐   ┌─────────┐
│   PdM   │──▶│ Context Manager  │──▶│   PdM   │
│ Hearing │   │   Investigation  │   │  Story   │
└─────────┘   └─────────────────┘   └────┬────┘
                                         │
    ┌────────────────────────────────────┘
    ▼
┌──────────┐   ┌───────────┐   ┌──────────────┐
│ Designer │──▶│ Architect │──▶│    Tester    │
│ UX Spec  │   │Task Decomp│   │  Write Tests │
└──────────┘   └───────────┘   └──────┬───────┘
                                      │
              Red ────────────────────┘
    ┌─────────────────────────────────┘
    ▼
┌──────────────┐   ┌──────────┐   ┌──────────┐
│ Implementer  │──▶│ Refactor │──▶│ Reviewer  │
│    Green     │   │ Improve  │   │  Review   │
└──────────────┘   └──────────┘   └─────┬─────┘
                                        │
    ┌───────────────────────────────────┘
    ▼
┌─────────┐   ┌─────────┐
│   QA    │──▶│   PdM   │
│ Browser │   │ Accept?  │
└─────────┘   └─────────┘
```

## Agents

| Agent | Role | Key Outputs |
|-------|------|-------------|
| **PdM** | Understand user problems, define stories, acceptance judgment | User stories, acceptance criteria |
| **Context Manager** | Investigate and maintain project knowledge base | Context reports, dependency maps |
| **Designer** | Define UX specs (behavior + visual) | UX specifications, interaction flows |
| **Architect** | Decompose stories into implementation tasks | Task breakdowns, technical decisions |
| **Tester** | Write failing tests first (Red phase) | Test files, coverage targets |
| **Implementer** | Minimal implementation to pass tests (Green phase) | Production code |
| **Refactor** | Improve code quality without changing behavior | Refactored code, design improvements |
| **Reviewer** | Code review for quality and consistency | Review comments, approval |
| **QA** | Browser verification via Playwright MCP | Verification reports, screenshots |

## Installation

### Prerequisites

- **jq** — Required for JSON processing

  ```bash
  # macOS
  brew install jq

  # Linux
  apt-get install jq
  ```

- **Playwright MCP** — For QA agent browser verification (optional, auto-configured by plugin)

### Claude Code

**Option A: Install via marketplace (recommended)**

Run these commands inside Claude Code:

```
/plugin marketplace add nakagater/heartbeat
/plugin install heartbeat@heartbeat-marketplace
```

You can choose an installation scope:

| Scope | Flag | Effect |
|-------|------|--------|
| User | `--scope user` | Available across all your projects (default) |
| Project | `--scope project` | Shared with all collaborators on this repo |
| Local | `--scope local` | Only for you in this repo |

**Option B: Load from local directory**

For development or testing, start Claude Code with the `--plugin-dir` flag:

```bash
claude --plugin-dir /path/to/heartbeat
```

Reload after changes with `/reload-plugins`.

**What gets registered:**

- 9 agents (PdM, Context Manager, Designer, Architect, Tester, Implementer, Refactor, Reviewer, QA)
- 5 skills (`/heartbeat`, `/heartbeat-backlog`, `/xp-values`, `/xp-retro`, `/browser-testing`)
- Playwright MCP server for browser testing
- Hooks for auto-retrospective and dashboard generation

### GitHub Copilot CLI

Install directly from the GitHub repository:

```bash
copilot plugin install nakagater/heartbeat
```

Or from a local directory:

```bash
copilot plugin install ./path/to/heartbeat
```

Other plugin management commands:

```bash
copilot plugin list              # List installed plugins
copilot plugin update heartbeat  # Update to latest
copilot plugin uninstall heartbeat
```

The plugin registers the same agents, skills, and hooks adapted for Copilot CLI.

## Usage

### `/heartbeat` — Main Workflow

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

### `/heartbeat-backlog` — Backlog Management

Manage stories without running the full workflow:

```
> /heartbeat-backlog Change login points to 5
> /heartbeat-backlog Put oauth in iteration 2
> /heartbeat-backlog Show backlog
```

### `/xp-values` — XP Reference

Get contextual guidance on XP values and practices for your current situation:

```
> /xp-values How should I handle this design disagreement?
```

### `/xp-retro` — Retrospective Insights

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

### `/browser-testing` — Ad-hoc QA

Launch browser verification outside the normal story workflow:

```
> /browser-testing Check if the login page renders correctly on mobile
```

Requires Playwright MCP (auto-configured by the plugin).

## Dashboard

Heartbeat auto-generates a progress dashboard at `.heartbeat/dashboard.html` after every file change. Open it in a browser to monitor your project in real time.

The dashboard includes:

- **Backlog Board** — Kanban view of stories across Draft / Ready / In Progress / Done columns
- **Velocity Chart** — Bar chart of completed story points per iteration with average trend line
- **Story Detail** — Select a story to see a Gantt-style timeline of agent activity and task status
- **Agent Messages** — Chronological feed of bulletin board entries showing agent handoffs and notes

Auto-reload is enabled by default (every 5 seconds), so the dashboard stays current while agents work. Supports dark mode via system preference.

To generate the dashboard manually:

```bash
./core/scripts/generate-dashboard.sh
open .heartbeat/dashboard.html
```

## Runtime Directory

Heartbeat generates state files in `.heartbeat/` as it works:

```
.heartbeat/
├── board.jsonl              # Agent bulletin board (append-only)
├── backlog.jsonl            # Story backlog with status and points
├── context.md               # Project context snapshot
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

All files are plain text — review diffs in Git, grep for insights, or process with standard tools.

## Project Structure

```
heartbeat/
├── core/                        # Platform-independent
│   ├── agent-personas/          # 9 agent persona definitions
│   ├── scripts/                 # auto-commit, dashboard, retro, insights
│   ├── templates/               # Dashboard HTML template
│   └── xp/                     # Values, practices, protocols
├── adapters/
│   ├── copilot/                 # GitHub Copilot CLI adapter
│   │   ├── agents/              # Agent wrappers
│   │   ├── hooks/               # hooks.json
│   │   └── skills/              # Skill definitions
│   └── claude-code/             # Claude Code adapter
│       ├── agents/              # Agent wrappers
│       ├── hooks/               # settings.json
│       └── skills/              # Skill definitions
└── tests/                       # 4-layer test suite
    ├── spec/                    # ShellSpec unit tests
    ├── structure/               # Agent definition validation
    └── evals/                   # LLM-as-Judge evaluations
```

## License

MIT
