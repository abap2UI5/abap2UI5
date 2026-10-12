---
target: abaplint
title: 'Report "#EC CI_SUBRC where sy-subrc is checked right after the statement'
summary: 'the pseudo comment silences check_subrc / the extended check for a sy-subrc that is in fact read - it is noise that hides a real finding once the check moves'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapOpenChecks check 078 (larshp/abapOpenChecks docs/_checks/78.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report "#EC CI_SUBRC where sy-subrc is checked right after the statement

The pseudo comment says "sy-subrc deliberately not checked" while the next statement checks it.

```abap
READ TABLE lt INDEX 1 TRANSPORTING NO FIELDS. "#EC CI_SUBRC
IF sy-subrc <> 0.
```

**Proposal.** Report "#EC CI_SUBRC (and ##SUBRC_OK) on a statement whose sy-subrc check_subrc would see as checked; quick fix removes it. Natural home: an option of unnecessary_pragma.

**Not reported.** Statements whose sy-subrc is not read.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** abapOpenChecks check 078.
