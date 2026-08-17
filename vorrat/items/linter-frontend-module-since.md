---
target: abap2ui5-linter
title: 'Judge a `sap.ui.define` dependency array against the target release'
summary: a module the release lacks 404s and takes the whole component down — a blank app, not a missing feature — and nothing checks the dependency list of a custom control
priority: low
state: open
upstream: abap2UI5/linter
evidence:
  - `sap/ui/core/Theming` and `sap/ui/core/Messaging` are both @since 1.118 and both appear in framework code that has to boot on 1.71
  - abap2UI5 resolves them lazily with `sap.ui.require("…")` at the point of use for exactly this reason (`Component.js`)
  - the failure mode is a blank screen with no useful error, which is the most expensive shape a version mistake can take
---

# Judge a `sap.ui.define` dependency array against the target release

## What happens

```js
sap.ui.define(["sap/ui/core/Theming"], function (Theming) {   // @since 1.118
```

On a 1.71 runtime the module 404s, and the ui5loader fails the **whole
component** rather than the one module. The app is blank. There is no
"unsupported feature" message, no degraded mode, nothing naming the module — so
the first guess is always the wrong one.

The workaround is `sap.ui.require("…")` at the point of use plus an `undefined`
branch, which is what abap2UI5's own `Component.js` does. It is easy to write
and easy to forget.

## Why this is filed low, and honestly

The module half is decidable in principle — parse the `sap.ui.define`
dependency array against a per-release module list — but it needs two things
the linter does not have today:

1. **the data file** — a module inventory per OpenUI5 minor, which the existing
   `properties.json` generator does not produce;
2. **a reason to read JavaScript at all.** The linter's input is app classes and
   view XML. `sap.ui.define` appears only in frontend modules — abap2UI5's own
   `app/webapp/` and a consumer's custom controls — so this would be a new
   input kind, and nothing else is asking for one.

Until something else needs a frontend-module input, the cheaper home for this is
a gate in `abap2UI5/abap2UI5` covering its own `app/webapp/`, and this item
stays as the record of what the linter *could* cover if that input ever exists.

The neighbouring half — `sap_horizon` needing ≥ 1.102 — is **out of scope**
either way: a theme is configuration, not view content, and belongs in prose.
