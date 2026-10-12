---
target: abaplint
title: 'Report * comments in code (Clean ABAP: comment with ", not *)'
summary: '* comments do not move with the indentation; abaplint/abaplint#633 asks for it'
priority: low
state: filed
filed: https://github.com/abaplint/abaplint/issues/633
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'code-pal-for-abap check comment-type (SAP/code-pal-for-abap docs/checks/comment-type.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report * comments in code (Clean ABAP: comment with ", not *)

```abap
* explains the next line
    lv = 1.
```

**Proposal.** Report full-line comments starting with * inside procedures (option: everywhere); quick fix to ".

**Not reported.** Header comment blocks at the top of an include (option); generated code.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** code-pal-for-abap check comment-type.

An upstream request exists (https://github.com/abaplint/abaplint/issues/633); this item collects the case and the scope for a pull request.
