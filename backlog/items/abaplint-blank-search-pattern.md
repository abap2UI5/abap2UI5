---
target: abaplint
title: 'Report a blank character literal as the pattern of REPLACE/FIND ALL OCCURRENCES'
summary: '`REPLACE ALL OCCURRENCES OF '' '' …` - trailing blanks of a c literal are ignored, so the pattern is empty and REPLACE ALL raises CX_SY_REPLACE_INFINITE_LOOP'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'ABAP keyword documentation, REPLACE pattern: an empty pattern with ALL OCCURRENCES raises CX_SY_REPLACE_INFINITE_LOOP'
---

# Report a blank character literal as the pattern of REPLACE/FIND ALL OCCURRENCES

The author meant to remove spaces; with a character literal the pattern is empty.

```abap
REPLACE ALL OCCURRENCES OF ' ' IN lv WITH ''.
```

Instead:

```abap
REPLACE ALL OCCURRENCES OF ` ` IN lv WITH ``.
```

**Proposal.** Report REPLACE/FIND ALL OCCURRENCES OF with a '…' literal that is empty or blanks only.

**Not reported.** Backtick literals (` `), which keep the blank; SUBSTRING/REGEX forms.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** ABAP keyword documentation; Clean ABAP 'Use ` to define literals'.
