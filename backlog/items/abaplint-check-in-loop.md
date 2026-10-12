---
target: abaplint
title: 'Report CHECK inside a loop (use IF … CONTINUE)'
summary: 'CHECK in a loop silently skips to the next pass; Clean ABAP and code-pal want the explicit IF … CONTINUE'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'code-pal-for-abap check check-in-loop (SAP/code-pal-for-abap docs/checks/check-in-loop.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report CHECK inside a loop (use IF … CONTINUE)

```abap
LOOP AT lt INTO DATA(ls).
  CHECK ls-active = abap_true.
ENDLOOP.
```

Instead:

```abap
LOOP AT lt INTO DATA(ls).
  IF ls-active = abap_false.
    CONTINUE.
  ENDIF.
ENDLOOP.
```

**Proposal.** Report CHECK directly or indirectly inside LOOP/DO/WHILE/SELECT…ENDSELECT; quick fix to IF NOT … CONTINUE.

**Not reported.** CHECK outside loops (exit_or_check reports that).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** code-pal-for-abap check check-in-loop.
