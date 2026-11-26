---
target: abap2ui5
title: 'Namespace rename: the addons that do not have it yet, and why'
summary: thirteen addons have abap2UI5's namespace rename (rename.mjs, build-rename); eight do not - BSP applications, function groups, authorization objects, Gateway projects and CDS views abaplint cannot rename, class names over 25 characters, a dependency without a rename - and abap2UI5-ext has none, which a renamed installation needs for every app on the legacy API; rename.mjs fits it unchanged once its pin is 1.151.0 or later
priority: medium
state: open
first_seen: 2026-11-03
upstream: abap2UI5-addons
evidence:
  - 'abap2UI5-addons, 2026-11-03 - namespace rename rolled out to admin-cockpit, http-connector, layout-management, lock-manager, open-source-libs, popups, range-filter, se16n, table-content-loader and table-maintenance (branch claude/addon-repo-namespaces-dnjqev): npm run rename green in all ten with the worst-case name of 10 characters (http-connector: 6), ZMYUI5 and /CA2UI5/ built for popups'
  - 'abap2UI5-addons, 2026-11-03 - headless-frontend (z2ui5_cl_frontend_sim and the example apps), abap-agent-runtime (z2ui5_cl_agent_llm_claude; names of at most 9 characters for its ICF node) and abap-cloud-gui (fifteen classes and interfaces) shortened to 25 characters and given the rename; abap2UI5''s developer tools generate the new simulator name'
  - 'the object types abaplint 2.120.92 renames: CLAS, INTF, TABL, DTEL, DOMA, TTYP, PROG, MSAG, SICF (Renamer.factory) - anything else throws "Renaming of <type> not yet supported"'
  - 'audit 2026-11-26, origin/main of every repository, abaplint 2.120.113-120: npm run rename green in layout-management, popups, table-maintenance, admin-cockpit, http-connector, lock-manager, range-filter, se16n, table-content-loader (popups and admin-cockpit also with --name /CA2UI5/); headless-frontend, abap-agent-runtime and abap-cloud-gui see addon-rename-behind-core-1-151'
  - 'audit 2026-11-26 - the shared rename.mjs copied into custom-controls: first IF_HTTP_EXTENSION unknown (its config takes abap2UI5 /src/**, see addon-rename-core-src03), with src/0[0-2] then "a new name is too long for its object type: CLAS Z2UI5_CL_CCI_SIGNATURE_PAD"; over 25 characters are z2ui5_cl_cci_network_status (27), _rich_text_editor (29), _signature_pad (26), _barcode_scanner (28)'
  - 'audit 2026-11-26 - the same in custom-controls-customer: with src/0[0-2] "zxxxxxxxxx_cl_ccc.clas.abap:25: the literal ''z2ui5_ccc'' names Z2UI5_CCC" - c_ns / c_ns_uri name the BSP''s resource root, and the BSP Z2UI5_CCC (WAPA) and its SICF nodes stay unrenamed'
  - 'audit 2026-11-26 - no addon on main references an object of abap2UI5-ext any more: z2ui5_cl_util appears only in a comment of each *_context class (layout-management, popups, table-maintenance, lock-manager, range-filter, table-content-loader); the shared rename.mjs copied into abap2UI5-ext renames it green against abap2UI5 main (90 files, z2ui5_t_91 -> 15 characters, within the 16 of a transparent table) and fails against its pin 1.149.0 and against 1.150.0 (11 issues, Z2UI5_IF_EXIT unknown in src/01/04/z2ui5_cl_ui5_user_exit - that release keeps the interface in its src/99)'
---

# Namespace rename: the addons that do not have it yet, and why

abap2UI5's namespace rename (`build-rename`, `.github/abaplint/rename.jsonc`)
reached the addons on 2026-11-03: `.github/scripts/rename.mjs` in each, the
same file everywhere, clones the abap2UI5 repositories an addon depends on,
renames them together with its `src/` and keeps only `src/` - so a renamed
addon runs on an abap2UI5 renamed with the same name. `npm run rename` checks
it in CI with the longest name the addon allows; `build-rename` pushes
`rename_<name>`.

