# Heartbeat

XP-driven AI agent team plugin for TDD-based development.

Runs on both GitHub Copilot CLI and Claude Code.

## Quick Start

```bash
# Development setup
./setup.sh

# Run tests
make test
```

## Overview

Heartbeat is an AI agent team plugin grounded in XP (Extreme Programming) values. 9 specialized agents collaborate through a file-based bulletin board to deliver value in TDD cycles.

## Agents

| Agent | Role |
|-------|------|
| pdm | Understand user problems, define stories, acceptance judgment |
| context-manager | Maintain project knowledge base |
| designer | Define UX specs (behavior + visual) |
| architect | Decompose stories into tasks |
| tester | Write tests (Red) |
| implementer | Minimal implementation (Green) |
| refactor | Improve code quality |
| reviewer | Code review |
| qa | Browser verification |

## License

MIT
