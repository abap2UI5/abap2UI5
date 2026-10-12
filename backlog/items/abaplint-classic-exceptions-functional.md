---
target: abaplint
title: 'Report methods with classic EXCEPTIONS called functionally'
summary: 'a method with classic EXCEPTIONS called functionally (or without an EXCEPTIONS clause) turns every RAISE into a runtime error - e.g. cl_abap_typedescr=>describe_by_name( <variable> )'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'larshp/abapOpenChecks d7b637a, ff5c37f, 9d5c567; abapGit/abapGit e3c1623 (#3724); abap2UI5/abap2UI5 79c0780'
  - '24 functional describe_by_name( <variable> ) calls in current trees, e.g. abapGit zcl_abapgit_gui_page_data:213/220, abap2xlsx zcl_excel_converter:956/1178'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report methods with classic EXCEPTIONS called functionally

```abap
lo_type = cl_abap_typedescr=>describe_by_name( lv_name ).
```

**Proposal.** Report a functional call, or a call without EXCEPTIONS, of a method that declares classic EXCEPTIONS (repository signatures plus a shipped list of SAP methods).

**Not reported.** Literal names known to exist (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abapOpenChecks, abapGit, abap2UI5 fix history.
