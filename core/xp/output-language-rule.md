# Output Language Rule

## Principle

Write all documents output to `.heartbeat/` in the same language
the user used in their input. If the user writes in Japanese, output
in Japanese. If the user writes in English, output in English.

## Applies to

- Markdown documents: brief.md, story.md, design.md, tasks.md,
  review.md, qa-report.md, verdict.md
- Knowledge base files: architecture.md, conventions.md,
  directory-map.md, dependencies.md
- Natural-language fields in JSONL: `note`, `summary`, `decision`,
  `reason`, `description`
- Retrospective outputs

## Does NOT apply to

- JSONL field names and enum values (`status`, `done`, `blocked`,
  `pending`, `action`) — always English
- Agent persona and protocol files (this file, values.md, etc.)
- Code and test files — follow the project's own conventions
- Script-generated artifacts (dashboard.html, insights.md)

## How to apply

1. Templates in persona files are structural guides, not literal text.
   Translate headings and body text into the user's language.
2. Keep technical terms in their original language (API names, library
   names, file paths, CLI commands).
3. Use one language consistently within a single document. Do not
   mix languages mid-document.
