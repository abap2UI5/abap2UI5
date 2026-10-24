---
target: abaplint
title: 'check_syntax: offset/length access on a numeric variable (`lv_int+1(2) = ...`) passes'
summary: 'offset and length specifications are allowed only on character-like and byte-like data (c, n, d, t, string, x, xstring); check_syntax accepts them on an i, p or f variable on every version, read and write, and the transpiled runtime fails at the first such access'
priority: medium
state: open
first_seen: 2026-10-24
upstream: abaplint/abaplint
evidence:
  - 'found 2026-10-24 writing a corpus report of abap2UI5-addons/abap-cloud-gui (report2cloud) - `DATA(lv_next) = lv_first + 31.` (an inline declaration of date arithmetic, typed as a number) followed by `lv_next+6(2) = ''01''.`; abaplint reported nothing, the transpiled runtime failed with "TypeError: old.substr is not a function at OffsetLength.set" (@abaplint/runtime 2.14.5)'
  - 'probed 2026-10-24 with @abaplint/core 2.120.75 - a method with `DATA lv_int TYPE i.` and `lv_int+1(2) = ''01''.`: no issue with check_syntax on for the versions v758, v750 and Cloud'
  - 'ABAP keyword documentation, offset and length specifications (data objects): allowed for flat character-like and byte-like data objects; for other types the specification is a syntax error'
---

# check_syntax: offset/length access on a numeric variable passes

```abap
DATA lv_int TYPE i.
lv_int+1(2) = '01'.            " does not activate - i is no character-like type

DATA(lv_next) = lv_day + 31.   " lv_day TYPE d: lv_next is a number
lv_next+6(2) = '01'.           " does not activate either
```

An offset or length (`+off(len)`) may stand on a flat character-like or
byte-like data object: `c`, `n`, `d`, `t`, `string`, `x`, `xstring`, or a
structure that is character-like as a whole. On `i`, `int8`, `p`,
`decfloat16/34` or `f`, it is a syntax error. `check_syntax` accepts it
on every version, for reading (`WRITE lv_int+1(2)`) and for writing.

The second shape is the one that occurs in code: date arithmetic declared
inline is a number, not a date (see `abaplint-inline-date-arithmetic-type`),
so the next offset access on the "date" is an offset access on a number.

**Proposal.** In `check_syntax`, report an offset or length on a target or
source whose type is numeric (`IntegerType`, `Integer8Type`, `PackedType`,
`DecFloat*Type`, `FloatType`).

**Not reported.** `d`, `t`, `n`, `c`, `string`, `x`, `xstring`, a
character-like structure, a field symbol or a generic parameter whose type
is not known.

**Where.** an extension of `check_syntax`. **Effort:** S.

**Source.** ABAP keyword documentation (offset/length specifications).
