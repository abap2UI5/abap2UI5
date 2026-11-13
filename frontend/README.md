# frontend/

The parts of the [abap2UI5/frontend](https://github.com/abap2UI5/frontend)
delivery branches that are **not** generated from `app/webapp/` — data, not
code. What turns the webapp into a branch lives in [`tools/`](../tools).

| | |
| --- | --- |
| `abap/cloud/`, `abap/standard/` | the ICF/BSP ABAP artefacts each branch ships — the HTTP handler, its SICF/service definitions, the packages |
| `abap/cloud/abaplint.jsonc` | lints the above in place (`npm run frontend:lint`), and is copied into each branch with its glob turned to `/src/` |
| `common/` | README, LICENSE, SECURITY, CODE_OF_CONDUCT, .gitignore — the files every generated branch inherits; `README_new.md` is the README of the `_new` branches |
| `page/` | the minimal UI5 app of the page the HTTP service answers a GET with: `webapp/Component.js`, `manifest.json` and `view/Main.view.xml`, whose one element is a `z2ui5.embed.Container`. It decides nothing - the handler names the class to start. Not part of a branch - `tools/app2abap/trans2abap.js` embeds it into `src/01/03`, next to the control from `node_modules` |
| `embed/` | the app of `standard_new` and `cloud_new` — one view with one `z2ui5.embed.Container`, which loads the abap2UI5 frontend from the backend; its rules are `embed/AGENTS.md` |

The Fiori project `cloud` and `cloud_v2` ship is **not** here: those branches carry
`app/` from this repository directly, the same project this repository is
developed with. A second copy is what let the two drift apart before.
