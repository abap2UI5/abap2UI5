---
target: abaplint
title: 'check_syntax: RAISE EXCEPTION (and a RAISING clause) in a method or function module that declares classic EXCEPTIONS'
summary: 'a procedure either declares classic EXCEPTIONS or raises class-based ones - RAISE EXCEPTION, THROW and a RAISING clause next to EXCEPTIONS do not activate, and check_syntax accepts all of them on every version'
priority: medium
state: open
first_seen: 2026-10-24
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/abap-cloud-gui, 2026-10-24 - `z2ui5_cl_cgui_frontend=>gui_upload( )`, whose signature carries the classic exceptions of GUI_UPLOAD, was written to stop the run with `RAISE EXCEPTION TYPE z2ui5_cx_cgui_stop` (a CX_NO_CHECK) when no file was picked; abaplint and the whole CI accepted it, the raise was moved into a private method without EXCEPTIONS before it reached a system (abap2UI5-addons/abap-cloud-gui#29)'
  - 'probed 2026-10-24 with @abaplint/core 2.120.75 - a class with `CLASS-METHODS run EXCEPTIONS failed.` whose implementation is `RAISE EXCEPTION TYPE cx_sy_zerodivide.`: no issue with check_syntax on for the versions v758, v702 and Cloud'
  - 'ABAP keyword documentation, RAISE EXCEPTION: the statement must not be used in a method or function module whose interface declares non-class-based exceptions; class-based exceptions raised in a procedure called from there (a CX_NO_CHECK) still propagate'
---

# check_syntax: RAISE EXCEPTION in a procedure with classic EXCEPTIONS

The interface of a method or function module declares classic exceptions
(`EXCEPTIONS`) or class-based ones (`RAISING`), not both. Inside a
procedure with classic exceptions, `RAISE EXCEPTION` and `THROW` are
syntax errors, even for a CX_NO_CHECK class that needs no declaration.

```abap
CLASS-METHODS gui_upload EXCEPTIONS file_open_error.

METHOD gui_upload.
  RAISE EXCEPTION TYPE zcx_stop.          " does not activate
ENDMETHOD.
```

The legal form raises in a procedure of its own, and the exception passes
through:

```abap
METHOD gui_upload.
  stop( ).                                " stop( ) holds the RAISE EXCEPTION
ENDMETHOD.
```

**Proposal.** In `check_syntax`, report:
- `RAISE EXCEPTION` and `THROW` inside a method or function module whose
  definition has `EXCEPTIONS`;
- a method definition, or a FUNCTION interface, with both `EXCEPTIONS` and
  `RAISING`.

**Not reported.**
- `RAISE <classic exception>` (`RAISE file_open_error.`): that is the
  statement such a procedure uses.
- A call of a method that raises a class-based exception.
- `RAISE EXCEPTION` in a local procedure (FORM) or in a method without
  `EXCEPTIONS`.

**Where.** an extension of `check_syntax` - the system refuses the code at
activation. **Effort:** S.

**Source.** ABAP keyword documentation (RAISE EXCEPTION; METHODS - EXCEPTIONS).
