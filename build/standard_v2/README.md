> ⚙️ **Generated branch `standard_v2`** — built in [abap2UI5/abap2UI5](https://github.com/abap2UI5/abap2UI5) by its `frontend_deploy` workflow and pushed here. Do not commit in this repository; changes belong into abap2UI5.

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
>   app/webapp/  ──▶  build/  ──────────▶  main           ──────────▶  cloud
>   (the webapp)      (each branch         result/<branch>             cloud_v2
>    + frontend/       as a committed      (all four trees,            standard
>                      tree)               one commit per              standard_v2
>                                          change)                     (each: main
>                                                                      + one commit)
>
>                                          standard_<name> is built on demand
>                                          and pushed straight onto its branch
> ```

#### Branch

Every branch is generated in [abap2UI5](https://github.com/abap2UI5/abap2UI5) — the webapp lives in `app/webapp` there, everything else a branch is built from in [`frontend/`](https://github.com/abap2UI5/abap2UI5/tree/main/frontend) — and committed there as a finished tree under [`build/`](https://github.com/abap2UI5/abap2UI5/tree/main/build). Its `frontend_deploy` workflow writes the four stamped trees as `result/<branch>` folders into one commit on `main` here, and the `deliver` workflow turns each folder into its branch: one commit on top of `main`, carrying the folder's content and nothing else. So every branch is always exactly one commit ahead of `main`, `main`'s history shows every change a branch ever received, and what arrives on a branch is what a pull request over there reviewed. Pull the one that matches your system:

| Name        | System                                                | UI5     | Built by |
|-------------|-------------------------------------------------------|---------|-------|
| cloud       | S/4 Public Cloud, BTP ABAP Environment                | classic | `npm run frontend:cloud` |
| cloud_v2    | S/4 Public Cloud, BTP ABAP Environment                | legacy-free (UI5 2.x) | `npm run frontend:cloud_v2` |
| standard    | S/4 Private Cloud, S/4 On-Premise, R/3 NetWeaver >750 | classic | `npm run frontend:standard` |
| standard_v2 | S/4 Private Cloud, S/4 On-Premise                     | legacy-free (UI5 2.x) | `npm run frontend:standard_v2` |

`main` carries this repository's own docs plus the machine-written `result/` trees — it is not a source either: a hand edit to `result/` is overwritten by the next delivery.

#### Where to change what

Nothing in this repository is written by hand any more. A change made to a generated branch or to `result/` is discarded on the next delivery, without a trace in the history:

| Content | Owned by |
|---|---|
| `result/` on `main` | [abap2UI5](https://github.com/abap2UI5/abap2UI5) — its `frontend_deploy` workflow commits the four finished trees, one commit per content change |
| every branch (`cloud`, `cloud_v2`, `standard`, `standard_v2`) | the `deliver` workflow here — each branch is `main` plus one commit carrying its `result/<branch>` content |
| `standard_<name>` | [abap2UI5](https://github.com/abap2UI5/abap2UI5) — built on demand by a `frontend_deploy` dispatch and pushed straight onto the branch |
| this repository's docs (`main`) | here, as a maintenance pull request |

So a frontend change belongs in abap2UI5: edit `app/webapp` there, run `npm run app2abap` to regenerate the embedded ABAP resources under `src/01/03` and `npm run frontend:build` to regenerate the delivery trees under `build/`, and commit both with the change. The BSP packaging is checked in the same pull request, against the webapp being changed (`frontend_check`), and `frontend_deploy` delivers the committed trees into `result/` on `main` here, from where `deliver` fans them out into the branches.

Because the overwrite is not loud — the change is merged, works, and vanishes on some later unrelated run — the convention is enforced rather than trusted: the `guard` workflow fails **every** pull request opened here, and a change to this repository's own docs is unlocked by a maintainer applying the `maintenance` label.

#### Renaming

Need the BSP under a **different name** (e.g. a second copy in the same system)? Run the [`frontend_deploy` workflow](https://github.com/abap2UI5/abap2UI5/actions/workflows/frontend_deploy.yaml) in abap2UI5 with a branch name of the form `standard_<name>` — plain (`ZMYUI5`) or in a registered namespace (`/ABAPGIT/` → BSP `/ABAPGIT/UI5`, handler `/ABAPGIT/CL_LP_HANDLER`) — it generates and pushes a branch `standard_<name>` / `standard_v2_<name>` with the whole deployment identity (BSP, SICF nodes, handler class) renamed. Details in [`tools/bsp_rename`](https://github.com/abap2UI5/abap2UI5/tree/main/tools/bsp_rename).

#### Sibling BSPs

`app/webapp/manifest.json` reserves two resourceRoots that point **next to** this BSP, so a system can add frontend artefacts without a change here:

| resourceRoot | Sibling BSP | Built from |
|---|---|---|
| `z2ui5_cci` | `Z2UI5_CCI` | [abap2UI5-addons/custom-controls](https://github.com/abap2UI5-addons/custom-controls) — community custom controls |
| `z2ui5_ccc` | `Z2UI5_CCC` | [abap2UI5/customer-frontend-extension](https://github.com/abap2UI5/customer-frontend-extension) — a customer's own reuse library, icon font or CSS |

Neither BSP has to be installed: the browser requests nothing from a resourceRoot until a view names the namespace. Both entries come from abap2UI5 `app/webapp` — see "Where to change what" above.

#### Dependencies
* [abap2UI5](https://github.com/abap2UI5/abap2UI5) — the frontend artefacts pair with the abap2UI5 framework installed in the backend

#### Issues
For bug reports or feature requests, please open an issue in the [abap2UI5 repository.](https://github.com/abap2UI5/abap2UI5/issues)
