---
target: abap2ui5
title: 'A named API over the positional `t_arg` frontend-action wire'
summary: 425 + 99 calls across 130 ports go through a positional argument table — deferred to a future dedicated ACTION OBJECT (maintainer decision 2026-08-11), and this item is the collected requirement for it
priority: medium
state: deferred
first_seen: 2026-08-11
upstream: abap2UI5/abap2UI5
evidence:
  - the corpus' most error-prone API — four arg-shape incidents to date (probe apps 609/624/625, app 012, app 263, app 285)
  - usage order 295 `control_global` / 137 `control_by_id` / 25 `binding_call` / 3 `keyboard_shortcut`
  - a per-method variant was implemented and reverted the same day (`f1a1813`, reverted by `208b7ec`) — the wire-fidelity test approach is preserved there
---

# A named API over the positional `t_arg` frontend-action wire

**Status: deferred to a future ACTION OBJECT (maintainer decision
2026-08-11).** The per-method variant WAS implemented and then deliberately
reverted the same day: 7 `z2ui5_if_client` methods (`toast_client`,
`control_call`/`control_call_client`, `binding_filter`/`binding_sort` +
`_client` twins), thin delegations unit-tested **byte-identical** to the
generic positional form — preserved in abap2UI5 git history on branch
`claude/ai-demokit-samples-simplify-kneyyl` (`f1a1813`, reverted by
`208b7ec`) and recorded in the framework's AGENTS.md Design Decisions.
Direction instead: collect these actions in **one dedicated action object**
with a designed surface rather than growing the client interface method by
method; observe real usage first, design later. This folder stays open as
the collected requirements for that object — the corpus usage numbers below
(295 control_global wires / 137 control_by_id / 25 binding_call / 3
keyboard_shortcut) are the priority order, and the reverted commit is the
reference for wire fidelity and the byte-identity test approach. Until the
object exists, ports keep using the generic
`follow_up_action`/`_event_client`; do not re-add per-method wrappers to
`z2ui5_if_client`. Original proposal below.

## Design notes for the action object (collected 2026-08-11)

Requirements and decisions gathered in the review discussion, so the future
design starts from them instead of rediscovering them.

### Candidate method catalog

Grouped by domain; wire mapping in parentheses. Priority order = the corpus
usage numbers in the status note above — the **core** group carries almost
all traffic.

**Core** (the reverted set): `toast( template, t_arg )`
(CONTROL_GLOBAL/MESSAGE_TOAST/show) · `control_call( id, method, t_arg,
view )` (CONTROL_BY_ID) · `binding_filter( id, aggregation, path, operator,
value1, value2 )` / `binding_sort( id, aggregation, path, descending,
group )` (BINDING_CALL).

**Control special forms** (today hidden method tokens inside CONTROL_BY_ID —
as named methods they become discoverable): `open_by( id, anchor_id, view )`
/ `toggle_by( … )` (the whole anchored-popup idiom family) · `css( id,
property, value )` (the whitelisted CSS declaration) · `bind_element( view,
index, path )` (today the least intuitive t_arg layout — path via `_bind`,
braces stripped by the serializer).

**Browser & page**: `focus( id )` · `scroll_to( x, y )` ·
`scroll_into_view( id )` · `set_title( text )` · `set_favicon( url )` ·
`clipboard_copy( text )` · `download( b64, filename )` ·
`open_new_tab( url )` · `redirect( url )` / `mail_to( … )` / `tel( … )` /
`sms( … )` (the four URLHELPER triggers as separate methods instead of the
object-literal t_arg) · `reload( )` · `history_back( )` ·
`play_audio( url )` · `store_data( … )`.

**Time & keyboard**: `timer( interval_ms, event )` (START_TIMER) ·
`shortcut( combination, event, scope )` (KEYBOARD_SHORTCUT incl. the scope
semantics — lowest usage but the hardest signature to remember).

**UI5 global singletons** (today CONTROL_GLOBAL tokens one has to look up):
`busy( val )` (BUSY_INDICATOR) · `announce( text, mode )`
(INVISIBLE_MESSAGE — the only ARIA-live route, practically undiscoverable
without the idiom guide) · `set_theme( theme )` (THEMING) ·
`custom_currency( code, digits )` (FORMATTING) · `popup_within_area( id )`
(POPUP/setWithinArea).

**Deliberately out**: `smart_variant_init` / `filter_bar_variant_init` (too
special, generic API suffices) and everything under `cs_event`'s
"obsolete?" block.

### Delivery form — decided against runtime detection

The idea "detect at runtime whether the RETURNING value is consumed: if yes
it is a view wire, if no a direct follow-up" was examined and **rejected**:

- `IS SUPPLIED` is not allowed for `RETURNING` parameters, and there is no
  signal anyway — a functional call always binds the result, a standalone
  call discards it; the callee cannot tell the two apart.
- It DOES work with an `EXPORTING handler` parameter (`IS SUPPLIED` is legal
  there) — but an EXPORTING parameter cannot be called functionally, which
  kills the inline view-chain form `)->a( n = `press` v = action->toast( … ) )`
  that carries most of the traffic (295 of ~520 calls are view wires).
- Half of the idea exists already by accident: `follow_up_action( )` accepts
  raw JS and the `_event_client` handler string IS executable JS — but
  routing framework events through the JS-string path would regress the
  deliberate pure-data serialization (`get_event_client_json`: follow-ups
  travel as JSON arrays, escaping entirely in ABAP).
