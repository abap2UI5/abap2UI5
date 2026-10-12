---
target: abaplint
title: 'Report COLLECT (configurable)'
summary: 'the keyword documentation advises against COLLECT outside its niche - it only works on tables with a matching key and numeric non-key fields, and silently changes meaning with the key'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'code-pal-for-abap check collect (SAP/code-pal-for-abap docs/checks/collect.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report COLLECT (configurable)

```abap
COLLECT ls_row INTO lt_sums.
```

**Proposal.** Report COLLECT; natural home an option of avoid_use.

**Not reported.** Off by default (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** code-pal-for-abap check collect.
