---
target: abap2ui5-linter
title: 'Let `generate-metadata.mjs` cover the SAPUI5-only libraries'
summary: a third resolve candidate plus an additive `--libs`, so `properties.json` can cover the `@sapui5/*` packages — without it the property and scope gates are blind wherever a control is SAPUI5-only
priority: medium
state: open
first_seen: 2026-08-11
upstream: abap2UI5/linter
evidence:
  - the prerequisite for opening `src/03`/`src/04` in `abap2UI5/samples-controls` (its AGENTS §3)
  - a control absent from the snapshot is silently passed today, so the gates report clean on ports nothing looked at
---

# Let `generate-metadata.mjs` cover the SAPUI5-only libraries

## Motivation

ai-demokit is opening a home for ports of SAPUI5-only controls —
`src/03` (`SAPUI5 <= 1.71`) and `src/04` (`SAPUI5 > 1.71`), see its AGENTS §3.
The blocker is not the ABAP side: it is that **no metadata snapshot covers
those libraries**, so the property gate, the scope gate and the release split
between `src/03` and `src/04` are all blind there.

The sources are available and already pinned: the `@sapui5/*` npm packages ship
the same JSDoc'd `src/sap/…` tree as `@openui5/*` (verified at 1.151.0 — the
class-level `@since`/`@deprecated` this generator reads are present and
identical in shape). ai-demokit pins eight of them in its `package.json` and
its `scripts/scope-of.mjs` already resolves SAPUI5 entities from them.

What is missing is `ui5/properties.json` coverage — and that file must keep
coming from **this one generator**. ai-demokit's own rule is explicit: one
generator, never a second parser, because two parsers over two checkouts had
already drifted once (a file-level `@deprecated` attributed to the control,
marking `sap.f.DynamicPageTitle` and `sap.f.semantic.SemanticPage` deprecated
when neither class doc says so). So the extension belongs here, not there.

## Current behavior

`scripts/generate-metadata.mjs` hardcodes both the library list and the npm
scope it resolves from:

```js
const LIBS = [
  'sap.m', 'sap.f', 'sap.ui.core', 'sap.ui.layout', 'sap.ui.table',
  'sap.ui.unified', 'sap.uxap', 'sap.tnt', 'sap.ui.codeeditor', 'sap.ui.integration',
];
…
const resolveDir = (pkg, libPath) => {
  const candidates = [];
  if (process.env.OPENUI5_DIR) {
    candidates.push(path.join(process.env.OPENUI5_DIR, 'src', pkg, 'src', ...libPath.split('/')));
  }
  candidates.push(path.join(ROOT, 'node_modules', `@openui5/${pkg}`, 'src', ...libPath.split('/')));
  return candidates.find((c) => fs.existsSync(c));
};
```

There is no knob for either: `--out` chooses the output file and `OPENUI5_DIR`
chooses the checkout, but a consumer cannot add a library or a second npm
scope. A SAPUI5 library is therefore unreachable, and every SAPUI5 control is
absent from the snapshot — which the property gate reads as "silently passed"
(a control not in `properties.json` at all is not flagged), the worst of the
three possible answers.

## Proposed change

Two small, additive edits:

1. **Resolve `@sapui5/<pkg>` as a third candidate**, after `OPENUI5_DIR` and
   `@openui5/<pkg>`. The layouts are identical (`<pkg>/src/<libPath>`), so this
   is one more `candidates.push`.
2. **Make the library list extensible** — an opt-in `--libs <a,b,c>` (or
   `UI5_LIBS`) that adds to `LIBS` rather than replacing it, so the default
   snapshot this repo commits is byte-identical and the `--check` drift gate
   keeps working unchanged.

Nothing about the parsing changes: same class-doc slicing, same `@since` /
`@deprecated` rules, same output shape.

## Example

```sh
# today — the default OpenUI5 snapshot, unchanged
node scripts/generate-metadata.mjs --out ui5/properties.json

# proposed — the same snapshot plus the SAPUI5-only libraries a consumer pins
node scripts/generate-metadata.mjs --out ui5/properties.json \
  --libs sap.suite.ui.commons,sap.suite.ui.microchart,sap.ui.comp,sap.ui.vbm,sap.ui.vk,sap.ndc,sap.viz,sap.gantt
```

Expected effect on ai-demokit, measured by hand against the pinned packages
(`@sapui5/*` 1.151.0) while writing this request — these are the twelve
candidate ports' controls, and the snapshot would have to reproduce them:

| Control | class `@since` | class `@deprecated` |
|---|---|---|
| `sap.suite.ui.microchart.InteractiveDonutChart` / `…LineChart` / `…BarChart` | 1.42.0 | — |
| `sap.suite.ui.microchart.RadialMicroChart` | 1.36.0 | — |
| `sap.suite.ui.microchart.HarveyBallMicroChart` | 1.34 | — |
| `sap.suite.ui.commons.ProcessFlow` | (base) | — |
| `sap.suite.ui.commons.Timeline` | (base) | — |
| `sap.suite.ui.commons.networkgraph.Graph` | 1.50 | — |
| `sap.suite.ui.commons.statusindicator.StatusIndicator` | 1.50 | — |
| `sap.ui.vbm.AnalyticMap` | (base) | — |
| `sap.ndc.BarcodeScannerButton` | (base) | — |
| `sap.viz.ui5.controls.VizFrame` | 1.22.0 | — |
| `sap.ui.comp.filterbar.FilterBar` | (base) | — |
| `sap.gantt.GanttChartWithTable` / `sap.gantt.GanttChartContainer` | (base) | **1.64** — use `sap.gantt.simple.GanttChartWithTable` |

The last row is the point of the request in miniature: two ports that look
portable are in fact built on a control deprecated six years ago, and no gate
in ai-demokit can currently say so — `scope-of.mjs` only can because it reads
the sources directly, which is a reporter, not a gate.

## Out of scope for this request

The metadata is one of three things a SAPUI5 port needs; the other two are
ai-demokit's problem, not the linter's, and are tracked in its AGENTS §3:

- **the sample templates** — SAPUI5 demo kit samples live only in the demo kit
  web app (`ui5.sap.com/test-resources/<lib>/demokit/sample/<Name>/`); there is
  no public SAPUI5 git repo and the npm packages ship no `test/` tree (neither
  do the `@openui5` ones, which is why the universe comes from a git clone);
- **the themes** — `@openui5/themelib_sap_horizon` carries built CSS for the
  OpenUI5 libraries only, there is no `@sapui5` themelib on npm, and the
  library packages ship `.less` sources with zero `.css`, so `render_smoke`
  would draw unthemed zero-size controls.
