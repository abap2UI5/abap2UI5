---
target: abaplint
title: 'check_syntax: PRIVATE/PROTECTED attributes and constants of another class'
summary: reading or writing a PRIVATE or PROTECTED attribute or constant of another class (no friend, no subclass) is refused by a system - "Access to private attribute ... is not allowed", "Field ... is unknown"; abaplint checks the visibility of methods but not of attributes
priority: high
state: filed
filed: https://github.com/abaplint/abaplint/pull/4362
first_seen: 2026-10-03
upstream: abaplint/abaplint
evidence:
  - abap2UI5#2783 - `Field "MV_SESSION_STICKY" is unknown` four times on a user's system (2026-09-23), a PRIVATE attribute of `z2ui5_cl_ui5_handler` used by two other classes; abap2UI5#2146 and #2507 - test classes without LOCAL FRIENDS
  - gated in abap2UI5 since then by `npm run check:members` and `npm run check_visibility`
  - measured 2026-10-03 on abaplint main 506e7b9 - no finding for a private or protected attribute, static or instance, read or write; the method control is reported
  - measured 2026-10-03 on a real system (S/4HANA, release 758, ADT) - `lo->mv_priv` is "Access to private attribute "MV_PRIV" is not allowed.", a protected static attribute and a private constant are refused the same way
  - filed 2026-10-03 as abaplint/abaplint#4362 - the visibility check of methods moves to ObjectOriented and also runs in AttributeName; 15 tests (9 errors, 6 ok), 0 new findings over abap2UI5 and samples-controls, 4 in open-abap-core where its own comment says "this should give syntax error, as they are not friends"
---

# check_syntax: PRIVATE/PROTECTED attributes of another class

## What happens

```abap
" zcl_action, reading a PRIVATE attribute of zcl_handler
DATA(lv) = zcl_handler=>mv_session_sticky.   " system: Field "MV_SESSION_STICKY" is unknown
```

`check_syntax` reports `Method "x" is private and cannot be accessed` for a
method, but resolves an attribute or constant without looking at its
visibility. The transpiler makes every member a plain JS property, so the
transpiled unit run is green as well.

## What it must NOT report

- the owning class itself, also on another instance of it
- friends and local friends, also through a super class
- PROTECTED members from a subclass
- public `READ-ONLY` attributes, interface attributes

## How it is filed

abaplint/abaplint#4362 runs the method visibility check for every attribute
and constant `AttributeName` resolves, instance and static, read and write.
