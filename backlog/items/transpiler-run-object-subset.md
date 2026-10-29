---
target: open-abap
title: 'transpiler: run( ) always transpiles the whole registry - a host that type-checks one object against 700 cannot ask for that one object, so the playground hides the rest behind a Proxy on IRegistry'
summary: '`Transpiler.run(reg)` iterates `reg.getObjects()` and emits every object; an editor that holds the framework and open-abap-core in the registry for the type check (684 objects, 18 s measured) and wants the JS of the user''s file only has no option for it - the playground wraps the registry in a `Proxy` that answers `getObjects` with the user''s objects, and the transpiler''s maintainer suggested the same shape on #1999 (''only these objects, against the full registry'')'
priority: high
state: open
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5/playground `src/editor/transpile-core.mjs:4-13` and `:28-37` (2026-10): ''the transpiler is handed a view of the registry in which those are the only objects there are'' - `new Proxy(reg, { get(...) { if (prop === "getObjects") return () => objects; …`; `docs/design/build-traps.md:208-218`: a full `run( )` over the corpus is ''684 objects, **18 seconds**. Useless behind a Run button'''
  - 'read 2026-10-22 in abaplint/transpiler main 53a708f - `packages/transpiler/src/index.ts:72`: `for (const obj of reg.getObjects())`, no filter; `ITranspilerOptions` has no object list'
  - 'the maintainer''s own framing, 2026-10-14 on abaplint/transpiler#1999 (closed): compile the full thing always; abap2UI5 recorded in `backlog/items/transpiler-cli-library-second-copy.md` that ''what could make one transpile of everything fast for an edit loop is a transpiler option "only these objects, against the full registry"'' - this is that option, for the API rather than the CLI'
  - 'abap2UI5/mcp-server `lib/npm-backend.mjs:47-66`: ''737 objects for one app class, measured'' for the CLI path; the full re-transpile after #1999 takes about 16 s per edit (`CHANGELOG.md:24-37`)'
checked_upstream: 2026-10-22
---

# transpiler: `run( )` with an object subset

## The problem

An interactive host (the abap2UI5 playground, the MCP server's edit loop,
a VS Code "run this class") keeps the framework and open-abap-core in the
abaplint registry so the user's code is checked against real types, and
wants the JavaScript of the user's objects only. `Transpiler.run(reg)`
has one mode: every object of the registry
(`packages/transpiler/src/index.ts:72`, `for (const obj of
reg.getObjects())`). Over the abap2UI5 corpus that is 684 objects and
18 seconds per keystroke.

The playground's workaround is a `Proxy` over `IRegistry` whose
`getObjects( )` lies (`src/editor/transpile-core.mjs:28-37`). It works
because the transpiler reads the object list through that one method
and resolves types through the scope, which still sees everything; it
depends on that staying true, and on `this` binding inside the registry.

## Proposed change

```ts
interface ITranspilerOptions {
  /** emit only these objects; the registry is still the whole one for the type check */
  objects?: abaplint.IObject[] | ((obj: abaplint.IObject) => boolean);
}
```

`run( )` validates the whole registry as today (or, better, only the
issues of the selected objects, since the rest was validated when it was
loaded) and loops over the selection. `databaseSetup` and the `requires`
of each chunk come out as today, so the host can order and load the
chunks. The CLI gains the same through `input_folder` vs `libs` later;
this item is the API.

## Test

`test/running_examples.ts` or a new `test/options.ts`: two objects in the
registry, `objects: [one]`, expect one chunk, and a type error in the
other object still reported (or not, documented either way).

## How to file

An issue against abaplint/transpiler; cite the Proxy and the 18 s.

