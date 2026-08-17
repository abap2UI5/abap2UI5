---
target: abaplint
title: 'Report `DELETE itab INDEX sy-tabix` inside a `LOOP AT` over the same table'
summary: deleting the current row from under the loop skips the next one — a wrong answer where `sy-tabix` is stale, a short dump where it is 0; found eight times across four repositories
priority: high
state: open
first_seen: 2026-08-17
upstream: abaplint/abaplint
evidence:
  - found 2026-08-17 by an e2e interaction — `abap2UI5/samples-controls` app 352's `listClose` round-trip answered HTTP 500 with `TABLE_INVALID_INDEX`
  - a pattern search then found eight sites — four ports in samples-controls (352 twice, 354, 298, 377), three in `abap2UI5/samples` (`z2ui5_cl_smp_context` twice, app 070), one in the vendored ajson
  - two of the eight were wrong twice over — the `sy-tabix` belonged to an inner loop, so the index deleted was another table's
  - no rule of the 188 abaplint ships reports it; `invalid_table_index` is constant index 0 only
---

# Report `DELETE itab INDEX sy-tabix` inside a `LOOP AT` over the same table

## What happens

```abap
LOOP AT tab INTO DATA(row).          " filters 10 rows, judges 5 of them
  IF <drop it>.
    DELETE tab INDEX sy-tabix.
  ENDIF.
ENDLOOP.
```

Deleting the current row shifts every row after it while the loop's own cursor
walks on, so the row *after* each deletion is never seen. The statement is
syntactically fine and looks like the obvious way to say "drop this one".

There are two outcomes and only the second is visible:

- **`sy-tabix` stale but positive** — nothing dumps. The result is plausible
  and wrong: a filter that keeps rows it was told to drop.
- **`sy-tabix` reset to 0** — an inner `LOOP` that has ended, or a `DO` between
  the `LOOP` and the `DELETE` — index 0 is a short dump, `TABLE_INVALID_INDEX`.

The first outcome is why this survived eight times in code that is read,
reviewed and linted: it produces output, and the output is wrong by a little.

## Why no existing rule catches it

`invalid_table_index` reports a **constant** index of 0 (`table[ 0 ]`,
`READ TABLE … INDEX 0`). It says nothing about a system field, and nothing
about the enclosing loop. `db_operation_in_loop` is about database calls. There
is no rule that relates a statement inside a loop to the table the loop walks.

## Proposed rule

Report `DELETE <itab> INDEX sy-tabix.` when `<itab>` is the table of an
enclosing `LOOP AT`, and the statement is not the first statement after a
`READ TABLE` on that same table.

The three parts are all statically decidable from one file: the loop's target
name, the deleted table's name, and whether a `READ TABLE <same itab>`
immediately precedes.

## What it must NOT report — the scope that makes it writable

`DELETE itab INDEX sy-tabix` directly after `READ TABLE itab …` is **correct
and common**: there `sy-tabix` is the index the read just set, and the pattern
is the standard read-then-delete. abap2UI5 vendors `z2ui5_cl_ajson`, which uses
it that way. A rule that reported the shape unconditionally would fire on
correct code in most large code bases and be switched off within a week — which
is why this proposal is anchored on the enclosing loop rather than on the
statement.

Nor should it report `DELETE itab WHERE …`, which is the right way to say the
same thing when the condition fits there.

## The fix the rule should point at

Build the result instead of mutating the table being walked:

```abap
DATA keep LIKE tab.
LOOP AT tab INTO DATA(row).
  IF <keep it>.
    APPEND row TO keep.
  ENDIF.
ENDLOOP.
tab = keep.
```

It reads as what it does and has neither failure mode.

## Sites the rule would have fired on

| Repository | Where |
|---|---|
| `abap2UI5/samples-controls` | `z2ui5_cl_smpc_app_352` (twice), `_354`, `_298`, `_377` |
| `abap2UI5/samples` | `z2ui5_cl_smp_context` (`filter_itab`, `itab_filter_by_val`), app 070 |
| vendored ajson | `z2ui5_cl_ajson_filter_lib` — upstream, deliberately not patched downstream |

All but the last are fixed; the sites are listed because "would it have fired,
and only there" is the question a rule proposal has to answer.

<!-- probe:start — written by `npm run backlog:probe`, do not edit by hand -->

## Measured

`abaplint-delete-index-in-loop.probe.mjs` — DELETE <t> INDEX sy-tabix inside an open LOOP AT <t>, and the correct READ-TABLE-then-DELETE form as the negative.
Run **2026-08-17** against `abap2UI5`, `samples`, `samples-controls`, `samples-stack`.

**Would fire on 1 site(s)** in 1 repository:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/00/01/z2ui5_cl_ajson_filter_lib.clas.locals_imp.abap`:86 | DELETE lt_tab INDEX sy-tabix. |

**Must NOT fire on 1 site(s)** that match the shape and are correct:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/00/01/z2ui5_cl_ajson.clas.abap`:205 | DELETE mt_json_tree INDEX sy-tabix. "#EC CI_SORTSEQ where pa |

**Where the detector is an approximation of the rule:**

- The detector reads line by line, so a `LOOP AT` or `DELETE` split across lines is missed. A real rule works on the statement tree and would find those too — this is a floor, not a ceiling.
- "Within 8 statements of a READ TABLE on the same table" stands in for the rule's real condition, which is whether anything has written sy-tabix since. abaplint can ask that exactly; this cannot.
- The site count is what is LEFT: seven of the eight found on 2026-08-17 were fixed the same day, so the number here measures the current trees rather than the size of the original finding. The one remaining is vendored upstream code, deliberately not patched downstream.

<!-- probe:end -->
