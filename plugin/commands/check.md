---
description: Run the abap2UI5 gates (abaplint and the abap2UI5 linter) over the project or the changed classes, explain every finding and fix the ones that are clearly safe.
argument-hint: "[file or folder - default: the classes changed in git, else src/]"
allowed-tools: Read, Grep, Glob, Bash(git status *), Bash(git diff *), Bash(npm run check), Bash(npm run check:abap), Bash(npm run check:abap2ui5), Bash(npm run check:abap2ui5:fast), mcp__plugin_abap2ui5_abap2ui5__validate_view, mcp__plugin_abap2ui5_abap2ui5__fix_view, mcp__plugin_abap2ui5_abap2ui5__pitfalls
---

Run the abap2UI5 gates on: **$ARGUMENTS**

## 1. Scope

- An argument names the files or folder to check.
- Without one: the `.clas.abap` / `.clas.xml` files that `git status --porcelain`
  and `git diff --name-only` report as changed or new. Nothing changed (or no
  git): the whole `src/` folder. Say which scope you took.

## 2. Run the gates

Pick the first that applies:

1. **The project has app-template's scripts** (`package.json` has a `check`
   script that runs `abaplint` and `abap2ui5lint`): `npm run check`. It lints
   the whole project; report the findings in scope first. Without
   `node_modules`, run `npm ci` first (ask before installing).
2. **Otherwise**, two commands:
   - abaplint, when the project has an `abaplint.json` / `abaplint.jsonc`:
     `npx --yes @abaplint/cli <that file>`. Without one, skip it and say so -
     do not invent a config.
   - the abap2UI5 linter: `npx --yes @abap2ui5/linter <files or folder>`
     (add `--no-render` when the render gate is not installed and says so).
     It honours the project's `abap2ui5lint.jsonc`.
3. **No shell, or npm unavailable, but the MCP server is there**:
   `validate_view { abap_source, project_dir }` per class. That covers the
   linter, not abaplint - say so.

## 3. Explain

For every finding: `file:line`, the rule id, what it means in one sentence,
and the fix. The linter explains its own rules
(`npx --yes -p @abap2ui5/linter abap2ui5lint --explain <rule-id>`, or
`validate_view { explain: true }`). Group by file; errors before warnings
before hints.

Then go over what the gates cannot see, using the
`abap2ui5:abap-check` and `abap2ui5:ui5-check` skills (MCP `pitfalls`
lists both): the `.clas.xml` byte format (BOM, LF, final newline,
`<CLSNAME>`, `<WITH_UNIT_TESTS>`, `&apos;`), activation traps, icons and
controls that do not exist in UI5 1.71. Report only what you actually find
in the files in scope.

## 4. Fix what is clearly safe

Safe means mechanical and behaviour-preserving:

- the linter's own fixes - `npm run fix` (app-template),
  `npx --yes @abap2ui5/linter <files> --fix`, or MCP `fix_view` (returns the
  source; write it back yourself);
- chain layout per the `abap2ui5:view-chain-layout` skill;
- sidecar format (BOM, line endings, final newline, `<CLSNAME>` case,
  `<WITH_UNIT_TESTS>` matching the test include);
- an obsolete call the linter names a direct replacement for
  (`_bind_edit` -> `_bind`, a leftover `view_model_update( )` deleted).

Do **not** change on your own: anything that alters behaviour, a control or
property swapped for a different one, waivers or baseline entries, the
project's lint configuration. List those as open, with the fix you propose.

Re-run the gates after fixing, and finish with: what ran, what was fixed,
what is left and why.
