# tools/

Everything that **generates** an artefact. One folder, so the answer to
"where does this file come from" is always the same place.

Not to be confused with `.github/scripts/`, which is the other kind of script
entirely: those are CI gates: they read the repository and answer yes or no.
Nothing in `.github/scripts/` produces a deliverable, and nothing here decides
whether a pull request may merge.

| | |
| --- | --- |
| `app2abap/` | `bundle/webapp/*` and `app_source/webapp/*` → the embedded ABAP string constants in `src/01/03/`, and `app_source/webapp/*` → the BSP `Z2UI5` in `src/03/02/` (`npm run app2abap`) - both with the embed control from the pinned checkout of abap2UI5-addons/embed-ui5-control in `tools/deps/` |
| `bsp/` | **`@abap2ui5/bsp`**, published to npm: any UI5 app folder → an abapGit BSP with its ICF nodes (`app2bsp`), a serialized BSP → an app folder (`bsp2app`), the page rules (`check`). What `app2abap` writes the BSP with. Its own README is the usage; `npm run test:bsp` its tests |
| `build-cloud.mjs` | the tree of the branch `cloud` → the git-ignored `tools/out/cloud` (`npm run cloud:build`); its header says what the branch carries and why |
| `bsp_rename/` | rewrites the deployment identity of `src/03` (BSP, SICF, handler) for a parallel install - the second half of `build-rename` (`.github/scripts/rename-service.mjs`) |
| `sbom.mjs` | the software bill of materials of a release, CycloneDX 1.5 (`npm run sbom`); `release.yaml` attaches it to every release, `check:sbom` holds the tree to "nothing third-party is shipped" |

Without a caller since 2026-11-17, when the delivery into abap2UI5/frontend
ended:

| | |
| --- | --- |
| `app2bsp/` | the classic webapp as a BSP with a minified component preload bundle. `bsp/`'s tests still read its `static_files` as the reference for the path mapping and the ICF node names |

The legacy-free (UI5 2.x) bootstrap patch `app2app_v2/` and its monthly guard
`check-v2-sdk.mjs` were deleted on 2026-11-27 - the build no longer ran
(`docs/agents/decisions.md`).

What these consume besides the two app folders - the ABAP artefacts of the
branch `cloud` and its README - lives in [`cloud/`](../cloud). Tools here,
data there.

## What is committed, and what is not

| Artefact | Committed? | Held to its source by |
| --- | --- | --- |
| `src/01/03/` - the frontend as ABAP classes | yes | `check:app2abap` (`check_app2abap.yaml`) |
| `src/03/02/` - the BSP `Z2UI5` | yes | the same gate: one `npm run app2abap` writes both |
| the branch `702` | no, generated on `main` | `auto_downport.yaml`, which lints what it publishes |
| the branch `cloud` | no, built into `tools/out/cloud` and laid over the tree of `main` | `delivery-check.yaml` on the pull request, `auto-cloud.yaml` on `main` |

`main` has to be installable as it stands, so what an installation pulls from
it is committed. The two generated branches are a function of `main` and
nobody commits to them.

## Running it

```bash
npm run app2abap       # regenerate src/01/03 and the BSP of src/03/02
npm run cloud:build    # the tree of the branch cloud -> tools/out/cloud
npm run check:service  # abaplint over src/03 and cloud/src/03
npm run test:bsp       # the tests of @abap2ui5/bsp
npm run rename         # the namespace rename against the placeholder name, src/03 included
```

## Why the generated branches may not drift

They are an **installation source**: abapGit repositories out there point at
`main`, `702`, `cloud` and the renamed variants. A change to what one carries
reaches every one of them on the next pull.

The BSP has rules of its own, each of which stands for a failure that reached
a real system or came within a step of it: a page line over 255 characters, a
page name `CREATE_NEW_PAGE` rejects, a content file missing from the page
directory, a `.js` page that stops being valid JavaScript once padded.
`app2bsp` refuses the first two before it writes anything, and `app2abap`
checks the BSP as stored before it replaces the committed one.

## History

Until 2026-11 the ICF node, the BSP and the cloud service were not part of
`src/`: `build-branches.mjs` built them into delivery trees, `frontend_deploy`
pushed those into branches of abap2UI5/frontend (`standard_new`, `cloud_new`,
and before them `standard`, `cloud` and their `_v2` twins with a copy of the
whole frontend), and an installation pulled that repository next to this one.
The embed control made the BSP four small files that never change with the
frontend, which is what made it reasonable to commit it here.