- Even if detectable, behavior switching on result consumption is
  action-at-a-distance: a handler string assigned to a variable but never
  built into the view silently does nothing (exactly the silent-failure
  class the dead-event-wire rule and auto-model-update exist to kill), and
  pulling a result into a variable for logging would change runtime
  behavior.

**Recommended surface instead — one method set, explicit terminal verb:**

```abap
)->a( n = `press` v = client->action( )->toast( template = `Hello {0}` … )->as_handler( ) )
client->action( )->toast( template = `Saved` )->run( ).
```

The verb makes explicit what today is implicit in choosing
`follow_up_action` vs `_event_client`; both forms stay functional and
inline-usable. (Runner-up: two entry points `action( )` / `action_client( )`
with a single method list each.)

### Principles carried over from the reverted implementation

- **Byte-identity as the test contract**: every method is unit-tested to
  emit exactly the wire of the hand-written generic form.
- **Pure assembly, no wire change**: `FrontendAction.js` untouched, all
  generic-path rules (allow/deny list, argument kinds, `id/aggregation/index`
  addressing) apply unchanged; the generic API remains the escape hatch.
- **UI5 version floors in the ABAP Doc per method** (`announce` ≥ 1.78,
  `popup_within_area` ≥ 1.89, `custom_currency` ≥ 1.120) — today they hide
  in the interface's collective comment.
- Before the corpus adopts the object, the linter rules that parse the
  generic calls (`frontend-action-unknown-id`, the client-composed-toast
  checks) must read the named forms too.

## Motivation

The frontend-action surface (`follow_up_action` and `_event_client`) is the
single most error-prone API in the corpus, because everything is a positional
`string_table`:

```abap
client->_event_client( val   = client->cs_event-control_global
                       t_arg = VALUE #( ( `MESSAGE_TOAST` )
                                        ( `show` )
                                        ( `Item selected: {0}` )
                                        ( `${$parameters>/item}.getText()` ) ) )
```

Measured over this corpus: **425 `_event_client` + 99 `follow_up_action`
calls in 130 of 365 ports**. The tuple order (object, method, template, args…
— different per event kind), the wire tokens (`MESSAGE_TOAST`, not
`MessageToast`), and the unvalidated id slot are all things the compiler
cannot check. The project history shows what that costs:

- the `idiom-lookup` guide needs dedicated rows just to document tuple order
  per event kind;
- two linter rules exist only to catch mistakes this API invites
  (`frontend-action-unknown-id`; the `CONTROL_METHODS` arg-kind audits);
- four of the recent framework rounds were argument-shape incidents on this
  wire (`control-method-args` → #2535, `control-method-null-arg`,
  `aggregation-item-address`, `table-set-sticky` — see `pr/README.md`
  Implemented table).

## Current behavior

`z2ui5_if_client` (src/02/z2ui5_if_client.intf.abap) offers exactly two
entries for every frontend action:

```abap
METHODS follow_up_action IMPORTING val TYPE string
                                   view TYPE clike DEFAULT cs_view-main
                                   t_arg TYPE string_table OPTIONAL.
METHODS _event_client    IMPORTING val TYPE clike
                                   view TYPE clike DEFAULT cs_view-main
                                   t_arg TYPE string_table OPTIONAL
                         RETURNING VALUE(result) TYPE string.
```

The per-kind argument contracts live only in the (long) ABAP Doc comment and
in `app/webapp/core/FrontendAction.js`.

## Proposed change

Add named convenience methods that build the same `t_arg` internally and
delegate to the existing pair — one per high-frequency kind, both in a
round-trip (`follow_up_…`) and a wire (`…_client`, returns the handler
string) flavor where both exist:

```abap
" control_by_id — today: t_arg = id / method / params
client->control_call( id = `carousel` method = `setActivePage`
                      t_arg = VALUE #( ( `carousel/pages/2` ) ) ).

" client-composed toast — today: MESSAGE_TOAST / show / template / args
)->a( n = `press` v = client->toast_client(
          template = `Item selected: {0}`
          t_arg    = VALUE #( ( `${$parameters>/item}.getText()` ) ) )

" binding_call filter — today: id / aggregation / `filter` / path / op / v1 / v2
client->binding_filter( id = `list` aggregation = `items`
                        path = client->_bind( val = t_items path = abap_true )
                        operator = `Contains` value1 = search ).
```

Design points:

- **Additive only.** `follow_up_action` / `_event_client` stay as the generic
  escape hatch (new frontend capabilities always land there first); nothing
  is deprecated.
- **Same wire.** The wrappers emit exactly the `t_arg` the frontend already
  parses — `FrontendAction.js` is not touched, so no behavior can drift.
- The candidates worth a named form, by corpus frequency: client-composed
  toast, `control_by_id` method call, `binding_call` filter/sort,
  `keyboard_shortcut`. Rare kinds stay on the generic API.
- IDE discoverability: the argument names document the contract that today
  lives in a 190-line ABAP Doc comment.

## Example

App 092's popinChanged toast today vs. proposed:

```abap
" today
)->a( n = `popinChanged` v = client->_event_client(
        val   = client->cs_event-control_global
        t_arg = VALUE #( ( `MESSAGE_TOAST` ) ( `show` )
                         ( `Number of hidden pop-ins: {0}` )
                         ( `${$parameters>/hiddenInPopin}.length` ) ) )

" proposed
)->a( n = `popinChanged` v = client->toast_client(
        template = `Number of hidden pop-ins: {0}`
        t_arg    = VALUE #( ( `${$parameters>/hiddenInPopin}.length` ) ) )
```
