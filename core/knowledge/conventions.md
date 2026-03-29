# Conventions

## Copilot Tool Alias Rules

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

| Agent           | read | edit | execute | search | playwright/* |
|-----------------|------|------|---------|--------|--------------|
| architect       | Y    | Y    |         | Y      |              |
| context-manager | Y    | Y    | Y       | Y      |              |
| designer        | Y    | Y    |         | Y      |              |
| implementer     | Y    | Y    | Y       | Y      |              |
| pdm             | Y    | Y    | Y       | Y      |              |
| qa              | Y    |      | Y       | Y      | Y            |
| refactor        | Y    | Y    | Y       | Y      |              |
| reviewer        | Y    |      |         | Y      |              |
| tester          | Y    | Y    | Y       | Y      |              |

## Copilot Hooks Event Names

| Event          | When it fires            | Notes                                   |
|----------------|-------------------------|-----------------------------------------|
| `postToolUse`  | After each tool call     | Used for retrospective-record, dashboard |
| `sessionEnd`   | When session terminates  | Used for auto-commit                    |

Note: `subagentStop` is NOT a recognized event (was used in older convention but silently ignored).

## Copilot Plugin Manifest

- Use `author` (not `publisher`) for the owner field in `.github/plugin/plugin.json`.

## Story Point Estimation

- Points measure **complexity and uncertainty**, not workload or effort.
- Valid values: **1** (Clear), **2** (Challenging), **3** (Uncertain) only.
- 3pt Gate Rule: A story estimated at 3pt must NOT proceed to implementation.
  The architect returns it to PdM (action: `split_story`, status: `rework`)
  for splitting, redefinition, or a research spike.
- Escape hatch: If a story remains 3pt after one rework attempt, the human
  can override and approve proceeding at 3pt.
- Completed stories retain their historical point values (may include
  pre-migration values like 5 or 13).

## Naming Rules

- Agent files: `{role}.agent.md` under `adapters/copilot/agents/`
- Core personas: `{role}.md` under `core/agent-personas/`
- Test files: `{descriptive_name}_spec.sh` under `tests/`
- Stories: kebab-case directory names under `.heartbeat/stories/`

## Test Conventions

- Framework: ShellSpec
- Test names: `{descriptive_name}_spec.sh`
- Assertion pattern: jq-based JSON validation with `>/dev/null 2>&1`
- Include defensive absence tests for removed/renamed keys

## Styling

- Shell scripts: POSIX-compatible where possible
- JSON: 2-space indentation
- YAML front matter: block list format (`- item`)

Last updated: 2026-03-29T04:00:00Z
Source story: point-criteria
