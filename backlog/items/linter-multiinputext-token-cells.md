---
target: abap2ui5-linter
title: 'Mirror `MultiInputExt`''s TokenKeyCell / TokenTextCells in the render harness'
summary: the linter carries a metadata-only mirror of the bundled companion controls, and the two properties the suggestion-row validator added are not in it - so a view that uses them fails view creation in the render gate
priority: medium
state: open
first_seen: 2026-08-22
upstream: abap2UI5/linter
evidence:
  - abap2UI5 shipped `TokenKeyCell` / `TokenTextCells` on `z2ui5.cc.MultiInputExt` on 2026-08-22 (the suggestion-row half of `MultiInput.addValidator`)
  - converting `abap2UI5/samples-controls` apps 612 and 613 to the companion failed the render gate immediately - `Error found in View: <z2ui5:MultiInputExt ... TokenKeyCell="0" TokenTextCells="3"/>` - and the conversion was held back rather than shipped behind two gate skips
  - the mirror is `lib/render.mjs`, the `boot()` function's `sap.ui.define('z2ui5/cc/MultiInputExt', ...)` block
---

# Mirror `MultiInputExt`'s TokenKeyCell / TokenTextCells

## What happens

`lib/render.mjs` boots the render harness with **metadata-only mirrors** of the
bundled abap2UI5 custom controls, because the harness only validates view
creation and does not need their behaviour:

```js
sap.ui.define('z2ui5/cc/MultiInputExt', ['sap/ui/core/Control'], function (Control) {
  return Control.extend('z2ui5.cc.MultiInputExt', {
    metadata: {
      properties: {
        MultiInputId: { type: 'string' },
        MultiInputName: { type: 'string' },
        addedTokens: { type: 'object' },
        checkInit: { type: 'boolean', defaultValue: false },
        removedTokens: { type: 'object' },
      },
      ...
```

That list is a copy of the control's own metadata, and a copy goes stale. On
2026-08-22 abap2UI5 added two properties to the real control —

| Property | Type | Meaning |
|---|---|---|
| `TokenKeyCell` | `int`, default `-1` | index of the suggestion row's cell whose text becomes the token KEY; `-1` leaves the row branch inert |
| `TokenTextCells` | `string`, default `""` | comma-separated cell indices composing the token TEXT as `key(a b)` |

— and a view that uses them now fails **view creation**, not just a property
check:

```
Error found in View (id: '__xmlview0').
XML node: '<z2ui5:MultiInputExt xmlns:z2ui5="z2ui5.cc" MultiInputId="multiInput2" TokenKeyCell="0" TokenTextCells="3"/>'
```

## Why it matters more than a missing property usually would

An unknown property on a real control is a finding a `POST_171`-style
declaration can carry. Here the mirror IS the control as far as the harness is
concerned, so an unmirrored property is indistinguishable from a typo and takes
the whole view down. The corpus held back the two ports the framework change
was made for rather than declare a `property_gate` plus a `render_smoke` skip
for something that is neither a version gap nor a typo.

## Proposed change

Add both properties to the mirror. Nothing else is needed — the harness never
runs the validator, only creates the view:

```js
        TokenKeyCell: { type: 'int', defaultValue: -1 },
        TokenTextCells: { type: 'string', defaultValue: '' },
```

## The general half, if it is wanted

The mirrors will drift again on the next companion-control change. Two ways
out, either is better than a hand-kept copy:

- **Generate them.** The metadata blocks live in `abap2UI5`'s
  `app/webapp/cc/*.js` and are already extracted mechanically into ABAP
  constants by that repository's `tools/app2abap`. The same source could emit a
  mirror module.
- **Be permissive for `z2ui5.cc.*` only.** A mirror could accept unknown
  properties on this one namespace, so a stale copy degrades to "not checked"
  rather than "view fails". That loses the typo check on eight controls, which
  is why generating is the better half of the pair.

## What it must NOT do

Do not make the harness permissive for control namespaces in general — the
whole point of the render gate is that a property UI5 does not know is a real
finding. This is about a mirror the linter itself maintains.
