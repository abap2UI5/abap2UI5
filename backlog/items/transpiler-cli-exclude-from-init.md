---
target: open-abap
title: 'transpiler-cli: no way to keep an object out of init.mjs - test fixtures and generated frontend classes are stripped from the output by regex, or stubbed at bundle time'
summary: 'every transpiled object is imported and registered by `init.mjs` (and inserted into TADIR); a consumer that wants to type-check against an object but not boot it - abap2UI5''s Node-only test fixtures in the npm package, the playground''s 69 generated `z2ui5_cl_ui5f_*` classes (1.7 MB) - rewrites the generated `init.mjs` with regexes or stubs the modules in esbuild; an `exclude_from_init` (per object, pattern or folder) or a lazy registration would end both'
priority: medium
state: open
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5 `node/setup/pack-npm.mjs:233-266` (`stripFixtures`, 2026-10): strips `insert.push(…tadir…)` lines and imports of fixture objects out of the transpiler''s `init.mjs` by regex - ''Transpiler output, so the shape is not ours'' - and scans the tarball afterwards'
  - 'abap2UI5/playground `tools/esbuild-plugins.mjs:203-255` stubs the 69 `z2ui5_cl_ui5f_*` classes at bundle time because the CLI cannot leave them out of `init.mjs`; `docs/design/build-traps.md:78-81`: ''init.mjs loads every object. Tree shaking is impossible as long as ABAP resolves classes dynamically'''
  - 'read 2026-10-22 in abaplint/transpiler main 53a708f - `packages/cli/src/types.ts`: `exclude_filter` drops an object from the *input* (then it is unknown to the type check); nothing distinguishes ''compile'' from ''boot'''
checked_upstream: 2026-10-22
---

# transpiler-cli: compile an object without booting it

## The problem

Two different hosts rewrite the generated `init.mjs`:

- abap2UI5's npm package carries Node-only test fixtures the framework's
  unit suite needs; they must be compiled (the tests reference them) but
  must not be registered in a consumer's runtime. `pack-npm.mjs`
  regex-strips their `import` and TADIR `insert.push` lines.
- the playground bundles the framework for the browser; 69 generated
  `z2ui5_cl_ui5f_*` classes (the webapp mirror, 1.7 MB) are never
  called there. esbuild stubs the modules, because `init.mjs` imports them
  all.

`exclude_filter` is not it: it removes the object from the input and the
type check fails on every reference.

## Proposed change

```json
"exclude_from_init": ["^zcl_fixture_", "z2ui5_cl_ui5f_.*"]
```

Matching objects are transpiled and written like any other, but
`init.mjs` neither imports nor registers them and TADIR gets no row.
A host that wants one later imports its module, which registers itself
(the modules already do `abap.Classes[…] = …` on load).

A larger variant, worth its own discussion: lazy registration - `init.mjs`
registers a loader per class and `abap.Classes` resolves on first access
- would make the bundle size follow use instead of the corpus.

## How to file

An issue against abaplint/transpiler with both hosts' rewrites.