Thirteen addons have it - headless-frontend, abap-agent-runtime and
abap-cloud-gui after their names were shortened to 25 characters the same day
(breaking, see their changelogs). On 2026-11-26 it is green on main in ten of
them; the other three lag the core release 1.151.0
(`addon-rename-behind-core-1-151`). These do not have it, each for a reason
that needs a decision or work beyond a mechanical rollout:

| Addon | What stops it |
|---|---|
| custom-controls | a BSP application (WAPA) - abaplint cannot rename it; its resource path `z2ui5_cci` is reserved in abap2UI5's frontend, so a renamed path needs a core change too; four class names over 25 characters (`z2ui5_cl_cci_rich_text_editor` 29, `_barcode_scanner` 28, `_network_status` 27, `_signature_pad` 26) - the trial stops at `Z2UI5_CL_CCI_SIGNATURE_PAD` |
| custom-controls-customer | the BSP `Z2UI5_CCC` and its SICF nodes; `z2ui5_cl_ccc` names its resource root in two literals (`c_ns`, `c_ns_uri`), which the rename's literal check reports; reserved path `z2ui5_ccc` as above. It is a template a customer copies into their own namespace - a rename may not be wanted at all |
| embed-excel | a BSP application (WAPA) |
| rfc-connector | a function group and SUSH objects (not renameable), and `z2ui5_cl_rfc_connector_handler` has 30 characters |
| config-management | authorization object `Z2UI5_CONF` and field `Z2UI5_CTYP` - not renameable, and at most 10 characters, so no longer prefix fits at all |
| launchpad-kpi | the Gateway project and service (IWPR, IWSV, IWMO, IWOM, IWSG) - not renameable; the service name is in the OData URL |
| rap-ext | two CDS views (DDLS) - not renameable |
| sql-console | builds on custom-controls (`z2ui5_cl_cci_spreadsheet`, `z2ui5_cl_cci_json_filter`), which has no rename; four class names over 25 characters (`z2ui5_cl_sql_native_console_st` 30) |

Both custom-controls repositories take abap2UI5's whole `/src/**` in their
lint config; with the shared script that first fails on the core's `src/03`
(`IF_HTTP_EXTENSION` unknown) - `addon-rename-core-src03`, to be fixed in the
script rather than per repository.

**abap2UI5-ext.** Until 2026-11 layout-management referenced classes that
moved from abap2UI5 to abap2UI5-ext (`z2ui5_cl_util`, ...); on 2026-11-26 no
addon does - each carries its own `*_context` class, and `z2ui5_cl_util` is
left only in a comment. The ext rename is still needed, for a different
reason: an app on the legacy API (`z2ui5_cl_xml_view`, the popups
`z2ui5_cl_pop_*`, `z2ui5_cl_util`) that moves to a renamed abap2UI5 needs
those classes renamed with the same name, or they reference `z2ui5_if_client`
and friends of an installation that is not there. abap2UI5-ext has no rename.
The shared `rename.mjs` fits it unchanged (all its objects are CLAS, INTF and
one TABL, the longest name 25 characters, `z2ui5_t_91` 15 after the rename) -
**against abap2UI5 main**. Against its pin 1.149.0, and against 1.150.0, the
cloned core fails to lint (`Z2UI5_IF_EXIT unknown`): those releases keep the
interface in `src/99`, which the pin leaves out. Because `build-rename` in
abap2UI5 renames main, the ext rename has to pair with main too - move the pin
to 1.151.0 when it is tagged (or `main`), then add `rename.mjs`,
`"rename": "node .github/scripts/rename.mjs"` and the two workflows.

**What a rollout to one of them needs.**

- Not-renameable object types: a text replacement in the workflow, the way
  abap2UI5 builds its renamed BSP (`tools/bsp_rename`), or an upstream
  renamer in abaplint for the type (WAPA, FUGR, DDLS, AUTH).
- Names over 25 characters: shortened, with a README note which old objects to
  delete after the pull - or a lower `config.renameMaxLength` in package.json
  (rename.mjs reads it), which limits the name the whole installation can be
  renamed to.
- A dependency without a rename: that one first.
- The abap2UI5 dependency as `src/0[0-2]` (until `addon-rename-core-src03` is
  fixed in the script).

**Reproduce.** Copy any addon's `.github/scripts/rename.mjs` into the
repository, `npm ci`, `node .github/scripts/rename.mjs` - it prints the first
failure.
