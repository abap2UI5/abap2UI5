---
target: open-abap
title: 'runtime: POSIX classes other than punct, digit, space and ^print are passed to JS unchanged - [[:cntrl:]] and [[:alpha:]] match nothing'
summary: '`abap_regex.ts` `convert( )` rewrites `[[:punct:]]`, `[^[:print:]]`, `[[:digit:]]` and `[[:space:]]` and leaves every other POSIX class as JS sees it - a character class of the letters `[`, `:`, `c`, `n`, … - so `REPLACE ALL OCCURRENCES OF REGEX ''[[:cntrl:]]''` leaves every control character in place and abap2UI5 replaces per character instead'
priority: medium
state: open
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'measured 2026-10-22 on abaplint/transpiler main 53a708f (runtime 2.14.10) with `runFiles`: `s = ''a'' && |\n| && ''b'' && |\t| && ''c''. REPLACE ALL OCCURRENCES OF REGEX ''[[:cntrl:]]'' IN s WITH ''''.` leaves `a\nb\tc`; `REPLACE ALL OCCURRENCES OF REGEX ''[[:alpha:]]'' IN ''ab12cd'' WITH ''X''` leaves `ab12cd`'
  - 'the cause, read in the same checkout - `packages/runtime/src/abap_regex.ts` `convert( )`: four replacements (`[[:punct:]]`, `[^[:print:]]`, `[[:digit:]]`, `[[:space:]]`, the last one only its first occurrence), nothing for `alpha alnum upper lower xdigit cntrl print graph blank word`'
  - 'abap2UI5 `src/00/03/z2ui5_cl_ui5_util_context.clas.abap:3197-3199`: ''one replace per character, no regex: [[:cntrl:]] is not a class every runtime … knows (the transpiled one left every byte in place)''; `:3235-3236` a `CO` plus a character loop instead of a regex because ''the transpiled runtime knows no character classes'''
checked_upstream: 2026-10-22
---

# runtime: most POSIX character classes are not translated

## What happens

```abap
DATA s TYPE string.
s = 'a' && |\n| && 'b'.
REPLACE ALL OCCURRENCES OF REGEX '[[:cntrl:]]' IN s WITH ''.
" system: ab      runtime 2.14.10: a\nb  (the class became [[:cntrl:]] in JS,
"                                        the letters c n t r l and a colon)
REPLACE ALL OCCURRENCES OF REGEX '[[:alpha:]]' IN s WITH 'X'.   " nothing replaced
```

ABAP's POSIX regex takes the bracket classes; JavaScript does not.
`packages/runtime/src/abap_regex.ts` `convert( )` maps four of them and
passes the rest through, where `[[:cntrl:]]` reads as a plain character
class followed by a literal `]`. No error, no match - a silent
difference, which is the worst kind: abap2UI5 found it with control
characters left in a JSON string.

## Proposed change

In `convert( )`, one table for all classes, applied inside bracket
expressions (so `[^[:alpha:][:digit:]]` works too) and globally, not
only the first occurrence:

| class | JS |
|---|---|
| alpha | `a-zA-Z` (`\p{L}` with the `u` flag) |
| alnum | `a-zA-Z0-9` |
| upper / lower | `A-Z` / `a-z` |
| digit | `0-9` |
| xdigit | `0-9A-Fa-f` |
| space | `\s` |
| blank | ` \t` |
| cntrl | `\x00-\x1F\x7F` |
| print / graph | `\x20-\x7E` / `\x21-\x7E` |
| punct | the existing list |
| word | `\w` |

A class name the table does not know should throw `CX_SY_REGEX` rather
than pass through.

## Test

`test/builtin/*` or `test/statements/replace.ts`: the two snippets, plus
`[^[:alpha:]]` and a negative class inside a longer bracket expression.

## How to file

An issue or PR against abaplint/transpiler; the change is the table in
`abap_regex.ts`.

