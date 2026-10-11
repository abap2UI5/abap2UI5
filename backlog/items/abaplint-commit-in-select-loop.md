---
target: abaplint
title: 'Report statements with an implicit or explicit database commit inside SELECT … ENDSELECT or an open cursor'
summary: 'COMMIT/ROLLBACK WORK, CALL FUNCTION … DESTINATION, CALL TRANSACTION, WAIT or SUBMIT AND RETURN inside SELECT…ENDSELECT (or between OPEN CURSOR without WITH HOLD and CLOSE CURSOR) closes the cursor - DBIF_RSQL_INVALID_CURSOR on the next fetch'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'ABAP keyword documentation on implicit database commits'
---

# Report statements with an implicit or explicit database commit inside SELECT … ENDSELECT or an open cursor

The database commit closes every open cursor.

```abap
SELECT * FROM ztab INTO @DATA(ls).
  COMMIT WORK.
ENDSELECT.
```

**Proposal.** Report the listed statements inside SELECT loops and open cursors of the same procedure.

**Not reported.** OPEN CURSOR WITH HOLD; calls into methods (would need cross-procedure analysis).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** ABAP documentation; Sonar S2240 idea.
