# Building apps with abap2UI5 — the agent guide

Self-contained, offline reference for AI assistants (and humans) **building
apps with** abap2UI5. It is derived from the framework sources in this
repository (`src/02/` public API, `z2ui5_cl_ui5_view_builder`, the
hello-world app) and the conventions proven over the 416 ported UI5
demo-kit samples in
[samples-controls](https://github.com/abap2UI5/samples-controls). The rendered
documentation site is <https://abap2ui5.github.io/docs/> — this file exists so
an agent without web access has the complete picture in-repo. When this guide
and the code disagree, the code wins (`src/02/z2ui5_if_client.intf.abap` is
the contract).

For working **on the framework itself**, read `AGENTS.md` instead.

## 1. The model in one paragraph

An abap2UI5 app is **one ABAP class** implementing `z2ui5_if_app`. The
framework calls its `main( client )` method on every HTTP roundtrip, and the
app dispatches on why it was called: it has to put its view on screen
(`check_on_navigated`, true on the first start and on every return into the
app), or the user interacted with it (`check_on_event`), or it is running for
the very first time and has one-time setup to do (`check_on_init`).
The app builds a UI5 XML view as a string, binds ABAP attributes into it,
and registers named events. Between roundtrips the framework
serializes the app object into a draft table and restores it — **every PUBLIC
attribute is persisted state and travels to the browser with the model**, so
bound data goes in `PUBLIC SECTION`, everything else in `PROTECTED SECTION`.
There is no JavaScript, no OData service and no deployment step: activate the
class, call the ICF endpoint with `?app_start=zcl_my_app`.

## 2. The canonical app template

```abap
CLASS zcl_my_app DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    " ONLY bound data here - PUBLIC attributes are serialized every roundtrip
    TYPES: BEGIN OF ty_s_item,
             product  TYPE string,
             quantity TYPE i,
           END OF ty_s_item.
    DATA t_items TYPE STANDARD TABLE OF ty_s_item WITH EMPTY KEY.
    DATA name    TYPE string.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    METHODS view_display.
    METHODS on_event.
    METHODS model_init.

  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_my_app IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.
    IF client->check_on_init( ).
      model_init( ).
      view_display( ).
    ELSEIF client->check_on_navigated( ).
      view_display( ).
    ELSEIF client->check_on_event( ).
      on_event( ).
    ENDIF.

  ENDMETHOD.

  METHOD view_display.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `View` ns = `mvc`
            )->a( n = `xmlns`     v = `sap.m`
            )->a( n = `xmlns:mvc` v = `sap.ui.core.mvc`
            )->a( n = `displayBlock` v = `true`
            )->a( n = `height`       v = `100%`

            )->ele( `Page`
                )->a( n = `title` v = `My App`

                )->tag( `Input`
                    )->a( n = `value` v = client->_bind( name )

                )->ele( `List`
                    )->a( n = `items` v = client->_bind( t_items )

                    )->ele( `items`

                        )->tag( `StandardListItem`
                            )->a( n = `title` v = `{PRODUCT}`
                            )->a( n = `info`  v = `{QUANTITY}`

                    )->end(
                )->end(

                )->tag( `Button`
                    )->a( n = `text`  v = `Save`
                    )->a( n = `press` v = client->_event( `SAVE` ) ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

  METHOD on_event.

    CASE client->get_event( ).
      WHEN `SAVE`.
        " bound data (name, t_items) already carries the user's input here,
        " and the changed model is pushed back automatically
        client->message_toast_display( |Saved, { name }| ).
    ENDCASE.

  ENDMETHOD.

  METHOD model_init.
    t_items = VALUE #( ( product = `Notebook` quantity = 2 )
                       ( product = `Mouse`    quantity = 5 ) ).
  ENDMETHOD.

ENDCLASS.
```

Conventions that keep apps uniform (proven in the samples-controls corpus):
`main` is a pure dispatcher; methods follow in call order with `model_init`
last; add `model_init`/`on_event` only when the app has data/events; always
dispatch events with `CASE client->get_event( ).` even for a single event.
**The `check_on_navigated( )` branch is part of the canonical dispatcher, not
an option**: without it the view is only ever built on `check_on_init`, so
navigating away (`nav_app_call`) and back leaves the app blank — the
framework fires `check_on_navigated`, nothing re-displays. Always re-run
`view_display( )` there.

## 3. The view builder — `z2ui5_cl_ui5_view_builder`

The builder maps **any** UI5 XML view 1:1 — every control, property,
aggregation and namespace, nothing is wrapped or approximated. Four verbs:

| Verb | XML meaning | Tree action |
|---|---|---|
| `ele( n ns )` | opening tag `<X>` | add child and **descend** into it |
| `tag( n ns )` | self-closing `<X/>` | add child, **stay** on current node |
| `end( )` | closing `</X>` | **ascend** to the parent |
| `a( n v )` / `a( n b )` | one `name="value"` | attribute on the element the chain points at |

- `n` = tag name, `ns` = namespace **prefix** (`f`, `l`, `core`, `mvc`, …);
  omit `ns` for the default namespace (usually `sap.m`). Declare every
  namespace as `xmlns:*` attributes on the root `View`, exactly like XML.
- **Aggregations are just tags**: `)->ele( `items` )` for `<items>`. An
  aggregation carries the same prefix as in the XML — `<m:content>` under a
  `sap.ui.table` default namespace is `)->ele( n = `content` ns = `m` )`.
- `stringify( )` renders from the root, so trailing `end( )` calls before
  the final `).` are optional — `end` only moves the cursor to add siblings.
  That is also what lets the whole view hang off the `factory( )` in one
  statement (see "Formatting the chain" below).
- **Booleans from ABAP variables** go through `b` instead of `v`:
  `` )->a( n = `editable` b = mv_edit_mode ) `` renders `true`/`false` (a
  literal is just `` v = `true` `` — never feed `abap_true` into `v` raw, it
  serializes as `X`).
