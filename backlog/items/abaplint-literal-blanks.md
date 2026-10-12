---
target: abaplint
title: 'Character literals whose blanks are dropped'
summary: 'trailing blanks of a ''…'' literal are ignored - so ''Hello '' loses its blank in CONCATENATE/&&, and '' '' as REPLACE/FIND ALL OCCURRENCES pattern is empty and raises CX_SY_REPLACE_INFINITE_LOOP'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'ABAP keyword documentation, REPLACE pattern: an empty pattern with ALL OCCURRENCES raises CX_SY_REPLACE_INFINITE_LOOP'
---

# Character literals whose blanks are dropped

Both are the same fact about c literals; one rule, the REPLACE/FIND case is the one that dumps.

Merged on 2026-10-12 from the items `abaplint-blank-search-pattern`, `abaplint-char-literal-trailing-blanks`.

## Report a blank character literal as the pattern of REPLACE/FIND ALL OCCURRENCES

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

**Source.** ABAP keyword documentation; Clean ABAP 'Use ` to define literals'.

## Report a character literal with trailing blanks where the blanks are dropped

Trailing blanks of fixed-length operands are ignored.

```abap
CONCATENATE 'Hello ' lv_name INTO lv.   " HelloJohn
```

**Proposal.** Report '…' literals ending in blanks in CONCATENATE without RESPECTING BLANKS and in && operands.

**Not reported.** Backtick literals; RESPECTING BLANKS; targets of type c where the blank is irrelevant.

**Source.** Clean ABAP 'Use ` to define literals'.

**Where.** a new rule, one option per check. **Effort:** S.
