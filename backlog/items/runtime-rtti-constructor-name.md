---
target: open-abap
title: 'runtime: RTTI and conversions dispatch on constructor.name - a minified bundle (keepNames off) describes an abap.types.String as whatever the minifier called it, and CONVT_NO_NUMBER follows'
summary: 'the runtime identifies its own types by `constructor.name` in places (DESCRIBE, RTTI kind, conversions), so any bundler that renames classes breaks type identification silently; every abap2UI5 browser build sets `keepNames: true` for that reason - a static `TYPE_NAME` (or a Symbol) on each `abap.types.*` class, used instead of the constructor name, would make the runtime bundler-safe'
priority: low
state: open
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5/playground `tools/build-framework.mjs:329-334` (2026-10): `keepNames: true` with the comment that `abap.types.String` ''collides with the global String on sight''; `docs/design/build-traps.md:44-50`: wrong DESCRIBE results that surfaced as `CONVT_NO_NUMBER` before the flag was set; the web build (abap2UI5/web-abap2UI5-build) carries the same flag'
  - 'read 2026-10-22 in abaplint/transpiler main 53a708f - `grep -rn "constructor.name" packages/runtime/src` finds the dispatch in the RTTI and conversion helpers'
checked_upstream: 2026-10-22
---

# runtime: do not identify types by `constructor.name`

## The problem

Parts of `@abaplint/runtime` and of the kernel code in open-abap-core
tell an `abap.types.Character` from a `String` or a `Packed` by
`value.constructor.name`. A bundler that minifies class names - the
default of esbuild, terser and webpack - renames them, and the runtime
then describes a string as a number or the other way round, which
surfaces far away as a conversion error. Every abap2UI5 browser build
turns `keepNames` on; a runtime that needs a bundler flag to be correct
is one trap per new host.

## Proposed change

A `static readonly TYPE_NAME = "String"` (or a shared `Symbol`) on every
class under `packages/runtime/src/types/`, and every `constructor.name`
read in the runtime and in open-abap-core's `@KERNEL` lines replaced by
it. `instanceof` where the module boundary allows it. A test that
minifies the runtime with esbuild (`minifyIdentifiers`) and runs the
RTTI suite would keep it that way.

## How to file

An issue against abaplint/transpiler listing the `constructor.name`
sites; the open-abap-core half follows.

