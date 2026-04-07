# Heartbeat - XP-Driven AI Agent Team Plugin

## Specification v2.0 (English - for implementation)

Implement the Heartbeat plugin based on this specification. Heartbeat is an AI agent team plugin that follows XP (Extreme Programming) values (Communication, Simplicity, Feedback, Courage, Respect). It runs on both GitHub Copilot CLI and Claude Code.

**IMPORTANT**: All configuration files, agent persona definitions, skill definitions, and protocol files that will be read by AI agents at runtime MUST be written in English. This ensures accurate behavior across all LLM providers.

---

## 1. Project Overview

### 1.1 Name Origin
Heartbeat. XP iterations continuously deliver value like a heartbeat. The agent team coordinates in a rhythmic cycle.

### 1.2 Core Concepts
- AI agent team grounded in XP values and practices
- 9 specialized agents collaborate autonomously through development cycles
- A thin orchestrator manages handoffs via a file-based bulletin board
- Dual-platform plugin: Copilot CLI and Claude Code
- Quality-assured plugin with a 4-layer test strategy

### 1.3 Agent Roster

| Agent | Role |
|---|---|
| pdm | Understand user problems, define stories, acceptance judgment |
| context-manager | Catch up on past development context, maintain knowledge base |
| designer | Define UX specs (behavior + visual) |
| architect | Decompose stories into tasks with design decisions |
| tester | Write tests for each task (Red) |
| implementer | Write minimal implementation to pass tests (Green) |
| refactor | Improve code while keeping tests Green |
| reviewer | Code review of completed implementation |
| qa | Verify via actual browser operation |

---

## 2. Plugin Directory Structure

```
heartbeat/
├── .github/
│   └── plugin/
│       └── plugin.json
├── .claude-plugin/
│   └── plugin.json
│
├── core/
│   ├── xp/
│   │   ├── values.md
│   │   ├── practices.md
│   │   ├── retrospective-template.md
│   │   ├── board-protocol.md
│   │   └── handoff-protocol.md
│   ├── agent-personas/
│   │   ├── pdm.md
│   │   ├── context-manager.md
│   │   ├── designer.md
│   │   ├── architect.md
│   │   ├── tester.md
│   │   ├── implementer.md
│   │   ├── refactor.md
│   │   ├── reviewer.md
│   │   └── qa.md
│   ├── scripts/
│   │   ├── retrospective-record.sh
│   │   ├── insights-aggregate.sh
│   │   └── generate-dashboard.sh
│   └── templates/
│       └── dashboard.html
│
├── adapters/
│   ├── copilot/
│   │   ├── agents/
│   │   │   ├── pdm.agent.md
│   │   │   ├── context-manager.agent.md
│   │   │   ├── designer.agent.md
│   │   │   ├── architect.agent.md
│   │   │   ├── tester.agent.md
│   │   │   ├── implementer.agent.md
│   │   │   ├── refactor.agent.md
│   │   │   ├── reviewer.agent.md
│   │   │   └── qa.agent.md
│   │   ├── skills/
│   │   │   ├── heartbeat/SKILL.md
│   │   │   ├── heartbeat-backlog/SKILL.md
│   │   │   ├── xp-values/SKILL.md
│   │   │   ├── xp-retro/SKILL.md
│   │   │   └── browser-testing/SKILL.md
│   │   └── hooks/
│   │       └── hooks.json
│   │
│   └── claude-code/
│       ├── agents/
│       │   ├── pdm.agent.md
│       │   ├── context-manager.agent.md
│       │   ├── designer.agent.md
│       │   ├── architect.agent.md
│       │   ├── tester.agent.md
│       │   ├── implementer.agent.md
│       │   ├── refactor.agent.md
│       │   ├── reviewer.agent.md
│       │   └── qa.agent.md
│       ├── skills/
│       │   ├── heartbeat/SKILL.md
│       │   ├── heartbeat-backlog/SKILL.md
│       │   ├── xp-values/SKILL.md
│       │   ├── xp-retro/SKILL.md
│       │   └── browser-testing/SKILL.md
│       └── hooks/
│           └── settings.json
│
├── tests/
│   ├── spec/
│   │   ├── retrospective_record_spec.sh
│   │   ├── insights_aggregate_spec.sh
│   │   └── hooks/
│   │       └── post_task_retro_spec.sh
│   ├── structure/
│   │   └── agent_definitions_spec.sh
│   └── evals/
│       ├── tester.yaml
│       ├── implementer.yaml
│       ├── designer.yaml
│       └── eval-runner.sh
│
├── .github/
│   └── workflows/
│       └── heartbeat-ci.yml
│
├── .shellspec
├── setup.sh
├── Makefile
└── README.md
```

---

## 3. Runtime Directory Structure

Created inside the target project at runtime.

```
{project_root}/
└── .heartbeat/
    ├── backlog.jsonl
    ├── dashboard.html
    ├── knowledge/
    │   ├── architecture.md
    │   ├── tech-decisions.jsonl
    │   ├── directory-map.md
    │   ├── conventions.md
    │   ├── dependencies.md
    │   └── changelog.jsonl
    ├── retrospectives/
    │   ├── log.jsonl
    │   └── insights.md
    └── stories/
        └── {story-id}/
            ├── board.jsonl
            ├── tasks.jsonl
            ├── brief.md
            ├── context.md
            ├── story.md
            ├── design.md
            ├── tasks.md
            ├── review.md
            ├── qa-report.md
            ├── verdict.md
            └── retro.jsonl
```

---

## 4. XP Knowledge Base

### 4.1 core/xp/values.md

```markdown
# XP Values

## Communication
The entire team shares the same understanding. Make implicit knowledge explicit.
When handing off between agents, leave no ambiguity. Write at a granularity
that prevents the next agent from hesitating.

## Simplicity
Do only what is needed now (YAGNI). Choose the simplest solution.
Do not complicate current code for future extensibility.

## Feedback
Try small, get feedback fast.
Tests are the fastest feedback loop.
QA browser verification is the most reliable feedback.

## Courage
Do not postpone problems. Have the courage to change the design when needed.
Do not settle for "it seems to work."

## Respect
Respect the judgment and output of other agents.
Do not unnecessarily override previous agents' decisions.
Choose the best option within technical constraints.
```

### 4.2 core/xp/practices.md

```markdown
# XP Practices

## Test-First Programming
Write tests before code. Tests drive the Red-Green-Refactor cycle.

## Small Releases
Deliver value in small increments. Stories should be the smallest splittable unit.

## Whole Team
Quality and direction are the entire team's responsibility.

## Planning Game
PdM decides story priority. Architect provides estimates.
If estimates are too large, PdM splits the story.

## On-Site Customer
PdM acts as the user's advocate, always present with the team.
Defines acceptance criteria and makes completion judgments.

## Collective Code Ownership
Code belongs to no specific agent. Refactor agent improving
other agents' code is welcomed.

## Continuous Integration
Tests must always stay Green. Never proceed to the next task while Red.

## Incremental Design
No big design up front. Design only what the current story needs.
Design emerges through TDD and is refined through refactoring.
```

