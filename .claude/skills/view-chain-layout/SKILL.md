---
name: view-chain-layout
description: The layout rules for a z2ui5_cl_ui5_view_builder chain - one call per line, four spaces per tree level, the end( ) column, which factory( ) shape goes with which chain shape, blank lines, and the chain-format gate that checks them. Identical in abap2UI5, abap2UI5/samples and abap2UI5/samples-controls. Use when writing, reviewing or reformatting any view built with the builder, when a chain has drifted, and when chain-format, chain-indentation or chain-element-per-line fails.
---

# The layout of a view-builder chain

A chain is read far more often than it is written, and its layout is the only
thing that makes it legible as the XML tree it stands for. Treat the indent as
load-bearing, not as taste: it is the one place a reader can see where in the
tree a line sits, so it has to be true.

**These rules are identical in all three repositories** — `abap2UI5`,
`abap2UI5/samples`, `abap2UI5/samples-controls`. They were unified in one pass
after a survey found the two sample corpora following opposite conventions for
the same builder.

## The six rules

1. **One call per line.** Every `ele( )`, `tag( )`, `a( )` and `end( )` opens
   its own line with `)->`. A control never shares its line with its own
   attributes, nor with the container it opens.
2. **Four spaces per level, everywhere.** A child sits one level in from its
   container, a control's attributes one level in from the control. The same
   step in every file.
3. **The closing paren rides with the arrow.** Never a `)` alone at a line end
   — carry it to the start of the next segment so it always reads `)->`. The
   whole view ends in a single `` ).``, not `` ) ).``.
4. **`end( )` stands alone in the column of the `ele( )` it closes.** That is
   what makes an ascent over several levels visible instead of hidden.
5. **One attribute per line, `v =` / `b =` column aligned** across a control's
   attribute block.
6. **`stringify( )` is a standalone final statement** —
   `client->view_display( view->stringify( ) ).`, never nested in the chain.

```abap
METHOD view_display.

  DATA(view) = z2ui5_cl_ui5_view_builder=>factory(
      )->ele( n = `View` ns = `mvc`
          )->a( n = `xmlns`     v = `sap.m`
          )->a( n = `xmlns:mvc` v = `sap.ui.core.mvc`

          )->ele( `Page`
              )->a( n = `title` v = `My App`

              )->ele( `List`
                  )->a( n = `items` v = client->_bind( t_items )

                  )->ele( `items`
                      )->tag( `StandardListItem`
                          )->a( n = `title` v = `{PRODUCT}`
                          )->a( n = `info`  v = `{QUANTITY}`

              )->end(

              )->tag( `Button`
                  )->a( n = `text`  v = `Save`
                  )->a( n = `press` v = client->_event( `SAVE` ) ).

  client->view_display( view->stringify( ) ).

ENDMETHOD.
```

## The two chain shapes, and the `factory( )` that goes with each

Both are correct. The choice is about the view, not about style — but the
`factory( )` shape is **not** free, because the variable has to denote the node
you attach to next.

- **A statement per subtree** — hold a container in a variable
  (`DATA(page)`, `DATA(cont)`) and start a new statement from it. The shape of
  the framework's own apps and of most of `samples`; the better one when a
  subtree is filled from a loop, when the same node is filled twice, or when a
  teaching sample reads better with its parts named.
  **The chain must hang off the `factory( )` — one statement, not two** — so
  the variable holds the `mvc:View` and a later `view->ele( \`Shell\` … )` lands
  *inside* it.

- **One chain for the whole view**, ascending with `end( )`. The shape of
  `samples-controls`, where a 1:1 port mirrors one original XML file.
  Here the `factory( ).` **may** be a statement of its own, because nothing
  attaches to the variable afterwards — `stringify( )` renders from the root
  either way — and it buys back two levels of indent across the whole view.

**The one combination that is broken:** a standalone `factory( ).` *with* the
split shape. The variable then holds the root, and `view->ele( \`Shell\` )` adds
a second root beside the `mvc:View` instead of a child inside it.

Splitting does not break reconstruction — the abap2UI5-linter reads all 172
documents of `samples` out of the split shape and renders every one. What is
not allowed is mixing the two inside one subtree.

## Blank lines

Only in the single-chain shape, where they carry the structure of a long chain.
`samples` splits into short statements and has none inside a chain at all.

A blank line opens a block, and there are exactly two blocks:

1. **the content of a control that carries attributes** — a blank after its
   last `a( )`, before its first child;
2. **a run of `tag`s** — a blank before the first one, none between them.

Everything else runs without a blank: none between a control and its own
`a( )`s, none between consecutive `tag`s, none after a bare `ele( )` whose
first child is another `ele( )`, blank before every `end( )`, none after an
`end( )` or between two of them.

## What checks this, and what does not

`npm run check:chains` / `npm run fmt:chains` — the same `chain-format` script
in all three repositories, byte for byte
(`.github/scripts/chain-format-gate.mjs` in `abap2UI5`, `scripts/chain-format.mjs`
in both sample repos; in `samples-controls` it is also the first step of
`npm run gates`). It checks rules 1–4 and applies them. It rewrites
whitespace *between* chain segments only, and verifies that collapsing every
run of code-whitespace leaves the file identical — **a layout fix can never
change what the view builds.** Rules 5–6 and the blank lines stay
reviewer-enforced.

Nothing else covers this, which is why the gate exists:

- **abaplint** — its formatting rules do not reach into a method-call chain,
  and `align_parameters` / `line_break_multiple_parameters` are excluded for
  the shipped apps in `auto_abaplint_fix.jsonc` so the auto-formatter does not
  undo the layout.
- **abap2UI5-linter `chain-element-per-line`** — covers rule 1. Ships as
  `hint`; raised to `warning` in `samples`.
- **abap2UI5-linter `chain-indentation`** — judges that a chain keeps its
  **own** rhythm (a sibling in a different column than its siblings, a call
  written left of the element it belongs to). It does **not** judge the step,
  so a chain uniformly indented by 8 passes it while saying the wrong thing
  about depth. 77 ports in `samples-controls` had drifted exactly that way, and
  every gate stayed green. That gap is the reason `chain-format` exists.

## When a chain has drifted

Run `npm run fmt:chains`. Do not re-indent by hand — the script is verified
whitespace-only, a hand fix is not. If it reports *"transform is not
whitespace-only, left untouched"*, that file has something the scanner
mis-reads (an unusual string template); fix that file by hand and say so.

The shape that destroys a chain, and what one call per line prevents:

```abap
" WRONG - up two levels, down two, all inside one attribute line.
" Four level changes nobody can follow, and every line after them starts
" in a column that means nothing.
)->a( n = `text` v = `id ` )->end( )->end( )->ele( `items` )->ele( `ColumnListItem`
```

When you need a node *again*, hold it in a variable and start a new statement
from it, or ascend with one `end( )` per line at the column of the `ele( )` it
closes.
