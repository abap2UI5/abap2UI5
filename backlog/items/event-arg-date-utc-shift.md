---
target: abap2ui5
title: 'A `Date`-typed control property is projected as UTC, so a local-date event argument arrives a day early'
summary: the control projection that made control-valued event parameters travel serializes a Date through `toISOString()`, so a control holding LOCAL midnight reaches the backend as the previous day everywhere east of Greenwich — measured, and it is why two ports still hand-roll one expression argument per array slot
priority: medium
state: open
first_seen: 2026-08-23
upstream: abap2UI5/abap2UI5
evidence:
  - measured 2026-08-23 in samples-controls `scripts/probes/control-valued-event-arg-probe.mjs`, candidate `dateRange-array`, real OpenUI5 in headless Chromium — local midnight of 2018-07-09 arrives as `2018-07-08T22:00:00.000Z` at `Europe/Berlin`, and correctly at `America/New_York` and `UTC`
  - samples-controls app 307 (`sap.ui.unified.sample.CalendarMultipleDaySelection`) keeps 31 index-guarded expression args with a declared cap that silently drops every day past the 31st, rather than take the projection route
  - samples-controls app 109 (`sap.m.sample.SinglePlanningCalendarDateSelection`) still toasts the event name alone where the original lists every selected date
---

# A `Date`-typed control property is projected as UTC, so a local-date event argument arrives a day early

## Motivation

`Lib.normalizeEventArgs` closed a real gap: a UI5 event parameter is often a
control or a whole array of controls, `JSON.stringify` throws on their circular
parent/aggregation graph, and the expression grammar has no loop or lambda with
which an app could project them itself. Marshalling each control into its `ID`
plus its metadata **properties** made those parameters travel, and apps read
them with ajson today.

It is lossless for the property types JSON has: strings, numbers, booleans,
enums. It is **not** lossless for a `Date`, and a `Date` is exactly what the
date-carrying controls hold — `sap.ui.unified.DateRange.startDate`/`endDate`,
`CalendarAppointment.startDate`/`endDate`, `DatePicker.dateValue`. UI5 fills
them with LOCAL midnight of the day the user picked; `JSON.stringify` writes
them through `Date.prototype.toJSON` → `toISOString()`, which is UTC. East of
Greenwich the date part of the result is the **previous day**.

So the capability announces itself as "control-valued parameters now travel",
and for a date control it hands the backend a wrong day with no error anywhere.

## Current behaviour

`app/webapp/core/Lib.js`:

```js
function projectControl(control) {
  const result = { ID: control.getId() };
  const properties = control.getMetadata().getAllProperties();
  for (const name in properties) {
    try {
      const value = control.getProperty(name);
      if (value !== undefined) result[name] = value;   // <- a Date lands here as a Date
    } catch { /* … */ }
  }
  return result;
}
```

`app/webapp/controller/View1.controller.js` puts the result on the body
(`oBody.ARGUMENTS = Lib.normalizeEventArgs(args)`), `core/Server.js` moves it
into `sFront.T_EVENT_ARG` and `JSON.stringify`s the body. Nothing in that path
looks at the property's declared **type**, which is where the information sits:
`getMetadata().getAllProperties()[name].type` is the string `"object"` for
these, and the control's own metadata says so.

### Measurement

`samples-controls/scripts/probes/control-valued-event-arg-probe.mjs`, candidate
`dateRange-array`: a `sap.ui.unified.Calendar` with two `DateRange`s added at
`new Date(2018, 6, 9)` and `new Date(2018, 6, 10)` — local midnight, which is
what the Calendar itself puts in the aggregation when a day is clicked — fires
`select` with the wire the framework emits.

| browser timezone | projected `startDate` of the first range | date part |
|---|---|---|
| `Europe/Berlin` (UTC+2) | `2018-07-08T22:00:00.000Z` | **2018-07-08 — wrong** |
| `America/New_York` (UTC-4) | `2018-07-09T04:00:00.000Z` | 2018-07-09 |
| `UTC` | `2018-07-09T00:00:00.000Z` | 2018-07-09 |

Two things follow. The defect is invisible west of Greenwich and in UTC, so a
CI run reports a false all-clear — and the affected half is where most ABAP
systems are.

### What it costs today

Both ports that need a date out of a control-valued parameter avoid the
projection and hand-roll the client-side formatting instead:

- **app 307** emits **31** expression arguments, one per selectable slot, each
  formatting `getSelectedDates()[i].getStartDate()` from its LOCAL parts
  (`getFullYear()`, `getMonth() + 1`, `getDate()`) and yielding `''` past the
  end of the aggregation. It works and it is capped: a user who navigates
  months and keeps selecting loses every day past the 31st, silently. That cap
  is a declared `IMPROVISED` deviation whose only cause is this issue.
- **app 109** does not reproduce its toast at all — the original prints
  `oRange.getStartDate().toDateString()` per selected date, the port toasts the
  event name alone.

## Proposed change

Serialize a `Date` property as its **local** parts, not as an instant, because
that is what the control means by it: these properties carry a calendar day the
user picked in their own timezone, not a point on the timeline.

In `projectControl`, format a `Date` value the way the rest of the framework
already treats dates on the wire — an ISO **local** `yyyy-MM-ddTHH:mm:ss`
without the `Z`:

```js
function projectValue(value) {
  if (value instanceof Date && !isNaN(value)) {
    const p = (n, w = 2) => String(n).padStart(w, "0");
    return `${p(value.getFullYear(), 4)}-${p(value.getMonth() + 1)}-${p(value.getDate())}` +
      `T${p(value.getHours())}:${p(value.getMinutes())}:${p(value.getSeconds())}`;
  }
  return value;
}
```

and call it where the property is read:

```js
const value = control.getProperty(name);
if (value !== undefined) result[name] = projectValue(value);
```

An ABAP app then reads `2018-07-09T00:00:00` and takes the first ten characters
as the day, which is the same shape `z2ui5_cl_ui5_view_builder` consumers
already bind dates in.

### Why local rather than an offset

Sending the UTC instant plus the browser offset would also be recoverable, but
it makes every consumer do the arithmetic, and the value being recovered is a
calendar day — there is nothing an instant adds. The framework's own inbound
direction already made this choice: `model/formatter.js`'s
`DateAbapDateToDateObject` builds a Date from local parts precisely so a
date-only string does not shift (samples-controls' `utc-date-shift-probe.mjs`
records the day this was learned in the other direction).

### Scope — what must NOT change

- Only a value that **is a `Date`** is touched. Every string, number, boolean
  and enum property keeps its current serialization, so no wire that works
  today moves.
- An **invalid** Date (`new Date('')`, which UI5 controls do produce for an
  empty optional date) must not become the string `"Invalid Date"` — the guard
  above leaves it to the existing path, which yields `null`, the same value the
  curated formatter's `DateCreateObject` returns for a falsy input.
- The change is in the projection only. `normalizeEventArg`'s array recursion,
  the depth cap and the pass-through for non-controls are unaffected.

## Example

`sap.m.SinglePlanningCalendar`, the app 109 case:

```abap
)->a( n = `selectedDatesChange` v = client->_event(
        val   = `DATES`
        t_arg = VALUE #( ( `${$parameters>/selectedDates}` ) ) )
```

Today the backend receives

```json
[{"ID":"__range0","startDate":"2018-07-08T22:00:00.000Z","endDate":null}]
```

and cannot tell which day the user clicked. With the change it receives

```json
[{"ID":"__range0","startDate":"2018-07-09T00:00:00","endDate":null}]
```

and app 307's 31 hand-rolled arguments collapse into one, cap included.
