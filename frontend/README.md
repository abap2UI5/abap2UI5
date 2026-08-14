# frontend/

The parts of the [abap2UI5/frontend](https://github.com/abap2UI5/frontend)
delivery branches that are **not** generated from `app/webapp/` — data, not
code. What turns the webapp into a branch lives in [`tools/`](../tools).

| | |
| --- | --- |
| `abap/cloud/`, `abap/standard/` | the ICF/BSP ABAP artefacts each branch ships — the HTTP handler, its SICF/service definitions, the packages |
| `abap/cloud/abaplint.jsonc` | lints the above in place (`npm run frontend:lint`), and is copied into each branch with its glob turned to `/src/` |
| `common/` | README, LICENSE, SECURITY, CODE_OF_CONDUCT, .gitignore — the files every generated branch inherits |

The Fiori project the cloud branches ship is **not** here: those branches carry
`app/` from this repository directly, the same project this repository is
developed with. A second copy is what let the two drift apart before.
