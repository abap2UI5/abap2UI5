---
target: abaplint
title: 'Report TODO, FIXME and XXX markers in comments'
summary: 'Clean ABAP asks for FIXME/TODO/XXX with an id; a linter finding keeps them from being forgotten'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapOpenChecks check 070 (larshp/abapOpenChecks docs/_checks/70.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report TODO, FIXME and XXX markers in comments

A marker in a comment is work that was left behind.

```abap
" TODO handle the empty case
```

**Proposal.** Report comments containing configurable markers (default TODO, FIXME, XXX), case-insensitive, as a word.

**Not reported.** Words that merely contain the marker ("todos"); ABAP Doc (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** abapOpenChecks check 070.
