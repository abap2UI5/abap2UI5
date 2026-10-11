---
target: abaplint
title: 'Report a constant offset/length on a string without a length guard'
summary: '`lv+0(6) = ''gpgsig''` on a STRING shorter than 6 dumps with STRING_OFFSET_TOO_LARGE / CX_SY_RANGE_OUT_OF_BOUNDS; CP ''gpgsig*'' or a strlen check is the fix'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abapGit/abapGit 3620e12 (#3394), 25f2bf4 (#4371), 4ca6c4a (#6468), c267d2a (#6415); larshp/abapOpenChecks 6b29404 (#1110)'
  - 'about 105 locally unguarded uses in current trees, many guarded earlier in the flow - so the rule needs flow analysis'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report a constant offset/length on a string without a length guard

```abap
IF lv_line(6) = 'gpgsig'.
```

**Proposal.** Report a constant offset/length on a STRING/XSTRING with no dominating strlen( ) / IS INITIAL guard in the method.

**Not reported.** Fixed-length fields (check_syntax decides them statically).

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abapGit, abapOpenChecks fix history.
