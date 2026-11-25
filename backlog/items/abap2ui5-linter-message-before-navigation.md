---
target: abap2ui5-linter
title: 'Report a message queued right before a navigation without keep_messages'
summary: 'a message_toast_display( ) or message_box_display( ) followed in the same flow by nav_app_leave( ) or nav_app_call( ) is dropped with the screen it was queued on - the "Saved." of a detail page that returns to its list never shows; keep_messages = abap_true carries it'
priority: medium
state: filed
filed: https://github.com/abap2UI5/linter/pull/204
first_seen: 2026-11-24
checked_upstream: 2026-11-24
evidence:
  - 'abap2UI5 cefce923 (2026-11-24): nav_app_leave( ) and nav_app_call( ) drop everything the leaving app queued (z2ui5_cl_ui5_action, prepare_app_stack), so the "Saved." toast of a detail page that returns to its list was never shown; the commit added keep_messages = abap_true and kept the old behaviour as the default'
  - 'docs/agents/building-apps.md section 6: "A message queued right before a navigation is dropped with the screen it was queued on" - prose only'
  - '@abap2ui5/linter 0.11.0: display-after-nav-app-call judges a display behind the navigation, not a message in front of it; no issue in abap2UI5/linter (searched 2026-11-24)'
---

# Report a message queued right before a navigation without keep_messages

## Motivation

```abap
client->message_toast_display( `Saved.` ).
client->nav_app_leave( ).
```

reads like "say Saved, then go back". What happens: the navigation builds
the response from the target app, and everything the leaving app queued in
this roundtrip - toasts, boxes, focus, scroll - is dropped with its screen.
The user sees the list, without the toast, and nothing logs anything. The
pattern is in every detail page that saves and returns.

Since abap2UI5 cefce923 the two navigation methods take
`keep_messages = abap_true`: the toasts and boxes of this roundtrip are
carried across the hop and shown after the target has rendered. The default
stays the old behaviour (an appended optional parameter), so existing code
is unchanged - and still loses its message.

## Current behaviour

- `z2ui5_cl_ui5_action=>prepare_app_stack( )` drops the leaving app's
  actions unless `keep_messages` was set on the call.
- `display-after-nav-app-call` reports a view or popup display BEHIND a
  navigation. The message in FRONT of it is not judged.

## Proposed rule

`message-before-navigation`, severity warning.

Report a `client->message_toast_display( )`, `client->message_box_display( )`,
or a `follow_up_action( )` of `cs_event-control_global` whose first argument
is `MESSAGE_TOAST` / `MESSAGE_BOX`, when the same statement sequence later
reaches `client->nav_app_leave( )` or `client->nav_app_call( )` without
`keep_messages = abap_true` - with no `RETURN`, `ELSE`/`WHEN`/`ENDIF`
boundary in between (the scope `display-after-nav-app-call` already uses).

Fixable: add `keep_messages = abap_true` to the navigation call.

## What it must not report

- A navigation that passes `keep_messages = abap_true` (or a variable - the
  author decided).
- A message and a navigation in different branches of an `IF` / `CASE`.
- A message queued AFTER the navigation - that is shown, by the target's
  roundtrip, only if the framework carries it; a different defect, not this
  one.
- `nav_app_call( )` of a popup app (a class whose `main( )` only calls
  `popup_display( )`): the caller's screen stays, so the message is shown -
  when the linter can tell; otherwise report (the parameter is harmless).

## Example

```abap
client->message_toast_display( `Saved.` ).
client->nav_app_leave( ).                               " reported at the toast

client->message_toast_display( `Saved.` ).
client->nav_app_leave( keep_messages = abap_true ).     " not reported
```
