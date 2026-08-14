---
name: build-an-app
description: How to build an application WITH abap2UI5 (as opposed to changing the framework) - app class template, lifecycle, view building via z2ui5_cl_ai_xml, two-way binding, events, popups, navigation, validation tooling. Use when writing or reviewing a z2ui5_if_app class, demo app, sample or any consumer application code.
---

# Building an abap2UI5 app

**Read `docs/agents/building-apps.md` in this repository — it is the complete
self-contained guide** (template, lifecycle, builder verbs, binding rules,
events, popups, navigation, portability rules, validation tooling). This
skill is the trigger and the checklist; the guide is the content.

Quick orientation while it loads:

- One ABAP class implements `z2ui5_if_app`; `main( client )` runs once per
  roundtrip — dispatch with `check_on_init( )` / `check_on_event( )`.
- PUBLIC attributes = serialized, browser-visible state. Bound data only;
  everything else PROTECTED.
- Build views with `z2ui5_cl_ai_xml` (`open`/`leaf`/`a`/`shut`/`stringify`).
  The legacy `z2ui5_cl_xml_view` is frozen — never use it in new code.
- Bind with `client->_bind( var )` (two-way, also for display-only;
  `_bind_edit` is obsolete). Row-template fields bind as `` `{UPPERCASE}` ``.
  Never write a model path as a text literal.
- Events: `client->_event( `NAME` )`, dispatch via
  `CASE client->get_event( ).`; client-resolved args are `$`-prefixed.
  Push data changes with `client->view_model_update( )`.
- Business logic is computed in ABAP, never in frontend formatters (thin
  frontend). UI5 1.71 is the compatibility floor — check "available since".
- The app checks its own authorizations at the top of `main`.
- Validate with the abap2UI5-linter
  (`npx --yes github:abap2UI5/linter <file>`); iterate without a SAP
  system via the ai-mcp server (`deploy_app` → `build_backend` → `run_app`).
- Before you finish, run the `abap-check` skill over what you wrote — it is the
  companion to this one and catches what a green lint does not: abapGit
  round-trip diffs, activation errors (`class_constructor` visibility,
  `LOCAL FRIENDS`), SLIN/ATC traps and runtime breakage that only shows on a
  real system.
- The API contract is `src/02/z2ui5_if_client.intf.abap` — when unsure about
  a method or a `cs_event` action, read it there; the `follow_up_action`
  abapdoc documents the full frontend-action catalog.
