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
| `build-branches.mjs` | drives the above into one delivery branch |
| `branch-stamp.mjs` | the provenance of a branch (`VERSION`, README banner), written at deploy time |
| `check-pages.mjs` | the BSP page invariants, checked on the built artefact |
| `verify-branches.mjs` | compares the committed trees against what abap2UI5/frontend publishes today |
| `check-v2-sdk.mjs` | the monthly guard on the pinned legacy-free SDK |

What these consume besides the webapp — the ABAP artefacts of the delivery
branches and the files every branch inherits — lives in
[`frontend/`](../frontend). Tools here, data there.

## Where a build lands

The branch name decides, not a flag:

| | |
| --- | --- |
| `cloud`, `cloud_v2`, `standard`, `standard_v2` | [`build/<branch>/`](../build) — **committed**, this is what gets pushed |
| anything else (`standard_<name>`, a trial run) | `tools/out/<branch>/` — git-ignored scratch |

The four published trees live in the repository because a delivery branch is an
installation source: committing it puts what is delivered into the pull request
that changes it, and lets `frontend_deploy` ship the reviewed tree instead of a
rebuild of it. An ad-hoc build cannot touch that tree, because its name sends it
to the scratch folder. Details in [`build/README.md`](../build/README.md).

## Running it

```bash
npm run app2abap                # regenerate src/01/03 from app/webapp
npm run frontend:build          # all four delivery branches -> build/
npm run frontend:standard       # just one
npm run check:frontend          # the CI gate: rebuild and fail on any diff in build/
npm run frontend:lint           # abaplint over frontend/abap/cloud (the standard handler is linted in build/standard)
node tools/check-pages.mjs      # BSP invariants on what was built
npm run frontend:verify         # diff the committed trees against the published branches
```

A change under `app/`, `frontend/` or `tools/` is committed **together
with the rebuilt `build/`** — same rule as `src/01/03/`. `tools/out/` is
generated and git-ignored.

## Why the delivery branches may not drift

They are an **installation source**: abapGit repositories out there point at
`standard`, `cloud` and the renamed variants. A change to what a branch carries
reaches every one of them on the next pull.

`frontend_check.yaml` builds every variant on every pull request that touches
`app/`, `frontend/`, `tools/`, `build/` or the npm dependencies, lints the generated ABAP and checks the
BSP page invariants — a page line over 255 characters, a page name
`CREATE_NEW_PAGE` rejects, a content file missing from the page directory, a
`.js` page that stops being valid JavaScript once padded. Each of those is a
failure that reached a real system, or came within a step of it.

`verify-branches.mjs` compares the committed tree of a branch against the
published one byte for byte. It is the acceptance test for anything that
changes *how* the branches are built rather than what is in them.

## Deployment

`frontend_deploy.yaml` pushes the delivery branches into abap2UI5/frontend: all
four on every push to `main` that changes `build/` or the `VERSION` stamp
inputs (the framework version constant, `branch-stamp.mjs`), a single named one
(including a renamed `standard_<name>`, which is built on the spot) on
dispatch, and everything again on a monthly safety-net cron.

For the four it pushes the committed tree — the deploy stamps the provenance
and pushes, it does not build. A run whose content matches what the branch
already carries pushes nothing: the comparison stamps the candidate with the
commit the published `VERSION` names, so a run that would only move the
provenance forward is not a commit. The commit that *is* written carries the
subject of the `main` commit behind it, so the history over there reads like
the history here.

The delivery repository builds nothing itself any more — its `main` carries
only its own docs, and each of its branches is a tree written by that
workflow.
