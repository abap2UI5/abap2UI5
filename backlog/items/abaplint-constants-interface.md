---
target: abaplint
title: 'Report interfaces that contain only constants'
summary: 'an interface of constants is implemented to save typing and leaks the constants into every implementer; Clean ABAP prefers enumeration classes'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'code-pal-for-abap check constants-interface (SAP/code-pal-for-abap docs/checks/constants-interface.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report interfaces that contain only constants

```abap
INTERFACE zif_consts PUBLIC.
  CONSTANTS c_a TYPE i VALUE 1.
ENDINTERFACE.
```

**Proposal.** Report an INTERFACE whose components are all CONSTANTS (and TYPES, option).

**Not reported.** Interfaces with any method, event or data.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** code-pal-for-abap check constants-interface.
