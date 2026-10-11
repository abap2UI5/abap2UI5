# AGENTS.md — frontend/embed

The app of the delivery branches `standard_new` and `cloud_new` of
[abap2UI5/frontend](https://github.com/abap2UI5/frontend), built on
[`@abap2ui5/embed-control`](https://www.npmjs.com/package/@abap2ui5/embed-control):
a UI5 app with one view and one `z2ui5.embed.Container` in it, filling the
page. The control loads the abap2UI5 frontend from the backend
(`?z2ui5-bundle`), so this app carries none of it. It came from the
repository abap2UI5/frontend-new.

`tools/build-branches.mjs` turns it into the branches: `standard_new` is its
`webapp/` with the control under `thirdparty/z2ui5/embed/` as the BSP `Z2UI5`
next to `frontend/abap/standard`, `cloud_new` is this folder as `app/` next to
`frontend/abap/cloud`, the endpoint turned to the HTTP service path.
Both handlers call `z2ui5_cl_ui5_http_handler`.

**A system switches between `standard` and `standard_new` (or `cloud` and
`cloud_new`) by pulling the other branch - nothing else may change for a
launchpad or an external caller.** `tools/check-identity.mjs` holds the
`_new` trees to the old ones (`npm run check:frontend`): every ABAP object and
its metadata, the BSP's attributes, the ICF nodes, the manifest's id, data
source, inbound, services, sibling roots and `sap.cloud`, the page's
component settings. What `start.js` hands over reaches the backend as the
classic frontend sent it (`client->get( )-t_comp_params`).

| Path | |
|---|---|
| `webapp/` | `Component.js` (the component `z2ui5`), `model/start.js` (which class starts, with which parameters), `view/Main.view.xml` (the one control), `controller/Main.controller.js` (the hash handed to the app, a failed start shown) - all but `Component.js` and `manifest.json` as `abap2ui5/frontend/` |
| `package.json`, `package-lock.json` | the project `cloud_new` ships; the control's version is pinned here AND in the root `package.json` (the BSP of `standard_new` is built from the root's `node_modules`) - the build fails when they differ |
| `ui5.yaml`, `ui5-local.yaml` | `npm start` to an SAP system, `npm run start-local` to abap2UI5 in Node on `localhost:3000` |
| `test/` | `model/start.js` in Node (`npm run test:embed`), not shipped |

## Rules

- **No copy of the abap2UI5 frontend, ever.** The control loads it from the
  system. A limitation of the frontend is fixed in `app/webapp`, one of the
  control in abap2UI5/embed-control - not worked around here.
- **Keep the app thin.** It decides which class starts and with which
  parameters (`model/start.js`) and shows a failed start; everything else
  comes from the backend.
- **Never take the endpoint from the URL or the launchpad.** What is loaded
  from it is code. Only `app_start` and the app's parameters come from
  there. The endpoint is `sap.app/dataSources/http/uri` of the manifest,
  where the classic frontend has it, and the cloud build turns it to the HTTP
  service path with the same patch as `cloud`'s.
- **The component is `z2ui5`**, as on `standard` and `cloud` - existing
  launchpad target mappings name it. Exactly two files of it are below
  `z2ui5/`, `Component.js` and `manifest.json`; everything else is
  `abap2ui5/frontend/` (the same folder, `sap.ui5/resourceRoots`), and nothing
  may be added below `z2ui5/` - a module of the same name in the bundle
  would never load.
- **UI5 1.71 is the floor** - no module, control, property or enum newer
  than 1.71.
- **`thirdparty/`, not `resources/`** for the control - a BSP answers every
  `<app>/resources/` path from the system's UI5.
- **Every name is the old branches'** - the abapGit repository, the
  packages and their texts, `Z2UI5_CL_LP_HANDLER`, the BSP `Z2UI5`, the ICF
  nodes. These branches replace those installations: never rename one.
- **The page is the control and nothing else, so the hash is the app's**
  (the control's `ownsHash`). Nothing else of this app may route by the
  hash or write it.
