---
target: abap2ui5-linter
title: 'Report set_session_stateful( abap_true ) without a release on the exit paths of the app'
summary: 'an app that turns the session stateful (usually for an ENQUEUE lock) and has a navigation or leave path that neither calls set_session_stateful( abap_false ) nor dequeues keeps a work process and the lock until the ICF timeout'
priority: medium
state: open
first_seen: 2026-11-25
checked_upstream: 2026-11-25
evidence:
  - 'abap2UI5-addons/table-maintenance (DEV, 2026-11-25): z2ui5_cl_tm_001 locks with ENQUEUE_E_TABLE and set_session_stateful( abap_true ); the README says the lock is released on Back, but no control raises the BACK event (showNavButton false) - a launchpad back or home leaves lock and stateful work process to the timeout'
  - 'the same repository: the overview app (tm_002) calls the embedded app''s release_lock( ) before that app''s main( client ) - the release runs on the client of an earlier roundtrip, so set_session_stateful( abap_false ) does not reach this response'
  - '@abap2ui5/linter 0.11.3 has no rule that reads set_session_stateful'
---

# Report set_session_stateful( abap_true ) without a release on the exit paths of the app

## Motivation

`client->set_session_stateful( abap_true )` binds the browser to one work
process until the app turns it off again. Apps do it to hold an ENQUEUE
lock. Every way out of the app - `nav_app_leave( )`, `nav_app_call( )` to an
app that does not return, a back event, an error path that ends in a message
and a leave - has to release both. Missing one is invisible in a test: the
lock and the work process simply stay until the session times out.

## Proposed rule

`stateful-without-release`, severity warning.

In a class that implements `z2ui5_if_app`, when a method calls
`set_session_stateful( abap_true )` (or `val = abap_true`), report each
`nav_app_leave( )` / `nav_app_call( )` call in the class that is not
preceded, in the same method or a method it calls, by
`set_session_stateful( abap_false )`.

Additionally report the class when it contains a `DEQUEUE_*` call by name
or literal nowhere while it contains an `ENQUEUE_*` call.

## What it must not report

- `nav_app_call( )` to a popup the app expects back (the target is a class
  whose name contains `popup`, or the call passes the result back) - the
  session stays stateful on purpose while the popup is open.
- A class that releases in a method named in its own `on_leave`/cleanup
  helper called before every navigation (follow one level of calls).

## Example

```abap
client->set_session_stateful( abap_true ).
...
WHEN `BACK`.
  client->nav_app_leave( ).                    " reported - still stateful

WHEN `BACK`.
  release_lock( ).                             " calls set_session_stateful( abap_false )
  client->nav_app_leave( ).                    " not reported
```
