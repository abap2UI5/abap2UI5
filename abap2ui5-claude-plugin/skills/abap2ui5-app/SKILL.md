---
name: abap2ui5-app
description: >-
  Build an abap2UI5 application in pure ABAP — an ABAP class implementing
  z2ui5_if_app with a main( ) method, rendering UI5 views via the fluent
  z2ui5_cl_xml_view builder, with data binding, events, navigation and popups.
  No JavaScript, OData or RAP. Use whenever the user wants to create, scaffold,
  extend or debug an abap2UI5 app, view, table, form, popup, popover, or any UI5
  control written in ABAP — on-premise (NW 7.02+) or ABAP Cloud. Also covers
  wiring the HTTP/ICF entry point and choosing the right control.
---

# Building an abap2UI5 application

abap2UI5 lets you build SAP UI5 apps purely in ABAP. Every app is **one ABAP
class** implementing `z2ui5_if_app` with a single `main( client )` method that
the framework calls on every HTTP roundtrip. The browser loads a generic UI5
shell once, then exchanges JSON with your ABAP class. You build views with the
fluent `z2ui5_cl_xml_view` builder (or the generic `z2ui5_cl_util_xml`), bind
ABAP variables to controls, and react to events — all in ABAP.

This skill carries a **control catalog** and **recipe book** mined from the ~360
official samples, so you build from proven patterns rather than guesswork.

## Step 0 — Prerequisites (check once per project)
The abap2UI5 framework must be installed in the system (pull
`https://github.com/abap2UI5/abap2UI5` via abapGit) and reachable over HTTP.
If the user is starting from nothing, see **`reference/setup.md`** for installing
the framework, wiring the HTTP/ICF entry point, and running the app. You don't
need to re-do this for every app — once the framework + one ICF handler exist,
new apps are just new classes.

## Step 1 — Clarify the app
Before writing code, settle:
- **Class name & namespace** — the user's own (e.g. `ZCL_MY_APP`,
  `/NS/CL_APP`). Do NOT use the `z2ui5_cl_demo_app_*` demo naming; that is only
  for the samples repo.
- **Package / where it lives** in their project.
- **Target** — on-premise vs ABAP Cloud (affects the HTTP handler factory and
  some available controls; the app class itself is identical).
- **What it does** — the screens, data, and actions.

Ask only what you can't infer. If the user already has a project with ABAP
conventions, match them.

## Step 2 — Find the closest worked example
Map the user's intent to **`reference/examples-index.md`** (every UI feature →
the demo class that shows it) and **`reference/recipes.md`** (copy-paste patterns:
tables, popups, navigation, binding, events, file up/download, custom controls).
The examples live in the public `abap2UI5/samples` repo
(`src/z2ui5_cl_demo_app_<NNN>.clas.abap`) — read the named one to see a complete,
working implementation, then adapt it to the user's class name and data. For the
available controls and client methods, use **`reference/controls.md`**. Don't
invent method names — confirm them against a sample or the catalog.

## Step 3 — Choose the structure by size
- **`main( )` stays small (< ~50 lines)** → write everything inside `main`,
  using the lifecycle `IF / ELSEIF` chain. Start from
  **`templates/app_simple.clas.abap`**.
- **Larger** → make `main` a dispatcher that calls `on_init` / `on_event`
  (/ `on_navigation`), and add `view_display` / `data_read` / `data_update` as
  needed. Start from **`templates/app_canonical.clas.abap`**.
Never over-structure a small app; never cram a large one into `main`.

## Step 4 — Write the app class
- Implement `INTERFACES z2ui5_if_app.`; the entry point is
  `METHOD z2ui5_if_app~main.` with the signature
  `IMPORTING client TYPE REF TO z2ui5_if_client`.
- Drive flow with the lifecycle checks, chained with `ELSEIF`:
  `client->check_on_init( )` → `check_on_navigated( )` → `check_on_event( )`.
- Build the view with `z2ui5_cl_xml_view=>factory( )`, then call
  `client->view_display( view->stringify( ) )` as a standalone final statement.
- Bind data: `client->_bind_edit( var )` for two-way (editable),
  `client->_bind( var )` for read-only (display / list items).
- See **`reference/conventions.md`** for the abap2UI5 essentials and the two
  established ABAP style flavors (framework-style vs samples-style) — follow the
  user's existing project standards; otherwise default to the framework style.

## Step 5 — Wire & run
If this is the project's first app, ensure an HTTP entry point exists
(`z2ui5_cl_http_handler=>factory( )` on-prem / `factory_cloud( )` in the cloud,
bound to an ICF service node — see **`reference/setup.md`**). Then run the app by
opening the ICF service URL (or the launchpad tile) in a browser and exercise the
flow.

## Step 6 — Validate
- If the project uses **abaplint** (`abaplint.jsonc`), run `npx abaplint` and fix
  all issues — clean lint is the bar.
- Eyeball the view-builder indentation against the conventions.
- Confirm two-way bindings round-trip (edit in the UI → value arrives in ABAP).

## Golden rules
- **Read a real example before writing.** The examples-index maps every feature
  to one.
- **One class = one app**, implementing `z2ui5_if_app~main`.
- **`_bind_edit` = editable/two-way, `_bind` = read-only.** Picking the wrong one
  is the most common bug.
- **Don't invent control or client-method names** — confirm in `controls.md` /a
  sample, else use the generic builder (`z2ui5_cl_util_xml` / `_generic`).
- **Match the project's ABAP conventions**; don't impose the demo naming.

## Reference files
| File | When to read |
|---|---|
| `reference/setup.md` | First app in a project: install + ICF/HTTP wiring + run |
| `reference/examples-index.md` | Find the demo class that shows a given feature |
| `reference/controls.md` | Pick the right fluent control / client method |
| `reference/recipes.md` | Patterns: tables, popups, nav, binding, events, files, custom controls |
| `reference/conventions.md` | abap2UI5 essentials + the two ABAP style flavors |
| `templates/*` | Starting points for the app class |

> Deeper framework internals and the canonical app-building guide:
> <https://abap2ui5.github.io/docs/advanced/agent.html> and the core repo's
> `AGENTS.md` at <https://github.com/abap2UI5/abap2UI5>.
