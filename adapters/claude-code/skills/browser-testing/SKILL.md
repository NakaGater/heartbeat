---
name: browser-testing
description: >
  Launch ad-hoc browser testing with the QA agent.
  Uses Playwright MCP for real browser verification.
  Triggers on: "browser test", "qa", "playwright", "verify in browser"
---

## Your Role
Launch the QA agent for ad-hoc browser testing outside the normal
story workflow. Useful for quick verification or exploratory testing.

## What to Do

1. Ask the user what they want to verify in the browser
2. Read `core/agent-personas/qa.md` for QA agent instructions
3. Use Playwright MCP to launch a browser and navigate to the target
4. Execute the verification steps the user describes
5. Report results using the QA report format

## Usage Examples

User: "Check if the login page looks correct"
→ Launch browser, navigate to login, verify visual elements

User: "Test the form validation"
→ Launch browser, try various inputs, report results

User: "Verify responsive layout on mobile"
→ Launch browser at mobile viewport width, check layout

## Output Format

```
🔍 Browser Verification Result

## Target: {what was tested}

## Results
1. ✅ or ❌ {verification 1}
2. ✅ or ❌ {verification 2}

## Screenshots
- {description}: {screenshot reference}

## Issues Found (if any)
- {issue description with reproduction steps}
```

## Tools
- Playwright MCP for browser operations
