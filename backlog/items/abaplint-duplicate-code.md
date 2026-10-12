---
target: abaplint
title: 'Duplicate code: identical WHEN bodies, copied statement blocks'
summary: 'identical WHEN branches of one CASE (merge the conditions or a copy-paste bug) and repeated statement sequences across methods are the same token comparison at two scopes'
priority: medium
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
  - 'identical_contents compares the start/end of IF branches, not whole WHEN bodies'
  - 'checked 2026-10-12 against the rule sources of abaplint main after v2.120.75 (an XML or cross-object check, not probed with a snippet): no rule decides it'
---

# Duplicate code: identical WHEN bodies, copied statement blocks

Start with the local WHEN case (M), the repository-wide clone search (L) can follow on the same tokeniser.

Merged on 2026-10-12 from the items `abaplint-identical-when-blocks`, `abaplint-identical-code-blocks`.

## Report WHEN blocks with identical bodies

```abap
CASE iv.
  WHEN 1.
    rv = iv * 2.
  WHEN 2.
    rv = iv * 2.
ENDCASE.
```

Instead:

```abap
CASE iv.
  WHEN 1 OR 2.
    rv = iv * 2.
ENDCASE.
```

**Proposal.** Report two WHEN blocks of one CASE whose statement lists are token-identical; suggest merging the WHEN conditions.

**Not reported.** Empty blocks; WHEN OTHERS (option).

## Report identical code blocks (copy-paste detection)

```abap
the same 15 statements in two methods
```

**Proposal.** Report token-identical (after normalising names, option) sequences of at least N statements across the repository.

**Not reported.** Generated code; test classes (option).

**Where.** a new rule, one option per check. **Effort:** M.
