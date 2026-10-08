---
target: open-abap
title: 'runtime: REPLACE ... OF ... WITH reads the WITH text like a regex replacement - \{ \} \$ lose the backslash, $& and $$ are JS patterns'
summary: '`packages/runtime/src/statements/replace.ts` unescapes `\$`, `\{`, `\}` in the WITH text and passes it to `String.prototype.replace` as a pattern string for every REPLACE, also a literal `OF` one, where ABAP inserts the text unchanged; `REPLACE ALL OCCURRENCES OF ''{'' IN s WITH ''\{''` leaves `{`. The built-in `replace( sub = ... with = ... )` keeps the backslash but turns `$&` into the match and `$$` into `$` - the code is right on a system and wrong in the transpiled build'
priority: medium
state: open
first_seen: 2026-10-08
upstream: abaplint/transpiler
evidence:
  - found 2026-10-08 in abap2UI5-addons/admin-cockpit - `z2ui5_cl_cockpit_wire=>xml_escape` escaped braces for a UI5 attribute with `REPLACE ALL OCCURRENCES OF '{' IN result WITH '\{'`; a new unit test that pinned the escaped text failed under `npm run unit` (got `{`, expected `\{`) while the same code escaped correctly on a system. The test had been green before only because no test looked at a brace - meanwhile a double escape in the source broke the Screen popup on a real system unnoticed. Worked around with the built-in `replace( val = ... sub = ... with = ... occ = 0 )`, which keeps the backslash
  - measured on `@abaplint/runtime` 2.13.99, calling `abap.statements.replace` and `abap.builtin.replace` directly - the table below
  - the cause, read in abaplint/transpiler main 65b3da1 - `packages/runtime/src/statements/replace.ts` lines 62-72 (`rr = rr.replace(/\\\$/g, "$")`, the same for `\{` and `\}`) run for the `input.of` branch as well as for `regex`/`pcre`, and line 92 `temp.replace(search, rr)` hands `rr` to JS as a replacement pattern; `packages/runtime/src/builtin/replace.ts` passes `wi` to `val.replace(sub, wi)` the same way
  - no literal WITH text with `\{`, `\}`, `\$`, `$&`, `$$` or `$n` in a non-regex REPLACE in abap2UI5/src, sapgui, popups, abap-cloud-gui or admin-cockpit (scan 2026-10-08); `escape_js_string`'s `\'` and `\n` survive. A WITH operand that is a variable can still carry a `$` from data
checked_upstream: 2026-10-08
---

# runtime: REPLACE ... OF ... WITH reads its WITH text like a regex replacement

## What happens

```abap
DATA(lv) = `a{b`.
REPLACE ALL OCCURRENCES OF `{` IN lv WITH `\{`.
" system: a\{b
" @abaplint/runtime 2.13.99: a{b
```

| Statement / call | System | Runtime |
|---|---|---|
| `REPLACE ALL OCCURRENCES OF '{' IN 'a{b' WITH '\{'` | `a\{b` | `a{b` |
| `REPLACE ALL OCCURRENCES OF '}' IN 'a}b' WITH '\}'` | `a\}b` | `a}b` |
| `REPLACE ALL OCCURRENCES OF 'x' IN 'axb' WITH '\$'` | `a\$b` | `a$b` |
| `REPLACE ALL OCCURRENCES OF 'x' IN 'axb' WITH '$&'` | `a$&b` | `axb` |
| `REPLACE ALL OCCURRENCES OF 'x' IN 'axb' WITH '$$'` | `a$$b` | `a$b` |
| `REPLACE ALL OCCURRENCES OF '\' IN 'a\b' WITH '\\'` | `a\\b` | `a\\b` |
| `replace( val = 'a{b' sub = '{' with = '\{' occ = 0 )` | `a\{b` | `a\{b` |
| `replace( val = 'axb' sub = 'x' with = '$&' occ = 0 )` | `a$&b` | `axb` |
| `replace( val = 'axb' sub = 'x' with = '$$' occ = 0 )` | `a$$b` | `a$b` |

For `REPLACE ... OF` (a substring, not `REGEX`/`PCRE`) and for the built-in
`replace( )` with `sub`, ABAP inserts the WITH text as it is. Only a regex
replacement gives `$0`..`$9`, `$&`, `` $` ``, `$'` and the escapes `\$`, `\{`,
`\}` (and `\\`) a meaning.

## Why

- `packages/runtime/src/statements/replace.ts`: the WITH text `rr` is
  unescaped (`\$` → `$`, `\{` → `{`, `\}` → `}`) for every input, not only for
  `regex`/`pcre`, and then given to `temp.replace(search, rr)`, where JS reads
  `$&`, `$$`, `$1`, `` $` ``, `$'` as replacement patterns.
- `packages/runtime/src/builtin/replace.ts`: no unescaping, but the same
  `val.replace(sub, wi)` with `wi` as a pattern string, also when `sub` (a
  literal) was given.

## A fix

- `statements/replace.ts`: unescape only in the `regex`/`pcre` branch; in the
  `of` branch insert the text literally - `temp.replace(search, () => rr)`
  (a replacer function is never read as a pattern).
- `builtin/replace.ts`: the same replacer function when `sub` was given (and
  for `off`/`len`, which already concatenate). Keep the pattern string for
  `regex`/`pcre`, where `$1` is meant.
- `replacementLength` in the statement then is `rr.length` for the `of` case.

## Tests to add

The nine rows of the table above, plus a `REGEX` replacement that keeps
working: `REPLACE ALL OCCURRENCES OF REGEX '(b)' IN 'abc' WITH '[$1]'` gives
`a[b]c`, and `WITH '\$'` there still gives a literal `$`.

## How to file

An issue or a PR against abaplint/transpiler (`packages/runtime`). Record the
search in `checked_upstream:` (2026-10-08: the issue search "REPLACE
OCCURRENCES WITH backslash brace dollar replacement text literal" in
abaplint/transpiler, 2 results, neither about this - #635 an infinite loop,
#675 REPLACE with REGEX).
