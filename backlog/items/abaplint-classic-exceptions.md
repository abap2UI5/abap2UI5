---
target: abaplint
title: 'Classic EXCEPTIONS: OTHERS missing, an exception mapped to 0, sy-subrc not read, functional call'
summary: 'the four ways a CALL FUNCTION/CALL METHOD … EXCEPTIONS goes wrong - no OTHERS, an exception mapped to 0, the sy-subrc set by EXCEPTIONS never read, and a method with classic exceptions called functionally - share one statement shape'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/pull/4605
first_seen: 2026-10-11
checked_upstream: 2026-11-20
upstream: abaplint/abaplint
evidence:
  - 'abapGit/abapGit d31627d (#7093) and 40efc56 added OTHERS after a dump'
  - '78 calls without OTHERS in the current abapGit, MBT-Base and ABAP-SDK-for-Azure trees'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'Marc-Bernard-Tools/MBT-Base 3492028 (''Fix exception in tree class'')'
  - '24 such mappings across four open-source ABAP trees, among them abapGit, MBT-Base and abap-file-formats-tools'
  - 'abaplint/abaplint#391 (''todo: CALL FUNCTION'' for check_subrc)'
  - 'abapGit/abapGit e3c1623 (#3724); abap2UI5/abap2UI5 79c0780'
  - '24 functional describe_by_name( <variable> ) calls in current trees, e.g. abapGit zcl_abapgit_gui_page_data:213/220, abap2xlsx zcl_excel_converter:956/1178'
  - 'checks 1 (no OTHERS) and 4 (classic exceptions called functionally) shipped in abaplint 2.120.111 as unhandled_classic_exception (abaplint/abaplint#4594, options missingOthers and missingExceptions); it found the pre-fix shapes of abapGit d31627d and 40efc56. abapGit/abapGit#8014 adds OTHERS at 50 sites and switches missingOthers on there'
  - 'check 3 (sy-subrc not read after EXCEPTIONS) filed 2026-11-20 as abaplint/abaplint#4605, options callFunction and callMethod of check_subrc - what abaplint/abaplint#391 asks for; it reports the pre-fix shapes of abapGit 12d6b480, 6f0dfc5a, b588daf5 and abap2UI5 c6366a8, b7ffcb5'
  - 'check 2 (a named exception mapped to 0) needs no rule: the cited MBT-Base 3492028 only satisfied classic_exceptions_overlap, which abaplint already has, and the 13 other named = 0 mappings in seven trees (about 1100 EXCEPTIONS lists) are all deliberate'
  - 'missingExceptions needs the callee signature: abaplint/deps#346 (2026-11-20) adds the RTTI classes and cl_oo_classname_service with their classic exceptions, which makes 16 abapGit sites visible (describe_by_name in gui_page_data, cts_api, data_utils, aifc among them)'
---

# Classic EXCEPTIONS: OTHERS missing, an exception mapped to 0, sy-subrc not read, functional call

All four read the EXCEPTIONS addition of a call (and what follows it); one rule, one option per check.

Merged on 2026-10-12 from the items `abaplint-fm-exceptions-without-others`, `abaplint-exceptions-mapped-to-zero`, `abaplint-subrc-after-exceptions`, `abaplint-classic-exceptions-functional`.

## Report CALL FUNCTION … EXCEPTIONS without OTHERS

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

**Source.** abapGit fix history.

## Report a named classic exception mapped to 0

```abap
CALL METHOD lo->get_icon
  EXCEPTIONS
    icon_not_found = 0.
```

**Proposal.** Report a named exception (not OTHERS) mapped to 0.

**Not reported.** OTHERS = 0, which is often deliberate.

**Source.** MBT-Base fix history.

## Report CALL FUNCTION/METHOD with EXCEPTIONS whose sy-subrc is not read

```abap
CALL FUNCTION 'Z_X' EXCEPTIONS not_found = 1 OTHERS = 2.
lv = 1.
```

**Proposal.** Option of check_subrc: report CALL FUNCTION / CALL METHOD with EXCEPTIONS not followed by a sy-subrc read.

**Not reported.** Calls whose EXCEPTIONS map everything to 0 (separate item).

**Source.** Sonar S1511.

## Report methods with classic EXCEPTIONS called functionally

```abap
lo_type = cl_abap_typedescr=>describe_by_name( lv_name ).
```

**Proposal.** Report a functional call, or a call without EXCEPTIONS, of a method that declares classic EXCEPTIONS (repository signatures plus a shipped list of SAP methods).

**Not reported.** Literal names known to exist (option).

**Source.** abapGit, abap2UI5 fix history.

**Where.** a new rule, one option per check. **Effort:** M.

An upstream request exists (https://github.com/abaplint/abaplint/issues/391); this item collects the cases and the scope for a pull request.
