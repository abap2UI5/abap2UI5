---
target: abaplint
title: 'Report CALL FUNCTION … EXCEPTIONS without OTHERS'
summary: 'a classic exception of the function module that the EXCEPTIONS list does not name raises RAISE_EXCEPTION, a short dump'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abapGit/abapGit d31627d (#7093) and 40efc56 added OTHERS after a dump'
  - '78 calls without OTHERS in the current abapGit, MBT-Base and ABAP-SDK-for-Azure trees'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report CALL FUNCTION … EXCEPTIONS without OTHERS

Only the named exceptions are mapped to sy-subrc.

```abap
CALL FUNCTION 'Z_READ'
  EXCEPTIONS
    not_found = 1.
```

Instead:

```abap
CALL FUNCTION 'Z_READ'
  EXCEPTIONS
    not_found = 1
    OTHERS    = 2.
```

**Proposal.** Report an EXCEPTIONS list without OTHERS.

**Not reported.** Calls without any EXCEPTIONS addition (class-based or none declared).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** abapGit fix history.
