---
target: linter
title: '`invalid-property-value` rejects the enum KEY, which is the spelling an XML view needs'
summary: for the handful of UI5 enums whose key differs from its value (`CalendarIntervalType.OneMonth` = "One Month"), the rule accepts only the VALUE - but an XML view is parsed with `parseValue( )`, which maps key -> value, so the value form is the one that breaks and the key form is the one the rule reports
priority: medium
state: open
first_seen: 2026-09-13
upstream: abap2UI5/linter
evidence:
  - 'found 2026-09-13 rebuilding the Team Calendar demo app (abap2UI5/samples-controls `z2ui5_cl_smpc_demo_003`): `intervalType="OneMonth"`, copied verbatim from the demo kit original, is reported as `sap.m.PlanningCalendarView intervalType="OneMonth" is not a valid value (allowed: Hour, Day, Month, Week, One Month)`'
  - 'the original writes the key: src/sap.m/test/sap/m/demokit/teamCalendar/webapp/view/PlanningCalendar.fragment.xml line 58, `intervalType="OneMonth"` - it has shipped in the demo kit for years'
  - '`sap/ui/unified/library.js` declares `CalendarIntervalType = { Hour: "Hour", Day: "Day", Month: "Month", Week: "Week", OneMonth: "One Month" }` - the only entry in the enum whose key and value differ'
  - '`sap/ui/base/DataType.js` `createEnumType( )`: `parseValue = function(sValue) { return oEnum[sValue]; }` (key -> value) and `isValid = function(v) { return mValues.hasOwnProperty(v); }` where `mValues` is keyed by VALUE. An XML view attribute goes through `parseValue( )` first, so `"OneMonth"` becomes `"One Month"` and validates, while `"One Month"` becomes `undefined` and fails'
  - waived in the port with `" abap2ui5lint-disable-next-line invalid-property-value` and a comment carrying this reasoning, rather than writing the spelling that would break the app
---

# `invalid-property-value` rejects the enum KEY, which is the spelling an XML view needs

## What happens

A view written exactly as the demo kit writes it is reported as wrong:

```abap
)->ele( `PlanningCalendarView`
    )->a( n = `key`          v = `OneMonth`
    )->a( n = `intervalType` v = `OneMonth`     " <- reported
    )->a( n = `description`  v = `Month` )
```

```
error  sap.m.PlanningCalendarView intervalType="OneMonth" is not a valid value
       (allowed: Hour, Day, Month, Week, One Month)  invalid-property-value
```

## Why the report is wrong

UI5 enums are `{ <key>: <value> }` maps and almost always have key === value,
which is why this has not surfaced before. `CalendarIntervalType` is the
exception: `OneMonth: "One Month"`.

An XML view attribute reaches `ManagedObject` as a string and is put through
the data type's `parseValue( )` before validation
(`sap/ui/base/DataType.js`, `createEnumType`):

```js
oType.isValid    = function (v) { return typeof v === "string" && mValues.hasOwnProperty(v); };  // mValues keyed by VALUE
oType.parseValue = function (s) { return oEnum[s]; };                                            // KEY -> VALUE
```

So the two spellings behave in exactly the opposite way to what the message
says:

| written in the view | `parseValue( )` | `isValid( )` | result |
|---|---|---|---|
| `OneMonth` (key) | `"One Month"` | true | renders - and is what the demo kit ships |
| `One Month` (value) | `undefined` | false | `validateProperty` throws, the view dies |

The rule's allowed-list is built from the enum's VALUES, so it accepts the
spelling that breaks and reports the spelling that works.

## Proposed change

Accept **both** the key and the value of an enum, i.e. build the allowed set
from `Object.keys(oEnum)` unioned with `Object.values(oEnum)`, and keep
reporting anything that is in neither. Where the two differ, prefer naming the
KEY first in the message, since that is what a view author writes and what the
demo kit samples are written in.

Nothing else in the rule needs to move: for every enum whose key equals its
value - the overwhelming majority - the union is the set the rule already has.

## Also seen in the same session, unrelated but worth a look

The reconstructor does not resolve a `client->_bind_path( )` call inside a
binding-string template when the chain statement is rooted at a DERIVED
variable rather than at the view root:

```abap
DATA(pc) = content->ele( `VBox` )->ele( `PlanningCalendar` ).
pc->a( n = `startDate` v = |\{ path: '{ client->_bind_path( start_date ) }', formatter: 'Formatter.DateCreateObject' \}| ).
```

reports `note: unresolved template expression: { client->_bind_path( start_date ) }`,
while the identical attribute inside one chain rooted at `view->` (as in
`z2ui5_cl_smpc_app_540`) resolves. The render gate still passes - the
attribute simply carries the unresolved text into the mock document - so this
is a fidelity gap in what the gate judges, not a failure.
