---
target: abaplint
title: 'rename: optionally rename references to objects of dependencies as well'
summary: '--rename skips every object of a dependency, so a reference in src/ to a class the dependency defines keeps the old name - three sample repositories clone their dependencies into the rename run and delete them afterwards to get it'
priority: medium
state: open
first_seen: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5/samples bf6ec6f, samples-controls 1043cf4, samples-stack 4e65f81, 2026-11: scripts/rename.mjs - "abaplint renames only the objects of its own files - dependencies stay as they are - so this script clones the abap2UI5 repositories the addon depends on ... renames them together with src/, and keeps only src/"; it also removes duplicate definitions and re-sorts the dependencies to make that work'
  - 'packages/cli/src/rename.ts on abaplint main, 2026-11-27: both loops skip an object for which reg.isDependency( o ) is true'
---

# rename: references to objects of a dependency

An addon is renamed together with the framework it builds on: `z2ui5_` ->
`zmyui5_` for both. The framework is a dependency of the addon in abaplint,
and `--rename` leaves dependencies alone - so the addon's own classes are
renamed, and every `z2ui5_cl_ui5_view_builder` they reference stays.

## Proposal

An opt-in setting, for example `rename.renameDependencies: true`: an object
of a dependency that matches a pattern is renamed in the registry, the
references in the project's own files follow, and the files of the
dependency are not written.

## Must not change

The default; an object of a dependency that matches no pattern; the
dependency files on disk.
