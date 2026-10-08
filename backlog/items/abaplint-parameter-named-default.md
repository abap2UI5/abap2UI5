---
target: abaplint
title: 'Report a method parameter named DEFAULT - a system reads it as the DEFAULT addition of the parameter before it'
summary: '`IMPORTING val TYPE clike default TYPE i RETURNING …` does not activate ("Unable to interpret RETURNING"); abaplint parses it as two parameters and reports nothing'
priority: high
state: filed
filed: https://github.com/abaplint/abaplint/pull/4391
first_seen: 2026-10-06
upstream: abaplint/abaplint
evidence:
  - abap2UI5-addons/admin-cockpit, 2026-10-06 - a user's pull, `z2ui5_cl_cockpit_setup` private section, method `to_int` with the parameters `val TYPE clike` and `default TYPE i` - "Unable to interpret "RETURNING". Possible causes of error include incorrect spellings or comma errors." then "Compilation was canceled"; fixed by renaming the parameter to `fallback`
  - measured 2026-10-06 on abaplint 2.120.70, every default rule on, `check_syntax` live - no finding on the declaration nor on the call `to_int( val = `1` default = 2 )`; the control probe (an undefined variable in the same class) fired
  - abap2UI5-addons/abap-agent-runtime, 2026-10-08 - a user's syntax check after a pull, 28 errors in 14 classes; three parameters named `default` (`z2ui5_cl_agent_settings=>check_llm`, `z2ui5_cl_agent_session->rows_of`, `z2ui5_cl_agent_llm_anthropic=>setting`) - "Unable to interpret "DEFAULT"" / ""RETURNING"" / ""OPTIONAL"", and the same error at the same line in the public section of every class using `z2ui5_cl_agent_settings`; the PR's build reports exactly these three on the pre-fix sources and nothing after the rename to `default_value`
---

# Report a method parameter named DEFAULT

## What happens

```abap
CLASS-METHODS to_int
  IMPORTING
    val           TYPE clike
    default       TYPE i
  RETURNING
    VALUE(result) TYPE i.
```

On a system, the class pool does not activate:

```
Unable to interpret "RETURNING". Possible causes of error include incorrect spellings or comma errors.
Compilation was canceled
```

The parameter list reads `default` as the `DEFAULT` addition of `val`. It
takes `TYPE` as the default value, and then cannot interpret `i` and
`RETURNING`. abaplint's `MethodDefImporting` parses `default TYPE i` as a
second parameter, so the class is green in every rule.

## Proposed check

In `check_syntax` or `parser_error`, report a parameter in `IMPORTING`,
`EXPORTING` or `CHANGING` whose name is `DEFAULT` and that is not escaped as
`!default`, when it follows another parameter. The message names the remedy:
rename the parameter or escape it with `!`.

## What it must NOT report

- A structure component named `default` (`BEGIN OF … default TYPE string, END OF …`): a structure has no such addition.
- A constant or attribute named `default`.
- `val TYPE i DEFAULT 5`: the addition itself.
- `!default TYPE i`: the escaped name (to confirm on a system).

Both open questions are answered by the measurement in abaplint/abaplint#4391
(SAP_BASIS 758 SP03, 214 signatures): `optional` fails the same way, and
`default` as the first parameter of a section, after `OPTIONAL` or after a
`DEFAULT` value is accepted.
