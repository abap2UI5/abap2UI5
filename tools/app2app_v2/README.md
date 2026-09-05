# app2app_v2

Generates the **legacy-free (UI5 2.0) variant** of this frontend, taking the
classic webapp coding over **1:1** and adapting only the bootstrap layer so it
runs on the legacy-free OpenUI5 build.

```
app/webapp ──▶ patchIndexHtml + patchManifest (patch-v2.mjs) ──▶ tools/app2bsp (preload.js + run.js) ──▶ [bsp_rename, only with --name] ──▶ src/
```

The output uses the same package layout as the `standard` branch:

```
src/package.devc.xml   root package
src/01/                ICF handler (SICF node + Z2UI5_CL_LP_HANDLER, from abap/standard)
src/02/                the BSP page
```

The result is built into the git-ignored `tools/out/standard_v2` and
published as the
[`standard_v2`](https://github.com/abap2UI5/frontend/tree/standard_v2)
branch by the `frontend_deploy` workflow, which runs the same build at
deploy time. The `cloud_v2` branch applies the same bootstrap patch
(`patch-v2.mjs`) directly to the webapp instead of building a BSP.

## Run

```bash
node tools/app2app_v2/build-legacy-free.mjs . app/webapp tools/out/_v2
npm run frontend:build         # all four; one on its own: node tools/build-branches.mjs standard_v2
```

## The only adaptations (everything else is 1:1)

| File | Change | Why |
| --- | --- | --- |
| `index.html` | load `1.142.0-legacy-free` SDK (CDN); 2.x config attributes `resource-roots` / `on-init` / `compat-version` / `frame-options`; `preconnect`; `libs=sap.m` | bootstrap the legacy-free build |
| `manifest.json` | `minUI5Version 1.136.0`, `_version 2.0.0` | legacy-free starts at 1.136 |

> The webapp ships **no routing section** anymore (removed upstream - the
> shell controller starts the app directly), so nothing routing-related
> needs patching; `patchManifest` only stamps `_version` and
> `minUI5Version`. (It used to carry a transitional migration of the
> classic routing options for webapp states that predate the removal -
> that safeguard has been deleted.)

Deployment identity stays `Z2UI5` — same name as the classic frontend, so the
legacy-free variant is a drop-in replacement (install either `standard` or
`standard_v2`, not both). Pass `--name Z2UI5_V2` to rename for a parallel
install; with a rename the backend handler is still shared (`/sap/bc/z2ui5`)
by default. `--own-backend` gives the renamed BSP its own one instead: the
ICF node stays `/sap/bc/<name>` and `src/01` is renamed with it, so the node
and the `<NAME>_CL_LP_HANDLER` class the manifest points at are in the
delivered tree. (Until 2026-09 only the manifest was repointed and `src/01`
kept shipping the `z2ui5` node, so the flag produced a BSP whose backend did
not exist.)

> The classic frontend JS is already forward-compatible (no jQuery.sap, no
> sync APIs, guarded `getCore()` fallbacks) — so no code changes are needed,
> only the bootstrap.
