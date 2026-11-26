---
target: abap2ui5
title: 'Addon rename red on main: headless-frontend, abap-agent-runtime and abap-cloud-gui lag abap2UI5 1.151.0'
summary: npm run rename is red on main of headless-frontend and abap-agent-runtime against abap2UI5 main (1.151.0) - router target and two new draft store methods; abap-cloud-gui is green only on its 1.150.0 pin (25 issues against main); DEV of all three passes - and abap-agent-runtime clones headless-frontend at its default branch instead of a pin
priority: high
state: open
first_seen: 2026-11-26
upstream: abap2UI5-addons
evidence:
  - 'headless-frontend origin/main ddcc1ae, npm run rename 2026-11-26: "src/z2ui5_cl_frontend_sim.clas.abap[1467, 49] - Component \"router\" not found in structure (check_syntax)", "src/z2ui5_cl_frontend_sim.clas.testclasses.abap[16, 7] - Implement method \"prune_chain\" from interface \"z2ui5_if_ui5_draft_store\"" and "... \"touch\" ..." (plus 4 IF_HTTP_EXTENSION errors, addon-rename-core-src03)'
  - 'abap-agent-runtime origin/main 7d3cad9, npm run rename: the three headless-frontend errors above from its clone of headless-frontend main, plus "src/01/z2ui5_cl_agent_mcp.clas.testclasses.abap[15, 7]" and "src/01/z2ui5_cl_agent_session.clas.testclasses.abap[17, 7] - Implement method \"prune_chain\" / \"touch\" from interface \"z2ui5_if_ui5_draft_store\"" - 7 issues'
  - 'abap-cloud-gui origin/main 87199b0: green on its pin 1.150.0 (256 files); with branch main 25 issues - Method definition "z2ui5_if_client~window_get_row" not found (3), Method "window_get_row" not found (2), method parameter "TOTAL"/"EVENT" must be supplied (3 each), Method importing parameter "T_SORT" does not exist, in z2ui5_cl_cgui_alv/report/select/view/sample_10'
  - 'DEV: headless-frontend 7d60587 (protocol 3) renames green; abap-agent-runtime 6764687 renames green with RENAME_DEPS_FROM pointing at headless-frontend DEV (69 files) and red with the default clone of headless-frontend main; abap-cloud-gui 89dac17 moves to 1.151.0'
  - 'abap2UI5 changelog 1.151.0: z2ui5_if_ui5_draft_store has two new methods prune_chain( ) and touch( ) - BREAKING for an own store; cs_global_target-router removed (protocol 3); no tag 1.151.0 yet (ls-remote shows 1.150.0)'
---

# Addon rename red on main: three addons lag abap2UI5 1.151.0

## What fails

`npm run rename` lints the addon together with a fresh clone of its abap2UI5
dependencies. Since abap2UI5 main moved to 1.151.0, this fails in three
addons:

- **headless-frontend main** still reads `z2ui5_if_ui5_types=>cs_global_target-router`,
  which protocol 3 removed. Its draft store test double lacks the two new
  methods `prune_chain` and `touch`. (It also hits addon-rename-core-src03.)
- **abap-agent-runtime main** has the same draft store doubles in
  `z2ui5_cl_agent_mcp` and `z2ui5_cl_agent_session`. On top of that, it
  inherits headless-frontend's errors: its `abaplint.jsonc` names
  headless-frontend without a `branch`, so `rename.mjs` clones that repo's
  default branch HEAD - not the commit `.github/deps.json` pins for
  release.yaml.
- **abap-cloud-gui main** is green only because it lints against 1.150.0.
  A renamed abap-cloud-gui from main cannot be installed next to the renamed
  abap2UI5 that `build-rename` builds from main: there are 25 errors around
  `window_get_row`, the `TOTAL`/`EVENT` parameters and `T_SORT`.

DEV of all three repos passes. The fixes exist; they are not released.

## Proposed fix

1. Release DEV in headless-frontend first, then abap-agent-runtime and
   abap-cloud-gui. For abap-cloud-gui, move the pin to the tag 1.151.0 once it
   is cut.
2. abap-agent-runtime: give the headless-frontend entry in `abaplint.jsonc` a
   `branch` (a tag, the same one `.github/deps.json` pins). `rename.mjs`
   clones with `--branch`. Then the rename gate no longer depends on the order
   in which another repository releases.
3. Consider a release-order rule in abap2UI5's RELEASING.md: a core release
   with a BREAKING change to an interface addons implement
   (`z2ui5_if_ui5_draft_store`) or a constant they read is followed by the
   addon releases before `build-rename` is advertised for that version.

## Reproduce

    git -C abap-agent-runtime archive origin/main | tar -x -C /tmp/aar && cd /tmp/aar
    npm ci && npm run rename
