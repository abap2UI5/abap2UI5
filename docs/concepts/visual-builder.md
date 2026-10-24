# Visual builder, both ways

## What exists

Two halves, in two places:

- **[abap2UI5/layout-editor](https://github.com/abap2UI5/layout-editor)** - a
  view put together by clicking, written out as an app class; it opens a
  class by URL or pasted, and hands it to the playground with "Open in
  Playground".
- **The playground's View tab** - the XML a class's builder chain builds,
  editable; an edit is written back into the chain. What nobody edited is
  not rewritten (`chain-patch.mjs`): a changed value is written over exactly
  itself, and every `_bind( )` and `_event( )` keeps its ABAP, so the app
  does not quietly become one with every binding frozen. The result is in
  the house layout the linter checks.

What neither does yet is the whole way: open a class that was **written by
hand**, change its view by clicking, bind a control to an attribute, add an
event - and get the same class back, with only the lines that changed
changed.

## The first cut

One loop, in the playground, on the code that is already there:

1. **Click to select, in the running app.** A click on a control in the app
   frame selects its node in the View tab's tree (the control's id leads to
   the chain node `chain-read.mjs` built), and the node's attributes open in
   a property sheet: the control's properties from the linter's metadata of
   the oldest supported UI5, with the type of each.
2. **Edit in the sheet, write through the patch.** A value typed into the
   sheet goes through the same path an XML edit goes: `view-edit.mjs` merges,
   `chain-patch.mjs` writes over exactly that value.
3. **Bind instead of type.** Next to each property: the app's public
   attributes whose type fits (from abaplint's analysis of the class), and
   choosing one writes `client->_bind( <attribute> )` - or `_bind_edit( )`
   for an input's value.
4. **An event is a method arm.** Choosing "new event" on a `press` writes
   `client->_event( \`NAME\` )` into the chain and an
   `ELSEIF client->check_on_event( \`NAME\` ).` arm into `main( )`, in the
   lifecycle chain's own place, empty for the developer to fill.
5. **Add from a palette.** A control dragged from a palette (sap.m first,
   only what 1.71 has) becomes a `tag( )` or `ele( )` at the drop position;
   this is the one edit that changes the shape of the tree, and it takes the
   writer's full rewrite of that chain, as an inserted control does today.

The class stays the source at every step. There is no design file, no
model next to it, nothing to keep in sync - closing the builder leaves a
class that reads as if it had been typed.

## What it must not become

- **A second source.** No layout stored outside the class; the layout
  editor's own design format stays a way to start, not a place to keep.
- **A builder that writes what the linter refuses.** Every write is checked
  by the same rules the panel runs - 1.71 names, the house layout, the
  lifecycle - before it lands.
- **A generator of everything.** Business logic stays typed. The builder
  writes view chains, bindings and empty event arms; nothing in the arms.

## Open questions

- One tool or two? The layout editor and the playground share the chain
  reader and writer in spirit, not in code. A shared package
  (`chain-read`, `chain-patch`, `chain-write`) would let the layout editor
  open hand-written classes with the same guarantees.
- A builder for the split shape (a statement per subtree, held in
  variables) as well as the single chain - the patch keeps it, the writer
  does not produce it.
- Fragments and popups: the same loop on a `popup_display( )` chain, which
  the frame shows only while the popup is open.
