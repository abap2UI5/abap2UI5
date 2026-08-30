---
target: abaplint
title: 'Downport: outline a table expression with ASSIGNING, not INTO — the component-level read loses the row reference'
summary: '`REF #( tab[ n ]-comp )` and `_bind( val = tab[ n ]-comp )` downport to `READ TABLE tab INDEX n INTO <wa>`, so the address taken is the work area''s and not the table row''s — while the whole-row form of the same expression is already lowered with ASSIGNING and keeps it'
priority: medium
state: open
first_seen: 2026-08-29
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5 `_bind( tab / tab_index )` — the cell binding matches the bound cell by data reference (`z2ui5_cl_ui5_srv_bind->bind_tab_cell`), so after the downport it refuses every cell written the natural way and the app gets BINDING_ERROR_TAB_CELL_LEVEL'
  - 'measured through both pipelines on a standalone class: transpiled as written every form resolves to the same cell (`a=same, b=same, c=same`); downported first, the component forms become copies (`a=COPY, b=COPY, c=same`)'
  - 'the asymmetry is inside the rule itself — `moveWithTableTarget` already emits `READ TABLE … ASSIGNING`, which is why `tab[ i ] = x`, `REF #( tab[ i ] )` and `ASSIGN tab[ i ] TO <row>` keep the row and only the component-level read does not'
  - 'the abap2UI5 test that proves the app-facing form is skipped in the transpiled suite for this reason (`node/setup/abap_transpile.json`), and the ABAP Doc on `z2ui5_if_client~_bind` has to tell app authors to assign the row first'
---

# Downport: outline a table expression with ASSIGNING, not INTO

## What happens

From 7.40 a table expression in a read position **addresses the row** — it is
not a copy, which is why `tab[ i ]-comp = x` is legal and why `REF #( tab[ i ] )`
hands back a reference into the table. The downport outlines the
component-level read into a work area instead:

```abap
lr = REF #( mt_tab[ 1 ]-name ).
```

```abap
DATA temp1 LIKE LINE OF mt_tab.
READ TABLE mt_tab INDEX 1 INTO temp1.     " <-- a COPY
ASSIGN temp1-name TO <temp2>.
GET REFERENCE OF <temp2> INTO lr.
```

For a value read the two are indistinguishable. For anything that takes the
value's **address** they are not: a pass-by-reference actual parameter,
`REF #( )`, `ASSIGN`. The reference then points at a temporary that nothing
else can reach.

The rule already knows this. `moveWithTableTarget` — the write position — emits

```abap
FIELD-SYMBOLS <temp1> LIKE LINE OF mt_tab.
READ TABLE mt_tab INDEX 1 ASSIGNING <temp1>.
```

which is exactly why `tab[ i ] = x`, `REF #( tab[ i ] )` and
`ASSIGN tab[ i ] TO <row>` survive the downport and only
`REF #( tab[ i ]-comp )` / `ASSIGN tab[ i ]-comp TO <fs>` do not.

## Measured

A standalone class builds four references to the same cell and compares each
against the one an `ASSIGN COMPONENT` walk arrives at:

| how the reference is built | as written | downported first |
|---|---|---|
| `REF #( tab[ 1 ]-name )` | same | **COPY** |
| `ASSIGN tab[ 1 ]-name TO <fs>` → `REF #( <fs> )` | same | **COPY** |
| `REF #( tab[ 1 ] )` → deref → `REF #( <row>-name )` | same | same |
| `ASSIGN tab[ 1 ] TO <row>` → `REF #( <row>-name )` | same | same |
| `READ TABLE tab INDEX 1 ASSIGNING <row>` → `REF #( <row>-name )` | same | same |

Transpiled directly the expression resolves correctly, so this is the
downport and not the transpiler.

## Where it bites

abap2UI5's cell binding, `_bind( val = tab[ n ]-comp tab = tab tab_index = n )`,
identifies the bound cell by data reference and refuses a `val` that is not a
component of the addressed row. After the downport that refusal fires on
correct code, so the binding is unusable in every downported build — including
the transpiled Node backend the framework's own browser tests and the sample
corpora's e2e smoke run on. Nothing reports it: the source is valid at the
v750 target, abaplint is green on the downported branch, and the failure is a
runtime exception on a system.

## Proposed fix

`replaceTableExpression` emits the same shape `moveWithTableTarget` already
does:

```diff
-      const uniqueName = this.uniqueName(high.getFirstToken().getStart(), lowFile.getFilename(), highSyntax);
+      const uniqueName = this.uniqueName(high.getFirstToken().getStart(), lowFile.getFilename(), highSyntax, true);
...
-      const fix1 = EditHelper.insertAt(lowFile, firstToken.getStart(), `DATA ${uniqueName} LIKE LINE OF ${pre}.
+      const fix1 = EditHelper.insertAt(lowFile, firstToken.getStart(), `FIELD-SYMBOLS ${uniqueName} LIKE LINE OF ${pre}.
 ${indentation}DATA ${tabixBackup} LIKE sy-tabix.
 ${indentation}${tabixBackup} = sy-tabix.
-${indentation}READ TABLE ${pre} ${condition}INTO ${uniqueName}.
+${indentation}READ TABLE ${pre} ${condition}ASSIGNING ${uniqueName}.
```

`uniqueName` needs one companion change: a `FIELD-SYMBOLS <temp3>` declaration
is known to the scope as `<temp3>`, so the collision check has to look up the
bracketed spelling — otherwise a second outline in the same method is handed
the same name and the result does not compile (`Variable name "<temp3>"
already defined`). A `fieldSymbol` flag that both decorates the name and
checks the decorated spelling is the whole change.

Tried against abaplint at `6bb7b53`: `packages/core` is green
(10885 passing, 0 failing) with four `testFix` expectations updated to the new
output — they are fixture text, not assertions about semantics — and the
downported repro then measures `a=same, b=same, c=same`.

## Risk

`ASSIGNING` binds the field symbol to the row for as long as it lives, where
`INTO` took a snapshot. The outlined read is inserted immediately before the
statement that consumes it, so there is no window in which the table can be
modified in between — except a statement that reads and modifies the same
table at once, which is where the two lowerings would genuinely differ.

The alternative, narrower fix is to assign only when the outlined value is
consumed in a reference position, but the rule does not carry that context at
the point of the rewrite, and the write path already assigns unconditionally.
