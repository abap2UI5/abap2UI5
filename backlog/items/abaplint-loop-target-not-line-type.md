---
target: abaplint
title: 'Report a LOOP/READ work area or field symbol not typed as the table''s line type'
summary: '`LOOP AT lt_a INTO ls_b` with a different but compatible structure copies by component position - it works until one structure changes'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapOpenChecks check 019 (larshp/abapOpenChecks docs/_checks/19.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report a LOOP/READ work area or field symbol not typed as the table's line type

A work area of another type is converted silently.

```abap
DATA lt TYPE STANDARD TABLE OF ty_a WITH DEFAULT KEY.
DATA ls TYPE ty_b.
LOOP AT lt INTO ls.
ENDLOOP.
```

Instead:

```abap
DATA ls TYPE LINE OF ty_t_a.
```

**Proposal.** Report INTO / ASSIGNING targets whose type is not the line type of the table (identical type or LINE OF), when both are known structures.

**Not reported.** Inline declarations; generic targets; identical types under another name (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abapOpenChecks check 019.
