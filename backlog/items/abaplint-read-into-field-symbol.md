---
target: abaplint
title: 'Report READ TABLE … INTO <fs> and LOOP AT … INTO <fs>'
summary: 'INTO copies into the row <fs> points to and so silently overwrites it; ASSIGNING was meant'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report READ TABLE … INTO <fs> and LOOP AT … INTO <fs>

A field symbol as INTO target is a write through the field symbol.

```abap
READ TABLE lt INTO <ls> WITH KEY id = 2.
```

**Proposal.** Report a field symbol as the INTO target of READ TABLE / LOOP AT.

**Not reported.** Field symbols deliberately bound to a work area (pseudo comment).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** code-pal sub-assign-read-table.
