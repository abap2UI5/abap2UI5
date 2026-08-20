---
name: view-chain-layout
description: The layout rules for a z2ui5_cl_ui5_view_builder chain - one call per line, four spaces per tree level, the end( ) column, which factory( ) shape goes with which chain shape, blank lines, and the linter rule that checks them. Identical in abap2UI5, abap2UI5/samples, abap2UI5/samples-controls and abap2UI5/samples-stack. Use when writing, reviewing or reformatting any view built with the builder, when a chain has drifted, and when chain-house-layout fails.
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

The rule is the abap2UI5-linter's **`chain-house-layout`**. It checks rules 1-4
and carries fixes, so `--fix` reformats a drifted chain. The rewrite only ever
touches whitespace *between* chain segments and the indent of a continuation
line that is not itself content, and it verifies that collapsing every run of
code-whitespace leaves the source identical — **a layout fix can never change
what the view builds.** Rules 5-6 and the blank lines stay reviewer-enforced.

It is the linter's one **opt-in** rule (`OPT_IN` in its `findings.mjs`): it is
not emitted at all until a config asks for it, because it encodes one house
style — this one — and because its fixes span a whole chain, which would defer
any other rule's fix inside the same chain to a second `--fix` pass.

All four repositories run the rule itself. `scripts/chain-format.mjs`, which
used to be the same algorithm written a second time, is gone:

| | how |
|---|---|
| `abap2UI5` | `npm run check:abap2ui5` / `npm run fmt:chains` — enabled in `abap2ui5lint.jsonc` |
| `abap2UI5/samples` | `npm run check:abap2ui5` / `npm run fmt:chains` — enabled in `abap2ui5lint.jsonc` |
| `abap2UI5/samples-stack` | `npm run check:abap2ui5` / `npm run fmt:chains` — enabled in `abap2ui5lint.jsonc` |
| `abap2UI5/samples-controls` | `npm run check:chains` / `npm run fmt:chains` — `abap2ui5lint-chains.jsonc`; also the first step of `npm run gates` |

samples-controls needs a config of its own because its corpus gate
(`view-gates.mjs`) only sees files that have a meta sidecar, while the layout
is a property of the source and has to cover the whole tree — including the
fourteen hand-written `src/03` classes and the generated overview app. That
config switches the property-gate rules off, because view-gates judges those
against the sidecars and a second opinion here would only be a worse one.

Two things that config must NOT do, both measured rather than assumed:
`properties: false` looks like the obvious way to isolate the layout and takes
the chain rules down with it — the check then passes everything, silently. And
`chain-house-layout` is opt-in, so a `rules` entry is what turns it on; without
one the run is green no matter how mangled the chain.

Nothing else covers this, which is why the rule exists:

- **abaplint** — its formatting rules do not reach into a method-call chain,
  and `align_parameters` / `line_break_multiple_parameters` are excluded for
  the shipped apps in `auto_abaplint_fix.jsonc` so the auto-formatter does not
  undo the layout.
- **`chain-element-per-line`** — covers rule 1 only for *elements*: it
  deliberately lets an attribute share its control's line, which the house
  layout does not. Ships as `hint`; raised to `warning` in `samples`.
- **`chain-indentation`** — judges that a chain keeps its **own** rhythm (a
  sibling in a different column than its siblings, a call written left of the
  element it belongs to). It does **not** judge the step, so a chain uniformly
  indented by 8 passes it while saying the wrong thing about depth. 77 ports in
  `samples-controls` had drifted exactly that way, and every gate stayed green.
  That gap is what `chain-house-layout` was written for.

## When a chain has drifted

Run `npm run fmt:chains`. Do not re-indent by hand — the fix is verified
whitespace-only, a hand fix is not. If a file is reported but never rewritten,
it has something the scanner mis-reads (an unusual string template); fix that
one by hand and say so.

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
