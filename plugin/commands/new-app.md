---
description: Build a new abap2UI5 app from a plain-language description - one class implementing z2ui5_if_app plus its abapGit sidecar, sample catalogue checked first, validated and looked at before it is handed over.
argument-hint: <what the app should do>
allowed-tools: Read, Grep, Glob, mcp__plugin_abap2ui5_abap2ui5__examples, mcp__plugin_abap2ui5_abap2ui5__read_example, mcp__plugin_abap2ui5_abap2ui5__capabilities, mcp__plugin_abap2ui5_abap2ui5__app_guide, mcp__plugin_abap2ui5_abap2ui5__api_reference, mcp__plugin_abap2ui5_abap2ui5__validate_view, mcp__plugin_abap2ui5_abap2ui5__fix_view, mcp__plugin_abap2ui5_abap2ui5__screenshot_view, mcp__plugin_abap2ui5_abap2ui5__pitfalls
---

Build an abap2UI5 app that does this: **$ARGUMENTS**

If that is empty, ask what the app should do and stop.

## 0. Tooling

The abap2UI5 MCP server ships with this plugin (`plugin:abap2ui5:abap2ui5`;
a copy added with `claude mcp add abap2ui5` exposes the same tools as
`mcp__abap2ui5__*`). If its tools are available, use them where named below.
If not, every step has a fallback - say once which path you are on.

## 1. Look before you write

A sample that already does it beats anything written from scratch: it is
gated, rendered and downported.

- MCP: `examples { query: "<keywords from the request>" }` - two or three
  queries with different keywords; `repo: "samples-controls"` when the
  request names a UI5 control. Read the best hit with `read_example { class }`.
  When the request needs a control you are unsure of,
  `capabilities` says whether abap2UI5 can express it at all.
- Without MCP: fetch https://abap2ui5.github.io/playground/samples/apps.json
  (title, summary and keywords of every sample of the three catalogues) and
  read the hit's source on GitHub. If that host is unreachable, the same
  catalogues are `catalogue.json` at the root of
  `https://raw.githubusercontent.com/abap2UI5/samples/main/`,
  `.../samples-controls/main/` and `.../samples-stack/main/`.
- Only propose a samples-stack sample when the user has what it needs
  (OData, RAP, APC, the launchpad).

Tell the user in one line which sample(s) you build on, or that none fits.

## 2. Follow the build-an-app skill

Load the `abap2ui5:build-an-app` skill and read the guide it points at,
`${CLAUDE_PLUGIN_ROOT}/docs/agents/building-apps.md` (chapters 2-5 at least;
MCP `app_guide` serves the same text). Keep the
`abap2ui5:view-chain-layout` skill open while writing the view.

## 3. Write ONE class

- Name: what the user asked for, else `zcl_<short_name>` (max 30 characters,
  lower case in the file name). Put it where the project keeps its classes
  (`src/` in a project made from abap2UI5/app-template); if that is unclear,
  ask.
- `<name>.clas.abap` - one class, `INTERFACES z2ui5_if_app`, the dispatcher
  on `check_on_navigated( )` / `check_on_event( )` (`check_on_init( )` only
  for one-time setup), the view built with `z2ui5_cl_ui5_view_builder`
  (never the frozen `z2ui5_cl_xml_view`), `client->_bind( )` on PUBLIC
  attributes only, booleans through `a( n = ... b = ... )`, UI5 1.71 names
  only, no line over 255 characters.
- `<name>.clas.xml` - the abapGit sidecar: UTF-8 **with BOM**, LF, one final
  newline, `<CLSNAME>` the class name upper-cased, `<LANGU>E</LANGU>`,
  `<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>` only when a `.testclasses.abap`
  exists, `&apos;` instead of a raw apostrophe in `<DESCRIPT>`. Copy the shape
  of a sidecar the project already has; app-template's
  `src/zcl_app_001.clas.xml` is the reference.
- No other objects (no DDIC, no second class) unless the user asks.

## 4. Validate and look - then iterate

Repeat until clean:

- MCP: `validate_view { abap_source, project_dir }` - fix every error and
  warning (`fix_view` applies the mechanical ones and returns the source; you
  write it back). Then `screenshot_view { abap_source, sizes: ["1280x900",
  "390x844"] }`, passing `model` with a few preview rows when a table or list
  would otherwise photograph empty.
- Without MCP: `npx --yes @abap2ui5/linter <file>` (`npm run check:abap2ui5`
  in an app-template project). For a picture,
  `npx --yes -p @abap2ui5/linter -p @abap2ui5/linter-render abap2ui5lint --screenshot <file>`
  writes a PNG (needs Chromium: `npx playwright install chromium`) - read
  the PNG.

**Look at the screenshot.** Compare it with the request: every field, button
and column there, nothing in the wrong place, nothing collapsed or empty
that should not be. Fix and re-run.

Optional, when the user wants the running app: `verify_app` (validate,
deploy, build, boot) or `deploy_app` -> `build_backend` -> `run_app`, and
`interact_app` to drive an event.

## 5. Finish with the gates

- Run `/abap2ui5:check` on the new class (abaplint + the linter, or
  `npm run check` in an app-template project) and get it green.
- Go through the `abap2ui5:abap-check` skill's section 1 (abapGit round trip)
  for the two files, and `abap2ui5:ui5-check` for any icon or control you
  are unsure about on 1.71. MCP `pitfalls` lists both catalogues.

Report: the files written, the sample it was based on, the gate result, what
the screenshot shows, and anything the request asked for that the app does
not do yet.
