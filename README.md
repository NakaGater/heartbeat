# Heartbeat

**XP enhanced Agile AI agents, Nine roles. Tests first. Every time.**

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Tests: 224 passing](https://img.shields.io/badge/Tests-224%20passing-brightgreen.svg)
![Platform: Copilot CLI / Claude Code](https://img.shields.io/badge/Platform-Copilot%20CLI%20%7C%20Claude%20Code-purple.svg)
![Stories: 17 self-built](https://img.shields.io/badge/Stories-17%20self--built-orange.svg)

*Heartbeat* — the pulse of a team. Nine agents work in rhythm: Red, Green, Refactor. Like a heartbeat, the cycle never stops and never skips a beat. Each iteration pumps knowledge through the system, making the next one stronger.

AI coding tools promise quality but skip the tests. Heartbeat is an XP-driven agent team for Claude Code and GitHub Copilot CLI that enforces Red-Green-Refactor on every story — no exceptions.

## Quick Start

```bash
# Claude Code
/plugin marketplace add nakagater/heartbeat
/plugin install heartbeat@heartbeat-marketplace

# Or GitHub Copilot CLI
copilot plugin install nakagater/heartbeat
```

Then type `/heartbeat` and describe what you want to build:

```
> /heartbeat

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

The agents take it from there — tests first, implementation, refactoring, code review, and browser verification.

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

## Why Heartbeat?

| | Traditional AI Coding | Heartbeat |
|---|---|---|
| **Testing** | "I'll add tests later" | Tests first, always |
| **Process** | One agent does everything | 9 specialists hand off like a real team |
| **Quality** | Hope it works | Red-Green-Refactor with code review and browser QA |
| **State** | Lost between sessions | Git-tracked JSONL/Markdown — resume anytime |

## A Team That Learns

Every story makes the next one better. Heartbeat implements three XP feedback loops that compound over time:

**Retrospective (Whole Team)** — After each story, every agent answers five XP-aligned questions: *Was this the simplest approach? Did I ignore any problems? Did I respect previous decisions?* Answers are scored and stored in `log.jsonl`.

**Insight Aggregation (Feedback)** — Patterns are extracted automatically. Repeated yellow/red flags surface as actionable recommendations — "add boundary tests before implementation," "extract shared validation logic." These accumulate in `insights.md`.

**Knowledge Reuse (Communication)** — When a new story starts, the Context Manager pulls relevant insights and technical decisions from past work into `context.md`. Every downstream agent receives this context. Lessons from story #3 inform the design of story #17.

```
Story Complete
    │
    ▼
┌──────────────┐   ┌───────────────┐   ┌─────────────────┐
│ Retrospective│──▶│   Aggregate   │──▶│  Knowledge Base  │
│  per agent   │   │   insights    │   │   updated        │
└──────────────┘   └───────────────┘   └────────┬────────┘
                                                │
                   Next Story Starts ◀──────────┘
                        │
                        ▼
                ┌───────────────┐
                │Context Manager│
                │reads insights │
                │+ past decisions│
                └───────┬───────┘
                        │
                        ▼
                  All agents get
                  enriched context
```

The result: agents don't repeat mistakes. Design decisions, coding conventions, and failure patterns are preserved in Git-tracked files — not lost between sessions, not locked in a black box.

## Built With Itself

This repository contains 17 completed stories — all developed through Heartbeat's own TDD workflow. 224 tests pass on every commit, including LLM-as-Judge evaluations that verify agent persona accuracy. Every agent handoff, every test-first decision, every retrospective — dogfooded.

## Agents

| Agent | Role |
|-------|------|
| **PdM** | Understand user problems, define stories, judge acceptance |
| **Context Manager** | Investigate and maintain project knowledge base |
| **Designer** | Define UX specs (behavior + visual) |
| **Architect** | Decompose stories into implementation tasks |
| **Tester** | Write failing tests first (Red phase) |
| **Implementer** | Minimal implementation to pass tests (Green phase) |
| **Refactor** | Improve code quality without changing behavior |
| **Reviewer** | Code review for quality and consistency |
| **QA** | Browser verification via Playwright MCP |

## Commands

| Command | What it does |
|---------|-------------|
| `/heartbeat` | Main entry point. Create stories, implement with TDD, resume work, manage backlog. |
| `/heartbeat-backlog` | Quick backlog edits — change points, priorities, iterations. |
| `/xp-values` | Get contextual XP guidance for your current situation. |
| `/xp-retro` | Surface patterns and trends from past retrospectives. |
| `/browser-testing` | Ad-hoc browser QA via Playwright. |

See [Usage Guide](docs/usage.md) for detailed examples.

## Dashboard

Heartbeat auto-generates a progress dashboard at `.heartbeat/dashboard.html` — Kanban board, velocity chart, agent activity timeline, and dark mode. Open it in a browser to monitor your project in real time.

```bash
./core/scripts/generate-dashboard.sh
open .heartbeat/dashboard.html
```

## Installation

### Prerequisites

- **jq** — `brew install jq` (macOS) or `apt-get install jq` (Linux)
- **Playwright MCP** — For QA browser verification (optional, auto-configured by plugin)

### Claude Code

```
/plugin marketplace add nakagater/heartbeat
/plugin install heartbeat@heartbeat-marketplace
```

### GitHub Copilot CLI

```bash
copilot plugin install nakagater/heartbeat
```

## Documentation

| Document | Contents |
|----------|----------|
| [Usage Guide](docs/usage.md) | Full command examples and workflow details |
| [Runtime State](docs/runtime-state.md) | `.heartbeat/` directory structure and file formats |
| [Contributing](CONTRIBUTING.md) | Project structure, CI, local development setup |

## License

MIT
