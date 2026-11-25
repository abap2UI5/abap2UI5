---
target: abap2ui5-linter
title: 'missing-view-display-on-navigated: no re-display is needed after a popup-only app'
summary: 'after nav_app_call( ) to an app that only shows a popup (z2ui5_cl_popup_value_help and the other popups addon classes), the caller''s own view is still in the main slot - the rule still demands a view_display( ) in the navigated branch'
priority: medium
state: filed
filed: https://github.com/abap2UI5/linter/pull/203
first_seen: 2026-11-25
checked_upstream: 2026-11-25
evidence:
  - '@abap2ui5/linter 0.11.3 + the S5S branches (abap2UI5/linter builder-helpers-across-classes) on oblomov-dev/S5S_DEV (DEV): /kro/ui504_cl_app_001 on_after_f4( ) - IF client->check_on_navigated( ) = abap_false. RETURN. ENDIF., then reads the result of z2ui5_cl_popup_value_help and returns; reported as error "never re-displays the view"'
  - 'the called app only calls popup_display( ) and closes it with nav_app_leave( ); the main slot keeps the caller''s view, and the value written back reaches the model on the same roundtrip'
  - 'abap2UI5/linter open issues and PRs checked 2026-11-25 (#195, #196, #197): nothing on this'
---

# missing-view-display-on-navigated: no re-display after a popup-only app

```abap
METHOD on_after_f4.                       " called from main( ) on every roundtrip
  IF client->check_on_navigated( ) = abap_false.
    RETURN.
  ENDIF.
  DATA(obj) = client->get_app_prev( ).
  IF obj IS NOT INSTANCE OF z2ui5_cl_popup_value_help.
    RETURN.
  ENDIF.
  mv_lgort = CAST z2ui5_if_popup_result( obj )->value_string( ).
ENDMETHOD.                                " reported: never re-displays the view
```

## Motivation

The rule is right for an app that replaces the main view: after it leaves,
the browser still shows the called app's screen. A popup app never replaced
it - it opened a dialog over the caller's view and closed it again. The
caller has nothing to re-display, and the error-level finding pushes a
redundant `view_display( )` (which rebuilds the view and drops its UI state).

## Proposal

Judge the navigated branch against the apps the class navigates to
(`nav_app_call( )` targets, already collected by `navTargetsOf( )`):

- when every target is known to show only a popup - the class index says so
  (`shows` = popup only), or it is one of the popups addon classes
  (`z2ui5_cl_popup_*`, a closed list) - the rule does not report;
- when the branch itself tests the previous app's class
  (`IS INSTANCE OF z2ui5_cl_popup_…`, `CAST z2ui5_cl_popup_…`), judge it
  against that class.

## Must not change

- A navigated branch after a target that displays a view (`view_display( )`)
  is still reported.
- A target the linter cannot see (not in the run, not a known popup class)
  keeps today's verdict.
