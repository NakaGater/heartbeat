# Contributing to Heartbeat

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
│   └── xp/                      # Values, practices, protocols
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

## Local Development

Load the plugin from a local directory:

```bash
claude --plugin-dir /path/to/heartbeat
```

Reload after changes with `/reload-plugins`.

### What Gets Registered

- 9 agents (PdM, Context Manager, Designer, Architect, Tester, Implementer, Refactor, Reviewer, QA)
- 5 skills (`/heartbeat`, `/heartbeat-backlog`, `/xp-values`, `/xp-retro`, `/browser-testing`)
- Playwright MCP server for browser testing
- Hooks for auto-retrospective and dashboard generation

### Installation Scopes (Claude Code)

| Scope | Flag | Effect |
|-------|------|--------|
| User | `--scope user` | Available across all your projects (default) |
| Project | `--scope project` | Shared with all collaborators on this repo |
| Local | `--scope local` | Only for you in this repo |

## CI

Heartbeat uses GitHub Actions for continuous testing:

- **Push / PR** — Runs all 224 deterministic tests (82 unit + 142 structure)
- **Persona changes** — Triggers LLM-as-Judge evaluations against agent persona definitions

### Running Tests Locally

```bash
make test            # Unit + structure tests
make test-unit       # ShellSpec unit tests only
make test-structure  # Agent definition validation only
make test-evals      # LLM-as-Judge (requires ANTHROPIC_API_KEY)
```

## GitHub Copilot CLI Management

```bash
copilot plugin install nakagater/heartbeat
copilot plugin list              # List installed plugins
copilot plugin update heartbeat  # Update to latest
copilot plugin uninstall heartbeat
```