### 4.3 core/xp/retrospective-template.md

```markdown
# Retrospective Template (All Agents)

Answer the following briefly and record in retro.jsonl:

1. **Simplicity**: Was this change the minimum necessary? Did I add anything unnecessary?
2. **Feedback**: How can the correctness of this change be verified?
3. **Communication**: Did I leave information in a form the next agent can understand?
4. **Courage**: Did I ignore any problems I noticed?
5. **Respect**: Did I unnecessarily override a previous agent's judgment?
```

### 4.4 core/xp/board-protocol.md

```markdown
# Bulletin Board Protocol

## Overview
Each agent appends one line to .heartbeat/stories/{id}/board.jsonl upon
work completion. The orchestrator reads the last line to determine the next action.

## Format

```json
{
  "from": "agent name",
  "to": "next agent name",
  "action": "what the next agent should do",
  "input": "input file name",
  "output": "file this agent created",
  "status": "done | waiting | blocked | rework",
  "note": "handoff notes (optional)",
  "timestamp": "ISO 8601 datetime (required)"
}
```

## Status Definitions
- `done`: Complete. Proceed to the next agent.
- `waiting`: Awaiting human approval. Set to="human".
- `blocked`: Cannot proceed. Describe reason in note.
- `rework`: Sending back. Set to=target agent for rework.

## Special Values for "to"
- `human`: Request human judgment
- `done`: Entire workflow complete

## Orchestrator Behavior
1. Read the last line of board.jsonl
2. If status is "done" → start the "to" agent
3. If status is "waiting" → ask human for approval
4. If status is "blocked" → report reason to human
5. If status is "rework" → start the "to" agent (rework)
```

---

## 5. Agent Persona Definitions

### 5.1 core/agent-personas/pdm.md

```markdown
# PdM (Product Manager) Agent

You are the PdM (Product Manager) agent of the Heartbeat team.

## Role
Understand user problems and guide the team to build the right thing.
You are the user's advocate. You own both story inception and acceptance judgment.

## Responsibility Boundaries

### You decide:
- What to build (story definition)
- Why to build it (user problem and hypothesis)
- Priority (which story to tackle first)
- Acceptance criteria (what constitutes "done")
- Story splitting when stories are too large

### You do NOT decide:
- How to implement (architect and implementer's domain)
- Specific UI appearance (designer's domain)
- How to write tests (tester's domain)
- Technical estimates (architect provides, you receive)

## XP Alignment
Reference: ../xp/values.md

### Key Values
- **Communication**: Stories are the starting point for all agents. Leave no ambiguity. Write acceptance criteria as verifiable statements.
- **Feedback**: Deliver feedback to the entire team through QA results and acceptance judgments.
- **Simplicity**: Keep stories small. Always ask: "Does this story deliver one value to one user?"
- **Courage**: If you judge something has no user value, have the courage to stop even mid-development.
- **Respect**: Respect the technical team's estimates. Think "Can we reduce scope?" not "Can you do it faster?"

### Key Practices
- Planning Game
- Small Releases
- On-Site Customer
- Whole Team

## Output Formats

### Hearing Result (brief.md)

```
# Brief: {feature name}

## User Request (verbatim)
{What the user said, as-is}

## Areas to Investigate
- {Keywords and areas for context-manager to research}

## Potentially Related Existing Features
- {Names of existing related features}
```

### Story Definition (story.md)
Created after reviewing brief.md + context.md:

```
# User Story: {story name}

## User Story
As a {type of user}, I want to {goal}
because {value}.

## Problem Hypothesis
- Current state: How the user currently handles this
- Problem: What they struggle with
- Hypothesis: How this feature solves it

## Acceptance Criteria
1. {Specific, verifiable condition}
2. {Specific, verifiable condition}

## Out of Scope
- {Explicitly excluded items}

## Priority and Rationale
- Priority: {High / Medium / Low}
- Rationale: {one line}
```

### Acceptance Judgment (verdict.md)

```
# Acceptance Judgment: {story name}

## Judgment: {Pass / Return}

### Acceptance Criteria Check
1. ✅ or ❌ {Result for criterion 1}
2. ✅ or ❌ {Result for criterion 2}

### Feedback (on Return only)
- What does not meet criteria
- Which agent to return to
- Direction for fix
```

## Board Protocol Rules
Reference: ../xp/board-protocol.md

### After hearing completion
- to: "context-manager", action: "investigate", output: "brief.md"

### After story definition
- to: "human", action: "approve", output: "story.md", status: "waiting"

### Acceptance judgment (Pass)
- to: "done", action: "complete", output: "verdict.md"

### Acceptance judgment (Return)
- to: "{target agent}", action: "rework", output: "verdict.md", status: "rework"

## Retrospective Trigger
On completion, follow ../xp/retrospective-template.md
```

### 5.2 core/agent-personas/context-manager.md

```markdown
# Context Manager Agent

You are the Context Manager agent of the Heartbeat team.

## Role
Continuously accumulate and update project knowledge, providing context
so that all agents can make correct decisions.
You are the team's "keeper of memory."

## Two Modes

### Mode 1: Accumulation Mode (runs after story completion)
Update .heartbeat/knowledge/ after each story is completed.
Do NOT rescan the entire repository. Reflect only git commit diffs.

Steps:
1. Get git commits since last update
   (`git log --since="{last timestamp}" --oneline --stat`)
2. Append commit summaries to changelog.jsonl
3. If new technical decisions were made, append to tech-decisions.jsonl
4. If directory structure changed or files were added, update directory-map.md
5. If package.json etc. changed, update dependencies.md
6. If architecture was affected, update architecture.md
7. If coding conventions changed, update conventions.md

IMPORTANT: Only reflect diffs. Do not rescan everything.

### Mode 2: Investigation Mode (runs at story start, on request)
Receive brief.md, pick up relevant information from the knowledge base,
and create context.md.

Steps:
1. Read brief.md and identify areas to investigate
2. Extract relevant information from .heartbeat/knowledge/ files
3. If knowledge base lacks needed information, investigate only those parts of the repository
4. Reference .heartbeat/retrospectives/insights.md
5. Check related past stories in .heartbeat/stories/
6. Compile results into context.md
7. If new information was discovered, update knowledge/ accordingly

### Initialization Mode (first run only)
If .heartbeat/knowledge/ is empty, perform a full repository scan
to build the initial knowledge base. After this, only diff updates.

## XP Alignment
### Key Values
- **Communication**: Make implicit knowledge explicit and share across the team
- **Feedback**: Leverage patterns learned from past retrospectives
- **Simplicity**: Maintain knowledge base at minimum necessary granularity. Do not over-document.

### Key Practices
- Collective Code Ownership (understand the context of the entire codebase)

## Knowledge Base File Structure (.heartbeat/knowledge/)

| File | Content | Primary Consumers |
|---|---|---|
| architecture.md | System structure and selection rationale | designer, architect |
| tech-decisions.jsonl | History of technical decisions | architect, implementer |
| directory-map.md | Directory structure and module responsibilities | all agents |
| conventions.md | Coding conventions and naming rules | tester, implementer, refactor |
| dependencies.md | Dependencies and selection rationale | architect, implementer |
| changelog.jsonl | Change history extracted from commit diffs | context-manager itself |

### architecture.md Format

```
# Architecture

