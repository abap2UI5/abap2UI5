---
target: abaplint
title: 'downport: line_exists( ) in an ELSEIF is moved in front of the IF and overwrites the sy-subrc the IF condition reads'
summary: '`replaceLineFunctions` turns `ELSEIF line_exists( tab[ … ] )` into a `READ TABLE … TRANSPORTING NO FIELDS` inserted before the whole IF chain (its comment - "assumption: no side effects in IF conditions"); the READ itself sets sy-subrc and sy-tabix, so an `IF sy-subrc <> 0` after an earlier READ now reads the hoisted READ''s result - silently different branching on every downported 702 branch and in the transpiled unit run'
priority: high
state: open
first_seen: 2026-10-08
upstream: abaplint/abaplint
evidence:
  - found 2026-10-08 in abap2UI5-addons/admin-cockpit, `z2ui5_cl_cockpit_session=>outcomes_of` - `READ TABLE lt_meta … WITH TABLE KEY id = lv_key.` followed by `IF lv_key IS INITIAL OR sy-subrc <> 0. … ELSEIF line_exists( lt_prev[ table_line = lv_key ] ).`; its unit test answered "unknown" for a draft that is in `lt_meta`, because the downported code (read in `node/downport/`, @abaplint/cli as pinned by abap2UI5 that day) runs `READ TABLE lt_prev WITH KEY table_line = lv_key TRANSPORTING NO FIELDS. temp143 = sy-subrc.` before the `IF`, and the IF's `sy-subrc <> 0` then tests that READ. Worked around by keeping the first READ's result in a variable at once
  - the cause, read at abaplint/abaplint main 00a31bb - `packages/core/src/rules/downport.ts`, `replaceLineFunctions`: for an `ElseIf` statement the insert position is `findStartOfIf( )`, the start of the IF chain, under the comment "assumption: no side effects in IF conditions"; the inserted `READ TABLE` is such a side effect (sy-subrc for line_exists, sy-tabix for line_index)
  - a scan of abap2UI5/src, sapgui, popups, abap-cloud-gui and admin-cockpit on 2026-10-08 finds no other IF chain that tests sy-subrc in its IF and has a line_exists / line_index in an ELSEIF (2 such ELSEIFs exist, neither IF reads sy-subrc) - the trap is rare, and silent when it hits
checked_upstream: 2026-10-09
---

# downport: line_exists( ) in an ELSEIF overwrites the sy-subrc the IF reads

## What happens

```abap
READ TABLE lt_meta INTO ls_meta WITH TABLE KEY id = lv_key.
IF sy-subrc <> 0.
  result = `unknown`.
ELSEIF line_exists( lt_prev[ table_line = lv_key ] ).
  result = `continued`.
ELSE.
  result = `stopped`.
ENDIF.
```

`downport` turns it into

```abap
READ TABLE lt_meta INTO ls_meta WITH TABLE KEY id = lv_key.
DATA temp1 LIKE sy-subrc.
READ TABLE lt_prev WITH KEY table_line = lv_key TRANSPORTING NO FIELDS.
temp1 = sy-subrc.
IF sy-subrc <> 0.          " now the result of the READ on lt_prev
  result = `unknown`.
ELSEIF temp1 = 0.
...
```

A key in `lt_meta` but not in `lt_prev` gives `unknown` on 7.02 and
`stopped` on 7.40 and later. Nothing reports it: the source is right, and
the downport's output is valid ABAP.

The same holds for `line_index( )`, whose READ sets sy-tabix, and for a
chain whose earlier `ELSEIF` - not the IF - reads sy-subrc or sy-tabix.

## Why

`packages/core/src/rules/downport.ts`, `replaceLineFunctions`:

```ts
let insertAt: Position | undefined = node.getFirstToken().getStart();
if (node.get() instanceof ElseIf) {
  // assumption: no side effects in IF conditions
  insertAt = this.findStartOfIf(node, highFile);
```

The condition of an ELSEIF cannot hold a statement, so the READ has to go
in front of the IF - but the READ is a side effect on exactly the two
system fields an IF condition is most likely to read.

## A fix

Keep the system fields around the inserted READ:

```abap
DATA temp1 LIKE sy-subrc.
DATA temp2 LIKE sy-subrc.
DATA temp3 LIKE sy-tabix.
temp2 = sy-subrc.
temp3 = sy-tabix.
READ TABLE lt_prev WITH KEY table_line = lv_key TRANSPORTING NO FIELDS.
temp1 = sy-subrc.          " sy-tabix for line_index
sy-subrc = temp2.
sy-tabix = temp3.
IF sy-subrc <> 0.
```

Only needed for an ELSEIF (for an IF the READ sits right in front of its
own statement, where nothing reads the old value afterwards). A narrower
variant emits the save and restore only when a condition of the chain
before the ELSEIF mentions `sy-subrc` / `sy-tabix`.

## Tests to add (packages/core/test/rules/downport.ts)

- the example above: the downported IF still tests the first READ
- `line_index( )` in an ELSEIF after a condition on `sy-tabix`
- two ELSEIFs with line_exists in one chain - both READs keep the fields

## How to file

A PR against abaplint/abaplint: the change in `replaceLineFunctions` and the
tests. Record the search in `checked_upstream:` (2026-10-08: the issue search
"downport line_exists ELSEIF sy-subrc" in abaplint/abaplint, 36 results,
none about this - the closest are #1723 and #3110, both check_subrc false
positives).
