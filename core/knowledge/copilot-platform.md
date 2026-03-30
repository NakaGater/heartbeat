# Copilot Platform Conventions

## Tool Alias Rules

The GitHub Copilot CLI recognizes a specific set of tool aliases in agent `tools:` front matter.
Unrecognized names are **silently ignored** -- the agent receives zero tool access with no error.

### Recognized Aliases (as of 2026-03)

| Alias          | Capability                        | Equivalent in Claude Code     |
|----------------|-----------------------------------|-------------------------------|
| `read`         | Read file contents                | Read                          |
| `edit`         | Create or modify files            | Write, Edit                   |
| `execute`      | Run shell commands (unscoped)     | Bash                          |
| `search`       | Search/grep codebase              | Grep, Glob                    |
| `agent`        | Invoke sub-agents                 | (native)                      |
| `playwright/*` | MCP Playwright browser automation | mcp__playwright__*            |

### Key Gotchas

- **Case**: Use lowercase (`read`, not `Read`). Docs say case-insensitive but examples are all lowercase.
- **No scoped shell**: Unlike the old `shell(npm:*)` syntax, `execute` grants unrestricted shell. No scoped alternative exists.
- **MCP format**: Use slash notation (`playwright/*`), not parentheses (`playwright(*)`).
- **Silent failure**: If a tool name is not recognized, it is simply dropped. No warning is emitted. This makes typos and outdated names very dangerous.

### Per-Agent Tool Assignments

| Agent           | read | edit | execute | search | agent | playwright/* |
|-----------------|------|------|---------|--------|-------|--------------|
| heartbeat       | Y    | Y    | Y       | Y      | Y     |              |
| architect       | Y    | Y    |         | Y      |       |              |
| context-manager | Y    | Y    | Y       | Y      |       |              |
| designer        | Y    | Y    |         | Y      |       |              |
| implementer     | Y    | Y    | Y       | Y      |       |              |
| pdm             | Y    | Y    | Y       | Y      |       |              |
| qa              | Y    |      | Y       | Y      |       | Y            |
| refactor        | Y    | Y    | Y       | Y      |       |              |
| reviewer        | Y    |      |         | Y      |       |              |
| tester          | Y    | Y    | Y       | Y      |       |              |

## Subagent Dispatch (agent tool)

The `agent` tool enables an orchestrator agent to invoke other custom agents as subagents.

### Prerequisites

1. The orchestrator's frontmatter must include `agent` in `tools`
2. The orchestrator's frontmatter must list allowed subagents in `agents`
3. Each subagent must have a `.agent.md` file in `adapters/copilot/agents/`

### Invocation

The orchestrator instructs the LLM with natural language:
"Use the {name} agent as a subagent to {task description}."

VS Code automatically calls `runSubagent` to start the named agent in an isolated context.

### Behavior

- Each subagent runs with its own context window (no shared conversation history)
- Subagents have only the tools listed in their own frontmatter
- Subagent results are returned to the orchestrator as text
- By default, subagents cannot invoke further subagents (no nesting)
  - Enable via `chat.subagents.allowInvocationsFromSubagents` setting (max depth 5)

### Relevant frontmatter properties

| Property | Values | Description |
|----------|--------|-------------|
| `agents` | list of names / `*` / `[]` | Which subagents this agent may invoke |
| `user-invocable` | `true` (default) / `false` | If `false`, agent only appears as subagent, not in dropdown |
| `disable-model-invocation` | `true` / `false` | If `true`, cannot be invoked as subagent |

### Heartbeat agent mapping

| Role | adapters/copilot/agents/ file | Invoked by |
|------|-------------------------------|------------|
| Orchestrator | heartbeat.agent.md | User (via dropdown) |
| PDM | pdm.agent.md | heartbeat |
| Context Manager | context-manager.agent.md | heartbeat |
| Designer | designer.agent.md | heartbeat |
| Architect | architect.agent.md | heartbeat |
| Tester | tester.agent.md | heartbeat |
| Implementer | implementer.agent.md | heartbeat |
| Refactor | refactor.agent.md | heartbeat |
| Reviewer | reviewer.agent.md | heartbeat |
| QA | qa.agent.md | heartbeat |

## Hooks Event Names

| Event          | When it fires            | Notes                                   |
|----------------|-------------------------|-----------------------------------------|
| `postToolUse`  | After each tool call     | Used for retrospective-record, dashboard |
| `sessionEnd`   | When session terminates  | Used for auto-commit                    |

Note: `subagentStop` is NOT a recognized event (was used in older convention but silently ignored).

## Plugin Manifest

- Use `author` (not `publisher`) for the owner field in `.github/plugin/plugin.json`.
