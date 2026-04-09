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
