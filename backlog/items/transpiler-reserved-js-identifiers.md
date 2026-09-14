---
target: open-abap
title: 'An ABAP name that is a reserved JS word should be renamed by the transpiler, not by a hand-kept list'
summary: an ABAP identifier called `with`, `class`, `delete`, … is emitted as-is and dies in strict mode — every consumer has to discover the word and add it to a config list first
priority: medium
state: open
first_seen: 2026-08-17
checked_upstream: 2026-09-14
patch: backlog/patches/transpiler-reserved-js-identifiers.patch
upstream: abaplint/transpiler
evidence:
  - abap2UI5 `e3d8889c` (#2351) — the importing parameter `with` of `c_replace_all` compiled to `let with = …` and took the unit job red
  - the fix had to be a config entry rather than a rename, because the parameter is public API
  - abap2UI5's `node/setup/abap_transpile.json` now carries seven such words (`return`, `in`, `class`, `for`, `delete`, `var`, `with`), each one discovered by a red build
  - 'read upstream 2026-09-14: the `keywords` OPTION is declared (`ITranspilerOptions`, packages/transpiler/src/types.ts:83, "list of keywords to rename, if not supplied default will be used") and NEVER READ - nothing in the transpiler or the CLI consumes it. The transpiler''s own test/keywords.ts passes `keywords: []` and its seven tests pass, which is only possible because the option is ignored. So abap2UI5''s seven-word list has never done anything; six of the seven happened to be in DEFAULT_KEYWORDS already, and `with`, the one that was not, has been a live defect the whole time'
  - 'the real defect is the SET: packages/transpiler/src/keywords.ts is a list copied from w3schools with `with` and `protected` commented out (no note saying why) and `case` never present. A patch adding the three, with tests, is attached - measured on the transpiler''s own suite: 2225 passing (2221 before), 127 failing unchanged (all of them the postgres tests, which need the docker stack)'
  - '`super` is the one reserved word that must NOT be added, and the suite says so at once: the emitter uses it (ABAP `super->method( )` becomes JS `super.method( )`), so adding it turns every redefined method into `$super is not defined` - four code_structure tests. Recorded in the patch where the next reader will look'
  - 'NOT PUSHED: this session has no write access to abaplint/transpiler (the Claude GitHub App is not installed on the abaplint org), so the change is parked here as a patch rather than opened as a pull request'
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

## What is actually there (read 2026-09-14)

Two findings, and the second is the one that matters.

**The `keywords` option is dead.** It is declared in `ITranspilerOptions`
(`packages/transpiler/src/types.ts`) as *"list of keywords to rename, if not
supplied default will be used"* and **nothing reads it** — not the transpiler,
not the CLI. The proof is in the transpiler's own `test/keywords.ts`, which
passes `keywords: []` and whose seven tests all pass: with replace semantics an
empty list would rename nothing and every one of them would fail. So
abap2UI5's seven-word list has never done anything at all. Six of the seven
were in the default set already; `with`, the one that was not, was a live
defect the whole time and the config entry that "fixed" it fixed nothing.

**The renaming itself already exists and is unconditional.**
`Traversal.prefixVariable` prefixes `$` onto any identifier in
`DEFAULT_KEYWORDS`, for locals, parameters and members alike — which is what
this item asked for. What is wrong is the SET: `packages/transpiler/src/keywords.ts`
is a list copied from w3schools' *"JavaScript Reserved Words"* page (which
mixes in Java's), with `with` and `protected` commented out — no note saying
why — and `case` never present.

## Proposed change

Complete the set, purely additively: `case`, `with`, `protected`. Nothing is
removed — the words in the list that are *not* reserved (`byte`, `final`,
`goto`, `synchronized`, …) stay, because renaming them is harmless while
removing one changes the emitted name for every consumer that has such an
identifier.

`super` is the one reserved word that must **not** be added: the emitter uses
it, ABAP's `super->method( )` becomes JS `super.method( )`, and adding the word
turns every redefined method into `$super is not defined` — four
`code_structure` tests fail the moment it goes in. The patch records that where
the next reader will look.

`protected` gets no test on purpose: it is reserved only in **strict** mode,
and the transpiler's harness runs emitted code as an `AsyncFunction` body,
which is sloppy — the test would pass with and without the fix, which is worse
than no test. It belongs in the set anyway, because the CLI writes ES
**modules** and a module is always strict.

The dead `keywords` option is a separate decision for the maintainer (wire it
as an addition to the defaults, or delete it), and the patch deliberately does
not take it.

## The patch

[`backlog/patches/transpiler-reserved-js-identifiers.patch`](../patches/transpiler-reserved-js-identifiers.patch)
— `git am` against `abaplint/transpiler`. Measured on that repository's own
suite:

```
npm run compile && mocha    2225 passing (2221 before), 127 failing unchanged
                            — all of them the postgres tests, which need the
                            docker stack
npx eslint                  clean
```

It is not open as a pull request because this session has no write access to
`abaplint/transpiler` (the Claude GitHub App is not installed on the `abaplint`
organization).

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
