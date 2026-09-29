---
target: open-abap
title: 'transpiler-cli cannot transpile against a library without emitting it again - the own classes of a host load a second copy, whose second CX_ROOT breaks every CATCH'
summary: every object the transpile reads - the libraries under `libs` included - is written to the output folder, and a transpiled class imports what it extends by a relative path. A host that transpiles its own classes against an already transpiled library (an npm package) loads a second copy of that library; the second CX_ROOT replaces the first in abap.Classes and exceptions fly through every CATCH. A lib option that type-checks against the library and imports it from a module specifier instead of emitting it would end the workarounds
priority: medium
state: open
first_seen: 2026-09-29
upstream: abaplint/transpiler
evidence:
  - found 2026-09-28 building "Your own apps" for @abap2ui5/node-runtime - a host class that extends an exception class, transpiled against the package's ABAP sources, imported `./cx_static_check.clas.mjs` from its own output, a second copy of open-abap-core registered itself in abap.Classes, and from then on every request failed because the framework's `CATCH cx_root` compared against a class its own exceptions did not extend
  - two workarounds exist today, both rewriting the transpiler's output - abap2UI5's `node/setup/own-apps.mjs` (the bin `abap2ui5-own-apps`, abap2UI5#2813) keeps the host's files and points their imports at `@abap2ui5/node-runtime/output/<file>`, and abap2UI5/mcp-server's npm backend (`rewriteImports`, abap2UI5/mcp-server#36) does the same for dev apps
  - `ITranspilerConfig.libs` of @abaplint/transpiler-cli 2.13.93 has `url`, `folder`, `files` and `exclude_filter` - nothing that keeps a library out of the output; unchanged at abaplint/transpiler main 916d00f (2026-09-29)
---

# Transpile against a library without emitting it

## The problem

A transpiled ABAP stack can be published as a package. abap2UI5 publishes
itself on npm as `@abap2ui5/node-runtime`: open-abap-core and the framework,
already transpiled. A host that wants to add classes of its own transpiles
them against the library's ABAP sources (`libs`), which the type check needs.
That goes wrong in two steps:

1. **Every object the transpile read is written to the output folder,** the
   library's included. There is no option to leave a lib out.
2. **A transpiled class imports what it extends by a relative path:**
   `const {cx_static_check} = await import("./cx_static_check.clas.mjs")`.
   Importing the host's class from its output folder therefore loads the
   output's copy of the library.

The copy's modules register themselves in `abap.Classes` again. A second
`CX_ROOT` replaces the first, and every `CATCH cx_root` of the package now
compares against a class its own exceptions do not extend: they fly through
every handler.

Without `addCommonJS` the transpiler writes no imports at all, and a class
that extends anything cannot load.

## Today's workarounds

Both rewrite the output after the transpile:

- abap2UI5's `own-apps.mjs` copies the host's files out of the output folder
  and points their imports of anything else at
  `@abap2ui5/node-runtime/output/<file>`.
- abap2UI5/mcp-server's npm backend does the same for the dev apps it
  transpiles.

Both have to recognise the shapes of the imports the transpiler writes, and
must fail loudly when a new shape appears.

## A proposal

A `libs` entry that is read for the type check and not emitted, and whose
objects the emitted code imports from a module specifier:

```json
{
  "libs": [
    {
      "folder": "node_modules/@abap2ui5/node-runtime/downport",
      "emit": false,
      "import": "@abap2ui5/node-runtime/output/"
    }
  ]
}
```

With `"emit": false`, no file of that lib is written. With `"import"`, a
reference to one of its objects becomes
`await import("@abap2ui5/node-runtime/output/cx_static_check.clas.mjs")`
instead of `"./cx_static_check.clas.mjs"`. The generated `init.mjs` then
initialises only the emitted objects. Two names are only a suggestion: `emit`
could as well be implied by `import`.

## How to file

It is a feature request, not a bug. The realistic ask is an issue describing
the case and the proposal above; the output shape is the transpiler
maintainers' decision.

1. Search the abaplint/transpiler tracker first and record the date in `checked_upstream:`.
2. Open the issue with this body.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
