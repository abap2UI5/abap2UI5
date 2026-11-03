---
target: abap2ui5
title: 'Namespace rename: the addons that do not have it yet, and why'
summary: 'ten addons got abap2UI5''s namespace rename on 2026-11-03 (.github/scripts/rename.mjs, build-rename, check-rename - references to abap2UI5 and to the addons they build on renamed along); eleven did not - BSP applications, function groups, authorization objects, Gateway projects and CDS views abaplint cannot rename, public names longer than 25 characters, a dependency on an addon without a rename - and abap2UI5-ext, which layout-management and the four addons on it need renamed, has no rename of its own'
priority: medium
state: open
first_seen: 2026-11-03
upstream: abap2UI5-addons
evidence:
  - 'abap2UI5-addons, 2026-11-03 - namespace rename rolled out to admin-cockpit, http-connector, layout-management, lock-manager, open-source-libs, popups, range-filter, se16n, table-content-loader and table-maintenance (branch claude/addon-repo-namespaces-dnjqev): npm run rename green in all ten with the worst-case name of 10 characters (http-connector: 6), ZMYUI5 and /CA2UI5/ built for popups'
  - 'the object types abaplint 2.120.92 renames: CLAS, INTF, TABL, DTEL, DOMA, TTYP, PROG, MSAG, SICF (Renamer.factory) - anything else throws "Renaming of <type> not yet supported"'
---

# Namespace rename: the addons that do not have it yet, and why

abap2UI5's namespace rename (`build-rename`, `.github/abaplint/rename.jsonc`)
reached the addons on 2026-11-03: `.github/scripts/rename.mjs` in each, the
same file everywhere, clones the abap2UI5 repositories an addon depends on,
renames them together with its `src/` and keeps only `src/` - so a renamed
addon runs on an abap2UI5 renamed with the same name. `npm run rename` checks
it in CI with the longest name the addon allows; `build-rename` pushes
`rename_<name>`.

Ten addons have it. These do not, each for a reason that needs a decision or
work beyond a mechanical rollout:

| Addon | What stops it |
|---|---|
| custom-controls, custom-controls-customer, office-addin | a BSP application (WAPA) - abaplint cannot rename it; custom-controls' resource path `z2ui5_cci` is reserved in abap2UI5's frontend, so a renamed path needs a core change too |
| rfc-connector | a function group and SUSH objects (not renameable), and `z2ui5_cl_rfc_connector_handler` has 30 characters |
| config-management | authorization object `Z2UI5_CONF` and field `Z2UI5_CTYP` - not renameable, and at most 10 characters, so no longer prefix fits at all |
| launchpad-kpi | the Gateway project and service (IWPR, IWSV, IWMO, IWOM, IWSG) - not renameable; the service name is in the OData URL |
| rap-ext | two CDS views (DDLS) - not renameable |
| sql-console | builds on custom-controls (`z2ui5_cl_cci_spreadsheet`, `z2ui5_cl_cci_json_filter`), which has no rename; four class names over 25 characters (`z2ui5_cl_sql_native_console_st` 30) |
| headless-frontend | four class names over 25 characters; `z2ui5_cl_frontend_simulator` (27) is named by the test classes abap2UI5's developer tools generate (`app/webapp/devtools/Journey.js`) - shortening it breaks every generated test and needs a core change |
| abap-agent-runtime | builds on headless-frontend; `z2ui5_cl_agent_llm_anthropic` has 28 characters; the ICF node `z2ui5_agent` (11) allows names of at most 9 characters |
| abap-cloud-gui | fifteen class and interface names over 25 characters (`z2ui5_cl_cgui_gui_alv_toolbar` 29) - a released 1.x API under semantic versioning, named in the code the report converter generates; shortening them is a major release |

**abap2UI5-ext.** layout-management references the classes that moved from
abap2UI5 to abap2UI5-ext (`z2ui5_cl_util`, ...), and popups, range-filter,
se16n and table-maintenance build on layout-management. The addons' rename
renames those references - so on an abap2UI5 release that no longer ships the
classes, a renamed installation needs a renamed abap2UI5-ext as well, and
abap2UI5-ext has no `build-rename`. The same `rename.mjs` and the two
workflows fit it unchanged (all its objects are classes).

**What a rollout to one of them needs.**

- Not-renameable object types: a text replacement in the workflow, the way
  abap2UI5 builds its renamed BSP (`tools/bsp_rename`), or an upstream
  renamer in abaplint for the type (WAPA, FUGR, DDLS, AUTH).
- Names over 25 characters: shortened, with a README note which old objects to
  delete after the pull - or a lower `config.renameMaxLength` in package.json
  (rename.mjs reads it), which limits the name the whole installation can be
  renamed to.
- A dependency without a rename: that one first.
