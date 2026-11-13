---
target: open-abap
title: 'runtime: replace( val sub with occ = 1 ) replaces nothing - only occ = 0 and no occ at all are handled'
summary: 'The builtin `replace` of `@abaplint/runtime` has a branch for "no `occ`" (the first occurrence) and one for `occ = 0` (all of them); any other `occ` falls through both and the value comes back unchanged, without an error. ABAP replaces the n-th occurrence.'
priority: low
state: open
first_seen: 2026-11-14
upstream: abaplint/transpiler
evidence:
  - 'found 2026-11-14 in `z2ui5_cl_ui5_http_handler=>_http_get_bundle`: `replace( val = ... sub = c_bundle_node_path with = ... occ = 1 )` left the token in the bundle under `npm run unit` and `npm run express`, while abaplint and the transpile were green - `test_main_get_bundle` caught it'
  - 'the cause, read in the installed package - `node_modules/@abaplint/runtime/build/src/builtin/replace.js`: after the `off`/`len` branches come `else if (input.occ === undefined && sub && wi !== undefined)` and `else if (input.occ && position(input.occ) === 0 && sub && wi !== undefined)`, and nothing after them'
  - 'worked around by leaving `occ` out - the first occurrence is ABAP''s default; the comment at the call says why'
  - 'not searched upstream for an existing issue yet'
---

# runtime: replace( ... occ = 1 ) replaces nothing

## What happens

```abap
DATA(lv_text) = replace( val = `a-b-a` sub = `a` with = `x` occ = 1 ).
" ABAP:                x-b-a
" @abaplint/runtime:   a-b-a
```

`occ = 0` (every occurrence) and a call without `occ` (the first one) work;
every other value - `1`, `2`, `-1` - is not handled and the text is returned
as it was.

## Where it bit

`z2ui5_cl_ui5_http_handler=>_http_get_bundle` writes the request's path into
the tail of the frontend bundle. With `occ = 1` the served bundle still held
the token, so a proxy-prefixed host would have got no node path. The call
has no `occ` now.

## What would fix it

A branch for `occ > 0` (replace the n-th match) and `occ < 0` (counted from
the end) in `builtin/replace.js`, or at least an exception instead of an
unchanged value.
