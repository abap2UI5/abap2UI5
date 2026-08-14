# frontend/

Everything the [abap2UI5/frontend](https://github.com/abap2UI5/frontend) delivery
repository is built from. The UI5 webapp itself is **not** here — it lives in
`app/webapp/` at the repository root, the single source it has always been.
This folder holds what turns that webapp into the branches a user pulls with
abapGit.

```
app/webapp/  ──▶  frontend/build-branches.mjs  ──▶  abap2UI5/frontend
                                                      cloud, cloud_v2
                                                      standard, standard_v2
                                                      standard_<name>, standard_v2_<name>
```

| | |
| --- | --- |
| `build-branches.mjs` | builds one output branch into `frontend/out/<branch>/` |
| `app2bsp/` | webapp → BSP pages, and the UI5 component preload bundle (`preload.js`) |
| `app2app_v2/` | the legacy-free (UI5 2.x) bootstrap patch and the branch built from it |
| `bsp_rename/` | renames the deployment identity for a parallel install |
| `abap/` | the ICF/BSP ABAP artefacts each branch ships (`cloud`, `standard`) |
| `app/` | the Fiori dev project files the cloud branches ship next to the webapp |
| `common/` | README, LICENSE and friends that every generated branch inherits |
| `abaplint.jsonc` | lints `abap/cloud`; copied into each branch with the path turned to `/src/` |
| `check-pages.mjs` | the BSP page invariants, checked on the built artefact |
| `verify-branches.mjs` | builds and compares against what is published today |
| `scripts/` | the monthly guard on the pinned legacy-free SDK |

## Running it

```bash
npm run frontend:build          # all four branches -> frontend/out/
npm run frontend:standard       # just one
npm run frontend:lint           # abaplint over frontend/abap/cloud
node frontend/check-pages.mjs   # BSP invariants on what was built
npm run frontend:verify         # diff against the published branches
```

`frontend/out/` is generated and git-ignored.

## Why the branches may not drift

The generated branches are an **installation source**: abapGit repositories out
there point at `standard`, `cloud` and the renamed variants. A change to what a
branch carries reaches every one of them on the next pull. Two things follow.

`frontend_check.yaml` builds every variant on every pull request that touches
`app/webapp/` or `frontend/`, lints the generated ABAP and checks the BSP page
invariants — a page line over 255 characters, a page name `CREATE_NEW_PAGE`
rejects, a content file missing from the page directory, a `.js` page that
stops being valid JavaScript once padded. Each of those is a failure that
reached a real system, or came within a step of it.

`verify-branches.mjs` compares a freshly built branch against the published one
byte for byte. It is the acceptance test for anything that changes *how* the
branches are built rather than what is in them.

## Deployment

`frontend_deploy.yaml` pushes a built branch into the delivery repository. It is
dispatch-only for now — see the comment at the top of the workflow.
