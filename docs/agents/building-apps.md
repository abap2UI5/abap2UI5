# Building apps with abap2UI5 — the agent guide

Self-contained, offline reference for AI assistants (and humans) **building
apps with** abap2UI5. It is derived from the framework sources in this
repository (`src/02/` public API, `z2ui5_cl_ai_xml`, the hello-world app) and
the conventions proven over the ~280 ported UI5 demo-kit samples in
[ai-demokit](https://github.com/abap2UI5/ai-demokit). The rendered
documentation site is <https://abap2ui5.github.io/docs/> — this file exists so
an agent without web access has the complete picture in-repo. When this guide
and the code disagree, the code wins (`src/02/z2ui5_if_client.intf.abap` is
the contract).

For working **on the framework itself**, read `AGENTS.md` instead.

## 1. The model in one paragraph

An abap2UI5 app is **one ABAP class** implementing `z2ui5_if_app`. The
framework calls its `main( client )` method on every HTTP roundtrip: once at
startup (`check_on_init`) and once per user interaction (`check_on_event`).
The app builds a UI5 XML view as a string, binds ABAP attributes into it
two-way, and registers named events. Between roundtrips the framework
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
    ELSEIF client->check_on_event( ).
      on_event( ).
    ELSEIF client->check_on_navigated( ).
      view_display( ).
    ENDIF.

  ENDMETHOD.

  METHOD view_display.

    DATA(view) = z2ui5_cl_ai_xml=>factory( ).

    view->open( n = `View` ns = `mvc`
        )->a( n = `xmlns`     v = `sap.m`
        )->a( n = `xmlns:mvc` v = `sap.ui.core.mvc`
        )->a( n = `displayBlock` v = `true`
        )->a( n = `height`       v = `100%`

        )->open( `Page`
            )->a( n = `title` v = `My App`

            )->leaf( `Input`
                )->a( n = `value` v = client->_bind( name )

            )->open( `List`
                )->a( n = `items` v = client->_bind( t_items )
                )->open( `items`
                    )->leaf( `StandardListItem`
                        )->a( n = `title` v = `{PRODUCT}`
                        )->a( n = `info`  v = `{QUANTITY}`

                )->shut(
            )->shut(

            )->leaf( `Button`
                )->a( n = `text`  v = `Save`
                )->a( n = `press` v = client->_event( `SAVE` ) ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

  METHOD on_event.

    CASE client->get( )-event.
      WHEN `SAVE`.
        " bound data (name, t_items) already carries the user's input here
        client->message_toast_display( |Saved, { name }| ).
        client->view_model_update( ).
    ENDCASE.

  ENDMETHOD.

  METHOD model_init.
    t_items = VALUE #( ( product = `Notebook` quantity = 2 )
                       ( product = `Mouse`    quantity = 5 ) ).
  ENDMETHOD.

ENDCLASS.
```

Conventions that keep apps uniform (proven in the ai-demokit corpus):
`main` is a pure dispatcher; methods follow in call order with `model_init`
last; add `model_init`/`on_event` only when the app has data/events; always
dispatch events with `CASE client->get( )-event.` even for a single event.
**The `check_on_navigated( )` branch is part of the canonical dispatcher, not
an option**: without it the view is only ever built on `check_on_init`, so
navigating away (`nav_app_call`) and back leaves the app blank — the
framework fires `check_on_navigated`, nothing re-displays. Always re-run
`view_display( )` there.

## 3. The view builder — `z2ui5_cl_ai_xml`

The builder maps **any** UI5 XML view 1:1 — every control, property,
aggregation and namespace, nothing is wrapped or approximated. Four verbs:

| Verb | XML meaning | Tree action |
|---|---|---|
| `open( n ns a )` | opening tag `<X>` | add child and **descend** into it |
| `leaf( n ns a )` | self-closing `<X/>` | add child, **stay** on current node |
| `shut( )` | closing `</X>` | **ascend** to the parent |
| `a( n v )` | one `name="value"` | attribute on the control just opened/leaf'd |

- `n` = tag name, `ns` = namespace **prefix** (`f`, `l`, `core`, `mvc`, …);
  omit `ns` for the default namespace (usually `sap.m`). Declare every
  namespace as `xmlns:*` attributes on the root `View`, exactly like XML.
- **Aggregations are just tags**: `)->open( `items` )` for `<items>`. An
  aggregation carries the same prefix as in the XML — `<m:content>` under a
  `sap.ui.table` default namespace is `)->open( n = `content` ns = `m` )`.
- `stringify( )` renders from the root, so trailing `shut( )` calls before
  the final `).` are optional — `shut` only moves the cursor to add siblings.
- **Booleans from ABAP variables** go through
  `z2ui5_cl_ai_xml=>as_bool( flag )` (a literal is just `` v = `true` `` —
  never feed `abap_true` raw, it serializes as `X`).
- Braces `{ }` inside an ABAP `|…|` string template must be escaped
  `\{ \}` — an unescaped `{` is parsed as a UI5 binding.

The legacy fluent builder `z2ui5_cl_xml_view` (one method per control) still
ships for existing apps but is **frozen** — new apps and new code use
`z2ui5_cl_ai_xml`.

## 4. Data binding

- `client->_bind( var )` binds a PUBLIC attribute **two-way**: the value
  renders into the view, and user input is written back into the attribute
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
- After changing bound data in an event handler, push it to the browser with
  `client->view_model_update( )` (no full re-render); call `view_display`
  again only when the view structure itself changes.

## 5. Events

- Wire: `)->a( n = `press` v = client->_event( `SAVE` ) )`.
- Read in `on_event` via `CASE client->get( )-event.`.
- **Pass values into an event** with `t_arg`; read them back with
  `client->get_event_arg( )` (index only for position 2+). A value resolved
  on the client must be `$`-prefixed — `` `${PRODUCT}` `` (row field),
  `` `$event.oSource.sId` `` (the pressed control's id),
  `` `${$parameters>/selected}` `` (an event parameter). A bare `{…}` arg is
  NOT resolved and arrives empty. Booleans arrive as `abap_bool` (`X`/space).
- Roundtrip-free client actions: `client->_event_client( val = … t_arg = … )`
  runs a whitelisted frontend action without a server call (toast from a row
  value, client-side sort/filter via `binding_call`, …).
- After the response, `client->follow_up_action( val = … t_arg = … )`
  schedules a frontend action: focus (`cs_event-set_focus`), scroll, title,
  clipboard, timers, keyboard shortcuts, `control_by_id` (call a public
  method on a control), `binding_call` (filter/sort an aggregation binding).
  The full catalog with per-action `t_arg` documentation sits on
  `z2ui5_if_client=>follow_up_action` and in `cs_event`.

## 6. Popups, popovers, messages

- `client->popup_display( val = … )` opens a `core:FragmentDefinition`
  string (build it with `z2ui5_cl_ai_xml` too) as a dialog. Closing: wire a
  Close button to `client->_event( z2ui5_if_client=>cs_event-popup_close )`
  (the framework handles it without reaching your `on_event`), or call
  `client->popup_destroy( )` server-side after handling your own event.
- `client->popover_display( xml = … by_id = … )` anchors a popover to a
  control id. **Mind the asymmetry**: the popup takes its XML as `val`, the
  popover as `xml` — one of the most common first-try mistakes.
- `client->message_toast_display( text )` and
  `client->message_box_display( text type title actions … )` for messages —
  never build your own toast/dialog for these.
- Bind popup data exactly like main-view data; update with
  `popup_model_update( )`.

## 7. Multi-view, navigation, routing

- One app can render `main`, two nested views, a popup and a popover
  simultaneously (`cs_view` names them for scoped actions).
- Call another app: `client->nav_app_call( NEW zcl_other_app( ) )`; return
  with `client->nav_app_leave( )` (or `client->get_app_prev( )` to hand data
  back). The framework keeps the app stack across roundtrips.
- URL routing: `client->set_nav_routing( )` in `check_on_init` makes the app
  bookmarkable and wires the browser Back/Forward buttons —
  `cs_nav_mode-keep` (default) restores the exact draft state,
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
  `z2ui5_cl_exit`.

## 9. Validate and iterate like the framework does

- **Starting a new app repo? Use
  [abap2UI5/app-template](https://github.com/abap2UI5/app-template)** — it
  ships the starter app, abaplint + linter CI, this guide as its AGENTS.md
  and the agent permission setup preconfigured.
- **[abap2UI5-linter](https://github.com/abap2UI5/linter)** checks
  app classes statically (unknown/deprecated/too-new controls and members,
  binding mistakes, builder-tree defects) and can render the view headless:
  `npx --yes github:abap2UI5/linter my_app.clas.abap` — also
  available as a GitHub Action and inside the VS Code extension.
- **[ai-mcp](https://github.com/abap2UI5/ai-mcp)** gives MCP-capable agents
  the full loop without a SAP system: `capabilities` → `deploy_app` →
  `build_backend` → `run_app` (headless screenshot + errors).
- **[vscode-extension](https://github.com/abap2UI5/vscode-extension)**:
  F9 launches the class in an embedded preview against a real system.
- **Worked examples**: ~280 gate-verified sample apps in
  [ai-demokit](https://github.com/abap2UI5/ai-demokit) (`src/`), curated
  samples in [abap2UI5/samples](https://github.com/abap2UI5/samples), and
  what-is-expressible answers in ai-demokit's `CAPABILITIES.md`.
