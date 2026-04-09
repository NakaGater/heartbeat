# Test Conventions

## Test Description Language

**Rule:** All test `Describe` and `It` text MUST be written in English.
English is required for every test title, description, and inline comment.

```sh
# Good
Describe "board-write.sh"
  It "exports write_board function"

# Avoid for new tests
Describe "board-write.sh"
  It "write_board 関数をエクスポートする"
```

### Scope

This rule applies to:
- **spec tests** (`tests/spec/`)
- **structure tests** (`tests/structure/`)

This rule does NOT apply to:
- **evals** (`tests/evals/`) -- LLM-as-Judge evaluations have their own format

### Existing Tests

Existing Japanese test descriptions MUST be rewritten in English.
All test titles and comments must be written in English without exception.

### Rationale

English descriptions improve consistency across the test suite and make test
output readable regardless of terminal locale settings. Keeping a single
language for test names also simplifies grep-based filtering of test results.

## Directory Structure

### Placement Rules

| Directory | Purpose | Grouping |
|---|---|---|
| `tests/spec/` | Unit tests for individual scripts | Grouped by the script under test |
| `tests/structure/` | Structure validation tests (file existence, naming, JSON schema) | Grouped by domain (e.g., agents, hooks, misc) |
| `tests/evals/` | LLM-as-Judge evaluations | Separate format; not covered here |

- Place a new **unit test** in `tests/spec/<subdirectory>/` where `<subdirectory>` matches the script being tested.
- Place a new **structure test** in `tests/structure/<subdirectory>/` where `<subdirectory>` matches the domain being validated.

### Subdirectory Naming

Subdirectory names MUST use **kebab-case** (lowercase words separated by hyphens).
The subdirectory name should match the script or domain name it covers.

```
tests/spec/board-write/        # unit tests for board-write.sh
tests/structure/agents/        # structure tests for agent definitions
tests/structure/misc/          # structure tests for miscellaneous conventions
```

### Where to Place a New Test

1. Determine whether the test validates **behaviour** (unit) or **structure** (file/schema).
2. Pick the matching top-level directory (`tests/spec/` or `tests/structure/`).
3. Find or create a kebab-case subdirectory that matches the script or domain.
4. Name the spec file descriptively, ending with `_spec.sh`.
