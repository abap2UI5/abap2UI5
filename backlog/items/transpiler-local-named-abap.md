---
target: open-abap
title: 'transpiler: a variable, parameter or field symbol named abap emits `let abap` and collides with the runtime global - SyntaxError or TDZ ReferenceError for the whole method'
summary: '`DATA abap TYPE i` becomes `let abap = …` in a scope where the generated code reads the `abap` global (`abap.types`, `abap.statements`); the module fails with `Identifier ''abap'' has already been declared` at top level or `Cannot access ''abap'' before initialization` in a method. Reserved JS words are escaped since #1840; `abap` is not, and samples-controls'' overview app was down a week for a local named `abap`'
priority: medium
state: open
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'measured 2026-10-22 on abaplint/transpiler main 53a708f with `runFiles`: `DATA x TYPE i. x = 1. DATA abap TYPE i. abap = x + 1. WRITE abap.` fails to load with `SyntaxError: Identifier ''abap'' has already been declared`'
  - 'samples-controls `scripts/lib/overview-emit.mjs:577-582` and `scripts/pattern-lint.mjs:328-331`, rule `runtime-global-shadow`: `DATA(abap)` in a method made every earlier `abap.` of the method a temporal-dead-zone read, HTTP 500 ''Cannot access ''abap'' before initialization''; the generated overview app was broken from 2026-09-15 to 2026-09-22 before the cause was found'
  - 'the precedent: abaplint/transpiler#1840 escapes every reserved JS word in identifiers (abap2UI5 `.claude/skills/abap-check/SKILL.md:1387-1396` - ''do not start a new list''); `abap` and the other names the generated code relies on (`INPUT`, `unique1…`, `temp1…` are prefixed already) are not in that set'
  - 'prepared 2026-10-22 as `oblomov-dev/fork-transpiler` branch `fix/identifier-named-abap` (41051a9) on abaplint/transpiler main 53a708f: the change plus tests, green in the package suites and the transpiler''s integration tests; the fourteen prepared branches merged together transpile open-abap-core main 239b817 and pass its whole unit suite (1172 tests).'
checked_upstream: 2026-10-22
---

# transpiler: an ABAP identifier named `abap` shadows the runtime

## What happens

```abap
DATA abap TYPE i.         " valid ABAP; `abap` is not a reserved word
abap = 1.
" transpiler main 53a708f:
"   top level: SyntaxError: Identifier 'abap' has already been declared
"   in a method: ReferenceError: Cannot access 'abap' before initialization
"   (every `abap.types…` above the declaration is in the temporal dead zone)
```

The generated code reaches the runtime through a free identifier `abap`.
A local of that name is legal ABAP, and it is not an exotic choice in a
framework whose every class starts with `abap`: samples-controls' generated
overview app carried `DATA(abap) = …` and served HTTP 500 for a week
(2026-09-15 to 09-22) until the method was found. The repository now has a
lint rule for it; a lint rule for a compiler's own name clash is the wrong
place.

## Proposed change

Treat `abap` like a reserved word in the identifier escaping that #1840
introduced (`keywords.ts` / `Traversal.prefixVariable`): an ABAP name
`abap` is emitted as `abap_` (or whatever the existing escape produces),
consistently in declarations, references, field-symbol names and
parameter objects (`INPUT.abap`). Alternatively bind the runtime to a name
no ABAP identifier can take (`$abap`), which is the larger change.

## Test

`test/statements/data.ts`: `DATA abap TYPE i. abap = 2. WRITE abap.` writes
`2`; the same as a method parameter and as a field symbol `<abap>`.

## How to file

An issue against abaplint/transpiler with the snippet and the week of
outage as the case.

