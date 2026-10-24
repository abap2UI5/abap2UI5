---
target: open-abap
title: 'String templates: ALPHA = IN ignores WIDTH - `|{ `100` ALPHA = IN WIDTH = 4 }|` is `100 `, not `0100`'
summary: '`alphaIn( )` of @abaplint/runtime takes the length to fill with leading zeros from the data object only (a Character, or alphaInContext); a string - or a value longer than its field - gets no zeros, and WIDTH afterwards pads to the right, so `|{ `100` ALPHA = IN WIDTH = 4 }|` answers `100 ` where ABAP answers `0100`'
priority: medium
state: open
first_seen: 2026-10-24
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5-addons/abap-cloud-gui - the report runtime normalized a screen number with `|{ dynnr ALPHA = IN WIDTH = 4 }|` (CALL SCREEN 100 is screen 0100); its transpiled ABAP Unit run answered `100 ` and the test failed. The runtime now moves the number into an `n LENGTH 4` instead'
  - 'read 2026-10-24 in @abaplint/runtime 2.14.5 - `build/src/alpha.js` `alphaIn( source, context )`: length 0 for a String source without a Character context, `txt.padStart( length, "0" )`; `build/src/template_formatting.js` calls it with `options.alphaInContext` only, `options.width` is applied after it as the padding of the text'
---

# String templates: ALPHA = IN ignores WIDTH

## What happens

```abap
DATA(lv_dynnr) = |{ `100` ALPHA = IN WIDTH = 4 }|.
" ABAP: lv_dynnr = `0100`
" transpiled: lv_dynnr = `100 `
```

ABAP's `ALPHA = IN` fills a numeric text with leading zeros up to the length
of the target - and with `WIDTH` that length is the width: the keyword
documentation of embedded expressions, *ALPHA*: "If WIDTH is specified, the
length is determined by WIDTH". The runtime's `alphaIn( )`
(`build/src/alpha.js`) takes the length from the data object only:

```js
let length = 0;
if (context instanceof types_1.String && source instanceof types_1.String) return txt;
else if (context instanceof types_1.Character) length = context.getLength();
else if (source instanceof types_1.Character) length = source.getLength();
txt = txt.trimEnd();
return txt.padStart(length, "0");
```

`templateFormatting( )` calls it with `options.alphaInContext` and applies
`options.width` afterwards, as the padding of a text - to the right. A string
or a literal therefore gets no zeros at all, and a `c` field gets the zeros of
its own length, not of the width.

## The change

In `templateFormatting( )`, when `alpha === "in"` and `width` is given, use the
width as the length `alphaIn( )` pads to (and leave the width padding out for
that case, since the text already has it).

## Example

```abap
cl_abap_unit_assert=>assert_equals( act = |{ `100` ALPHA = IN WIDTH = 4 }|  exp = `0100` ).
cl_abap_unit_assert=>assert_equals( act = |{ `ABC` ALPHA = IN WIDTH = 6 }|  exp = `ABC   ` ). " no digits: as it is, then WIDTH
```
