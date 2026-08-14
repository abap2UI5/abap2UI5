# build/

The four delivery branches of [abap2UI5/frontend](https://github.com/abap2UI5/frontend),
as trees. **Generated — never edit anything below this file.**

| | |
| --- | --- |
| `cloud/` | the webapp as a Fiori source project + the ICF ABAP artefacts |
| `cloud_v2/` | the same, bootstrap patched to legacy-free (UI5 2.x) |
| `standard/` | BSP `Z2UI5` (pages + the minified component preload) + ICF handler |
| `standard_v2/` | the same BSP, legacy-free |

Each folder is the *whole* branch: `.abapgit.xml`, `README.md`, `abaplint.jsonc`
and `src/` exactly as an abapGit repository out there pulls them.
`frontend_deploy.yaml` pushes the folder as it stands — it does not build.

## Why they are committed

A delivery branch is an **installation source**: abapGit repositories point at
`cloud`, `standard` and the renamed variants, so what a branch carries reaches
every one of them on the next pull. Committing the tree makes that content
reviewable *before* it is delivered — the diff of a pull request shows the
webapp change and the four trees it produces, side by side — and it removes the
build from the deploy: the tree that reaches a system is the tree the pull
request approved, not a rebuild of it afterwards.

This is the same contract `src/01/03/` has against `app/webapp/`: generated,
committed, and gated. `frontend_check.yaml` rebuilds all four on every pull
request and fails on any difference.

## When they change

Whenever `app/webapp/`, `frontend/` or `tools/` changes:

```bash
npm run frontend:build   # rebuild all four in place
git add build            # and commit them with the change that caused them
```

`npm run check:frontend` is the same rebuild plus the diff check CI runs.

## What is *not* here

The renamed BSP variants (`standard_<name>`, see
[`tools/bsp_rename`](../tools/bsp_rename)) — they are unbounded in number and
built on demand by a `frontend_deploy` dispatch, into the git-ignored
`tools/out/`.

And `VERSION`: it names the commit a branch was built from, which does not
exist yet while that very commit is being made. `tools/branch-stamp.mjs` writes
it — and the provenance sentence of the branch `README.md` — at deploy time.
