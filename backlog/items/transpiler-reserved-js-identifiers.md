---
target: open-abap
title: 'An ABAP name that is a reserved JS word should be renamed by the transpiler, not by a hand-kept list'
summary: an ABAP identifier called `with`, `class`, `delete`, … is emitted as-is and dies in strict mode — every consumer has to discover the word and add it to a config list first
priority: medium
state: open
first_seen: 2026-08-17
upstream: abaplint/transpiler
evidence:
  - abap2UI5 `e3d8889c` (#2351) — the importing parameter `with` of `c_replace_all` compiled to `let with = …` and took the unit job red
  - the fix had to be a config entry rather than a rename, because the parameter is public API
  - abap2UI5's `node/setup/abap_transpile.json` now carries seven such words (`return`, `in`, `class`, `for`, `delete`, `var`, `with`), each one discovered by a red build
---

# An ABAP name that is a reserved JS word should be renamed by the transpiler

## What happens

An ABAP identifier is emitted into the generated JavaScript under its own name.
Where that name is a reserved word, the emitted module is not valid JS:

```abap
METHODS c_replace_all
  IMPORTING with TYPE string.
```

```js
let with = INPUT.with;   // SyntaxError in strict mode
```

The transpiler has a `keywords` option that renames the listed words, and that
is the whole mitigation today. abap2UI5's list is seven words long and every
entry was added after a build went red:

```json
"keywords": ["return", "in", "class", "for", "delete", "var", "with"]
```

## Why the list is the wrong shape

The set of reserved JavaScript words is **known to the transpiler** and fixed
by the language spec. Nothing about a given project decides which of them are
dangerous, so the list carries no project-specific information — it is a record
of which words that project has happened to trip over so far. A word not yet
tripped over is a latent red build in every consuming repository at once, and
it surfaces as a `SyntaxError` in generated code rather than as anything
pointing at the ABAP name that caused it.

The workaround also pushes the cost onto the wrong side. Renaming the ABAP is
usually not available: `with` here is a **public parameter of a released
interface**, so bending the ABAP API to suit the code generator would be a
breaking change for every caller in every system.

## Proposed change

Rename reserved words during emission, unconditionally: mangle any identifier
whose emitted name would collide with a JS reserved word (a fixed suffix is
enough — `with_`, `class_`), for locals, parameters and members alike. The
`keywords` option then has nothing left to do and can keep working as an
override for anything a project wants renamed for its own reasons.

The reserved set is `ReservedWord` and `FutureReservedWord` from the ECMAScript
grammar plus the strict-mode additions (`implements`, `interface`, `let`,
`package`, `private`, `protected`, `public`, `static`, `yield`) — all of which
are ordinary, likely ABAP identifiers.

## Example

```abap
DATA class TYPE string.
DATA with  TYPE string.
class = `a`.
with  = `b`.
```

Today this needs both words configured before it compiles at all; the request
is that it simply compiles.

<!-- probe:start — written by `npm run backlog:probe`, do not edit by hand -->

## Measured

`transpiler-reserved-js-identifiers.probe.mjs` — an ABAP declaration named after a reserved JavaScript word, with the seven abap2UI5 already configures as the negatives.
Run **2026-08-17** against `abap2UI5`, `samples`, `samples-controls`, `samples-stack`.

**Would fire on 1 site(s)** in 1 repository:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/99/01/z2ui5_cl_util.clas.abap`:885 | `new` — new           TYPE any |

**Must NOT fire on 7 site(s)** that match the shape and are correct:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.abap`:1919 | `class` — DATA class    TYPE REF TO data. |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3237 | `delete` — delete                 TYPE clike OPTIONAL |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7486 | `for` — for                           TYPE clike OPTIONAL |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8805 | `var` — var           TYPE clike OPTIONAL |
| samples | `src/z2ui5_cl_smp_app_000.clas.abap`:134 | `class` — class       TYPE string OPTIONAL |
| samples-controls | `src/z2ui5_cl_smpc_app_overview.clas.abap`:216 | `class` — class       TYPE string OPTIONAL |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:162 | `class` — class       TYPE string OPTIONAL |

**Where the detector is an approximation of the rule:**

- One row per reserved word per repository, not per occurrence: the question is which words this code base uses, and every occurrence of one shares its fate.
- Only local data, field symbols and method parameters are counted. A constant or a structure component becomes an object KEY, where a reserved word is legal JavaScript — the corpus transpiles green today with `enum`, `false`, `null` and `default` as component names, which is why counting them would have inflated this by a factor of three.
- Only declarations with an explicit `TYPE`/`LIKE` on one line are matched. Inline `DATA(x)` and parameters split across lines are missed, so this is a floor.
- The negatives are the words already listed in `node/setup/abap_transpile.json` — code that compiles only because somebody was bitten first. They are the argument, not an exception.

<!-- probe:end -->