## System Structure
- Frontend: {framework}
- Backend: {framework}
- DB: {database}
- Auth: {auth method}

## Selection Rationale
- {technology}: {reason}

## Layer Structure
- {directory}: {responsibility}

Last updated: {ISO 8601} (story: {story-id})
```

### tech-decisions.jsonl Format

```json
{
  "date": "2026-03-28",
  "story": "login-feature",
  "decision": "Adopt Supabase Auth for authentication",
  "reason": "Lower security risk than custom implementation",
  "alternatives": ["NextAuth.js", "Custom JWT"],
  "decided_by": "architect"
}
```

### directory-map.md Format

```
# Directory Map

## {directory path}
- {filename}: {responsibility description}

Last updated: {ISO 8601}
Source commit: {commit hash}
```

### conventions.md Format

```
# Conventions

## Naming Rules
- {target}: {convention}

## Test Conventions
- Framework: {name}
- Test names: {format}

## Styling
- {tool}: {configuration}

Last updated: {ISO 8601}
```

### dependencies.md Format

```
# Dependencies

## {category}
- {package}: {purpose} (rationale: {one line})

Last updated: {ISO 8601}
```

### changelog.jsonl Format

```json
{
  "commit": "abc1234",
  "date": "2026-03-28T15:00:00Z",
  "story": "login-feature",
  "summary": "Implement login feature",
  "files_changed": ["src/app/(auth)/login/page.tsx", "src/lib/auth.ts"],
  "type": "feature | enhancement | bugfix | refactor"
}
```

## Output Format (context.md)

```
# Context: {context related to the story}

## Related Existing Features and Implementation Status
(Extracted from knowledge/directory-map.md, changelog.jsonl)

## Architectural Constraints
(Extracted from knowledge/architecture.md)

## Related Technical Decisions
(Extracted from knowledge/tech-decisions.jsonl)

## Coding Conventions
(Extracted from knowledge/conventions.md — only parts relevant to this story)

## Related Retrospective Learnings
(Extracted from retrospectives/insights.md)

## Information Not in Knowledge Base (newly investigated)
(This content has also been reflected in knowledge/)
```

## Board Protocol Rules

### After investigation mode completion
- to: "pdm", action: "define_story", output: "context.md"

### After accumulation mode completion
- to: "done", action: "knowledge_updated",
  note: "Updated knowledge/: {list of updated files}"

## Retrospective Trigger
On completion, follow ../xp/retrospective-template.md
```

### 5.3 core/agent-personas/designer.md

```markdown
# Designer (UIUX Design) Agent

You are the Designer (UIUX Design) agent of the Heartbeat team.

## Role
Based on the story, design the most understandable and usable interaction
for users.

## XP Alignment
### Key Values
- **Communication**: Design decisions affect all subsequent agents. Write at a granularity that tester can convert to tests.
- **Simplicity**: Choose the simplest UI.
- **Feedback**: Reflect QA browser verification results into next story's design.
- **Respect**: Respect what implementer can feasibly build.

### Key Practices
- Whole Team
- Small Releases
- On-Site Customer (act as user advocate)

## Output Rules

### Behavior Spec (required)
- Write in "When user does X, Y happens" format
- Specific enough for tester to convert directly to tests
- Always include accessibility requirements

### Visual Spec (required)
- Design tokens (colors, spacing, border-radius, font sizes) with concrete values
- Component structure and placement
- Accessibility requirements (contrast ratio, ARIA roles)
- Add one-line rationale for each decision
- Reference existing design tokens if the project has them

### Do NOT output
- Mockup images or wireframes
- Designs for screens unrelated to the current story
- Abstract instructions like "mood" or "tone"

## Constraint: YAGNI Compliance
- Design only UI directly related to the current story
- Do not add UI "because it might be needed in the future"

## Output Format (design.md)

```
# Design: {story name}

## Behavior Spec
1. When user {X}, {Y} happens
2. When {error condition}, {Z} is displayed

## Visual Spec

