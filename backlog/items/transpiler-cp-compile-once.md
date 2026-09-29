---
target: open-abap
title: 'CP compiles its pattern on every call, and a trailing * makes it walk the rest of the string - the open-abap XML parser pays that per token'
summary: cp( ) builds a new RegExp per call and turns a trailing * into [\s\S]*$, so `lv_xml CP '<*'` walks the whole rest of the string; open-abap's cl_ixml parser asks that once per token with the rest of the document, and reading a document costs the square of its length. Dropping the trailing run of * and caching the compiled pattern changes no answer. @abap2ui5/node-runtime ships it as a runtime patch meanwhile; the upstream change is attached as a patch
priority: low
state: open
first_seen: 2026-09-29
patch: backlog/patches/transpiler-cp-compile-once.patch
upstream: abaplint/transpiler
evidence:
  - measured 2026-09-29 - CPU profiles of an abap2UI5 roundtrip with a large table put the second hot spot, after the LOOP of [transpiler-loop-sorted-primary-key](transpiler-loop-sorted-primary-key.md), in `compare/cp.ts`, called from open-abap-core's `cl_ixml` (`if_ixml_parser~parse`) reading the draft; the two changes together took the event roundtrip of 2000 rows from 22.6 s to 1.8 s in a CAP project
  - abap2UI5's unit suite alone scans ~2.5 GB of text through these patterns
  - the runtime patch (`accelerate()` of @abap2ui5/node-runtime, abap2UI5#2813) was compared call for call with the original on 30 000 seeded cases per run - Unicode incl. astral and lone surrogates, Kelvin sign and long s under `iu`, trailing blanks of c operands, `#` escapes incl. `#*`, `##` and a trailing `#`, `+`, runs of `*` - and six deliberate mutations each turn that test red
  - unchanged at abaplint/transpiler main 916d00f (2026-09-29); the attached patch passes the non-database test sets (2286 tests, one new CP test that passes before and after - the answers do not change) and eslint
---

# CP: compile a pattern once, and let a trailing * end the match

## The problem

`cp( )` (`packages/runtime/src/compare/cp.ts`) builds
`new RegExp("^" + pattern + "$", "iu")` on every call, and a trailing `*`
becomes `[\s\S]*$`. The engine then walks the whole rest of the string to
confirm what the characters before the `*` already decided.

open-abap's XML parser (`cl_ixml`, `if_ixml_parser~parse`) asks
`lv_xml CP '<*'` (and `'<?*'`, `'<!--*'`, `'<![CDATA[*'`, `'<!DOCTYPE*'`,
`'</*'`) once per token, with `lv_xml` the *rest* of the document. Every token
walks the remaining XML, so reading a document costs the square of its length.
abap2UI5 keeps each app's state (the draft) as such a document.

## The change

- **The trailing `*` goes.** `^X[\s\S]*$` matches exactly the strings `^X`
  matches, so a trailing run of `*` and the `$` anchor are dropped, and `^<`
  decides `lv_xml CP '<*'` at the first character.
- **The compiled pattern is cached.** A pattern string compiles to the same
  RegExp every time, so it is kept per pattern string, at most 1000 of them.
- **`reg.test( l )` replaces `l.match( reg ) !== null`.** The two are the
  same for a regex without `g`/`y`.
- **Case folding is unchanged.** The flags stay `iu`, and dropping `$` does
  not change what they match.
- **`np( )` and a range row with option CP** get the change through `cp( )`.

Attached as
[`backlog/patches/transpiler-cp-compile-once.patch`](../patches/transpiler-cp-compile-once.patch)
(`git am --keep-cr` against 916d00f). The new test in `test/operators/cp.ts`
pins the answers for the XML patterns, escapes, case, `**` and the empty
string. It passes before and after, because the answers do not change. The
non-database test sets pass (2286 tests), and eslint is clean.

## How to file

1. Search the abaplint/transpiler tracker first and record the date in `checked_upstream:`.
2. Open a PR with the patch and this body. Link [transpiler-loop-sorted-primary-key](transpiler-loop-sorted-primary-key.md), since the measurements are for both.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