- **An element gets its attributes before its first child.** `a( )` lands on
  the element the chain is pointing at — the child just added by `ele( )` or
  `tag( )`, or the node itself while it has none. Once an element has a
  child, `a( )` can no longer reach it.
- Braces `{ }` inside an ABAP `|…|` string template must be escaped
  `\{ \}` — an unescaped `{` is parsed as a UI5 binding.

The legacy fluent builder `z2ui5_cl_xml_view` (one method per control) still
ships for existing apps but is **frozen** — new apps and new code use
`z2ui5_cl_ui5_view_builder`.

### Formatting the chain (strict — reviewers check these)

A chain is read far more often than it is written, and its layout is the only
thing that still makes it legible as the XML tree it stands for. The rules
below are the ones the sample repositories are ported and reviewed against;
`.github/abaplint/auto_abaplint_fix.jsonc` excludes the shipped apps from
`align_parameters` / `line_break_multiple_parameters` so the auto-formatter
does not undo them.

**They are machine-checked.** The abap2UI5-linter's `chain-house-layout` rule
checks one call per line, four spaces per level and the closing call's column;
`npm run check:abap2ui5` reports and `npm run fmt:chains` applies. It rewrites
whitespace *between* chain segments only and verifies that collapsing every run
of code-whitespace leaves the file identical, so a layout fix can never change
what the view builds. The blank-line rules below stay reviewer-enforced.

The rule is **opt-in** in the linter, because it encodes one house style — this
one — and is named in `abap2ui5lint.jsonc` rather than inherited. It is what
the linter's two older layout rules cannot reach: they judge a chain against
ITSELF, so a chain whose every level is uniformly wrong keeps its own rhythm
and passes.

- **The `factory( )` shape follows the chain shape, and there are two.** The
  variable has to denote the node you will attach to next:
  - **A view split into a statement per subtree** (the shape of the apps here
    and of `abap2UI5/samples`) hangs the chain off the `factory( )` — one
    statement, not two — so the variable holds the `mvc:View` and a later
    `view->ele( `Shell` … )` lands inside it:

    ```abap
    DATA(view) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `View` ns = `mvc`
            )->a( n = `xmlns`     v = `sap.m`
            )->a( n = `xmlns:mvc` v = `sap.ui.core.mvc` ).
    ```
  - **A view built as one chain** (the shape of `abap2UI5/samples-controls`,
    where a 1:1 port mirrors one original XML file) may take the `factory( ).`
    as a statement of its own, because nothing attaches to the variable
    afterwards — `stringify( )` renders from the root either way. It buys two
    levels of indent back across the whole view, which is worth having in a
    deeply nested one.

  What is never right is the standalone `factory( ).` *with* the split shape:
  the variable then holds the root, and `view->ele( `Shell` )` adds a second
  root next to the `mvc:View` instead of a child inside it.
