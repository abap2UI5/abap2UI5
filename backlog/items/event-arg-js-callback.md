---
target: abap2ui5-linter
title: 'Report a JS callback in an event argument — UI5 ExpressionParser has no function keyword, so the WHOLE handler fails to parse'
summary: '`.map(function(r){…})` in a t_arg does not degrade to a wrong value; it throws at parse time and every argument of that handler is lost'
priority: high
state: open
first_seen: 2026-08-24
evidence:
  - samples-controls apps 537, 538, 539 and 547 shipped `.map(function(r){…})` / `.some(function(a){…})`. All four intervalSelect and appointmentSelect wires were dead, including 547's group report
  - app 601 shipped the same shape on both toolbar buttons, so "expand selected nodes" and "collapse selected nodes" - the whole sample - throw on every press
  - the failure mode is invisible on screen in 537/538/539: the calendar still renders, only the round trip never happens
---

## What happens

`get_t_arg` leaves an argument starting with `$` raw, so the callback text
reaches the emitted `.eB(…)` / `.eF(…)` handler verbatim. At press time
`EventHandlerResolver.parse` hands the **whole** handler string to
`BindingParser.parseExpression` → `ExpressionParser`.

`ExpressionParser` has no `function` keyword — its token table knows only
`false`/`null`/`true`/`in`/`typeof` — and `{` is the object-literal `nud`. So
parsing `map(function (o) {` hits `advance(",")` on a `{` and throws.

The important part: this is **not** a wrong argument value. The exception is on
the handler, so *every* argument is lost and the event never reaches the
backend.

## Proposed rule

Report any `t_arg` entry containing `function` followed by `(` — the construct
has no legal spelling in the expression grammar, so a substring match is
sufficient and has no false-positive surface worth the extra machinery.

## What it must not report

- The word `function` inside a **quoted** argument, i.e. one that does not start
  with `$` or `{` and is therefore shipped as a JS string literal (a toast
  template may legitimately contain the word).
- An arrow function: it is equally unparseable, so it should be reported too —
  but by the same rule, not a second one. Match on `=>` as well.

## Note for whoever fixes a port

The repair is usually not a cleverer expression. Three of the five ports were
fixed by binding the state instead: `PlanningCalendarRow.selected` and
`CalendarAppointment.selected` are bindable, so the flags travel with the rows
and ABAP does the work. App 601 is the counter-example — `sap.m.Tree` exposes no
`getSelectedIndices()`, so it needs framework support (see
`tree-selected-indices`).
