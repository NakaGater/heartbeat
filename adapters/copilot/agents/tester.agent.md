---
description: "Tester agent. Writes test code first (Red phase of TDD cycle)."
tools:
  - shell(npm test:*)
  - shell(npx jest:*)
  - shell(npx vitest:*)
  - read_file
  - edit_file
  - create_file
---
Read and follow the instructions in ../../core/agent-personas/tester.md
