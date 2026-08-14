# tools/

Everything that **generates** an artefact out of `app/webapp/`. One folder, so
the answer to "where does this file come from" is always the same place.

Not to be confused with `.github/scripts/`, which is the other kind of script
entirely: those are CI gates: they read the repository and answer yes or no.
Nothing in `.github/scripts/` produces a deliverable, and nothing here decides
whether a pull request may merge.

| | |
| --- | --- |
| `app2abap/` | `app/webapp/*` → the embedded ABAP string constants in `src/01/03/` (`npm run app2abap`) |
| `app2bsp/` | `app/webapp/*` → BSP pages, plus the minified UI5 component preload bundle (`preload.js`) |
| `app2app_v2/` | the legacy-free (UI5 2.x) bootstrap patch, and the branch built from it |
| `bsp_rename/` | rewrites the deployment identity (BSP, SICF, handler) for a parallel install |
| `build-branches.mjs` | drives the above into one delivery branch, in `tools/out/<branch>/` |
| `check-pages.mjs` | the BSP page invariants, checked on the built artefact |
| `verify-branches.mjs` | builds and compares against what abap2UI5/frontend publishes today |
| `check-v2-sdk.mjs` | the monthly guard on the pinned legacy-free SDK |

What these consume besides the webapp — the ABAP artefacts of the delivery
branches and the files every branch inherits — lives in
[`frontend/`](../frontend). Tools here, data there.

## Running it

```bash
npm run app2abap                # regenerate src/01/03 from app/webapp
npm run frontend:build          # all four delivery branches -> tools/out/
npm run frontend:standard       # just one
npm run frontend:lint           # abaplint over frontend/abap
node tools/check-pages.mjs      # BSP invariants on what was built
npm run frontend:verify         # diff against the published branches
```

`tools/out/` is generated and git-ignored.

## Why the delivery branches may not drift

They are an **installation source**: abapGit repositories out there point at
`standard`, `cloud` and the renamed variants. A change to what a branch carries
reaches every one of them on the next pull.

`frontend_check.yaml` builds every variant on every pull request that touches
`app/webapp/`, `frontend/` or `tools/`, lints the generated ABAP and checks the
BSP page invariants — a page line over 255 characters, a page name
`CREATE_NEW_PAGE` rejects, a content file missing from the page directory, a
`.js` page that stops being valid JavaScript once padded. Each of those is a
failure that reached a real system, or came within a step of it.

`verify-branches.mjs` compares a freshly built branch against the published one
byte for byte. It is the acceptance test for anything that changes *how* the
branches are built rather than what is in them.

## Deployment

`frontend_deploy.yaml` builds and pushes the delivery branches into
abap2UI5/frontend: all four on every push to `main` that touches `app/`,
`frontend/` or `tools/`, a single named one (including a renamed
`standard_<name>`) on dispatch, and everything again on a monthly safety-net
cron. A build whose tree matches the published branch pushes nothing.

The delivery repository builds nothing itself any more — its `main` carries
only its own docs, and each of its branches is a tree written by that
workflow.
