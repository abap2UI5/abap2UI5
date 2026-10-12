---
target: abaplint
title: 'Report a WHEN block longer than a configured number of statements'
summary: 'a long WHEN branch is a method waiting to be extracted; abapOpenChecks reports it'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapOpenChecks check 034 (larshp/abapOpenChecks docs/_checks/34.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report a WHEN block longer than a configured number of statements

```abap
CASE lv_kind.
  WHEN 'A'.
    " 60 statements
  WHEN OTHERS.
ENDCASE.
```

**Proposal.** Report a WHEN block with more than N statements (default e.g. 20). Could also be an option of method_length.

**Not reported.** WHEN OTHERS (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** abapOpenChecks check 034.
