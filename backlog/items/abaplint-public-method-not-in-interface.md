---
target: abaplint
title: 'Report public instance methods that are not part of an interface'
summary: 'public methods outside an interface cannot be mocked and couple callers to the class; code-pal reports it'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'code-pal-for-abap check interface-in-class (SAP/code-pal-for-abap docs/checks/interface-in-class.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report public instance methods that are not part of an interface

```abap
CLASS zcl_svc DEFINITION PUBLIC FINAL.
  PUBLIC SECTION.
    METHODS run.
ENDCLASS.
```

**Proposal.** Report METHODS in the PUBLIC SECTION of a global class that are not REDEFINITION and not constructor, when the class implements no interface or the method is not an interface method.

**Not reported.** CLASS-METHODS; exception classes; test classes; constructor.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** code-pal-for-abap check interface-in-class.
