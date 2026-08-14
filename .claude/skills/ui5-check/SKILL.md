---
name: ui5-check
description: The catalogue of UI5 problems a green CI does not catch - names that do not exist in the oldest supported release (icons, controls, properties, aggregations, enum values, modules, themes), layout that only works from a newer release on, views that fail to load rather than to render, and CSP/runtime traps. Also the staging area for the abap2UI5 linter - every entry says what a rule would need to decide it. Use when writing or reviewing any XML view, fragment or frontend module, when an icon or control "is simply not there" on an old system, and add the case here whenever a new one is found.
---

# What a green CI does not prove about the UI5 side

> **Scope.** This skill is about the *view* — the XML a backend builds, the
> fragments and modules the frontend ships — and about surviving the oldest UI5
> release abap2UI5 supports. It is the sibling of `abap-check`, which is the
> same idea for ABAP that has to survive a real SAP system. `build-an-app` is
> the third: how to *write* an app. Build with `build-an-app`, check the ABAP
> with `abap-check`, check the view with this one.
>
> **This file is a staging area.** The intent is that its entries move into the
> [abap2UI5 linter](https://github.com/abap2UI5/linter) over time — so every
> entry below carries a **Linter:** line saying whether a rule already decides
> it, what data a rule would need, and what it cannot decide. An entry that
> can never become a rule says so; that is the honest half of the catalogue.

**Everything here is a defect that actually shipped**, on `main`, past a fully
green CI. The failure mode that binds them together: **UI5 does not complain.**
An unknown icon name, a property the release does not have, a control laid out
by the wrong box model — none of these is an error. Nothing appears in the
browser console, nothing in `npm run verify`, nothing in ui5lint. The app just
renders slightly wrong, on somebody else's system, and somebody tells you
months later.

## The floor

**OpenUI5 1.71.** Everything abap2UI5 ships must render there. That is not a
theme setting or a nice-to-have: it is the release a large part of the
installed base is pinned to, and the one the bug reports come from.

## How to check a fact against 1.71 without a system

This is the single most useful technique in this file, and it needs no SAP
system, no CDN and no network beyond npm. **The OpenUI5 sources are on npm,
per library, per version:**

```
npm pack @openui5/sap.ui.core@1.71.80    # newest 1.71 patch
npm pack @openui5/sap.m@1.71.80
tar xzf openui5-sap.m-1.71.80.tgz package/src/sap/m/themes/base/Bar.less
```

What you get, and what each answers:

| File | Answers |
|---|---|
| `sap/ui/core/IconPool.js` (1.71) / `sap/ui/core/_IconRegistry.js` (newer) | does this icon name exist? — the name→codepoint map is inline in the source |
| `themes/base/<Control>.less` | how is it laid out? Diff the same file across two versions and the layout change is right there |
| `<Control>Renderer.js` | does it render a `<div>` or a `<span>` — block or inline? |
| `<Control>.js` metadata block | `@since` of the control, its properties and aggregations; `forwarding:` tells you where an aggregation actually lands |

**Diffing two versions of one `.less` or one renderer is how both entries in
section 2 were found.** When something works for you and not for a user on
1.71, pull both versions and diff the file — do not guess.

For the pure metadata questions (`@since` of a control, property or enum value)
there is a shortcut: `@abap2ui5/linter` ships
`data/properties.json` — 970 controls with per-member `@since`, generated from
the OpenUI5 sources. It has no icon and no layout data, which is exactly the
gap this file documents.

## Why the existing tooling is blind to most of this

Five separate holes, worth knowing precisely:

- **abaplint parses ABAP.** A view built by string concatenation or by a
  builder chain is, to abaplint, a set of valid string literals. There is no
  UI5 in its model at all.
- **ui5lint only reads `app/webapp/`, and `manifest.json` is excluded** — which
  is where `minUI5Version: 1.71` lives. It never sees a view the backend
  builds, which is where nearly every abap2UI5 view comes from.
- **The abap2UI5 linter has a 1.71 property gate but no icon and no layout
  gate**, and — as of the pin in `abap2UI5/samples` — it recognizes only app
  classes that call `z2ui5_cl_ai_xml=>factory`. The samples repository builds
  with `z2ui5_cl_xml_view`, so `npx abap2ui5lint` there reports
  *"no checkable files"* and its CI job is green without checking anything.
  **Check what it actually scanned before trusting it.**
- **The browser says nothing.** This is the important one. UI5 logs an unknown
  *module* loudly and an unknown *icon name*, *property* or *enum value* not
  at all — the first 404s, the others are silently dropped.
- **The 1.71 e2e gate only covers what its specs render.** The `ui5-1.71`
  Playwright project boots the shell and the roundtrip specs against pinned
  1.71, which catches a hard breakage on that path. Popups, fragments, custom
  controls and every backend-built view are outside it.

---

## 1. Names the target release does not have

All of these share one shape: a name that is perfectly valid *today* and did
not exist in 1.71. They differ only in how loudly they fail.

### 1.1 Icon names — the silent one

An unknown `sap-icon://` name is **not an error**. `IconPool` looks it up,
finds nothing, and the control renders with no icon at all. Nothing is logged.

| Icon | Reality | Use instead |
|---|---|---|
| `information` | reached the font after 1.71 | `message-information` — same circled "i", exists from 1.71 on |
| `clear-all` | reached the font after 1.71 | `eraser` |
| `textFormatting` | **exists in no release at all** | `text-formatting` |

That last row is its own trap: `IconPool.getIconInfo` resolves the URI through
`URI.parse( )` and reads `parts.hostname`, and a hostname is **lower-cased**.
So icon names are effectively case-insensitive, and a camelCase name is not
"nearly right" — it matches nothing, in every release, forever.

Where it bit us: the developer tools' help button and the legacy popups in
`src/99`, both on `information`; `abap2UI5/samples` sample 446; and
`abap2UI5/samples-stack` sample 489 on `clear-all` (all in `#2576` / `#750` /
`#21`, all found by a user reporting *"not all icons are shown"*).

**Linter:** *gated in this repository* by `npm run check:icons`
(`.github/scripts/ui5-icon-gate.mjs`) against a snapshot of the 1.71 registry
(`ui5-icons-1.71.json`, 654 names). **Ready to move into the abap2UI5 linter
as-is** — it needs nothing but the name list and a regex, and it belongs there,
because every consumer repository has the same exposure and none of them can
run this repository's gate. The name list is a snapshot on purpose: 1.71 is
closed for new features, so it cannot grow. Icons added later are precisely
what the rule rejects.

### 1.2 Properties, aggregations and enum values

The linter's property gate covers controls and members. It does **not** cover
enum *values*, and that is where this one hides:

- **`sap.m.ButtonType`** — `Critical`, `Negative`, `Success`, `Neutral` are
  **1.73**, `Attention` is **1.77**. On 1.71 the value is dropped and the
  button renders `Default`. This is why the overview headers use a
  `core:Icon` with `color=` rather than a coloured `Button`.
- **`sap.m.Dialog.footer`** — public only since **1.110**. Use `buttons`
  (1.21.1). This one is worse than a dropped property; see section 3.1.
- **`sap.m.Page.titleAlignment`** — **1.72**. Harmless (the title just keeps
  the 1.71 default, centered), but it explains why a 1.71 screenshot has a
  centered page title and a modern one does not. Not every difference in a
  screenshot is a bug.
- **`sap.m.IllustratedMessage`** — **1.98**, a whole control.

**Linter:** controls and members are **already decided** by the linter's
`ui5: "1.71"` property gate. Enum values are the gap: `properties.json` carries
`enumSince` per value (`sap.m.ButtonType.Critical → 1.73`), so the data is
there and only the rule is missing — **the cheapest next rule to add.**

### 1.3 Modules and themes

- **`sap.ui.define([...])` with a module the release lacks 404s and takes the
  *whole component* with it** — blank app, not a missing feature. Known
  post-1.71 modules: `sap/ui/core/Theming` and `sap/ui/core/Messaging` (both
  **1.118**). Resolve them lazily with `sap.ui.require("…")` at the point of
  use and handle `undefined` (see `Component.js`).
- **`sap_horizon` needs ≥ 1.102.** A 1.71 run needs `sap_fiori_3`. This is why
  the `ui5-1.71` Playwright project rewrites the theme as well as the
  bootstrap.

**Linter:** the module half is decidable — parse the `sap.ui.define` dependency
array and compare against a per-release module list. Needs a data file the
linter does not have yet. The theme half is configuration, not view content;
**out of scope for a view linter**, keep it as prose.

---

## 2. Layout that only works from a newer release on

The nastiest family, because the view is *correct* — every control and every
property exists in 1.71 — and it still renders wrong. Only the CSS changed.

### 2.1 Toolbar-only controls inside a `sap.m.Bar`

**`sap.m.ToolbarSpacer` and `sap.m.ToolbarSeparator` render a `<div>`** (see
their renderers) and are laid out as intended only inside a `sap.m.Toolbar`,
which is a flex container.

`sap.m.Bar` is not, before 1.76:

| Release | `.sapMBarLeft` / `.sapMBarRight` |
|---|---|
| 1.71 – 1.75 | `position: absolute` + `text-align`, children in **normal flow** |
| 1.76 and up | `display: inline-flex; align-items: center` |

In normal flow a **block-level child starts a new line**, and
`.sapMBarContainer { overflow: hidden }` at the bar's `height: 3rem` cuts away
everything from that line on. So on 1.71 a separator in a bar does not draw a
rule between two groups of icons — it **deletes every icon after it**, without
a word.

**And you rarely put a control into a `Bar` on purpose.** You get one from:

- `sap.m.Page` `headerContent` — forwarded to the internal Bar's `contentRight`
  (`forwarding: {getter: "_getInternalHeader", aggregation: "contentRight"}`)
- `customHeader` / `footer` with an explicit `<Bar>`

Where it bit us: the framework start page (two of four header icons gone), the
`abap2UI5/samples` overview header (documentation + GitHub gone) and the
`abap2UI5/samples-stack` overview header, where the first separator sits behind
the very first button and took **all five** family icons with it — all three
green in CI, all three fine on a modern release.

**The fix is not a different separator: it is no separator.** Put only inline
controls into a bar and express grouping with a margin class
(`sapUiMediumMarginBegin` on the first icon of the next group). A
`ToolbarSpacer` in `contentRight` is doubly pointless — that container is
right-aligned by itself.

**Linter:** decidable, and worth having — the rule is "a `ToolbarSpacer` /
`ToolbarSeparator` whose nearest ancestor control is a `Bar` (or a `Page`
`headerContent` / `customHeader` / `footer` aggregation) rather than a
`Toolbar`". The reconstructed view tree the linter already builds has
everything it needs; no new data file. **The best candidate after the icon
rule.**

The general form, worth keeping in mind before the next one is found: **a
control whose layout depends on its parent being a flex box is version-
sensitive even when every name in the view exists.** When something renders
right for you and wrong on 1.71, diff `themes/base/<Parent>.less` between the
two releases before looking at the view.

---

## 3. Views that fail to *load*, not to render

These are the loud ones — and they kill the whole view rather than one control.

### 3.1 A generic aggregation tag that is not an aggregation

`<ns:name>` — from `heading( ns )`, a literal `<footer>`, `_generic( name = …
ns = … )` — **must name an aggregation the parent actually has.** Otherwise UI5
resolves it as a **control class** and 404s with `failed to load
sap/<lib>/<name>.js`, killing the view.

Real 1.71 crashes fixed this way:

- `<footer>` on a `sap.m.Dialog` — the public `footer` aggregation is ~1.110,
  so on 1.71 `sap/m/footer.js` is requested and does not exist. Use `buttons`
  (1.21.1); UI5 lays the buttons out in an overflow toolbar. See
  `DeveloperTools.fragment.xml`, where the comment sits at the code site.
- (samples) `heading( 'uxap' )` on a `sap.uxap.ObjectPageSection`, which has no
  `heading` aggregation at all. It *is* valid on a parent that has one
  (`sap.f.DynamicPageTitle`), and `sap.m.Page.footer` is fine.

**This is section 1.2 with a worse blast radius**: a post-1.71 *property* is
dropped silently, a post-1.71 *aggregation* takes the view down.

**Linter:** decidable and high value — the aggregation names per control are in
`properties.json`, and the release floor is already configured. A lowercase tag
that is not an aggregation of its parent in the target release is an error.

---

## 4. Runtime and environment

Not about names or layout — these only show up when the app runs.

- **No expression binding (`{= … }`) in framework-controlled XML.** It is
  compiled with `eval`/`new Function`, so it dies under any CSP stricter than
  the default. Drive the state from a plain model property instead (see the
  DeveloperTools `closeEnabled` boolean). Conversely, the default CSP **keeps**
  `'unsafe-eval'` because the 1.71 ui5loader evals module source — removing it
  breaks the 1.71 bootstrap with a CSP `EvalError`.
- **A fragment dialog with a fixed `id` is loaded once and reused.** Destroying
  it on close and re-loading on the next open races the close animation on
  1.71: the fragment-scoped id is still registered and you get *"adding element
  with duplicate id"*. `show()` reuses, `close()` closes, only `exit()`
  destroys (see `DeveloperTools.js`).
- **`sap.m.MessageBox` always closes on Escape** and offers no way to suppress
  it. A popup that must not be Escape-dismissable — the fatal-error overlay —
  is a `sap.m.Dialog` with `escapeHandler: (oPromise) => oPromise.reject()`.

**Linter:** the expression-binding rule is decidable from the view text alone
(`{=` in any attribute value) and is a good early candidate. The other two are
about JS lifecycle, not about a view — **they stay prose**, here and in
`AGENTS.md` rules 16/17.

---

## 5. Reading a bug report about a missing icon

The two failure modes look identical from the outside — "the icon is not
there" — and have nothing to do with each other. Tell them apart first:

1. **One icon missing, others fine** → a name (section 1.1). Check it against
   the 1.71 list.
2. **A run of icons missing, always from the same position on** → layout
   (section 2.1). Look for a block-level control just before the first missing
   one.

The report that produced this file was both at once, in the same screenshot.
Do not stop at the first cause.

---

## Adding a new case

Same discipline as `abap-check`: one entry, one defect that actually happened.

1. **Say what UI5 does, not what it should do.** "Renders no icon and logs
   nothing" is the entry; "the icon is wrong" is not.
2. **Name the release boundary and how you established it.** `@since` from the
   control metadata, or the two npm packages you diffed. An entry that says
   "newer UI5" without a version is not actionable and will be wrong.
3. **Name the evidence** — the PR, commit or issue. Say when a user found it;
   those are the expensive ones.
4. **Say why the existing tooling missed it**, against the five holes above. If
   the answer is "it did not, we ignored it", it belongs in a lint config, not
   here.
5. **Write the `Linter:` line.** This is the point of the file. Three honest
   answers: *already decided* (say by what), *ready to move* (say what data and
   what detection a rule needs), or *cannot be decided* (say why). An entry
   without this line is a note, not a candidate.
6. **When an entry does move into the linter, keep it here** and change its
   `Linter:` line to point at the rule. The reasoning is why the rule is
   allowed to exist; deleting it invites somebody to relax the rule later.
