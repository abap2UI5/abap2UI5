---
target: abap2ui5
title: 'A client control action cannot set a string property to the EMPTY string — `castArgAuto` turns it into the boolean `false`'
summary: an empty argument to an unlisted control method is inferred as `false`, and UI5 casts a non-string implicitly for a string-typed property, so a `setText`/`setValue` that should clear a control writes the literal word "false" instead
priority: medium
state: open
first_seen: 2026-08-23
upstream: abap2UI5/abap2UI5
evidence:
  - samples-controls app 462 (`sap.m.sample.InputValueUpdate`) keeps a round-trip per keystroke — declared lossy, because abap2UI5 drops an event fired while one is in flight — rather than use the roundtrip-free `control_by_id` `setText`, precisely because clearing the input would render the word "false"
  - traced 2026-08-23 in `app/webapp/core/actions/ControlCall.js` (`castArgAuto`) and in the pinned OpenUI5 `ManagedObject.validateProperty`, which casts implicitly with `"" + oValue` for a `string`-typed property rather than rejecting the boolean
---

# A client control action cannot set a string property to the EMPTY string

## Motivation

`CONTROL_BY_ID` became far more useful when it stopped enumerating methods and
started allowing any non-denied public control method. For a method with no
declared argument kinds the arguments are typed by inference:

```js
function castArgAuto(raw) {
  if (raw === "X" || raw === "true") return true;
  if (raw === "" || raw === " " || raw === "false") return false;
  return raw;
}
```

The `"X"`/space mapping is the ABAP boolean contract and has to be there. The
cost is that **the empty string has no representation left**: every string
setter reached through the unlisted path can be given any value except `""`.

UI5 then makes the failure silent rather than loud. `ManagedObject.validateProperty`
does not reject a boolean for a `string`-typed property — it casts implicitly:

```js
if (oType.getName() == "string") {
  if (!(typeof oValue == "string" || oValue instanceof String)) {
    oValue = "" + oValue;
  }
}
```

So `setText("")` arrives as `setText(false)` and renders the four characters
**false**. No error, no console warning, and a screenshot that looks like a
typo rather than a type bug.

## What it costs today

`samples-controls` app 462 rebuilds `sap.m.sample.InputValueUpdate`, whose
controller is one line:

```js
onLiveChange: function (oEvent) {
  this.byId("getValue").setText(oEvent.getParameter("value"));
}
```

The faithful abap2UI5 form is roundtrip-free and needs no backend at all:

```abap
)->a( n = `liveChange` v = client->follow_up_action(
        val   = client->cs_event-control_by_id
        t_arg = VALUE #( ( `getValue` ) ( `setText` ) ( `${$parameters>/value}` ) ) )
```

It is not used. The port keeps a **round-trip per keystroke** instead, and
declares the consequence: abap2UI5 serializes round-trips, so a `liveChange`
fired while one is in flight is dropped and the Text shows the last completed
trip under fast typing. That is the worse behaviour of the two — and it is
chosen because the better one breaks on the one keystroke the sample is about,
the one that empties the field.

The same hole applies to `setValue`, `setTitle`, `setPlaceholder`,
`setTooltip`, `setDescription` — every string setter, whenever the value can
legitimately be empty.

## Proposed change

Give the empty string a spelling that survives inference. Two options, in the
order I would try them:

**1. Type the argument from the control's own metadata.** At the call site the
control and the method name are both known, so for a `setXxx` the declared
property type is available:

```js
const prop = control.getMetadata().getAllProperties()[lcFirst(method.slice(3))];
if (prop && prop.type === "string") return raw;   // never infer, keep it a string
```

This removes the guess entirely for exactly the case where the guess is wrong,
uses UI5's own declaration as the authority, and needs no new wire syntax. A
method that is not a `setXxx`, or a property that is not a string, keeps the
current inference.

**2. A sentinel for the empty string**, e.g. the backend emitting a reserved
token that `castArgAuto` maps back to `""`. Cheaper to implement, but it adds a
thing to remember to every future caller, and a sentinel that leaks is worse
than the bug.

Option 1 is the one to do; option 2 is listed so the trade-off is on record.

## Scope — what must NOT change

- **The `"X"`/space boolean contract stays** for every argument whose target is
  not a declared string property. That mapping is how ABAP booleans travel and
  a great many wires depend on it.
- **`"true"`/`"false"` string literals keep mapping to booleans** on the
  inferred path, for the same reason.
- **Declared argument kinds are unaffected** — `castArgs` with a non-null
  `kinds` list already types those, and `NULLABLE_KINDS` already handles the
  "empty means null" contract for `controlIdOrNull`. This is only about the
  `kinds === null` branch.
- The fix must not make an empty argument reach a method that **expects** to be
  called with no argument at all: the backend's `get_t_arg` still drops a
  trailing empty entry, and that behaviour is relied on (`open()` must stay
  no-arg). This change is about an empty argument in a NON-trailing position,
  or one the caller made explicit.

## Example

With the change, app 462 drops its `on_event` entirely and becomes a
view-only class — the original is a one-line controller, so the port would be
one wire, roundtrip-free, and would lose the declared keystroke-dropping
deviation with it.
