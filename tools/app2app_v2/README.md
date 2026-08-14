# app2app_v2

Generates the **legacy-free (UI5 2.0) variant** of this frontend, taking the
classic webapp coding over **1:1** and adapting only the bootstrap layer so it
runs on the legacy-free OpenUI5 build.

```
app/webapp ──▶ patchIndexHtml + patchManifest (patch-v2.mjs) ──▶ tools/app2bsp (preload.js + run.js) ──▶ [bsp_rename, nur mit --name] ──▶ src/
```

The output uses the same package layout as the `standard` branch:

```
src/package.devc.xml   root package
src/01/                ICF handler (SICF node + Z2UI5_CL_LP_HANDLER, from abap/standard)
src/02/                the BSP page
```

The result is published as the [`standard_v2`](https://github.com/abap2UI5/frontend/tree/standard_v2)
branch by the `build_standard_v2` workflow (shared base `build_branch.yaml`), which builds the output branches
(`cloud`, `cloud_v2`, `standard`, `standard_v2`) from `main`. The `cloud_v2`
branch applies the same bootstrap patch (`patch-v2.mjs`) directly to the
webapp instead of building a BSP.

## Run

```bash
node tools/app2app_v2/build-legacy-free.mjs . app/webapp tools/out/_v2
npm run frontend:build         # alle vier; einzeln: node tools/build-branches.mjs standard_v2
```

## The only adaptations (everything else is 1:1)

| File | Change | Why |
| --- | --- | --- |
| `index.html` | load `1.142.0-legacy-free` SDK (CDN); 2.x config attributes `resource-roots` / `on-init` / `compat-version` / `frame-options`; `preconnect`; `libs=sap.m` | bootstrap the legacy-free build |
| `manifest.json` | `minUI5Version 1.136.0`, `_version 2.0.0` | legacy-free starts at 1.136 |

> The webapp ships **no routing section** anymore (removed upstream in
> abap2UI5/abap2UI5 - the shell controller starts the app directly), so
> nothing routing-related needs patching. `patchManifest` still carries a
> transitional migration of the classic routing options
> (`viewPath`/`viewName`/`viewId` → `path`/`name`/`id` + `type: "View"`) as a
> safeguard for building from a webapp state that predates the removal -
> schema v2 rejects the v1-style options (blank page). It is a no-op for
> current deploys and can be deleted once `main`'s webapp is synced.

Deployment identity stays `Z2UI5` — same name as the classic frontend, so the
legacy-free variant is a drop-in replacement (install either `standard` or
`standard_v2`, not both). Pass `--name Z2UI5_V2` to rename for a parallel
install; with a rename the backend handler is still shared (`/sap/bc/z2ui5`)
by default, `--own-backend` keeps an isolated one.

> The classic frontend JS is already forward-compatible (no jQuery.sap, no
> sync APIs, guarded `getCore()` fallbacks) — so no code changes are needed,
> only the bootstrap.
