---
target: abap2ui5
title: 'setBadgeMinValue / setBadgeMaxValue take no declared arg kind, so UI5 compares the bounds as STRINGS and silently rejects a valid pair'
summary: neither setter is in CONTROL_METHODS, so castArgAuto leaves the value a string; sap.m.Button then evaluates `iMin <= this._badgeMaxValue` lexicographically, and a pair like min 9 / max 50 is dropped with only a Log.warning
priority: low
state: open
first_seen: 2026-08-26
upstream: abap2UI5/abap2UI5
evidence:
  - sap.m.Button.setBadgeMinValue (Button.js:339) guards on `iMin && !isNaN(iMin) && iMin >= BADGE_MIN_VALUE && iMin != this._badgeMinValue && iMin <= this._badgeMaxValue`, and falls into an else that only calls Log.warning - so a rejected value is invisible to the app
  - with a string argument, `"9" <= 50` is true but `"50" <= "9"` is FALSE, so the max setter rejects any max whose leading digit sorts below the min's - min 9 / max 50 is the smallest realistic pair that breaks
  - samples-controls app 249 drives both setters from its MIN_CHANGE / MAX_CHANGE wires, so the live port already carries this; it was found while fixing that port's separate rebuild-loss defect and is deliberately reported apart from it
  - neither setter appears in CONTROL_METHODS, so both take the unlisted path where castArgAuto keeps a numeric string a string
---

# The badge bounds are compared as strings

## Motivation

`CONTROL_METHODS` declares an argument kind per method, and `int` is what makes
a numeric argument arrive as a number. `setBadgeMinValue` and
`setBadgeMaxValue` are not declared, so they take the unlisted path, where
`castArgAuto` deliberately leaves a numeric string alone.

`sap.m.Button` then compares the incoming value against the *stored* bound. One
side is a string and the other a number, so JavaScript's relational operator
decides by string order whenever both are strings. `"50" <= "9"` is false, and
the setter drops the value into an `else` whose only effect is a
`Log.warning` - nothing the ABAP side can observe.

The failure is therefore silent, data-dependent (it needs a differing digit
count), and invisible to every gate.

## Proposed change

Declare the two setters with the `int` kind, as their siblings already are:

```js
setBadgeMinValue: ["int"],
setBadgeMaxValue: ["int"],
```

## What the change must NOT do

- **It must not change the unlisted path itself.** `castArgAuto`'s
  string-preserving behaviour is deliberate and documented; the fix is to
  declare these two methods, not to make inference cleverer.
- **It must not paper over the silence.** Even with `int` the setter still
  rejects an out-of-range pair with only a `Log.warning`. If a reported failure
  is wanted, that is a second, larger question about unlisted-method results
  generally - do not fold it in here.
