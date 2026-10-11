# abap2UI5 frontend (embed control)

The abap2UI5 frontend app for a system: a UI5 app whose one view holds one
[`z2ui5.embed.Container`](https://www.npmjs.com/package/@abap2ui5/embed-control)
filling the page. It carries **no copy of the abap2UI5 frontend**: the
control loads it from the abap2UI5 service of the system it runs on
(`?z2ui5-bundle`), so the frontend always has the version of the backend it
talks to - an abap2UI5 update is one abapGit pull, and this branch does not
have to follow it.

It is the successor of the branches `standard` and `cloud` of this
repository, which carry a generated copy of abap2UI5's `app/webapp`. Every
object, package, text and ICF node is named as there, so it replaces that
installation, and the launchpad component is `z2ui5` as before.

> This branch is generated, like every branch here: the app lives in
> [`frontend/embed`](https://github.com/abap2UI5/abap2UI5/tree/main/frontend/embed)
> of abap2UI5, and changes belong there.

| Branch | System | What it carries |
|---|---|---|
| `standard_new` | S/4 Private Cloud, S/4 On-Premise, R/3 NetWeaver >750 | the BSP `Z2UI5` and the handler `Z2UI5_CL_LP_HANDLER` with its node `/sap/bc/z2ui5` |
| `cloud_new` | S/4 Public Cloud, BTP ABAP Environment | the HTTP service `Z2UI5` (`/sap/bc/http/sap/z2ui5`) with its handler, and the app as a Fiori project in `app/` |

## Install

Needs the first abap2UI5 release **after 1.146.0** on the system - its
`?z2ui5-bundle` gives the frontend the second name this app relies on
([installation guide](https://abap2ui5.github.io/docs/configuration/installation.html)).

**`standard_new`** - pull the branch with abapGit into a package of your
own:

| | |
|---|---|
| abapGit repository | `abap2UI5-frontend` |
| `src/` | package "abap2UI5 - frontend" |
| `src/01` | package "abap2UI5 - service": the class `Z2UI5_CL_LP_HANDLER` and its ICF node `/sap/bc/z2ui5` |
| `src/02` | package "abap2UI5": the BSP `Z2UI5` and its ICF nodes `/sap/bc/ui5_ui5/sap/z2ui5`, `/sap/bc/bsp/sap/z2ui5` |

On a system that has `standard` installed, switch that abapGit repository
to the branch `standard_new` and pull - the objects are the same, their
content changes. Activate the nodes in `SICF`, then open

```
/sap/bc/ui5_ui5/sap/z2ui5/index.html
/sap/bc/ui5_ui5/sap/z2ui5/index.html?app_start=z2ui5_cl_ui5_app_hi_world
```

**`cloud_new`** - pull the branch with abapGit (ADT): `src/` is the HTTP
service and its handler, as on `cloud`. Then deploy the Fiori project in
`app/` to the system (SAP Business Application Studio or VS Code with the
SAP Fiori tools: `npm install`, then add a deployment configuration and
deploy). The app talks to `/sap/bc/http/sap/z2ui5`.

The component is `z2ui5`, with the inbound `z2ui5-display`: a launchpad
target mapping made for `standard` or `cloud` starts this app unchanged.
The abap2UI5 frontend the control loads into it is a component `z2ui5` too,
so the control creates it under the second name the backend gives it,
`z2ui5.embed.frontend`.

## Which app starts

| Where | What decides |
|---|---|
| Fiori Launchpad | the intent's `app_start` parameter (inbound `z2ui5-display`); every other parameter reaches the app as `client->get( )-t_comp_params` |
| standalone | `?app_start=` of the page's URL; the other URL parameters reach the backend as before |
| neither | `sap.ui5/config/defaultApp` of `webapp/manifest.json` - the start page `Z2UI5_CL_UI5_APP_START` |

The endpoint is never taken from the URL: the frontend is code, and it is
loaded from there.

**Not released yet:** this app needs `@abap2ui5/embed-control` newer than
0.1.1 and abap2UI5 newer than 1.146.0 (the frontend's second name, the hash
handed to the app). Until both are published the page says so instead of
starting an app.

## What is different from `standard` and `cloud`

| | `standard`, `cloud` | `standard_new`, `cloud_new` |
|---|---|---|
| objects, packages, ICF nodes | `Z2UI5`, `Z2UI5_CL_LP_HANDLER`, `/sap/bc/z2ui5`, ... | the same |
| frontend code in the BSP | a generated copy of `app/webapp` (~ the whole frontend) | none - the app, its view and the control (9 pages) |
| after an abap2UI5 update | pull the matching frontend branch as well | nothing to do |
| component in the launchpad | `z2ui5`, inbound `z2ui5-display` | the same - existing target mappings keep working |
| URL hash | the app's: hash routing, `set_push_state`, `hash_replace`, browser back between routed apps | the app's as well - the page is the control and nothing else, so it hands the hash to the app (`ownsHash`) |

Not covered: the legacy-free (UI5 2.x) variants and the renamed
`standard_<name>` builds.

#### Issues
For bug reports or feature requests, please open an issue in the [abap2UI5 repository.](https://github.com/abap2UI5/abap2UI5/issues)
