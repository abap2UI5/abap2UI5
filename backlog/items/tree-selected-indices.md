---
target: abap2ui5
title: 'sap.m.Tree has no callback-free way to read its selected rows, so expand/collapse-selected cannot be wired at all'
summary: 'sap.ui.table.TreeTable has getSelectedIndices(); sap.m.Tree has only getSelectedItems(), and mapping it to indices needs a JS callback the UI5 expression grammar cannot parse'
priority: medium
state: open
first_seen: 2026-08-24
evidence:
  - samples-controls app 601 (sap.m.sample.TreeExpandMulti) has two toolbar buttons whose only job is expand/collapse of the selected nodes; both are dead, because the only spelling available is `.getSelectedItems().map(function (o) { … })` and that throws in ExpressionParser
  - app 248 ports the same interaction successfully on sap.ui.table.TreeTable, using `$event.oSource.getSelectedIndices()` - a plain method chain with no callback. The difference is purely which control the sample uses
---

## The gap

`Tree.expand(int|int[])` and `Tree.collapse(int|int[])` take indices.
`sap.m.Tree` can give you the selected **items** (`getSelectedItems()`) and can
turn one item into an index (`indexOfItem`), but there is no member that returns
the indices directly — so the mapping needs a loop, and a loop in an event
argument needs a callback, which the expression grammar does not have.

`sap.ui.table.TreeTable.getSelectedIndices()` closes exactly this gap for the
other tree control, which is why app 248 works and 601 does not.

## Options

1. **A synthetic `CONTROL_METHODS` entry** — e.g. `expandSelected` / `collapseSelected`
   on the Tree target, implemented frontend-side as the loop the app cannot write.
   Smallest change, and it keeps the app free of JS.
2. **A generic index projection** in the argument vocabulary — something like a
   documented `.eIdx(<aggregation>)` that resolves a control array to indices.
   More general, larger surface.
3. **Nothing, and declare it.** 601's deviation now says the wire is not live.
   That is honest but leaves a sample whose entire subject does not work.

Option 1 is the one this item proposes; the other two are recorded so they are
not re-proposed as if new.
