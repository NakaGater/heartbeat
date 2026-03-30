# Heartbeat

**Your AI dev team that actually does TDD.**

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Tests: 224 passing](https://img.shields.io/badge/Tests-224%20passing-brightgreen.svg)
![Platform: Copilot CLI / Claude Code](https://img.shields.io/badge/Platform-Copilot%20CLI%20%7C%20Claude%20Code-purple.svg)

Nine AI agents collaborate through Red-Green-Refactor cycles, grounded in Extreme Programming values. Type `/heartbeat`, describe what you want, and watch them build it — with tests first, always.

No database. No server. All state lives in JSONL and Markdown files tracked by Git.

## What Makes Heartbeat Different?

| | Traditional AI Coding | Heartbeat |
|---|---|---|
| **Testing** | "I'll add tests later" | Tests are written first, every time |
| **Process** | One agent does everything | 9 specialists hand off like a real team |
| **Quality** | Hope it works | Red-Green-Refactor with code review and browser QA |
| **State** | Lost between sessions | Git-tracked JSONL/Markdown — resume anytime |
| **Values** | None explicit | XP: Communication, Simplicity, Feedback, Courage, Respect |

## Quick Start

```bash
# 1. Install (inside Claude Code)
/plugin marketplace add nakagater/heartbeat
/plugin install heartbeat@heartbeat-marketplace

# 2. Launch
/heartbeat
```

```
📋 Backlog is empty — let's create your first story!

What would you like to do?
1. Create a story
2. Implement a story
3. Create and implement a story   ← recommended for first time
4. Continue in-progress story
5. Manage backlog

> 3

What would you like to build?
> A user login page with email and password
```

Choose **3** and describe what you want. The agents take it from there — writing tests first, implementing, refactoring, reviewing, and verifying in a browser.

## How It Works

```
User Request
    │
    ▼
┌─────────┐   ┌─────────────────┐   ┌─────────┐
│   PdM   │──▶│ Context Manager │──▶│   PdM   │
│ Hearing │   │   Investigation │   │  Story  │
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
│ Implementer  │──▶│ Refactor │──▶│ Reviewer │
│    Green     │   │ Improve  │   │  Review  │
└──────────────┘   └──────────┘   └─────┬────┘
                                        │
    ┌───────────────────────────────────┘
    ▼
┌─────────┐   ┌─────────┐
│   QA    │──▶│   PdM   │
│ Browser │   │ Accept? │
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

Use the refresh button in the dashboard header to update while agents work. Supports dark mode via system preference.

To generate the dashboard manually:

```bash
./core/scripts/generate-dashboard.sh
open .heartbeat/dashboard.html
```

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

## CI

Heartbeat uses GitHub Actions for continuous testing:

- **Push / PR** — Runs all 224 deterministic tests (82 unit + 142 structure)
- **Persona changes** — Triggers LLM-as-Judge evaluations against agent persona definitions

```bash
# Run locally
make test            # Unit + structure tests
make test-unit       # ShellSpec unit tests only
make test-structure  # Agent definition validation only
make test-evals      # LLM-as-Judge (requires ANTHROPIC_API_KEY)
```

## Runtime Directory

Heartbeat generates state files in `.heartbeat/` as it works:

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

All files are plain text — review diffs in Git, grep for insights, or process with standard tools.

## Project Structure

```
heartbeat/
├── agents/                      # Claude Code plugin agent entries
├── skills/                      # Claude Code plugin skill entries
├── core/                        # Platform-independent
│   ├── agent-personas/          # 9 agent persona definitions (.md)
│   ├── knowledge/               # XP knowledge base (conventions, story points, etc.)
│   ├── scripts/                 # auto-commit, board-stamp, dashboard, retro, insights
│   ├── skills/                  # 5 skill definitions (shared across adapters)
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
├── tests/                       # 224 tests across 3 layers
│   ├── spec/                    # ShellSpec unit tests (82 examples)
│   ├── structure/               # Agent definition validation (142 examples)
│   ├── helpers/                 # Shared test utilities
│   └── evals/                   # LLM-as-Judge evaluations
├── .github/workflows/           # CI pipeline (GitHub Actions)
├── setup.sh                     # Initial setup script
└── Makefile                     # Test runner shortcuts
```

## Dogfooding

Heartbeat builds itself with itself. This repository has 17 completed stories — from dashboard fixes to workflow boundary enforcement — all developed through the same TDD agent workflow that ships to users.

## License

MIT
