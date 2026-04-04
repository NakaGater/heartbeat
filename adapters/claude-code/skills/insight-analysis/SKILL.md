---
name: insight-analysis
description: >
  UCD層別構造によるユーザーインサイト分析ワークフローを起動する。
  定性データ（テキストファイルまたはFigJamボード）を入力し、
  Raw -> Findings -> Insights -> Opportunities の4層構造で
  インサイトを体系的に抽出・蓄積する。
  Triggers on: "insight", "analysis", "user research", "interview analysis"
allowed-tools: Agent, Read, Bash, Grep, Glob
---

## Your Role

You are the entry point for the insight-analysis workflow.
Launch the `insight-analyst` agent to perform UCD layered analysis
on qualitative user research data.

## Usage

```
/heartbeat:insight-analysis --files <path...>
/heartbeat:insight-analysis --figma <board-url-or-id>
/heartbeat:insight-analysis --files <path...> --figma <board-url-or-id>
```

## Arguments

### --files <path...>

One or more file paths to qualitative data sources (interview transcripts,
survey results, feedback logs, etc.). Markdown format recommended.

Examples:
```
--files interview_2026-04-01.md
--files interview_A.md survey_results.md feedback_log.md
```

### --figma <board-url-or-id>

A Figma board URL or board ID for a FigJam board. Data is retrieved
via Figma MCP. Sticky notes, sections, and connector relationships
are extracted as text for analysis.

If Figma MCP is not available, a warning is displayed and the user
is guided to use --files as a fallback (graceful degradation).

Examples:
```
--figma https://www.figma.com/board/abc123
--figma abc123
```

### Combined usage

Both --files and --figma can be specified together:
```
/heartbeat:insight-analysis --files notes.md --figma abc123
```

## Workflow

1. **Input acquisition**: Validate arguments and read input data
   - --files: Read specified text files
   - --figma: Retrieve FigJam board data via Figma MCP
2. **Raw layer**: Record input metadata in `.heartbeat/insights/raw.jsonl`
3. **Findings extraction**: Extract facts (statements, behaviors) into `findings.jsonl`
4. **Insights derivation**: Derive patterns and insights into `insights.jsonl`
5. **Opportunities identification**: Identify improvement opportunities into `opportunities.jsonl`
6. **Summary generation**: Run `user-insight-summary.sh` to generate `summary.md`
7. **Notification**: Write completion entry to board.jsonl

## Agent

This skill delegates analysis to the `insight-analyst` agent
(`core/agent-personas/insight-analyst.md`).

## Output

All output is stored under `.heartbeat/insights/`:

| File | Layer | Description |
|------|-------|-------------|
| `raw.jsonl` | Raw | Source metadata (RAW-NNN) |
| `findings.jsonl` | Findings | Extracted facts (FND-NNN) |
| `insights.jsonl` | Insights | Derived insights (INS-NNN) |
| `opportunities.jsonl` | Opportunities | Identified opportunities (OPP-NNN) |
| `summary.md` | Summary | Cross-layer Markdown summary |

## Reference

- Story: `.heartbeat/stories/0045-pdm-insight-analysis/story.md`
- Agent persona: `core/agent-personas/insight-analyst.md`
- Analysis script: `core/scripts/user-insight-analyze.sh`
- Summary script: `core/scripts/user-insight-summary.sh`
