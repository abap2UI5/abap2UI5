---
target: abap2ui5-linter
title: 'unconditional-popup-display: respect early RETURN guards and CASE/IF branches in called methods'
summary: 'unconditional-popup-display follows main( ) into a called method and reports a popup_display( ) there as top level, although the call sits behind an early RETURN guard or inside a WHEN/IF branch of the callee'
priority: medium
state: open
first_seen: 2026-11-25
checked_upstream: 2026-11-25
evidence:
  - '@abap2ui5/linter 0.11.3 on oblomov-dev/S5S_DEV (DEV 2bcdc50): /kro/ui501_cl_app_005 - main( ) calls on_after_layout( ), which starts with IF client->check_on_navigated( ) = abap_false. RETURN. ENDIF. and only then calls render_view( ) -> popup_display( ); reported as "popup_display( ) at the top level of main( ) runs on EVERY roundtrip". render_view( ) is otherwise called only inside IF mv_init = abap_false'
  - 'same run: /kro/ui503_cl_app_003 - main( ) calls on_event( ), which calls render_popup_setup( ) -> popup_display( ) only under CASE client->get_event( ). WHEN ''BUTTON_SETUP''; reported the same way'
  - 'both are baselined as false positives in S5S_DEV abap2ui5lint-baseline.json (falsePositives block); open issues/PRs of abap2UI5/linter could not be searched from that session (repository not attachable) - checked_upstream records the attempt, re-check before filing'
---

# unconditional-popup-display: respect guards and branches in called methods

```abap
METHOD z2ui5_if_app~main.
  me->client = client.
  on_event( ).                 " reported: "popup_display( ) at the top level of main( )"
ENDMETHOD.

METHOD on_event.
  CASE client->get_event( ).
    WHEN 'BUTTON_SETUP'.
      render_popup( ).         " -> client->popup_display( ... )
  ENDCASE.
ENDMETHOD.
```

and the early-exit form:

```abap
METHOD on_after_layout.        " called unconditionally from main( )
  IF client->check_on_navigated( ) = abap_false.
    RETURN.
  ENDIF.
  render_view( ).              " -> client->popup_display( ... )
ENDMETHOD.
```

## Motivation

The rule is right about the defect it targets - a `popup_display( )` that
runs on every roundtrip rebuilds the dialog each time. But it decides "top
level" only for the statement in `main( )`; once it follows the call into a
helper it treats every `popup_display( )` there as unconditional. Apps that
dispatch from `main( )` into `on_event( )` / `on_after_layout( )` - the
usual shape of a larger app and of every class derived from a base app - get
an error-level false positive for correct code.

## Proposal

When the rule follows a call from `main( )` into a method of the same class
(or the inheritance chain), a `popup_display( )` there counts as top level
only if it is reached unconditionally in that callee too:

- not inside `IF` / `ELSEIF` / `ELSE`, `CASE ... WHEN`, `LOOP`, `DO`,
  `WHILE`, `TRY ... CATCH`;
- not after an early exit of the callee whose condition can be false
  (`IF ... RETURN. ENDIF.`, `CHECK ...`).

Apply the same test at each level of the call chain; one guarded level
makes the whole path conditional.

## Must not change

- A `popup_display( )` written directly at the top level of `main( )`, or
  reached through helpers that call it unconditionally at every level, is
  still reported.
- A guard on `check_on_init( )` / an init flag stays what it is today
  (conditional - not reported).
