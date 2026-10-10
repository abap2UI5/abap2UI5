# bsp_rename

`rename-bsp.mjs` renames the abap2UI5 frontend BSP so a second copy can be
installed into the **same SAP system** without object-name collisions — the
delivered `standard`/`standard_v2` branches ship as `Z2UI5`, a renamed
variant ships under the name of your choice (e.g. `ZMYUI5`).

Dependency-free Node script (Node 16+). Nothing to install.

## Renamed branches via `frontend_deploy` (recommended)

The easiest way to get a renamed install: run the **`frontend_deploy`**
GitHub workflow (Actions → frontend_deploy → Run workflow) and enter the
branch name **`standard_<name>`** / **`standard_v2_<name>`** (name
lowercased, e.g. `standard_zmyui5`; for namespaced names `/` becomes `#`
like in abapGit file names, e.g. `standard_#abapgit#ui5`, see below). It
builds the base variant, applies this rename script to the generated `src`
tree and pushes the result as that branch into `abap2UI5/frontend` — ready
to pull with abapGit. Re-running the workflow with the same name updates
the branch to the current `main` state.

The same build runs locally with

```bash
node tools/build-branches.mjs standard_zmyui5        # -> tools/out/standard_zmyui5
node tools/build-branches.mjs standard_v2_zmyui5     # legacy-free variant
node tools/build-branches.mjs 'standard_#abapgit#'   # namespaced -> BSP /ABAPGIT/UI5
node tools/build-branches.mjs 'standard_#abap2ui5#__#abap2ui5#'  # + renamed backend, see below
```

The renamed branch is fully self-contained: BSP, SICF nodes and the ICF
handler class all carry the new name, so it installs alongside an existing
`Z2UI5` without touching it (it still requires the abap2UI5 backend, see
below).

## Usage

Run it from the **repository root** (so the default `src` path resolves):

```bash
node tools/bsp_rename/rename-bsp.mjs ZMYUI5            # rename, asks for confirmation
node tools/bsp_rename/rename-bsp.mjs                   # prompts for the name
node tools/bsp_rename/rename-bsp.mjs zmyui5 --dry-run  # preview only, writes nothing
node tools/bsp_rename/rename-bsp.mjs ZMYUI5 --yes      # no confirmation prompt
node tools/bsp_rename/rename-bsp.mjs /abapgit/         # rename into a registered namespace
```

| Option | Meaning |
| --- | --- |
| `--dir <paths>` | Comma-separated roots to process (default `src`). |
| `--backend <prefix>` | The handler calls `<prefix>cl_http_handler` — for a backend renamed with `build-rename`, see below. |
| `--with-namespace` | Also rewrite the UI5 namespace — advanced, see below. |
| `--dry-run` | Show what would change, write nothing. |
| `--yes`, `-y` | Skip the confirmation prompt. |
| `-h`, `--help` | Show help. |

The new name must start with a letter, contain only letters/digits/`_`, and be
at most 15 characters (ICF service / BSP application name limit). A warning is
printed if it does not start with `Z`/`Y` (SAP customer namespace).

After running, review with `git status` / `git diff`, then commit.

## Namespaced names (`/NS/`)

Instead of a plain name you can rename into a **registered SAP namespace**:

| Input | BSP application | ICF handler class |
| --- | --- | --- |
| `/ABAPGIT/` | `/ABAPGIT/UI5` | `/ABAPGIT/CL_LP_HANDLER` |
| `/ABAPGIT/MYAPP` | `/ABAPGIT/MYAPP` | `/ABAPGIT/MYAPP_CL_LP_HANDLER` |

(The abapGit file-name spelling `#abapgit#myapp` is accepted as input too —
that is also how the name is encoded in the branch name given to the
`frontend_deploy` dispatch.)

Namespace max. 8 characters between the slashes, full BSP name max. 15
characters including the slashes. What happens on top of a plain rename:

- **File names** use the abapGit `#` escaping: `#abapgit#ui5.wapa.*`,
  `#abapgit#cl_lp_handler.clas.*`.
- **SICF paths** follow the SAP convention for namespaced BSPs — the
  namespace replaces the `sap` path segment and is an ICF node of its own:
  `/sap/bc/abapgit/ui5`, `/sap/bc/bsp/abapgit/ui5`,
  `/sap/bc/ui5_ui5/abapgit/ui5`. The `<ICF_NAME>` fields carry only the leaf
  name (`UI5`), since ICF node names cannot contain slashes.
- **Namespace-level ICF nodes** (`/sap/bc/abapgit`, `/sap/bc/bsp/abapgit`,
  `/sap/bc/ui5_ui5/abapgit`) do not exist in a vanilla system and abapGit
  does not create intermediate nodes, so the script **generates** one extra
  `.sicf.xml` per parent node.
