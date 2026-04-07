# Plugin Manifests

## Overview

Heartbeat runs on two platforms (Copilot CLI, Claude Code). Each has a plugin manifest
that registers agents, skills, hooks, and MCP servers. The manifests are thin pointers
to resources under `adapters/`.

## Copilot: `.github/plugin/plugin.json`

```json
{
  "name": "heartbeat",
  "version": "...",
  "description": "...",
  "author": "NakaG",
  "agents": [
    "adapters/copilot/agents/architect.agent.md",
    "adapters/copilot/agents/context-manager.agent.md",
    ...
    "adapters/copilot/agents/heartbeat.agent.md"   // orchestrator, last
  ]
}
```

Key rules:
- `author` (not `publisher`) is the correct field name.
- `agents` array must include the orchestrator (`heartbeat.agent.md`) in addition to the 9 sub-agents (total 10).
- Agent paths are relative to repo root and point to `adapters/copilot/agents/`.

## Claude Code: `.claude-plugin/plugin.json`

```json
{
  "name": "heartbeat",
  "version": "...",
  "description": "...",
  "agents": ["adapters/claude-code/agents/*.md"],
  "skills": ["adapters/claude-code/skills/*/"],
  "hooks": "./adapters/claude-code/hooks/settings.json",
  "mcpServers": { "playwright": { ... } }
}
```

Key rules:
- All four fields (`agents`, `skills`, `hooks`, `mcpServers`) must be present.
- Paths reference `adapters/claude-code/` resources.
- `mcpServers` mirrors the Copilot Playwright MCP configuration.

## `.github/` Directory Usage

| Path | Purpose | Managed by |
|------|---------|------------|
| `.github/plugin/plugin.json` | Copilot plugin manifest | plugin-config-cleanup |
| `.github/workflows/` | CI pipeline (heartbeat-ci.yml) | standard GitHub Actions |
| `.github/agents/` | DELETED -- was legacy duplicate of `adapters/copilot/agents/` |
| `.github/hooks/` | DELETED -- was orphaned hook file |

Rule: `.github/` should contain only `plugin/` (Copilot manifest) and `workflows/` (CI).
Agent files, hooks, and skills belong under `adapters/`.

## Orchestrator Placement

The orchestrator (`heartbeat.agent.md`) must satisfy three conditions on Copilot:
1. File exists at `adapters/copilot/agents/heartbeat.agent.md`
2. Registered in `.github/plugin/plugin.json` agents array
3. Frontmatter `agents:` lists all 9 sub-agents; `tools:` includes `agent`

Without all three, subagent dispatch silently fails.

## Single Source of Truth

```
core/agent-personas/*.yaml   -- canonical persona definitions (SSoT)
  |
  +-- adapters/copilot/agents/*.agent.md    -- Copilot adapter (manual sync)
  +-- adapters/claude-code/agents/*.md      -- Claude Code adapter (manual sync)
```

Currently adapters are manually maintained. Future improvement: auto-generate
adapter files from core personas to eliminate drift risk.

Last updated: 2026-03-30 (story: plugin-config-cleanup)
