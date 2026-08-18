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
`frontend_deploy.yaml` ships the folder as it stands — it does not build: it
stamps the provenance and commits all four as `result/<branch>` folders onto
abap2UI5/frontend's `main`, from where that repository's `deliver` workflow
fans each folder out into its branch (one commit on top of `main`, so every
branch is always exactly one commit ahead of it).

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

## Reading a diff of this folder

Two things make a change here look far bigger than it is. Both are intended;
this section exists so nobody "cleans up" either one.

**A `_v2` tree is its base plus three files.** `cloud_v2` differs from `cloud`
only in `README.md`, `app/webapp/index.html` and `app/webapp/manifest.json`;
`standard_v2` differs from `standard` only in `README.md`,
`src/02/z2ui5.wapa.index.html` and `src/02/z2ui5.wapa.manifest.json`. Everything
else is byte-identical, because legacy-free is a **bootstrap** patch
(`tools/app2app_v2/patch-v2.mjs`), not a different build. So a change to the
webapp shows up twice on each side, and a 150-file diff here is usually a
6-file change. Storing only the delta was considered and rejected: it would put
back exactly the build step the section above removes from the deploy.

**`app/package-lock.json` is here twice** (in `cloud/app/` and `cloud_v2/app/`),
byte-identical to the one at the repository root — about 900 KB of the tree.
It is not redundancy to collect. The cloud branches deliver the *complete Fiori
source project*: someone who pulls that branch runs `npm ci` inside it, and a
delivered project without its lockfile resolves floating versions, which is the
drift every other pin in this repository exists to prevent. The 900 KB buys the
consumer the same toolchain this repository built against.

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
it — and the provenance sentence of the branch `README.md` — at deploy time,
into the `result/<branch>` copy that lands on abap2UI5/frontend's `main`.
