# Story Point Estimation

- Points measure **complexity and uncertainty**, not workload or effort.
- Valid values: **1** (Clear), **2** (Challenging), **3** (Uncertain) only.
- 3pt Gate Rule: A story estimated at 3pt must NOT proceed to implementation.
  The architect returns it to PdM (action: `split_story`, status: `rework`)
  for splitting, redefinition, or a research spike.
- Escape hatch: If a story remains 3pt after one rework attempt, the human
  can override and approve proceeding at 3pt.
- Completed stories retain their historical point values (may include
  pre-migration values like 5 or 13).
