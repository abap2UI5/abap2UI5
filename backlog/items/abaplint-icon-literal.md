---
target: abaplint
title: 'Report icon codes written as literals (''@00@'') instead of ICON_ constants'
summary: '`lv_icon = ''@00@''` hides which icon is meant and breaks where-used; the type pool ICON names every code'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapOpenChecks check 010 (larshp/abapOpenChecks docs/_checks/10.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report icon codes written as literals ('@00@') instead of ICON_ constants

An icon code is a four-character literal between @ signs; the ICON type pool has a constant for each.

```abap
lv_icon = '@00@'.
```

Instead:

```abap
lv_icon = icon_okay.
```

**Proposal.** Report a character literal matching '@[0-9A-Z]{2}@' (optionally followed by a quick-info part) in code.

**Not reported.** Literals in comments and string templates that are clearly not icons; test classes (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** abapOpenChecks check 010.
