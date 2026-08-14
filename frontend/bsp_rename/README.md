# bsp_rename

`rename-bsp.mjs` renames the abap2UI5 frontend BSP so a second copy can be
installed into the **same SAP system** without object-name collisions — the
way this repo ships as `Z2UI5` and `frontend-legacy-free` ships as `Z2UI5_V2`.

Dependency-free Node script (Node 16+). Nothing to install.

## Renamed branches via `build_rename` (recommended)

The easiest way to get a renamed install: run the **`build_rename`** GitHub
workflow (Actions → build_rename → Run workflow), pick the base variant
(`standard` or `standard_v2`) and enter the new BSP name (e.g. `ZMYUI5`, or
a namespaced name like `/ABAPGIT/`, see below). It builds the base branch,
applies this rename script to the generated `src` tree and pushes the result
as branch **`standard_<name>`** / **`standard_v2_<name>`** (name lowercased;
for namespaced names `/` becomes `#` like in abapGit file names, e.g.
`standard_#abapgit#ui5`) — ready to pull with abapGit. Re-running the
workflow with the same name updates the branch to the current `main` state.

The same build runs locally with

```bash
node frontend/build-branches.mjs standard_zmyui5        # -> frontend/out/standard_zmyui5
node frontend/build-branches.mjs standard_v2_zmyui5     # legacy-free variant
node frontend/build-branches.mjs 'standard_#abapgit#'   # namespaced -> BSP /ABAPGIT/UI5
```

The renamed branch is fully self-contained: BSP, SICF nodes and the ICF
handler class all carry the new name, so it installs alongside an existing
`Z2UI5` without touching it (it still requires the abap2UI5 backend, see
below).

## Usage

Run it from the **repository root** (so the default `src` path resolves):

```bash
node frontend/bsp_rename/rename-bsp.mjs ZMYUI5            # rename, asks for confirmation
node frontend/bsp_rename/rename-bsp.mjs                   # prompts for the name
node frontend/bsp_rename/rename-bsp.mjs zmyui5 --dry-run  # preview only, writes nothing
node frontend/bsp_rename/rename-bsp.mjs ZMYUI5 --yes      # no confirmation prompt
node frontend/bsp_rename/rename-bsp.mjs /abapgit/         # rename into a registered namespace
```

| Option | Meaning |
| --- | --- |
| `--dir <paths>` | Comma-separated roots to process (default `src`). |
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
that is also how the name is encoded in the `build_rename` branch name.)

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
- the global runtime object `z2ui5` (`window.z2ui5`, `z2ui5.oConfig`, …)
- the event protocol constant `Z2UI5` (handlers map in `core/FrontendAction.js`)
- the `z2ui5-xapp-state` cross-app-state key
- the **UI5 framework namespace `z2ui5`** — module paths `z2ui5/core/*`,
  `z2ui5/cc/*` and the custom controls `z2ui5.cc.*`. The backend-generated
  view XML references this namespace.

> `frontend-legacy-free` proves this split: it renamed the BSP to `Z2UI5_V2`
> but kept the custom controls as `z2ui5.*` and mapped
> `resourceroots {"z2ui5": "./cc/"}`.

## `--with-namespace` (advanced)

Also rewrites the UI5 namespace (resourceroots, module paths, `.extend(...)`,
`controllerName`, custom controls `z2ui5.cc.*`, manifest `id`/`viewPath`/
`viewName`). Only use it when rebranding the whole stack **including the
backend** — otherwise custom controls and backend-generated views stop working.
Even in this mode the runtime global `z2ui5`, the `Z2UI5` event constant and
`z2ui5_cl_http_handler` are still preserved.
