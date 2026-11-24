---
target: abaplint
title: 'check_syntax: a dynamic attribute on a REF TO object is reported as "Not an object reference"'
summary: 'mo_app->(''MV_FLAG'') = abap_true. and IF mo_app->(''...'') = abap_true. on a generic object reference activate on the system; check_syntax reports "Not an object reference, target" / "field chain" - ASSIGN and CALL METHOD of the same shape pass'
priority: high
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'oblomov-dev/s5s_dev 80891c9: /KRO/UI501_CL_APP_007 and /KRO/UI501_CL_APP_000 write and read attributes of the calling app through mo_app TYPE REF TO object, mo_app->(''/KRO/UI501_IF_000~MV_VIEW_DISPLAY'') - the classes activate on an S/4HANA EWM system (2026-11-24); abaplint reports them, and they are among the 16 files abaplint.jsonc excludes from check_syntax as a whole, which hides every real syntax error in them'
  - 'probed 2026-11-24 against abaplint 2.120.116, every rule on from `abaplint --default`, open-abap-core as dependency, an isolated project with a control finding firing: DATA mo_app TYPE REF TO object. - mo_app->(''MV_FLAG'') = abap_true. reports "Not an object reference, target (check_syntax)", IF mo_app->(''/KRO/UI501_IF_000~MV_VIEW_DISPLAY'') = abap_true. reports "Not an object reference, field chain (check_syntax)"; ASSIGN mo_app->(''MV_FLAG'') TO FIELD-SYMBOL(<flag>). and CALL METHOD mo_app->(''RUN''). are not reported'
---

# check_syntax: a dynamic attribute on a REF TO object is reported as "Not an object reference"

```abap
DATA mo_app TYPE REF TO object.

mo_app->('MV_FLAG') = abap_true.                              " Not an object reference, target
IF mo_app->('/KRO/UI501_IF_000~MV_VIEW_DISPLAY') = abap_true.  " Not an object reference, field chain
ENDIF.

ASSIGN mo_app->('MV_FLAG') TO FIELD-SYMBOL(<flag>).            " not reported
CALL METHOD mo_app->('RUN').                                   " not reported
```

A dynamic component after `->` on a generic object reference is valid ABAP -
the attribute is resolved at runtime, and the system activates the class
(`CX_SY_ASSIGN_ILLEGAL_COMPONENT` / a dump if it does not exist). The
`ASSIGN` and `CALL METHOD` forms of the same access pass `check_syntax`; the
direct write and read do not.

**Current behaviour.** `5_syntax/expressions/target.ts` and
`5_syntax/expressions/field_chain.ts`, at an `InstanceArrow`: the context must
be an `ObjectReferenceType`, a `DataReference` or a `VoidType`. `REF TO object`
is a `GenericObjectReferenceType`, so the arrow is reported before the dynamic
component is looked at.

**Proposal.** At the `InstanceArrow`, accept a `GenericObjectReferenceType`
when the component after it is dynamic (`ComponentName` in parentheses, a
`Dynamic` expression), and give the result a `VoidType` / `AnyType` - its type
is only known at runtime. A static component name after `->` on `REF TO object`
stays an error (the system refuses it: `object` has no attributes).

**Not reported.** A dynamic component on any reference, typed or generic.
**Still reported:** a static attribute name on `REF TO object`; an arrow on a
variable that is not a reference at all.

**Where.** `check_syntax` - `target.ts` and `field_chain.ts`. **Effort:** S.

**Cost of the false positive.** `check_syntax` has no per-statement suppression
that survives every release, so a consumer excludes the whole file - in S5S
this shape is part of why 16 files are excluded from `check_syntax`, i.e. no
syntax check at all.

**Source.** S5S (a consumer system), linted against the system's own
activation the same day.

A PR is being prepared from oblomov-dev/fork-abaplint.

Related upstream: abaplint/abaplint#2773 (closed - "Not a object reference" on `CLEAR r->*`, a typo and a different shape).
