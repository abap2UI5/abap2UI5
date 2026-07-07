# rename

`build-rename.mjs` builds a renamed variant of abap2UI5: every ABAP artifact
(classes, interfaces, the draft table) is moved from the `z2ui5` namespace to
a new prefix so a second copy can be installed into the **same SAP system**
without object-name collisions — one installation per release, per module or
per app (see the [renaming guide](https://abap2ui5.github.io/docs/advanced/renaming.html)).

## Renamed branches via `build_rename` (recommended)

The easiest way to get a renamed install: run the **`build_rename`** GitHub
workflow (Actions → build_rename → Run workflow) and enter the new namespace
(e.g. `ZMYUI5`). It renames all artifacts and pushes the result as branch
**`rename_<name>`** (name lowercased, e.g. `rename_zmyui5`) — ready to pull
with abapGit. Re-running the workflow with the same name updates the branch
to the current `main` state.

The same build runs locally with

```bash
node .github/rename/build-rename.mjs ZMYUI5      # -> .github/out/rename_zmyui5
```

The renamed branch is fully self-contained: sources, abapGit descriptor
(`.abapgit.xml` with the version constant turned to `<NAME>_IF_APP=>VERSION`)
and an `abaplint.jsonc` with the naming rules turned to the new namespace, so
the abaplint check also works on the output branch.

## Naming rules

The new namespace must start with a letter, contain only letters, digits and
underscore, and be at most **9 characters** — longer prefixes would push the
generated `*_js` class names past the 30-character ABAP name limit even after
truncation. A warning is printed if it does not start with `Z`/`Y` (SAP
customer namespace). Registered namespaces (`/NS/`) are not supported.

## How it works

1. **abaplint rename** — the script generates an abaplint config with rename
   patterns (`z2ui5(.*)` → `<name>$1` for `CLAS|INTF|TABL`) and runs
   `abaplint --rename`, which rewrites every object, file name and code/XML
   reference consistently. Objects whose new name would exceed 30 characters
   (the generated `z2ui5_cl_app_*_js` frontend-embed classes) get an explicit
   truncating pattern, using the same stem-truncation scheme as
   `.github/app2abap/trans2abap.js`; name collisions after truncation abort
   the build.
2. **String literals** — object names inside string literals are not covered
   by abaplint's rename, but a few are functional on a renamed installation
   (the user-exit discovery in `z2ui5_cl_exit`, the dynamic cloud dispatch in
   `z2ui5_cl_util_api`). The script therefore rewrites every occurrence of a
   renamed object name in the ABAP sources, preserving case style. The
   embedded frontend under `src/01/03` is excluded: there `z2ui5` is the UI5
   module namespace of the webapp (`z2ui5/cc/...`, `z2ui5.Util`), which is
   browser-side only, collision-free and part of the frontend public
   contract — it must not change.
3. **Assemble** — renamed `src/` plus `.abapgit.xml`, `abaplint.jsonc`,
   README (with a generated-branch banner) and the common root files are
   written to `.github/out/rename_<name>/`; the workflow lints that tree and
   pushes it as a single commit onto the existing branch history (the `main`
   commit is carried as second parent, no push when nothing changed).

The renamed install still serves the standard UI5 frontend — only ABAP
object names change, the browser-side app is identical. Apps built for the
original install must implement the renamed interfaces (e.g.
`zmyui5_if_app` instead of `z2ui5_if_app`).
