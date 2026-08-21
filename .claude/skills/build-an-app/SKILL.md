---
name: build-an-app
description: How to build an application WITH abap2UI5 (as opposed to changing the framework) - app class template, lifecycle, view building via z2ui5_cl_ui5_view_builder, data binding, events, popups, navigation, validation tooling. Use when writing or reviewing a z2ui5_if_app class, demo app, sample or any consumer application code.
---

# Building an abap2UI5 app

**Read `docs/agents/building-apps.md` in this repository — it is the complete
self-contained guide** (template, lifecycle, builder verbs, binding rules,
events, popups, navigation, portability rules, validation tooling). This
skill is the trigger and the checklist; the guide is the content.

**Before writing one from scratch, ask whether it exists.** `abap2UI5/samples`
holds 149 working apps, each linted, rendered and downported to three
releases — a value help, a tree, navigation between two apps, a dynamic table
typed at runtime. Reading one beats reproducing it, and beats any snippet: the
sample is gated, a snippet is a copy somebody has to keep in step.

- With the [MCP server](https://github.com/abap2UI5/mcp-server): the `examples`
  tool queries that catalogue (`examples { query: "value help f4" }`) and
  hands back the class to read. Its neighbour `capabilities` answers the other
  question — whether a UI5 *control* can be expressed at all — out of
  samples-controls' 416 ports.
- Without it: [SAMPLES.md](https://github.com/abap2UI5/samples/blob/main/SAMPLES.md)
  is the same catalogue as a page.

Quick orientation while it loads:

- One ABAP class implements `z2ui5_if_app`; `main( client )` runs once per
  roundtrip — dispatch with `check_on_init( )` / `check_on_event( )` /
  `check_on_navigated( )`.
- **The `check_on_navigated( )` branch is part of the dispatcher, not an
  option.** `check_on_init( )` is "this app instance never ran", not "the app
  starts": it stays false when a called app hands control back
  (`nav_app_leave`, any `z2ui5_cl_pop_*` value help — those run over
  `nav_app_call` too) and when a bookmarked state is restored. Those roundtrips
  fire `check_on_navigated( )` alone, and a branch that does not re-run
  `view_display( )` there leaves the previous screen standing with no error
  anywhere. Apps built without it work perfectly until the day someone calls
  them from a navigation — the linter's `missing-view-display-on-navigated`
  covers the branch that exists but never displays.
- **Ask the lifecycle with the call itself, never with `IS INITIAL`.** The
  three `check_on_*( )` methods return `abap_bool`, so the branch is
  `IF client->check_on_init( ).` — a predicative call, the way the sample corpus
  and the documentation on `z2ui5_if_client` write it. Compounds keep the
  shape (`IF client->check_on_init( ) OR client->check_on_navigated( ).`,
  `` ELSEIF client->check_on_event( `LOCK` ). ``). `IS NOT INITIAL` asks a
  boolean whether it is EMPTY, which is what that question means for a string,
  and it is one more dialect an app author has to read. Only a NEGATIVE branch
  is spelled out, as `= abap_false`: the corpus has no negated predicative
  form. Every other `abap_bool` follows the same rule: `IF mv_flag = abap_false.`
  and `DELETE lt_x WHERE flag = abap_false.`, never `IS INITIAL` on either.
- PUBLIC attributes = serialized, browser-visible state. Bound data only;
  everything else PROTECTED.
- Build views with `z2ui5_cl_ui5_view_builder`
  (`ele`/`tag`/`a`/`end`/`stringify`). The legacy `z2ui5_cl_xml_view` is
  frozen — never use it in new code.
- **A boolean from an ABAP variable goes through `a( )`'s `b` parameter**:
  `` )->a( n = `editable` b = mv_edit_mode ) `` renders `true`/`false`.
  Never feed `abap_true` into `v` raw — it serializes as `X`.
- **The chain's layout is strict, not taste — read the `view-chain-layout`
  skill before writing one.** It is the single source of the rules, identical
  in this repository and both sample repositories, and it is machine-checked
  (the linter's `chain-house-layout` rule: `npm run check:abap2ui5` reports,
  `npm run fmt:chains` applies). In short: one call per line, four spaces per
  level, the `)` rides with the arrow (`)->`), `end( )` alone
  in the column of the `ele( )` it closes, a control's `a( )`s one level in
  with their `v =` aligned. Blank lines only in the single-chain shape, where
  a blank opens a block and there are exactly two.
- **Which `factory( )` shape you use is decided by the chain shape**, not by
  preference: a view split into a statement per subtree hangs the chain off
  the `factory( )` (one statement, not two) so the variable holds the
  `mvc:View`; a view written as one chain may take a `factory( ).` of its own.
  A standalone `factory( ).` *with* the split shape is broken — the variable
  then holds the root and the next statement adds a second root beside the
  `mvc:View`. See the skill.
- Bind with `client->_bind( var )` (also for display-only;
  `_bind_edit` is obsolete). Row-template fields bind as `` `{UPPERCASE}` ``.
  Never write a model path as a text literal.
- Events: `client->_event( `NAME` )`, dispatch via
  `CASE client->get_event( ).`; client-resolved args are `$`-prefixed.
  Changed bound data is pushed automatically — `view_model_update( )` is
  obsolete, does nothing, and gets deleted whenever you touch an app.
- Business logic is computed in ABAP, never in frontend formatters (thin
  frontend). UI5 1.71 is the compatibility floor — check "available since".
- The app checks its own authorizations at the top of `main`.
- Validate with the abap2UI5-linter
  (`npx --yes @abap2ui5/linter <file>`); iterate without a SAP
  system via the mcp-server (`deploy_app` → `build_backend` → `run_app`).
- Before you finish, run the `abap-check` skill over what you wrote — it is the
  companion to this one and catches what a green lint does not: abapGit
  round-trip diffs, activation errors (`class_constructor` visibility,
  `LOCAL FRIENDS`), SLIN/ATC traps and runtime breakage that only shows on a
  real system.
- The API contract is `src/02/z2ui5_if_client.intf.abap` — when unsure about
  a method or a `cs_event` action, read it there; the `follow_up_action`
  abapdoc documents the full frontend-action catalog.
