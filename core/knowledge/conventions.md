# Conventions

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
- Shared helpers: `tests/helpers/common.sh`

## Styling

- Shell scripts: POSIX-compatible where possible
- JSON: 2-space indentation
- YAML front matter: block list format (`- item`)
- Timestamps: `date -u +%Y-%m-%dT%H:%M:%SZ` (consistent across all scripts)

## PostToolUse Hook Ordering

Both platforms (Claude Code, Copilot) fire PostToolUse hooks on Write/Edit in this order:

1. `board-stamp.sh` -- Overwrites `timestamp` on last line of board.jsonl with real UTC time
2. `retrospective-record.sh` -- Records retrospective entries
3. `generate-dashboard.sh` (async) -- Regenerates dashboard HTML

**Rationale:** board-stamp.sh must run before generate-dashboard.sh so the dashboard reads corrected timestamps. New hooks that modify board.jsonl data should be inserted before generate-dashboard.sh.

**Key pattern (hook-based auto-stamping):** When LLM agents cannot reliably produce accurate data (e.g., system time), use a PostToolUse hook to mechanically inject the correct value rather than relying on agent instructions alone.

## Dashboard ES5 Patterns

- Use `var`, `function`, `forEach` (no `let`/`const`/arrow functions)
- Use `filter()[0]` instead of `find()` for ES5 compatibility
- Defensive data access: `BACKLOG_DATA || []`, `STORIES_DATA || []`
- `sel.value = id` for programmatic dropdown selection (browser ignores invalid values)

Last updated: 2026-03-30