- **The closing paren rides with the arrow.** Never leave a `)` alone at the
  end of a line — carry it to the **start of the next segment**, so every
  continuation reads `)->`. With the `a( )` chain there is no nested `VALUE`,
  so the whole view ends in a single `` ).`` (not `) ).`).
- **Indent after every `ele`.** Each `ele( )` shifts its children's `)->`
  one level (4 spaces) to the right, `end( )` shifts back left, and the `)->`
  of an `end` sits in the same column as the `ele` it closes.
- **The indent *states* the depth — 4 spaces, never 2.** The column a line
  starts in is the only place the reader can see where in the tree they are,
  so it has to be true: same depth, same column; one level deeper, exactly
  four more. A step of two, or a line that changes depth and leaves the next
  line in the old column, and the layout is no longer describing the XML — it
  is decorating it.
- **One call per line — no exceptions.** Every `ele( )`, `tag( )`, `a( )` and
  `end( )` opens its own line with `)->`. A control does not share its line
  with its own attributes (`` )->tag( `Label` )->a( n = `text` … ``), and a
  container does not hand straight over to the next
  (`` view->ele( `Shell` )->ele( `Page` ``). Both used to be allowed here as
  "they hide nothing", and both were dropped when the two sample corpora were
  unified: the exception is what the worst shape grows out of.
  `` )->end( )->end( )->ele( `footer` )->ele( `OverflowToolbar` `` at the end
  of an attribute line — up two, down two — is four level changes nobody can
  follow, after which every line starts in a column that means nothing. With
  one call per line there is no line for it to hide on. This is also the
  abap2UI5-linter's `chain-element-per-line`.
- **Come back to a node through a variable, not through a run of `end( )`s.**
  `end( )` is for closing what you are finished with, one level, at the start
  of its own line. When you need a node *again* — a page you hang three
  sections off, a `footer` beside a form — keep it: `` DATA(page) =
  view->ele( `Shell` )->ele( `Page` … ) ``, then `page->ele( … )` per subtree,
  each its own statement, each starting at the method's indent. Every app in
  the framework and in `abap2UI5/samples` is built this way, and it is what
  keeps the rule above satisfiable: a statement that never unwinds can indent
  monotonically. A subtree deep enough that its lines drift past the
  right-hand side of the screen is telling you the same thing — split it.
- **A control's `a( )` lines sit one level (4 spaces) in from the control's
  own `)->` line** — one attribute per line, `v =` column aligned across the
  block.
- **A blank line opens a block — nothing else in the chain gets one.** A
  block is a run of lines that is read as one thing, and there are exactly
  two of them:
  1. **the content of a control that carries attributes** — a blank after its
     last `a( )`, before its first child. The attribute lines are the
     control's own head; the content starts below them;
  2. **a run of `tag`s** — a blank before the first one, none between them.
     A form's fields, a toolbar's buttons, a list's items belong together and
     are read as one block, whether or not each carries attributes.

  Everything else runs without a blank:
  - **none** between a control and its own `a( )`s — they are its head, not
    its content;
  - **none between consecutive `tag`s** — see block 2. This overrules
    "separate a sibling": only a *container* block is set off from the
    sibling before it;
  - **none** after a bare `ele` whose first child is another `ele` — a
    `Shell` → `Page` scaffold is one path down, not two blocks;
  - **blank before every `end`**; none after an `end` or between two `end`s.
- Long text or binding values split with `&&` — an `.abap` line is capped at
  255 characters.

The two blocks, and the scaffold that is neither:

```abap
    )->ele( `Shell`                        " bare ele into another ele -
        )->ele( `Page`                     " one path down, no blank
            )->a( n = `title` v = `My App`
                                           " block 1: Page's content starts
            )->ele( n = `SimpleForm` ns = `form`
                )->a( n = `editable` v = `true`
                                           " block 1: SimpleForm's content
                )->ele( n = `content` ns = `form`
                                           " block 2: the run of leafs
                    )->tag( n = `Title` ns = `core`
                        )->a( n = `text`  v = `Your data`
                    )->tag( `Label`
                        )->a( n = `text`  v = `Name`
                    )->tag( `Input`
                        )->a( n = `value` v = client->_bind( name ) ).
```

The blank above `Title` is what makes the three fields read as the form's
content rather than as a continuation of the `content` aggregation; the
missing blanks between them are what keep the three together. Blanks in both
places, or in neither, and the same view reads as a pile of fragments.

**The blank lines are the part no gate catches.** abaplint's formatting rules
are deliberately kept off the app chains (`align_parameters` and
`line_break_multiple_parameters` are excluded in the framework repository's
`.github/abaplint/auto_abaplint_fix.jsonc`, `indentation` is off — they would
flatten exactly the layout this section builds), and no linter rule judges
where a blank line belongs. That stays with the reader.

The *shape* around them is judged. The abap2UI5-linter has three layout rules:
`chain-indentation` (a sibling in a different column than its siblings, a call
written left of the element it belongs to; the step *size* is not judged, only
that a chain keeps its own rhythm), `chain-element-per-line` (several controls
on one line; attributes may share their control's line, and so may the
container it opens), and `chain-house-layout`, which judges the step size too
and is the one this section describes.

**All three default to `hint`, which a config with `failOn: warning` does not
even print — so what decides is the repository you are in, and every repository
in this ecosystem raises them.** `abap2UI5`, `abap2UI5/samples-stack` and
`abap2UI5/app-template` enable `chain-house-layout` at `warning`;
`abap2UI5/samples` raises `chain-indentation` and `chain-element-per-line`
instead; `abap2UI5/samples-controls` runs its own `chain-format` gate. Check
the config before you trust a green run — and either way, re-read the chain you
just wrote against the example above.

#### What a broken chain looks like

From `abap2UI5/samples` `z2ui5_cl_smp_app_052`, after the port to this builder
— lint-green, and unreadable:

```abap
    lo_popover->ele( `Popover`
        )->a( n = `title`        v = |abap2UI5 - Popover - { mv_product }|
        )->a( n = `contentWidth` v = `20rem` )->ele( n = `SimpleForm` ns = `form`
          )->a( n = `layout`   v = `ColumnLayout`
          )->a( n = `editable` b = abap_false )->ele( n = `content` ns = `form` )->tag( `Label`
              )->a( n = `text` v = `Product` )->tag( `Text`
              )->a( n = `text` v = mv_product )->tag( `Text`
              )->a( n = `text` v = `this is a text` )->end( )->end( )->ele( `footer` )->ele( `OverflowToolbar`
              )->tag( `ToolbarSpacer` )->tag( `Button`
                )->a( n = `press` v = client->_event( `BUTTON_DETAILS` ) ).
```

Three defects, and they compound: the indent steps by 2 and then by 4 and then
stops moving at all; one line opens `content` *and* a `Label`; and the
`` )->end( )->end( )->ele( `footer` )->ele( `OverflowToolbar` `` at the end of
an attribute line leaves the `ToolbarSpacer` two levels away from where its
column claims it is. Nothing here says `footer` is a sibling of `SimpleForm`.
The same tree, with the subtree held in a variable:

```abap
    DATA(popover) = lo_popover->ele( `Popover`
        )->a( n = `title`        v = |abap2UI5 - Popover - { mv_product }|
        )->a( n = `contentWidth` v = `20rem` ).

    popover->ele( n = `SimpleForm` ns = `form`
        )->a( n = `layout`   v = `ColumnLayout`
        )->a( n = `editable` b = abap_false
        )->ele( n = `content` ns = `form`
            )->tag( `Label` )->a( n = `text` v = `Product`
            )->tag( `Text`  )->a( n = `text` v = mv_product
            )->tag( `Text`  )->a( n = `text` v = `this is a text` ).

    popover->ele( `footer` )->ele( `OverflowToolbar`
        )->tag( `ToolbarSpacer`
        )->tag( `Button`
            )->a( n = `press` v = client->_event( `BUTTON_DETAILS` )
            )->a( n = `text`  v = `details` ).
```

## 4. Data binding

- `client->_bind( var )` binds a PUBLIC attribute: the value renders into
  the view, and user input is written back into the attribute
  before your event handler runs. Use it for everything, display-only
  included (`_bind_edit` is an obsolete alias — do not use it in new code).
- Inside a bound aggregation (a table/list template), child properties bind
  **relative to the row** with braces on the upper-cased field name:
  `` `{PRODUCT}` ``. A camelCase ABAP field `supplierName` becomes
  `{SUPPLIERNAME}`.
- A value shared by the whole app lives at the model **root** — inside a row
  template a relative `{FIELD}` resolves against the row and silently renders
  empty if the row has no such column; bind root values with
  `client->_bind( field )` even inside templates.
- **Never hard-code a model path as text** (`'/T_ITEMS'`): paths come from
  `_bind`, so renames cannot break bindings. For raw binding-info strings
  (typed bindings, sorters) get the bare path via
  `client->_bind( val = t_items path = abap_true )`, e.g.
  `` v = |\{ path: '{ client->_bind( val = t_items path = abap_true ) }', sorter: \{ path: 'PRODUCT' \} \}| ``.
- Typed/complex bindings pass through verbatim (braces escaped):
  `` v = |\{ path: 'PRICE', type: 'sap.ui.model.type.Float' \}| `` — note the
  `path:` uses the upper-cased ABAP field name.
- Type numeric/boolean model fields as `i`/`p`/`abap_bool`, not `string` —
  UI5 2.x rejects a JSON string on a float/int/boolean control property.
- An ABAP field is never *absent* — it is initial — so by default every field
  reaches the browser as an explicit `""`/`0`, which **overrides the control's
  own default** (and an enum-typed property rejects the empty string outright).
  When a bound template's rows fill different subsets of the same properties,
  bind with `client->_bind( val = t_rows omit_initial = abap_true )`: initial
  fields then stay out of the model and each control keeps its UI5 default.
  A **boolean that must send `false`** is the exception — `abap_false` is
  itself initial, so the blanket flag would drop it and the control would fall
  back to its default `true`. Scope the omission instead:
  `client->_bind( val = t_rows omit_initial_paths = VALUE #( ( `MIN` ) ( `MAX` ) ) )`
  lists the columns that may vanish and leaves every other field alone.
- A control property that expects an **object** — a `sap.ui.integration`
  widgets:Card `manifest` is the case this exists for — cannot be fed from a
  typed ABAP value at all: a manifest's keys (`sap.app`, `sap.card`) are not
  valid ABAP field names, so it is no structure, and UI5 reads a *string*
  manifest as a manifest **URL**. Keep the JSON in a `string` attribute and
  bind it with `client->_bind( val = manifest json = abap_true )` — the
  serializer then splices its content into the model as a JSON node instead of
  a quoted string. Outbound only (the client renders such a payload, it never
  authors it), and a string that does not parse raises rather than shipping
  broken JSON. Where the sample keeps one manifest per file, bind its URL
  instead — that path needs no flag.
- **Bound data changed in an event handler is pushed automatically** — the
  framework compares the model before and after `main( )` on every event
  round-trip and, when it differs, sends it to every open view slot (MAIN,
  POPUP, POPOVER; the nested views inherit MAIN's model). A handler cannot
  render stale by forgetting anything: there is nothing to call and nothing
  to switch on. Call `view_display` again only when the view **structure**
  itself changes.
- `view_model_update( )`, `popup_model_update( )`, `popover_model_update( )`
  and the two nested variants are **obsolete and do nothing**. They stay in
  the interface so existing apps keep compiling; delete the calls whenever
  you touch such an app, and never add a new one.

## 5. Events

- Wire: `)->a( n = `press` v = client->_event( `SAVE` ) )`.
- Read in `on_event` via `CASE client->get_event( ).`.
- **Pass values into an event** with `t_arg`; read them back with
  `client->get_event_arg( )` (index only for position 2+). A value resolved
  on the client must be `$`-prefixed — `` `${PRODUCT}` `` (row field),
  `` `$event.oSource.sId` `` (the pressed control's id),
  `` `${$parameters>/selected}` `` (an event parameter). A bare `{…}` arg is
  NOT resolved and arrives empty. Booleans arrive as `abap_bool` (`X`/space).
- **A control-valued event parameter arrives as JSON.** Several UI5 events
  hand over a control or a whole array of controls rather than a scalar —
  `ViewSettingsDialog.confirm` gives `filterItems`,
  `SinglePlanningCalendar.selectedDatesChange` a list of `DateRange`. Pass the
  parameter like any other (`` `${$parameters>/filterItems}` ``); the frontend
  marshals each control into an object carrying its `ID` plus its public
  properties, so `client->get_event_arg( )` returns a JSON array you read with
  `z2ui5_cl_ajson`. Do **not** parse a display string such as
  `filterString` — it is localized and its format is not a contract.
  **Map corresponding fields only**: the payload carries *every* public
  property of the control, not just the ones you modelled — a
  `ViewSettingsItem` also brings `enabled`, `textDirection` and `wrapping` —
  and a plain `to_abap( )` aborts on the first field your structure lacks
  (`Path not found @/1/wrapping`). Chain
  `parse( … )->to_abap_corresponding_only( )->to_abap( … )` and declare only
  the fields you actually use.
- Roundtrip-free client actions: `client->follow_up_action( val = … t_arg = … )`
  written where its RESULT is consumed — in a view attribute — runs a
  whitelisted frontend action without a server call (toast from a row value,
  client-side sort/filter via `binding_call`, …). `client->_event_client( )`
  is the obsolete name for exactly this and emits the identical wire.
- After the response, `client->follow_up_action( val = … t_arg = … )` as a
  STATEMENT schedules a frontend action: focus (`cs_event-set_focus`), scroll, title,
  clipboard, timers, keyboard shortcuts, `control_by_id` (call a public
  method on a control), `binding_call` (filter/sort an aggregation binding).
  The full catalog with per-action `t_arg` documentation sits on
  `z2ui5_if_client=>follow_up_action` and in `cs_event`.

## 6. Popups, popovers, messages

- `client->popup_display( val = … )` opens a `core:FragmentDefinition`
  string (build it with `z2ui5_cl_ui5_view_builder` too) as a dialog. Closing: wire a
  Close button to `client->_event( z2ui5_if_client=>cs_event-popup_close )`
  (the framework handles it without reaching your `on_event`), or call
  `client->popup_destroy( )` server-side after handling your own event.
- `client->popover_display( xml = … by_id = … )` anchors a popover to a
  control id. **Mind the asymmetry**: the popup takes its XML as `val`, the
  popover as `xml` — one of the most common first-try mistakes.
- `client->message_toast_display( text )` and
  `client->message_box_display( text type title actions … )` for messages —
  never build your own toast/dialog for these.
- Bind popup data exactly like main-view data; changed bound data reaches
  an open popup automatically.
- A popup or popover is closed automatically by anything that replaces the
  screen underneath it: a `client->view_display( )` in the same roundtrip
  and a navigation to another app both take it down. Re-open it in that same
  roundtrip if it is meant to stay — `view_display( )` first, then
  `popup_display( )` — and call `popup_destroy( )` only when you close it
  without rebuilding the view.

## 7. Multi-view, navigation, routing

- One app can render `main`, two nested views, a popup and a popover
  simultaneously (`cs_view` names them for scoped actions).
- Call another app: `client->nav_app_call( NEW zcl_other_app( ) )`; return
  with `client->nav_app_leave( )` (or `client->get_app_prev( )` to hand data
  back). The framework keeps the app stack across roundtrips.
- URL routing: `client->follow_up_action( val = z2ui5_if_client=>cs_event-set_nav_routing )`
  in `check_on_init` makes the app bookmarkable and wires the browser
  Back/Forward buttons — the mode rides in `t_arg`: `cs_nav_mode-keep` (the
  default when `t_arg` is empty) restores the exact draft state,
  `cs_nav_mode-fresh` restarts clean. Works inside the Fiori Launchpad.

## 8. Rules that keep apps portable

- **Thin frontend**: business logic (thresholds, classification, unit
  conversion, validation) is computed in ABAP and bound as a finished value —
  never in a frontend formatter or custom JS. The shipped `z2ui5.Formatter`
  helpers are a **marshalling layer, not a formatting toolbox**: a function
  only lives there when ABAP physically cannot produce the finished value —
  a real JS `Date` for an object-typed property (`DateCreateObject`,
  `DateAbapDateToDateObject`, `DateAbapDateTimeToDateObject`) or an icon-font
  glyph of the loaded theme (`expandInlineIcons`). That is the whole set.
  Rounding a number, joining fields into a string or mapping a status to a
  `ValueState`/icon is your app's job: compute it in ABAP and bind it
  (`state="{STATUS_STATE}"`). Functions that did those things were shipped
  once and removed again — the module header states the admission criteria
  and `npm run check:formatter` enforces them.
- **UI5 1.71 floor**: the framework supports OpenUI5 down to 1.71. Before
  using a control/property/aggregation, check its "available since" in the
  UI5 API — post-1.71 members need a UI5 release that has them; a wrong
  aggregation name 404s the whole view on old releases.
- **State discipline**: every PUBLIC attribute is serialized into the draft
  and sent to the browser on every render. Large helper data, catalogs and
  anything not bound belongs in PROTECTED (or is re-read per request) — a
  bloated public section makes every click slower.
- Authorization is **the app's job**: any user who can reach the ICF node can
  start any `z2ui5_if_app` class. Check your authorizations at the top of
  `main` and render an error/leave when denied.
- The default UI5 bootstrap loads from the CDN; system-local hosting and
  CSP/theme/bootstrap customizing go through `z2ui5_if_exit` /
  `z2ui5_cl_ui5_user_exit`.
- **A third-party JS library is a deployment decision, not a view trick.**
  The default CSP in `z2ui5_cl_ui5_user_exit` already whitelists `cdn.jsdelivr.net`
  and `cdnjs.cloudflare.com`, so a library loaded from one of them is
  allowed out of the box — anything else needs your own
  `content_security_policy` in the exit, and a system-local copy served by
  your own ICF node is the option that survives an offline system. Whichever
  you pick, load the library through the UI5 loader
  (`sap.ui.loader.config` path mapping + `sap.ui.define`) and drive it from a
  custom control; do **not** rely on the jQuery `$` global — UI5 2.x no
  longer ships it — and keep the library call itself free of business
  decisions (see "thin frontend" above).
- **An imperative UI5 method that has no bindable equivalent** — the
  `sap.m.p13n.*` panels take their item list only through `setP13nData( )`,
  a `sap.m.Carousel` only moves via `setActivePage( )` — is reached with
  `client->follow_up_action( val = cs_event-control_by_id … )`. Check
  `cs_event` and the whitelist before writing custom JS: an argument the
  whitelist does not declare is silently dropped, but a method it declares
  needs no JS at all.

## 9. Validate and iterate like the framework does

- **Starting a new app repo? Use
  [abap2UI5/app-template](https://github.com/abap2UI5/app-template)** — it
  ships the starter app, abaplint + linter CI, this guide as its AGENTS.md
  and the agent permission setup preconfigured.
- **[abap2UI5-linter](https://github.com/abap2UI5/linter)** checks
  app classes statically (unknown/deprecated/too-new controls and members,
  binding mistakes, builder-tree defects) and can render the view headless:
  `npx --yes @abap2ui5/linter my_app.clas.abap` — also
  available as a GitHub Action and inside the VS Code extension.
- **[mcp-server](https://github.com/abap2UI5/mcp-server)** gives MCP-capable agents
  the full loop without a SAP system: `capabilities` → `deploy_app` →
  `build_backend` → `run_app` (headless screenshot + errors).
- **[vscode-extension](https://github.com/abap2UI5/vscode-extension)**:
  F9 launches the class in an embedded preview against a real system.
- **Worked examples**, three catalogues with the same row shape, so one search
  reads all of them: curated apps for "has somebody built this pattern" in
  [abap2UI5/samples](https://github.com/abap2UI5/samples), 416 gate-verified
  demo-kit ports for "how is this control expressed" in
  [samples-controls](https://github.com/abap2UI5/samples-controls) (`src/`), and
  apps that need something from your stack — OData, RAP, APC, the launchpad —
  in [samples-stack](https://github.com/abap2UI5/samples-stack). What abap2UI5
  can express at all is answered in samples-controls' `CAPABILITIES.md`, each
  claim naming the port that proves it.
