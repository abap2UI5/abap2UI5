---
target: abap2ui5-linter
title: 'Hint at a timer handler that changes an attribute on every tick'
summary: 'an unchanged timer tick writes no draft (abap2UI5 cdd2fb25), but only when main( ) leaves the app byte for byte as it was - a handler that stamps a time or bumps a counter on every tick writes a draft per tick for as long as the page is open'
priority: low
state: filed
filed: https://github.com/abap2UI5/linter/pull/204
first_seen: 2026-11-24
checked_upstream: 2026-11-24
evidence:
  - 'abap2UI5 cdd2fb25 (2026-11-24): a START_TIMER tick whose main( ) left the app so that it serializes byte for byte to the draft it continued answers with that draft''s id and writes no row (z2ui5_cl_ui5_handler=>main_end_reuse, z2ui5_cl_ui5_app_cont=>db_check_unchanged)'
  - 'docs/agents/architecture-seams.md, "Fewer drafts - the unchanged tick and the pruned chain"'
  - 'low confidence: no app is known to have been measured yet - the case is the shape of the optimisation, a polling page that writes "last refreshed at" into a bound attribute on each tick; @abap2ui5/linter 0.11.0 has no rule on timer handlers; no issue in abap2UI5/linter (searched 2026-11-24)'
---

# Hint at a timer handler that changes an attribute on every tick

## Motivation

A polling page re-arms `START_TIMER` and asks the backend every few
seconds. Since abap2UI5 cdd2fb25 a tick that changed nothing writes no
draft: the framework compares the serialized app with the draft it
continued and answers with that draft's id. That turns hours of polling
into one row instead of thousands - but only when the tick really changes
nothing. A handler that writes the current time into an attribute ("last
refreshed 12:04:31"), or counts the ticks, makes every tick different, and
the page writes one draft per tick as it did before.

Often the value is needed (the user wants to see the time); sometimes it is
not, or it could be computed on the frontend. The author cannot see the
difference without knowing the optimisation exists.

## Current behaviour

- The reuse is automatic and silent in both directions.
- No rule looks at the handler of a timer event.

## Proposed rule

`timer-tick-changes-state`, severity hint, off by default (opt-in).

Find the event name a `START_TIMER` follow-up action arms (the first entry
of its `t_arg`), find the branch that handles it (`WHEN` / `check_on_event( )`
on that name), and report an assignment in that branch to an instance
attribute from a source that differs on every call: `sy-uzeit`, `sy-datum`,
`utclong_current( )`, `GET TIME STAMP`, `cl_abap_context_info=>get_system_*`,
or `attr = attr + 1`.

Message: this tick always changes the app, so it always writes a draft;
if the value is only shown, consider an expression binding or leaving it
unchanged when the polled data did not change.

## What it must not report

- An assignment from the polled data itself (it changes when the data does,
  which is the point).
- An assignment guarded by a comparison with the previous value.
- A timer whose event is not resolvable to a literal.

## Example

```abap
WHEN `TICK`.
  mv_refreshed_at = sy-uzeit.        " hint: every tick writes a draft
  mt_orders = read_orders( ).
```