- The **SMIM** folder URL becomes `/SAP/BC/BSP/<NS>/<NAME>`.

Prerequisite: the `/NS/` namespace must exist in the target system
(transaction SE03 → Display/Change Namespaces, with a developer/changeable
license) before the abapGit pull — otherwise the objects cannot be created.
`--with-namespace` is not available for `/NS/` names (UI5 module ids cannot
carry a SAP namespace; the `z2ui5` UI5 namespace is kept as usual).

## A renamed backend (`--backend`)

The backend has a rename of its own: the
[`build-rename` workflow](https://github.com/abap2UI5/abap2UI5/actions/workflows/build-rename.yaml)
of abap2UI5 turns every `z2ui5_*` object into `<prefix>*` (`ZMYUI5` →
`zmyui5_cl_http_handler`, `/ABAP2UI5/` → `/abap2ui5/cl_http_handler`) and
pushes the result to the branch `rename_<name>`. A BSP renamed with this
script alone still calls `z2ui5_cl_http_handler`, which such a backend no
longer ships — the ICF node answers with a class-not-found dump. `--backend`
takes the same prefix the workflow took and rewrites the call:

```bash
node tools/bsp_rename/rename-bsp.mjs /abap2ui5/ --backend /abap2ui5/   # handler calls /abap2ui5/cl_http_handler
node tools/bsp_rename/rename-bsp.mjs ZMYUI5 --backend zmyui5           # handler calls zmyui5_cl_http_handler
```

Accepted: a customer name with or without its trailing `_` (max. 10
characters without it, the limit of `build-rename`) or a namespace with both
slashes (max. 10 characters, `#abap2ui5#` works too). `z2ui5` itself is refused — leave the option out
for an unrenamed backend. Nothing else changes: the UI5 namespace `z2ui5` is
a frontend module id, not an ABAP object, and the backend rename does not
touch it either.

In a `build-branches.mjs` / `frontend_deploy` branch name the backend
follows the BSP name after a double underscore:

| Branch | BSP | Handler calls |
| --- | --- | --- |
| `standard_#abap2ui5#__#abap2ui5#` | `/ABAP2UI5/UI5` | `/abap2ui5/cl_http_handler` |
| `standard_v2_zmyui5__zmyui5` | `ZMYUI5` | `zmyui5_cl_http_handler` |

The `abaplint.jsonc` of such a tree reads the backend from the branch
`rename_<backend>` instead of `main`, so run `build-rename` for that name
first — `frontend_deploy` lints the tree against it.

## What it renames (the "deployment identity")

These are the objects that collide when you install a second copy into one
system:

- **BSP application** object (`Z2UI5` → `<NEW>`)
- **SICF service nodes** (3×): `/sap/bc/z2ui5`, `/sap/bc/bsp/sap/z2ui5`,
  `/sap/bc/ui5_ui5/sap/z2ui5`
- **SMIM** folder URL (`/SAP/BC/BSP/SAP/Z2UI5`)
- **ICF handler class** `Z2UI5_CL_LP_HANDLER` → `<NEW>_CL_LP_HANDLER`
- **manifest.json** data source `/sap/bc/z2ui5` (points at the handler above)
- **all on-disk file names** (`z2ui5.wapa.*`, `z2ui5_cl_lp_handler.*`, and the
  SICF files — both the 15-char name field and the 25-char hash. The hash is
  the first 25 hex chars of `sha1(<ICF URL>)`, so it changes with the rename;
  keeping the old hash would make abapGit re-serialize the service under a
  different file name after the pull, i.e. a permanent diff)

## What it deliberately keeps

These are **protocol contracts with the abap2UI5 backend** (which lives in a
different repository). Renaming them breaks the app unless the backend is
rebranded too:

- `z2ui5_cl_http_handler` — the backend framework class the handler calls
  (unless `--backend` names a renamed one, see above)
- the `z2ui5-xapp-state` cross-app-state key
- the **UI5 framework namespace `z2ui5`** — module paths `z2ui5/core/*`,
  `z2ui5/cc/*` and the custom controls `z2ui5.cc.*`. The backend-generated
  view XML references this namespace.

> Every renamed branch proves this split: `standard_v2_zmyui5` renames the
> BSP to `ZMYUI5` but keeps the custom controls as `z2ui5.*` and maps
> `resourceroots {"z2ui5": "./cc/"}`.

## `--with-namespace` (advanced)

Also rewrites the UI5 namespace (resourceroots, module paths, `.extend(...)`,
`controllerName`, custom controls `z2ui5.cc.*`, manifest `id`/`viewPath`/
`viewName`). Only use it when rebranding the whole stack **including the
backend** — otherwise custom controls and backend-generated views stop working.
Even in this mode `z2ui5_cl_http_handler` is still preserved.
