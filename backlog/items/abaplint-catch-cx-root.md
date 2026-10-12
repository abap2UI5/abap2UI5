---
target: abaplint
title: 'Report CATCH cx_root'
summary: 'catching cx_root also swallows CX_NO_CHECK system errors; code-pal asks for the concrete classes'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'code-pal-for-abap check cx-root-usage (SAP/code-pal-for-abap docs/checks/cx-root-usage.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report CATCH cx_root

```abap
TRY.
    run( ).
  CATCH cx_root.
ENDTRY.
```

**Proposal.** Report cx_root in a CATCH clause; option to allow it in the outermost handler of a request (e.g. methods named handle_request) or with INTO + RAISE ... previous.

**Not reported.** CATCH cx_static_check / cx_dynamic_check (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** code-pal-for-abap check cx-root-usage.
