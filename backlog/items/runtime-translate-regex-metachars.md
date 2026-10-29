---
target: open-abap
title: 'runtime: translate( from = '']'' ) builds an unescaped JS character class - ] [ ^ - \ in FROM are not translated (or throw)'
summary: '`builtin/translate.ts` builds `new RegExp("[" + from + "]", "g")` from the FROM text as it stands, so a `]` closes the class early, `[` opens a nested one, `-` is a range and `\` an escape; `translate( val = ''a]b'' from = '']'' to = ''x'' )` answers `a]b` where a system answers `axb`'
priority: medium
state: filed
filed: https://github.com/abaplint/transpiler/pull/2016
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'measured 2026-10-22 on abaplint/transpiler main 53a708f (runtime 2.14.10) with `runFiles`: `s = translate( val = ''a]b[c'' from = '']'' to = ''x'' ).` writes `a]b[c` (a system: `axb[c`)'
  - 'the cause, read in the same checkout - `packages/runtime/src/builtin/translate.ts:33-34`: `const reg = new RegExp("[" + from + "]", "g"); val = val.replace(reg, m => chars[m] || "")`'
  - 'samples-controls `src/02/01/z2ui5_cl_smpc_app_651.clas.abap:195-197` (2026-10-20): three `replace( … occ = 0 )` calls instead of `translate( from = `[]"` to = `` )` because the transpiled `translate( )` reads FROM as a regex class; `.claude/skills/e2e-debugging/SKILL.md:205-206`'
  - 'prepared 2026-10-22 as `oblomov-dev/fork-transpiler` branch `fix/translate-no-regex` (e4ee2af) on abaplint/transpiler main 53a708f: the change plus tests, green in the package suites and the transpiler''s integration tests; the fourteen prepared branches merged together transpile open-abap-core main 239b817 and pass its whole unit suite (1172 tests); abap2UI5 itself, downported and transpiled with that stack (`node/setup/abap_transpile.json`, open-abap-core pinned at 9c1271b with the compare_tables correction), passes `npm run unit` in full (1558 tests).'
  - 'filed 2026-10-22 as abaplint/transpiler#2016, merged 2026-10-23 into main, unchanged; it ships with the next @abaplint/runtime release (2.14.11, abaplint/transpiler#2011 pending on 2026-10-23) - bump the pin in abap2UI5 then and delete this item'
checked_upstream: 2026-10-23
---

# runtime: `translate( )` reads FROM as a regex class

## What happens

```abap
DATA s TYPE string VALUE 'a]b[c'.
s = translate( val = s from = ']' to = 'x' ).
" system: axb[c      runtime 2.14.10: a]b[c
s = translate( val = s from = '[' to = 'x' ).     " SyntaxError from new RegExp
```

`packages/runtime/src/builtin/translate.ts` turns the FROM characters into
`new RegExp("[" + from + "]", "g")` without escaping them. `]` ends the
class early, `[` nests one, `a-z` becomes a range, `\` escapes the next
character, `^` in the first position negates. `translate` takes
characters, never a pattern.

## Proposed change

No regex: walk the string once and map each character through the
FROM/TO table (`Map<char, char>`), which is also what the `TRANSLATE`
statement in `statements/translate.ts` should share. If a regex is kept,
escape FROM with `replace(/[\]\[\\^-]/g, "\\$&")`.

## Test

`translate( val = 'a]b[c-d\\e^' from = ']' to = 'x' )`, and the same
for `[`, `-`, `\`, `^`; plus the existing cases.

## How to file

A PR against abaplint/transpiler; one function.

