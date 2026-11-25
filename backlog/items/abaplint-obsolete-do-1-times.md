---
target: abaplint
title: 'Report `DO 1 TIMES` used as a block to leave with EXIT'
summary: 'abapOpenChecks 08 (Obsolete statement, code 022) reports DO 1 TIMES - abaplint 2.120.116 has no rule or obsolete_statement option for it, so the ATC finding only shows on the system'
priority: low
state: open
first_seen: 2026-11-25
checked_upstream: 2026-11-25
upstream: abaplint/abaplint
evidence:
  - 'a downstream app repository, ATC run of 2026-11-25: "008 - Obsolete statement - DO 1 TIMES" on a selection class whose get_data wrapped its body in DO 1 TIMES ... ENDDO and left it with EXIT; abaplint 2.120.116 with every obsolete_statement option on: no finding'
  - 'rule list of abaplint 2.120.116 (cli bundle): no rule key and no obsolete_statement option for DO 1 TIMES; abapOpenChecks zcl_aoc_check_08 matches the statement pattern DO 1 TIMES* (code 022, on by default)'
---

# Report `DO 1 TIMES` used as a block to leave with EXIT

```abap
DO 1 TIMES.
  IF lgnum IS INITIAL.
    EXIT.          " a GOTO to ENDDO
  ENDIF.
  ...
ENDDO.
```

A loop that runs once is a jump target in disguise; the ATC with
abapOpenChecks reports it (check 08, code 022). The fix is a guard
condition (`IF ... ENDIF`) or a method left with `RETURN`.

**Proposal.** A new `obsolete_statement` option `doOneTimes`
(or a small rule) reporting `DO 1 TIMES` - the count a literal 1.

**Not reported.** `DO n TIMES` with a variable or any other literal.

**Where.** `obsolete_statement` option. **Effort:** S.
