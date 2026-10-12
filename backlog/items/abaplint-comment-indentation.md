---
target: abaplint
title: 'Report " comments not indented like the statement that follows'
summary: 'a comment refers to the code below it; one at another indentation reads as if it belonged elsewhere'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'code-pal-for-abap check comment-position (SAP/code-pal-for-abap docs/checks/comment-position.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report " comments not indented like the statement that follows

```abap
  METHOD run.
" explains the return
    RETURN.
```

**Proposal.** Report full-line " comments whose column differs from the next statement's; quick fix re-indents. Could be an option of indentation.

**Not reported.** End-of-line comments; comments in empty branches; ABAP Doc (wrong_abapdoc_position).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** code-pal-for-abap check comment-position.
