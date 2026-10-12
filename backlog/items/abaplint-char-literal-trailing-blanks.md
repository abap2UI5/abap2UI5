---
target: abaplint
title: 'Report a character literal with trailing blanks where the blanks are dropped'
summary: '''Hello '' in CONCATENATE without RESPECTING BLANKS or as an operand of && loses its blank - the result is silently wrong'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report a character literal with trailing blanks where the blanks are dropped

Trailing blanks of fixed-length operands are ignored.

```abap
CONCATENATE 'Hello ' lv_name INTO lv.   " HelloJohn
```

**Proposal.** Report '…' literals ending in blanks in CONCATENATE without RESPECTING BLANKS and in && operands.

**Not reported.** Backtick literals; RESPECTING BLANKS; targets of type c where the blank is irrelevant.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** Clean ABAP 'Use ` to define literals'.