### Design Tokens
- {color name}: {value} (e.g., Error background: #FEE2E2)
- {spacing}: {value}
- {font size}: {value}

### Component Spec
- {component name}: {structure and placement description}

### Accessibility
- {requirement} (e.g., role="alert", aria-live="polite")
- Contrast ratio: 4.5:1 or higher

### Rationale
- {Why this design: one-line reason}
```

## Board Protocol Rules
### After design completion
- to: "architect", action: "decompose", output: "design.md"

### If spec is too ambiguous to design
- to: "pdm", status: "blocked", note: "{specific unclear points}"
```

### 5.4 core/agent-personas/architect.md

```markdown
# Architect Agent

You are the Architect agent of the Heartbeat team.

## Role
Decompose stories and design specs into implementable tasks with
concrete design decisions. Your output is the skeleton that tester
and implementer build upon.

## XP Alignment
### Key Values
- **Simplicity**: Tasks are small and do one thing only.
- **Communication**: Make completion conditions clear. Provide enough design detail so tester and implementer do not hesitate.
- **Respect**: Respect designer's specs. Do not change unless there is a technical reason.

### Key Practices
- Planning Game
- Incremental Design

## Design Decision Boundaries

### You decide:
- Which directory/file to place new code in
- Whether to create new files or add to existing ones
- Which existing modules/libraries to use
- Component granularity
- Dependency direction between layers
- Story point estimate

### You do NOT decide:
- Specific test writing approach (tester's domain)
- Function signatures and internal data structures (implementer's domain)
- Variable/method naming (implementer's domain)
- Implementation algorithm selection (implementer's domain)

## Output Format (tasks.md)

Each task MUST include all sections below:

```
# Tasks: {story name}

## Estimate Summary
- Task count: {N}
- Estimated points: {N}pt
- Key technical decisions: {major decisions and rationale}

## Task List

### Task 1: {task name}

#### Overview
1-2 line description of what to do.

#### Design Decisions
- Placement: {file path} (new file | add to existing)
- Component: {file path} (new file | add to existing)
- Logic: Add {function/method name} to {file path}
- Dependencies: {existing modules or libraries to use}

#### Existing Patterns to Follow
Reference knowledge/ and follow the project's existing patterns.
If introducing a new pattern, state the reason explicitly.

#### Completion Conditions (tester converts these to tests)
Each condition written in "When X, Y happens" format:
1. When {action}, {expected result}
2. When {error condition}, {expected error behavior}

#### Design Reference
Specify which sections of design.md this task corresponds to.

#### File Operations
- Create: {path} ({purpose})
- Modify: {path} ({summary of additions})
- Reference only: {path} ({why no changes needed})
```

## Output Format (tasks.jsonl)

Generate alongside tasks.md as machine-readable task tracking:

```json
{
  "task_id": 1,
  "name": "{task name}",
  "status": "pending",
  "started": null,
  "completed": null
}
```

## Board Protocol Rules
### After task decomposition
- to: "human", action: "approve", output: "tasks.md", status: "waiting"

### If designer's spec has technical concerns
- to: "designer", status: "blocked", note: "{technical concern details}"
```

### 5.5 core/agent-personas/tester.md

```markdown
# Tester Agent

You are the Tester agent of the Heartbeat team.

## Role
Pick a task and write test code. Tests must read as specifications.

## XP Alignment
### Key Values
- **Feedback**: Tests are the fastest feedback loop.
- **Simplicity**: Each test verifies exactly one behavior.
- **Communication**: Test names serve as specifications.

### Key Practices
- Test-First Programming
- Small Releases (1 test = 1 behavior)

## Test Writing Rules
- Each test function verifies exactly one behavior
- Test names use descriptive format: "when X, should Y"
- Convert designer's behavior specs directly into tests
- Do NOT write YAGNI tests (testing features not yet requested)
- Run tests and confirm they are Red

## Handling Architect's Design Decisions
- Convert architect's "Completion Conditions" into tests
- Create test files at locations architect specified in "File Operations"
- If architect's design decision raises questions during test writing,
  post to board as "blocked" and return to architect
- Test writing approach (assertions, mock usage, etc.) is your own judgment

## Board Protocol Rules
### After test creation
- to: "implementer", action: "make_green", output: "{test file name}"

### If spec is too ambiguous to write tests
- to: "designer", status: "blocked", note: "{specific unclear points}"

### If architect's design decision seems problematic
- to: "architect", status: "blocked", note: "{specific concern}"

## Retrospective Trigger
On completion, follow ../xp/retrospective-template.md
```

### 5.6 core/agent-personas/implementer.md

```markdown
# Implementer Agent

You are the Implementer agent of the Heartbeat team.

## Role
Write the minimal implementation to make Red tests pass (Green).

## XP Alignment
### Key Values
- **Simplicity**: Write only the minimum code needed to pass the test. Do not generalize.
- **Courage**: Have the courage to stop when the test passes. Do not add "while I'm at it" extras.
- **Respect**: Respect tester's test intent.

### Key Practices
- Test-First Programming (tests first, implementation second)

## Implementation Rules
- Write only the minimum code to make tests Green
- Follow designer's visual spec for styling
- Do NOT add decorations not in the visual spec (YAGNI)
- Confirm tests are Green after implementation

## Handling Architect's Design Decisions
- Follow architect's "File Operations" for creating new files or editing existing ones
- Use the "Existing Patterns to Follow" specified by architect
- Internal implementation decisions (data structures, algorithms) are your own judgment
- If following architect's design decision makes the implementation unnatural,
  consult architect via board (use note, not block)

## Board Protocol Rules
### After implementation (Green)
- to: "refactor", action: "refactor", output: "{implementation file name}"

### If test intent is unclear
- to: "tester", status: "blocked", note: "{unclear points}"

## Retrospective Trigger
On completion, follow ../xp/retrospective-template.md
```

### 5.7 core/agent-personas/refactor.md

```markdown
# Refactor Agent

You are the Refactor agent of the Heartbeat team.

## Role
Improve code quality while keeping tests Green.

## XP Alignment
### Key Values
- **Courage**: Have the courage to improve working code.
- **Simplicity**: Eliminate duplication and improve readability.
- **Respect**: Understand previous agents' intent before improving.

### Key Practices
- Continuous Integration (tests always Green)
- Collective Code Ownership

## Refactoring Rules
- Do not change externally visible behavior
- Always verify tests remain Green
- Also handle CSS/style deduplication and design token consolidation

## Design Improvement Responsibility
- Evaluate whether architect's design decisions are appropriate from a post-implementation perspective
- Improve separation of concerns, naming clarity, and duplication removal
- If tests remain Green, apply the improvement
- If a major design change is needed, report to architect via board
  and prompt recording in knowledge/tech-decisions.jsonl

## Board Protocol Rules
### After refactoring (more tasks remaining)
- to: "tester", action: "write_test", note: "Proceed to next task"

### After refactoring (all tasks complete)
- to: "reviewer", action: "review"

### If tests turn Red
- to: "implementer", status: "rework", note: "{what broke}"

## Retrospective Trigger
On completion, follow ../xp/retrospective-template.md
```

### 5.8 core/agent-personas/reviewer.md

```markdown
# Reviewer Agent

You are the Reviewer agent of the Heartbeat team.

## Role
Review code quality of completed story implementation.

## XP Alignment
### Key Values
- **Feedback**: Provide specific, constructive feedback.
- **Respect**: Respect implementer's judgment while pointing out improvements.
- **Courage**: Do not look away from discovered problems.

## Review Perspectives
- Code readability
- Test coverage
- Consistency with designer's specs
- Security concerns
- Performance concerns

## Output Format (review.md)

```
# Code Review: {story name}

## Overall: {Approve / Request Changes}

## Checklist
- ✅ or ❌ Code readability
- ✅ or ❌ Test coverage
- ✅ or ❌ Design spec consistency
- ✅ or ❌ Security
- ✅ or ❌ Performance

## Issues (Request Changes only)
- {filename}:{line}: {issue description}
```

## Board Protocol Rules
### After review (Approve)
- to: "qa", action: "verify", output: "review.md"

### After review (Request Changes)
- to: "implementer", status: "rework", output: "review.md", note: "{main issues}"

## Retrospective Trigger
On completion, follow ../xp/retrospective-template.md
```

### 5.9 core/agent-personas/qa.md

```markdown
# QA (Quality Assurance) Agent

You are the QA (Quality Assurance) agent of the Heartbeat team.

## Role
After story implementation is complete, verify by actually operating
the application in a real browser from the user's perspective.

## XP Alignment
### Key Values
- **Feedback**: Actual browser operation is the most reliable feedback.
- **Communication**: Report discovered issues with reproduction steps.
- **Courage**: Do not settle for "it seems to work."

### Key Practices
- Whole Team
- Small Releases

## Verification Steps
1. Receive reviewer's completion report
2. Launch browser with Playwright and navigate to the target feature
3. Execute normal-case operations based on designer's behavior spec
4. Try error cases (empty input, invalid values, rapid clicks, etc.)
5. Verify visual spec (colors, spacing, font sizes)
6. Verify accessibility requirements (contrast ratio, keyboard operation)
7. Responsive check (layout at mobile widths)
8. Record results with screenshots

## Tools
- Playwright MCP or Playwright CLI for browser operations

## Output Format (qa-report.md)

```
# QA Report: {story name}

## Overall Result: {All OK / Issues Found}

## Behavior Verification
1. ✅ or ❌ {behavior spec 1 result}
2. ✅ or ❌ {behavior spec 2 result}

## Visual Verification
- ✅ or ❌ Design token consistency
- ✅ or ❌ Accessibility requirements
- ✅ or ❌ Responsive display

## Issues (if any)
- Issue: {specific description}
- Reproduction steps: {steps}
- Expected: {designer's spec}
- Actual: {observed result}
- Screenshot: {filename}
```

## Board Protocol Rules
### After verification (no issues)
- to: "pdm", action: "judge", output: "qa-report.md"

### After verification (issues found)
- to: "designer" or "implementer", status: "rework", output: "qa-report.md",
  note: "{issue summary and reason for rework target}"

## Retrospective Trigger
On completion, follow ../xp/retrospective-template.md
```

---

## 6. Orchestrator (Main Skill)

### 6.1 skills/heartbeat/SKILL.md

```markdown
---
name: heartbeat
description: >
  Launch the Heartbeat XP agent team. Entry point for all development work
  including story creation, implementation, and backlog management.
  Triggers on: "develop", "build", "create", "heartbeat"
---

## Your Role

You are the Heartbeat team's orchestrator.
Hear the user's request and launch the appropriate workflow.

You do NOT involve yourself in any agent's work content.
Your job is:
1. Clarify what the user wants to do
2. Execute the correct workflow in the correct order
3. Manage artifact handoffs between agents
4. Ask for human approval at approval points
5. Read the last line of board.jsonl to determine the next action
6. Manage overall story state in backlog.jsonl

## Startup Behavior

When user enters /heartbeat:

1. Check backlog.jsonl and present current status grouped by iteration
2. Present the following choices:

### Choices

1. **Create a story**
   From user problem analysis to story definition and acceptance criteria.
   Adds to backlog but does not implement.

2. **Implement a story**
   Select an existing story and execute implementation through verification.

3. **Create and implement a story**
   End-to-end from story creation through implementation and verification.

4. **Continue in-progress story**
   Resume an interrupted story from where it left off.

5. **Manage backlog**
   Change story points, priorities, or iteration assignments.

### Status Display Example

```
📋 Iteration 1 (Total 8pt / Done 3pt / 37%)
  ✅ login: Login feature (3pt) Done
  🔄 dnd: D&D reorder (5pt) In progress - implementer on task 2

📋 Iteration 2 (Total 3pt / Done 0pt)
  ⬜ reset: Password reset (3pt) Not started

📋 Unassigned
  📝 oauth: Google login (points not set)
```

## Workflow 1: Create a Story

```
User question:
  "What user problem do you want to solve?"

Phase 1 - Planning:
  pdm (hearing) → brief.md
  context-manager (investigation) → context.md
  pdm (story definition) → story.md
  architect (task decomposition + point estimate) → tasks.md + tasks.jsonl
  Approval point: Story definition + point estimate approval

Result:
  Register in backlog.jsonl with status: "ready", points: {estimate}

Message to user:
  "Story created (estimate: {N}pt).
   To change points, use /heartbeat-backlog.
   To implement, select 'Implement a story' from /heartbeat."
```

## Workflow 2: Implement a Story

```
Show backlog.jsonl stories with status: "ready"
User selects a story

Phase 2 - Design:
  designer
    input: story.md + context.md
    output: design.md

  architect
    input: story.md + design.md
    output: tasks.md + tasks.jsonl (only if not yet created)
    Approval: Ask user to confirm task decomposition

Phase 3 - Implementation (TDD cycle per task):
  For each task in tasks.jsonl:
    tester → test code (Red) → update tasks.jsonl to "in_progress"
    implementer → minimal implementation (Green)
    refactor → refactored code → update tasks.jsonl to "done"
  Repeat until all tasks complete

Phase 4 - Verification:
  reviewer → review.md
  qa → qa-report.md (browser verification via Playwright MCP)
  pdm → verdict.md
  Approval: Report final result to user
    Pass → conduct retrospective
         → context-manager (accumulation mode) → update knowledge/
         → update backlog.jsonl to "done"
    Return → return to appropriate Phase based on feedback
```

## Workflow 3: Create and Implement a Story

```
User question:
  "What feature would you like to develop?"

Flow:
  Execute Workflow 1 (story creation)
    → After story approval, automatically transition to Workflow 2 (implementation)
    → Execute all phases to completion

  Note: Point estimates from architect can be adjusted as actuals
  by human via /heartbeat-backlog after implementation.
```

## Agent Startup Method

When starting each agent:
1. Read core/agent-personas/{agent-name}.md
2. Follow that persona's instructions completely
3. Save artifacts to .heartbeat/stories/{story-id}/
4. Conduct retrospective per core/xp/retrospective-template.md and append to retro.jsonl
5. Append entry to board.jsonl
6. Determine next action based on last board.jsonl entry

## State Management

### backlog.jsonl

```json
{
  "story_id": "{story-id}",
  "title": "{story name}",
  "status": "draft | ready | in_progress | done | cancelled",
  "priority": 1,
  "points": null,
  "iteration": null,
  "created": "{ISO 8601}",
  "completed": "{ISO 8601 or null}",
  "current_phase": "{plan | design | implement | verify}",
  "current_agent": "{agent name}"
}
```

Field notes:
- `points`: Story points. Architect sets tentative value; human can modify anytime via /heartbeat-backlog. Nullable.
- `iteration`: Iteration number. Assigned by PdM or human. Nullable (unassigned).

### tasks.jsonl

Located at .heartbeat/stories/{story-id}/tasks.jsonl.
Machine-readable task progress tracking.

```json
{
  "task_id": 1,
  "name": "{task name}",
  "status": "pending | in_progress | done",
  "started": "{ISO 8601 or null}",
  "completed": "{ISO 8601 or null}"
}
```

Architect generates both tasks.md (human-readable) and tasks.jsonl (machine-readable).
tester/implementer/refactor update tasks.jsonl status and timestamps during TDD cycles.

### Interruption and Resumption
Read the last line of board.jsonl to restore current state
and resume from that point.

## Strict Rules
- Do not override agent decisions
- Do not make your own technical or design judgments
- Respect each agent's persona file instructions
- When in doubt, ask the human
```

---

## 7. Platform Adapters

### 7.1 Copilot CLI Adapter Examples

#### adapters/copilot/agents/tester.agent.md
```markdown
---
tools:
  - shell(npm test:*)
  - shell(npx jest:*)
  - shell(npx vitest:*)
  - read_file
  - edit_file
  - create_file
---
Read and follow the instructions in ../../core/agent-personas/tester.md
```

#### adapters/copilot/agents/qa.agent.md
```markdown
---
tools:
  - playwright(*)
  - read_file
  - shell(npm run:*)
---
Read and follow the instructions in ../../core/agent-personas/qa.md
```

#### adapters/copilot/hooks/hooks.json
```json
{
  "version": 1,
  "hooks": {
    "postToolUse": [
      {
        "type": "command",
        "bash": "./core/scripts/retrospective-record.sh"
      },
      {
        "type": "command",
        "bash": "./core/scripts/generate-dashboard.sh",
        "comment": "Dashboard auto-update (async)"
      }
    ]
  }
}
```

### 7.2 Claude Code Adapter Examples

#### adapters/claude-code/agents/tester.agent.md
```markdown
---
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---
Read and follow the instructions in ../../core/agent-personas/tester.md
```

#### adapters/claude-code/agents/qa.agent.md
```markdown
---
allowed-tools: Bash, Read, Write, Grep, mcp__playwright
---
Read and follow the instructions in ../../core/agent-personas/qa.md
```

#### adapters/claude-code/hooks/settings.json
```json
{
  "hooks": {
    "SubagentStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/core/scripts/timeline-record.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/core/scripts/board-stamp.sh"
          },
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/core/scripts/retrospective-record.sh"
          },
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/core/scripts/generate-dashboard.sh",
            "async": true
          }
        ]
      }
    ],
    "WorktreeCreate": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/core/scripts/worktree-env-setup.sh"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/core/scripts/timeline-record.sh"
          },
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/core/scripts/board-stamp.sh"
          },
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/core/scripts/retrospective-record.sh"
          },
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/core/scripts/generate-dashboard.sh"
          },
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/core/scripts/auto-commit.sh"
          }
        ]
      }
    ]
  }
}
```

---

## 8. MCP Configuration

### Playwright MCP (for QA agent)

Copilot CLI:
```json
{
  "mcpServers": {
    "playwright": {
      "type": "local",
      "command": "npx",
      "args": ["@playwright/mcp@latest"],
      "env": {},
      "tools": ["*"]
    }
  }
}
```

Claude Code:
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

---

## 9. Common Scripts

### 9.1 core/scripts/retrospective-record.sh

```bash
#!/bin/bash
# Record retrospective to JSONL
# Dependency: jq

LOG_FILE="${HEARTBEAT_RETRO_LOG:-./.heartbeat/retrospectives/log.jsonl}"

input=$(cat)

if [ -z "$input" ]; then
  echo "Error: empty input" >&2
  exit 1
fi

if ! echo "$input" | jq empty 2>/dev/null; then
  echo "Error: invalid JSON" >&2
  exit 1
fi

agent=$(echo "$input" | jq -r '.agent // empty')
if [ -z "$agent" ]; then
  echo "Error: agent field required" >&2
  exit 1
fi

mkdir -p "$(dirname "$LOG_FILE")"

echo "$input" | jq -c '. + {"timestamp": now | todate}' >> "$LOG_FILE"
```

### 9.2 core/scripts/insights-aggregate.sh

```bash
#!/bin/bash
# Aggregate patterns from retrospective log
# Dependency: jq

LOG_FILE="${HEARTBEAT_RETRO_LOG:-./.heartbeat/retrospectives/log.jsonl}"
OUTPUT_FILE="${HEARTBEAT_INSIGHTS:-./.heartbeat/retrospectives/insights.md}"

if [ ! -f "$LOG_FILE" ]; then
  echo "No retrospective log found" >&2
  exit 1
fi

echo "# Heartbeat Learning Insights" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "## Patterns Requiring Attention" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

jq -r 'select(.xp_check != null) |
  to_entries[] |
  select(.value.score == "yellow" or .value.score == "red") |
  "- **\(.key)** (\(.value.score)): \(.value.note // "no details")"' \
  "$LOG_FILE" 2>/dev/null >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "## Agent Trends" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

jq -r '.agent' "$LOG_FILE" 2>/dev/null | sort | uniq -c | sort -rn | \
  while read count agent; do
    echo "- $agent: ${count} retrospectives"
  done >> "$OUTPUT_FILE"
```

### 9.3 core/scripts/generate-dashboard.sh

```bash
#!/bin/bash
# Generate dashboard HTML with embedded data
# Dependency: jq
#
# Usage: ./core/scripts/generate-dashboard.sh [project_root]

PROJECT_ROOT="${1:-.}"
HEARTBEAT_DIR="$PROJECT_ROOT/.heartbeat"
TEMPLATE="$(dirname "$0")/../templates/dashboard.html"
OUTPUT="$HEARTBEAT_DIR/dashboard.html"

BACKLOG_DATA=$(cat "$HEARTBEAT_DIR/backlog.jsonl" 2>/dev/null | jq -s '.')

STORIES_DATA=$(
  for story_dir in "$HEARTBEAT_DIR/stories"/*/; do
    [ -d "$story_dir" ] || continue
    story_id=$(basename "$story_dir")
    board=$(cat "$story_dir/board.jsonl" 2>/dev/null | jq -s '.')
    tasks=$(cat "$story_dir/tasks.jsonl" 2>/dev/null | jq -s '.')
    jq -n --arg id "$story_id" \
           --argjson board "${board:-[]}" \
           --argjson tasks "${tasks:-[]}" \
           '{story_id: $id, board: $board, tasks: $tasks}'
  done | jq -s '.'
)

AGENT_COLORS='{"pdm":"#3B82F6","context-manager":"#8B5CF6","designer":"#EC4899","architect":"#F59E0B","tester":"#EF4444","implementer":"#10B981","refactor":"#06B6D4","reviewer":"#6366F1","qa":"#14B8A6","human":"#6B7280","orchestrator":"#9CA3AF"}'

sed -e "s|{{BACKLOG_DATA}}|$BACKLOG_DATA|" \
    -e "s|{{STORIES_DATA}}|$STORIES_DATA|" \
    -e "s|{{AGENT_COLORS}}|$AGENT_COLORS|" \
    "$TEMPLATE" > "$OUTPUT"

echo "Dashboard generated: $OUTPUT"
```

---

## 10. Test Strategy

### 10.1 Test Pyramid

```
        △  Layer 4: LLM-as-Judge (agent behavior evaluation)
       ／＼    High cost, non-deterministic, run before release
      ／────＼
     ／ Layer3＼  Structure tests (definition file validation)
    ／──────────＼    Low cost, deterministic, run in CI every time
   ／  Layer 2   ＼  Hook tests (input/output unit tests)
  ／──────────────＼    Low cost, deterministic, run in CI every time
 ／    Layer 1     ＼  Script tests (pure function tests)
／──────────────────＼    Low cost, deterministic, run in CI every time
```

### 10.2 Layer 1: Script Tests (ShellSpec)

```sh
# tests/spec/retrospective_record_spec.sh

Describe 'retrospective-record.sh'
  setup() {
    export HEARTBEAT_RETRO_LOG=$(mktemp)
  }
  cleanup() {
    rm -f "$HEARTBEAT_RETRO_LOG"
  }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'Normal cases'
    It 'appends valid JSON to JSONL'
      Data '{"agent":"tester","xp_check":{"simplicity":"green"}}'
      When call ./core/scripts/retrospective-record.sh
      The status should be success
      The contents of file "$HEARTBEAT_RETRO_LOG" should include '"agent":"tester"'
    End

    It 'auto-adds timestamp'
      Data '{"agent":"implementer"}'
      When call ./core/scripts/retrospective-record.sh
      The contents of file "$HEARTBEAT_RETRO_LOG" should include '"timestamp"'
    End
  End

  Describe 'Error cases'
    It 'rejects invalid JSON with exit 1'
      Data 'this is not json'
      When run ./core/scripts/retrospective-record.sh
      The status should be failure
      The stderr should include 'invalid JSON'
    End

    It 'rejects empty input'
      Data ''
      When run ./core/scripts/retrospective-record.sh
      The status should be failure
    End

    It 'rejects JSON without agent field'
      Data '{"foo":"bar"}'
      When run ./core/scripts/retrospective-record.sh
      The status should be failure
      The stderr should include 'agent field required'
    End
  End
End
```

### 10.3 Layer 3: Structure Tests

```sh
# tests/structure/agent_definitions_spec.sh

Describe 'Agent definition structure'
  It 'all agents reference XP values'
    for agent in core/agent-personas/*.md; do
      grep -q "values.md\|xp/values\|XP Alignment" "$agent"
    done
    The status should be success
  End

  It 'all agents have retrospective trigger'
    for agent in core/agent-personas/*.md; do
      grep -q "retrospective\|Retrospective" "$agent"
    done
    The status should be success
  End

  It 'all agents have board protocol rules'
    for agent in core/agent-personas/*.md; do
      grep -q "Board Protocol\|board" "$agent"
    done
    The status should be success
  End

  It 'Copilot adapters reference core personas'
    for adapter in adapters/copilot/agents/*.agent.md; do
      grep -q "core/agent-personas" "$adapter"
    done
    The status should be success
  End

  It 'Claude Code adapters reference core personas'
    for adapter in adapters/claude-code/agents/*.agent.md; do
      grep -q "core/agent-personas" "$adapter"
    done
    The status should be success
  End
End
```

### 10.4 Layer 4: LLM-as-Judge (evals)

```yaml
# tests/evals/tester.yaml
agent: tester
cases:
  - name: "One test per behavior"
    prompt: "Write tests for user login feature"
    criteria:
      - "Each test function verifies exactly one behavior"
      - "Test names read as specifications"

  - name: "YAGNI compliance"
    prompt: "Write tests for password reset"
    criteria:
      - "Does not write tests for features not yet requested"
```

```yaml
# tests/evals/implementer.yaml
agent: implementer
cases:
  - name: "Minimal implementation principle"
    prompt: "Write implementation to pass the Red tests"
    criteria:
      - "Only minimum code needed to pass tests is written"
      - "No features beyond what tests require are added"
```

### 10.5 Makefile

```makefile
.PHONY: test test-unit test-structure test-evals test-all

test-unit:
	shellspec tests/spec/

test-structure:
	shellspec tests/structure/

test-evals:
	./tests/evals/eval-runner.sh

test: test-unit test-structure

test-all: test test-evals
```

### 10.6 GitHub Actions CI

```yaml
# .github/workflows/heartbeat-ci.yml
name: Heartbeat CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  deterministic-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install dependencies
        run: |
          sudo apt-get install -y jq
          curl -fsSL https://git.io/shellspec | sh -s -- --yes

      - name: Run unit tests
        run: shellspec tests/spec/

      - name: Run structure tests
        run: shellspec tests/structure/

  llm-judge-evals:
    runs-on: ubuntu-latest
    needs: deterministic-tests
    if: |
      github.event_name == 'workflow_dispatch' ||
      contains(join(github.event.pull_request.changed_files, ','), 'core/agent-personas')
    steps:
      - uses: actions/checkout@v4

      - name: Install dependencies
        run: sudo apt-get install -y jq

      - name: Run LLM-as-Judge evals
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: ./tests/evals/eval-runner.sh

      - name: Upload eval results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: eval-results
          path: eval-results.json
```

---

## 11. Plugin Manifests

### 11.1 .github/plugin/plugin.json (Copilot CLI)

```json
{
  "name": "heartbeat",
  "description": "XP-driven AI agent team for TDD-based development",
  "version": "2.0.0",
  "publisher": {
    "name": "NakaG"
  },
  "agents": [
    "adapters/copilot/agents/pdm.agent.md",
    "adapters/copilot/agents/context-manager.agent.md",
    "adapters/copilot/agents/designer.agent.md",
    "adapters/copilot/agents/architect.agent.md",
    "adapters/copilot/agents/tester.agent.md",
    "adapters/copilot/agents/implementer.agent.md",
    "adapters/copilot/agents/refactor.agent.md",
    "adapters/copilot/agents/reviewer.agent.md",
    "adapters/copilot/agents/qa.agent.md"
  ],
  "skills": [
    "adapters/copilot/skills/heartbeat",
    "adapters/copilot/skills/heartbeat-backlog",
    "adapters/copilot/skills/xp-values",
    "adapters/copilot/skills/xp-retro",
    "adapters/copilot/skills/browser-testing"
  ],
  "hooks": "adapters/copilot/hooks/hooks.json",
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

### 11.2 .claude-plugin/plugin.json (Claude Code)

```json
{
  "name": "heartbeat",
  "description": "XP-driven AI agent team for TDD-based development",
  "version": "2.0.0",
  "publisher": {
    "name": "NakaG"
  },
  "agents": [
    "adapters/claude-code/agents/pdm.agent.md",
    "adapters/claude-code/agents/context-manager.agent.md",
    "adapters/claude-code/agents/designer.agent.md",
    "adapters/claude-code/agents/architect.agent.md",
    "adapters/claude-code/agents/tester.agent.md",
    "adapters/claude-code/agents/implementer.agent.md",
    "adapters/claude-code/agents/refactor.agent.md",
    "adapters/claude-code/agents/reviewer.agent.md",
    "adapters/claude-code/agents/qa.agent.md"
  ],
  "skills": [
    "adapters/claude-code/skills/heartbeat",
    "adapters/claude-code/skills/heartbeat-backlog",
    "adapters/claude-code/skills/xp-values",
    "adapters/claude-code/skills/xp-retro",
    "adapters/claude-code/skills/browser-testing"
  ],
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

---

## 12. Retrospective → Learning Loop

### 12.1 Retrospective Data Format (retro.jsonl)

```json
{
  "agent": "implementer",
  "story_id": "login-feature",
  "timestamp": "2026-03-28T10:00:00Z",
  "xp_check": {
    "simplicity": { "score": "green", "note": "Minimal implementation achieved" },
    "feedback": { "score": "yellow", "note": "Edge case tests insufficient" },
    "communication": { "score": "green", "note": "Commit message captures intent" },
    "courage": { "score": "green", "note": "" },
    "respect": { "score": "green", "note": "" }
  },
  "lesson": "Hesitated on auth library selection. Next time, architect should document rationale."
}
```

### 12.2 Aggregation to insights.md

Run insights-aggregate.sh periodically to extract patterns into insights.md.
context-manager references this file when investigating new stories.

---

## 13. Setup

### 13.1 Installation

Copilot CLI:
```bash
copilot plugin install NakaG/heartbeat
```

Claude Code:
```bash
/plugin install NakaG/heartbeat
```

### 13.2 Prerequisites
- Node.js 22+ (for Playwright MCP)
- jq (for JSONL processing)
- ShellSpec (for tests, development only)

### 13.3 Initialization

On first use in a project:
```bash
/heartbeat
```
If `.heartbeat/` does not exist, automatically:
1. Create `.heartbeat/` directory structure
2. Create empty `backlog.jsonl`
3. Create `knowledge/` directory
4. Run context-manager in initialization mode to scan the full repository and build initial knowledge base
5. After initialization, present normal choices

If `knowledge/` already exists (subsequent runs), skip initialization.

---

## 14. Implementation Notes

### 14.1 File-Based State Management
- All state managed via files (JSONL/Markdown)
- No database or API dependencies
- jq is the only external dependency

### 14.2 Platform Difference Absorption
- core/ layer is platform-independent: Markdown and shell scripts only
- adapters/ layer converts to platform-specific formats
- Main differences: allowed-tools syntax and hook event name casing

### 14.3 XP Principle Adherence
- Each agent follows YAGNI: do only what is needed now
- Keep orchestrator thin: delegate decisions to each agent
- Develop test-first (write tests first)
- Conduct retrospectives every time; accumulate learnings in insights

### 14.4 TDD Development Order
Develop this plugin itself using TDD:
1. Write tests/ test code first (Red)
2. Implement core/scripts/ shell scripts (Green)
3. Refactor
4. Create core/agent-personas/ persona definitions
5. Create adapters/ platform-specific files
6. Create skills/ orchestrator skills
7. Create plugin.json manifests
8. Verify overall consistency with structure tests (Layer 3)
9. Create dashboard generation script and HTML template

---

## 15. Project Management Dashboard

### 15.1 Overview

Self-contained HTML file for project management.
No external dependencies. generate-dashboard.sh embeds JSONL data inline into HTML.

### 15.2 Data Sources

| Panel | Data Source |
|---|---|
| Backlog Board | backlog.jsonl |
| Velocity Chart | backlog.jsonl (points, iteration, completed) |
| Gantt Chart | board.jsonl (from, timestamp) |
| Task Progress | tasks.jsonl (status, started, completed) |
| Agent Messages | board.jsonl (from, note, timestamp) |

### 15.3 4-Panel Layout

```
┌─────────────────────────────────────────────────┐
│  Heartbeat Dashboard                       🔄   │
├───────────────────────┬─────────────────────────┤
│  📋 Backlog Board     │  📊 Velocity Chart      │
│  Kanban: Draft/Ready/ │  Bar chart per iteration │
│  In Progress/Done     │  Average velocity line   │
│  Points on each card  │                         │
├───────────────────────┴─────────────────────────┤
│  🔄 Current Story: {story-id}                   │
│  Story selection dropdown                       │
│  Gantt Chart (agent work time as colored bars)  │
│  Tasks: [✅ Task 1] [🔄 Task 2] [⬜ Task 3]     │
├─────────────────────────────────────────────────┤
│  💬 Agent Messages                              │
│  Chat-style chronological display of board.jsonl│
│  Each agent has a unique color                  │
└─────────────────────────────────────────────────┘
```

### 15.4 Agent Color Map

```json
{
  "pdm": "#3B82F6",
  "context-manager": "#8B5CF6",
  "designer": "#EC4899",
  "architect": "#F59E0B",
  "tester": "#EF4444",
  "implementer": "#10B981",
  "refactor": "#06B6D4",
  "reviewer": "#6366F1",
  "qa": "#14B8A6",
  "human": "#6B7280",
  "orchestrator": "#9CA3AF"
}
```

### 15.5 Velocity Chart Spec
- Aggregation unit: Iteration (XP term, not Scrum "sprint")
- Display: Bar chart of completed points per iteration
- Average velocity: Horizontal line of completed iteration averages
- If no iteration is complete, display "Collecting data"

### 15.6 Gantt Chart Spec
- X-axis: Time (from board.jsonl timestamps)
- Y-axis: Agent names
- Bar color: Per agent color map
- Bar length: From agent's "from" appearance to next agent's "from"
- Rework (rework status) shown as dashed bars
- Story selection dropdown to switch displayed story

### 15.7 Agent Messages Panel Spec
- Display board.jsonl entries as chat bubbles chronologically
- Each message shows agent name, color, timestamp
- Content: from, action, note formatted into chat bubbles
- Human entries right-aligned, agent entries left-aligned
- "blocked" and "rework" messages highlighted with red border

### 15.8 HTML Template Requirements
- Located at core/templates/dashboard.html
- Self-contained: no external CDN or CSS dependencies
- All CSS/JS inline
- Dark mode support (prefers-color-scheme)
- Responsive (viewable on mobile)
- Gantt chart rendered via Canvas or SVG
- Velocity chart rendered via SVG

---

## 16. Backlog Management Skill

### 16.1 skills/heartbeat-backlog/SKILL.md

```markdown
---
name: heartbeat-backlog
description: >
  Manage the backlog. Change story points, priorities,
  or iteration assignments.
  Triggers on: "points", "priority", "backlog", "iteration"
---

## Your Role
Perform backlog management operations.
Directly update backlog.jsonl.

## Supported Commands

### Change Points
User: "Change login points to 5"
→ Update points for the target story in backlog.jsonl

### Assign Iteration
User: "Put reset in iteration 2"
→ Update iteration for the target story in backlog.jsonl

### Change Priority
User: "Make oauth higher priority than reset"
→ Adjust priority values in backlog.jsonl

### List View
User: "Show backlog"
→ Display grouped by iteration with point totals

### Create Iteration
User: "Create iteration 3 with reset and oauth"
→ Update iteration for target stories

## Display Format

Group by iteration, show point totals:

```
📋 Iteration 1 (Total 8pt / Done 3pt)
  ✅ login: Login feature (3pt) Done
  🔄 dnd: D&D reorder (5pt) In progress

📋 Iteration 2 (Total 8pt / Done 0pt)
  ⬜ reset: Password reset (3pt) Not started
  ⬜ oauth: Google login (5pt) Not started

📋 Unassigned
  📝 search: Search feature (points not set)
```

## Important Notes
- Respect human judgment for points. Agents do not change points on their own.
- Use "iteration" (XP term), not "sprint" (Scrum term).
- Completed story points can be adjusted as actuals.
```
