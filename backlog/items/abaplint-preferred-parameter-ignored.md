---
target: abaplint
title: 'Report a `PREFERRED PARAMETER` the compiler ignores, and stop treating it as OPTIONAL'
summary: the addition does nothing unless every IMPORTING parameter is optional — ABAP warns and abaplint says nothing, while its syntax check goes the other way and accepts a call that omits the mandatory parameter
priority: medium
state: open
first_seen: 2026-09-05
checked_upstream: 2026-09-05
upstream: abaplint/abaplint
evidence:
  - abap2UI5 `z2ui5_cl_ui5_util_context=>msg_get_internal` — a user's system reported the warning on 2026-09-05, hours after #2719 added the addition that morning to a signature whose first parameter is mandatory; `npx abaplint` was green over that file (0 issues, 264 files, 2.120.38, `check_syntax` on)
  - abaplint#2841 ("Syntax issue using PREFERRED PARAMETER") shows the misunderstanding the rule would end — the reporter took the addition to make a parameter optional, which is what it does only when every input parameter already is
  - measured 2026-09-05 on 2.120.38, isolated two-file project: the declaration with the ignored addition plus a call that omits the mandatory parameter is accepted; deleting the addition alone turns the same call into `method parameter "VAL" must be supplied`
---

# Report a `PREFERRED PARAMETER` the compiler ignores

> **Upstream check 2026-09-05: no rule is asked for.** The three items that
> mention the addition are parser and syntax fixes —
> [abaplint#2841](https://github.com/abaplint/abaplint/issues/2841) *"Syntax
> issue using PREFERRED PARAMETER"* with its fix
> [#2843](https://github.com/abaplint/abaplint/pull/2843), and the earlier
> [#2588](https://github.com/abaplint/abaplint/pull/2588). Nothing reports the
> declaration itself, and the second half of this item is a comment on what
> #2843 landed.

## What happens

```abap
CLASS-METHODS msg_get_internal
  IMPORTING
    val           TYPE any
    iv_check_rap  TYPE abap_bool DEFAULT abap_true
      PREFERRED PARAMETER val
  RETURNING
    VALUE(result) TYPE ty_t_msg.
```

A system answers the activation with a warning:

> *Declare the parameter "VAL" as OPTIONAL. The addition PREFERRED PARAMETER is
> ignored if non-optional parameters are used.*

`PREFERRED PARAMETER` names the input parameter that a short-form call
`meth( x )` fills, and it takes effect only when **every** importing parameter
is optional. With a mandatory one in the list the addition is ignored — the
short form goes to that single mandatory parameter, which is the same binding,
so nothing breaks and nothing but a system says a word.

That is exactly how it gets written. The declaration above had one importing
parameter and no addition; a change added a second, defaulted one and the
addition with it, to keep the positional callers (`msg_get_internal( <row> )`)
reading the same. They read the same without it. The addition was a no-op that
bought a warning in every system the code is activated in.

## Why nothing reports it

abaplint **parses** the addition and no rule reads it:
`MethodDefImporting` is `seq("IMPORTING", plus(...), optPrio(seq("PREFERRED
PARAMETER", field)))` — the field is accepted and discarded. Grepping the
2.120.38 bundle for the words finds exactly that one occurrence, in the
grammar.

## Proposed rule

Report a `METHODS` / `CLASS-METHODS` (and the `FUNCTION-POOL` equivalents, if
they carry the addition) whose IMPORTING clause has `PREFERRED PARAMETER` while
at least one importing parameter carries neither `OPTIONAL` nor `DEFAULT`.

Everything the rule needs is inside the one statement abaplint already parses:
the parameter list and the preferred field are siblings in
`MethodDefImporting`. No cross-statement analysis, no type information.

Message, close to the compiler's: *"PREFERRED PARAMETER is ignored while VAL is
not optional"*.

**A quick fix should remove the addition, not add `OPTIONAL`.** The compiler's
own wording suggests the opposite, and that is the more dangerous of the two:
making a mandatory parameter optional widens the contract, so a call that
forgets it compiles and the method runs on an unfilled parameter. Removing the
ignored addition changes nothing at all.

## What it must NOT report

- The correct use: `PREFERRED PARAMETER` where every importing parameter is
  `OPTIONAL` or has a `DEFAULT`. That is the whole point of the addition.
- A `PREFERRED PARAMETER` naming a parameter that does not exist — a different
  finding, and the syntax check owns it.
- Mandatory `EXPORTING` or `CHANGING` parameters, until somebody measures what
  a system does with those. The message names the importing list, and the gate
  this repository ships (`check:atc`, rule `preferred_param`) stays there for
  the same reason.

## The other half: `check_syntax` accepts a call a system rejects

Measured on 2.120.38, `check_syntax` on, `syntax.version` v750, in a two-file
project with nothing else in it:

```abap
CLASS-METHODS meth
  IMPORTING
    val           TYPE string
    other         TYPE i DEFAULT 1
      PREFERRED PARAMETER val
  RETURNING
    VALUE(result) TYPE i.
...
DATA(lv2) = meth( other = 2 ).      " val not supplied
```

| | abaplint |
|---|---|
| as written above | **0 issues** |
| the same file with the `PREFERRED PARAMETER` line deleted | `method parameter "VAL" must be supplied` |

So the addition makes the parameter optional *for abaplint* — which is what
#2841 asked for and #2843 landed. It is right for the case that issue was
about, where the parameter is declared `OPTIONAL` anyway, and it is inverted
for this one: the only time the leniency is ever exercised is when the addition
is ignored, and there the parameter is still mandatory. A call omitting it is
green here and a syntax error on a system.

If the rule above lands, this half follows from it: the addition may only make
a parameter optional when every importing parameter of the method already is.

**Not verified from here:** the system-side rejection of that call. What was
measured is the warning on the declaration (a user's system, 2026-09-05) and
the compiler's own statement that the addition *is ignored*, from which the
parameter's mandatory-ness follows.
