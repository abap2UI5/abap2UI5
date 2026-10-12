---
target: abaplint
title: 'Report WHEN blocks with identical bodies'
summary: 'two WHEN branches with the same code are either a copy-paste bug or should be one WHEN a OR b'
priority: medium
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapOpenChecks check 042 (larshp/abapOpenChecks docs/_checks/42.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
  - 'identical_contents compares the start/end of IF branches, not whole WHEN bodies'
---

# Report WHEN blocks with identical bodies

```abap
CASE iv.
  WHEN 1.
    rv = iv * 2.
  WHEN 2.
    rv = iv * 2.
ENDCASE.
```

Instead:

```abap
CASE iv.
  WHEN 1 OR 2.
    rv = iv * 2.
ENDCASE.
```

**Proposal.** Report two WHEN blocks of one CASE whose statement lists are token-identical; suggest merging the WHEN conditions.

**Not reported.** Empty blocks; WHEN OTHERS (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abapOpenChecks check 042.
