[![frontend_check](https://github.com/abap2UI5/abap2UI5/actions/workflows/frontend_check.yaml/badge.svg?branch=main)](https://github.com/abap2UI5/abap2UI5/actions/workflows/frontend_check.yaml)
[![frontend_deploy](https://github.com/abap2UI5/abap2UI5/actions/workflows/frontend_deploy.yaml/badge.svg?branch=main)](https://github.com/abap2UI5/abap2UI5/actions/workflows/frontend_deploy.yaml)

# abap2UI5 frontend

This repository contains an abap2UI5 frontend artefacts service. For more information on installation, check out the [installation guide.](https://abap2ui5.github.io/docs/configuration/installation.html)

> ### This repository is generated — it does not take manual pull requests
>
> It is not where the frontend is written, it is where the frontend is *published*. **Every** branch here is built in [abap2UI5](https://github.com/abap2UI5/abap2UI5) and pushed in — first as `result/<branch>` folders into one commit on `main`, then fanned out by the `deliver` workflow — so **frontend changes belong there** and bug reports belong in [its issues](https://github.com/abap2UI5/abap2UI5/issues). The `guard` check fails every pull request opened here by default; maintaining this repository's own docs is the one exception, unlocked by a maintainer with the `maintenance` label. Full rationale: [CONTRIBUTING.md](https://github.com/abap2UI5/frontend/blob/main/CONTRIBUTING.md).
>
> ```
> abap2UI5/abap2UI5                       abap2UI5/frontend
>                    frontend_deploy                        deliver
>   app/webapp/  ──▶  tools/out/  ──────▶  main           ──────────▶  cloud
>   (the webapp)      (each branch         result/<branch>             cloud_v2
>    + frontend/       built at deploy     (all six trees,             standard
>      abap, embed     time, git-ignored,  one commit per              standard_v2
>                      never committed)    change)                     cloud_new
>                                                                      standard_new
>                                                                      (each: main
>                                                                      + one commit)
>
>                                          standard_<name> is built on demand
>                                          and pushed straight onto its branch
> ```

#### Branch

Every branch is generated in [abap2UI5](https://github.com/abap2UI5/abap2UI5) — the webapp lives in `app/webapp` there, everything else a branch is built from in [`frontend/`](https://github.com/abap2UI5/abap2UI5/tree/main/frontend) — and built there by `tools/build-branches.mjs` into the git-ignored `tools/out/`, never committed on that side. Its `frontend_deploy` workflow writes the six stamped trees as `result/<branch>` folders into one commit on `main` here, and the `deliver` workflow turns each folder into its branch: one commit on top of `main`, carrying the folder's content and nothing else. So every branch is always exactly one commit ahead of `main`, `main`'s history shows every change a branch ever received, and what arrives on a branch is what a pull request over there reviewed. Pull the one that matches your system:

| Name        | System                                                | UI5     | Built by |
|-------------|-------------------------------------------------------|---------|-------|
| cloud       | S/4 Public Cloud, BTP ABAP Environment                | classic | `npm run frontend:cloud` |
| cloud_v2    | S/4 Public Cloud, BTP ABAP Environment                | legacy-free (UI5 2.x) | `npm run frontend:cloud_v2` |
| standard    | S/4 Private Cloud, S/4 On-Premise, R/3 NetWeaver >750 | classic | `npm run frontend:standard` |
| standard_v2 | S/4 Private Cloud, S/4 On-Premise                     | legacy-free (UI5 2.x) | `npm run frontend:standard_v2` |
| cloud_new   | S/4 Public Cloud, BTP ABAP Environment                | embed control | `npm run frontend:cloud_new` |
| standard_new | S/4 Private Cloud, S/4 On-Premise, R/3 NetWeaver >750 | embed control | `npm run frontend:standard_new` |

The `_new` branches carry no copy of the abap2UI5 frontend: their app is one view with one [`z2ui5.embed.Container`](https://www.npmjs.com/package/@abap2ui5/embed-control), a custom control that loads the frontend from the backend it runs against (`?z2ui5-bundle`) — the frontend always has the version of the backend it talks to, and an abap2UI5 update needs no frontend pull any more. Same objects, names, endpoints and launchpad settings as `cloud` and `standard` - a system switches between the branches by pulling another one, and launchpad target mappings and external links keep working (checked on every build by `tools/check-identity.mjs`); they need an abap2UI5 newer than 1.146.0. The app lives in [`frontend/embed`](https://github.com/abap2UI5/abap2UI5/tree/main/frontend/embed) of abap2UI5, the control is developed in [abap2UI5/embed-control](https://github.com/abap2UI5/embed-control) and published as `@abap2ui5/embed-control`, and each of the two branches has a README of its own.

`main` carries this repository's own docs plus the machine-written `result/` trees — it is not a source either: a hand edit to `result/` is overwritten by the next delivery.

#### Where to change what

Nothing in this repository is written by hand any more. A change made to a generated branch or to `result/` is discarded on the next delivery, without a trace in the history:

| Content | Owned by |
|---|---|
| `result/` on `main` | [abap2UI5](https://github.com/abap2UI5/abap2UI5) — its `frontend_deploy` workflow commits the six finished trees, one commit per content change |
| every branch (`cloud`, `cloud_v2`, `standard`, `standard_v2`, `cloud_new`, `standard_new`) | the `deliver` workflow here — each branch is `main` plus one commit carrying its `result/<branch>` content |
| `standard_<name>` | [abap2UI5](https://github.com/abap2UI5/abap2UI5) — built on demand by a `frontend_deploy` dispatch and pushed straight onto the branch |
| the app of `cloud_new` and `standard_new` | [abap2UI5](https://github.com/abap2UI5/abap2UI5), [`frontend/embed`](https://github.com/abap2UI5/abap2UI5/tree/main/frontend/embed) — the control it holds is [abap2UI5/embed-control](https://github.com/abap2UI5/embed-control)'s, pinned as `@abap2ui5/embed-control` |
| this repository's docs (`main`) | here, as a maintenance pull request |

So a frontend change belongs in abap2UI5: edit `app/webapp` there and run `npm run app2abap` to regenerate the embedded ABAP resources under `src/01/03`. No delivery tree is committed with it: `frontend_check` builds all six branches from the pull request into the git-ignored `tools/out/` and checks the BSP packaging against the webapp being changed, and `frontend_deploy` runs the same build on `main`, stamps the trees and delivers them into `result/` on `main` here, from where `deliver` fans them out into the branches. (`npm run frontend:build` is that build on your machine, `npm run frontend:verify` compares it with what is published here.)

The `_new` branches take the other route to the same place. Nothing of `app/webapp` is generated into them: their app in [`frontend/embed`](https://github.com/abap2UI5/abap2UI5/tree/main/frontend/embed) is one view with one `z2ui5.embed.Container`, and the control fetches the abap2UI5 frontend from the backend at runtime — so a change to the frontend reaches a system on these branches with the backend, without a delivery here. What *is* delivered is the app itself, the control at the version pinned in `frontend/embed/package.json` and in the root `package.json` of abap2UI5 (both, or the build fails), and the ABAP artefacts. The control is developed in [abap2UI5/embed-control](https://github.com/abap2UI5/embed-control) and published as [`@abap2ui5/embed-control`](https://www.npmjs.com/package/@abap2ui5/embed-control): a limitation of the control is fixed there, one of the frontend in `app/webapp`, and neither is worked around in the app.

Because the overwrite is not loud — the change is merged, works, and vanishes on some later unrelated run — the convention is enforced rather than trusted: the `guard` workflow fails **every** pull request opened here, and a change to this repository's own docs is unlocked by a maintainer applying the `maintenance` label.

#### Renaming

Need the BSP under a **different name** (e.g. a second copy in the same system)? Run the [`frontend_deploy` workflow](https://github.com/abap2UI5/abap2UI5/actions/workflows/frontend_deploy.yaml) in abap2UI5 with a branch name of the form `standard_<name>` — plain (`ZMYUI5`) or in a registered namespace (`/ABAPGIT/` → BSP `/ABAPGIT/UI5`, handler `/ABAPGIT/CL_LP_HANDLER`) — it generates and pushes a branch `standard_<name>` / `standard_v2_<name>` with the whole deployment identity (BSP, SICF nodes, handler class) renamed. For a backend that was itself renamed with the [`build-rename` workflow](https://github.com/abap2UI5/abap2UI5/actions/workflows/build-rename.yaml), append `__<name>` (`standard_#abap2ui5#__#abap2ui5#`): the handler then calls that backend's `cl_http_handler`. Details in [`tools/bsp_rename`](https://github.com/abap2UI5/abap2UI5/tree/main/tools/bsp_rename).

#### Sibling BSPs

`app/webapp/manifest.json` reserves two resourceRoots that point **next to** this BSP, so a system can add frontend artefacts without a change here:

| resourceRoot | Sibling BSP | Built from |
|---|---|---|
| `z2ui5_cci` | `Z2UI5_CCI` | [abap2UI5-addons/custom-controls](https://github.com/abap2UI5-addons/custom-controls) — community custom controls |
| `z2ui5_ccc` | `Z2UI5_CCC` | [abap2UI5-addons/custom-controls-customer](https://github.com/abap2UI5-addons/custom-controls-customer) — a customer's own reuse library, icon font or CSS |

Neither BSP has to be installed: the browser requests nothing from a resourceRoot until a view names the namespace. Both entries come from abap2UI5 `app/webapp` — see "Where to change what" above.

#### Dependencies
* [abap2UI5](https://github.com/abap2UI5/abap2UI5) — the frontend artefacts pair with the abap2UI5 framework installed in the backend

#### Issues
For bug reports or feature requests, please open an issue in the [abap2UI5 repository.](https://github.com/abap2UI5/abap2UI5/issues)
