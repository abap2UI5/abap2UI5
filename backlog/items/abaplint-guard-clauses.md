---
target: abaplint
title: 'Guard clauses: CHECK in loops, long IF blocks at the end of a loop or method'
summary: 'CHECK inside a loop and a long IF wrapping the rest of a loop or method body both hide the early exit; Clean ABAP, code-pal and abap-cleaner turn them into IF NOT … CONTINUE/RETURN'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'code-pal-for-abap check check-in-loop (SAP/code-pal-for-abap docs/checks/check-in-loop.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
  - 'SAP/abap-cleaner rule IfBlockAtLoopEndRule, IfBlockAtMethodEndRule (docs/rules/IfBlockAtLoopEndRule.md); probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on: no rule reports it'
---

# Guard clauses: CHECK in loops, long IF blocks at the end of a loop or method

Both are style findings with a mechanical quick fix; one rule, one option per check. CHECK outside loops is exit_or_check's, already shipped.

Merged on 2026-10-12 from the items `abaplint-check-in-loop`.

## Report CHECK inside a loop (use IF … CONTINUE)

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

**Source.** code-pal-for-abap check check-in-loop.

## Replace a long IF block at the end of a loop or method by an early exit

```abap
LOOP AT lt INTO DATA(ls).
  IF ls-active = abap_true.
    " 20 statements
  ENDIF.
ENDLOOP.
```

Instead:

```abap
LOOP AT lt INTO DATA(ls).
  IF ls-active = abap_false.
    CONTINUE.
  ENDIF.
  " 20 statements
ENDLOOP.
```

**Proposal.** Report an IF without ELSE that is the last statement of a LOOP/DO/WHILE body or of a method and holds more than N statements; quick fix inverts it into IF NOT … CONTINUE/RETURN.

**Not reported.** IF with ELSE/ELSEIF; short blocks.

**Source.** SAP/abap-cleaner rule IfBlockAtLoopEndRule, IfBlockAtMethodEndRule.

**Where.** a new rule, one option per check. **Effort:** S.
