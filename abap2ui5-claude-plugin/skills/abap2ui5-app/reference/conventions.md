# Conventions

There are **abap2UI5 essentials** that always apply, and **ABAP style** which
depends on your project. Match the conventions of the project you're working in
(if it has an `abaplint.jsonc`, that is the source of truth). Below: the
essentials first, then the two established style flavors so you can pick.

## abap2UI5 essentials (always)
- One class per app: `INTERFACES z2ui5_if_app.`, entry point
  `METHOD z2ui5_if_app~main.` (`IMPORTING client TYPE REF TO z2ui5_if_client`).
- Drive flow with the lifecycle checks, **chained with `ELSEIF`**, never separate
  `IF`s:
  ```abap
  IF client->check_on_init( ).         " first roundtrip
    ...
  ELSEIF client->check_on_navigated( ). " returned from a sub-app/popup
    ...
  ELSEIF client->check_on_event( ).     " a user event fired
    ...
  ENDIF.
  ```
  For a specific event, `check_on_event( 'SAVE' )`; for many events, a
  `CASE client->get( )-event.`.
- Never use an init flag (`mv_init`, `is_initialized`, …) — use
  `client->check_on_init( )`.
- **Binding direction is the #1 source of bugs:** `_bind_edit( var )` = two-way
  (editable, read back next roundtrip); `_bind( var )` = read-only (display, list
  / combo / suggestion items). Use `path = abap_true` when only the binding path
  is needed inside a JSON literal (`items` / `rows`).
- Build the view with `z2ui5_cl_xml_view=>factory( )`, finish with
  `client->view_display( view->stringify( ) )` as a **standalone final
  statement** — never nested in the fluent chain.
- Indent the fluent chain to mirror the XML hierarchy: descending into a child
  indents deeper; siblings stay at the same level. One control parameter → inline;
  two or more → one per line, aligned.
- Back navigation: bind `navbuttonpress = client->_event_nav_app_leave( )` +
  `shownavbutton = client->check_app_prev_stack( )` directly in the view.
- App-to-app: push with `client->nav_app_call( NEW zcl_other( ) )` (set public
  attributes on the instance first to pass parameters); read results back in the
  `check_on_navigated` branch via `CAST zcl_other( client->get_app_prev( ) )`.

## Deprecated / avoid
- Prefer the fluent `z2ui5_cl_xml_view` builder over hand-assembling XML
  strings. The former generic builder `z2ui5_cl_util_xml` is obsolete (moved
  to package `src/99`) — do not use it in new apps.
- Avoid `boolc( )` — use `xsdbool( )`.
- The canonical, always-current list of deprecated controls and patterns is in
  the official guide: <https://abap2ui5.github.io/docs/advanced/agent.html>.

## ABAP style — match the project; these are reasonable defaults

**Most important: match the conventions of the project you're editing.** Read its
`abaplint.jsonc` and a couple of existing classes first. If there is no house
standard, the defaults below are safe.

Note that **app classes are written in a light style** even in the official repos
— e.g. the framework's own `z2ui5_cl_app_hello_world` and every sample app use no
Hungarian prefixes on scalars and a single `client` reference. The heavy
`mv_/mo_/mt_` prefixing documented for the framework is mainly its **internal
engine** convention, not a requirement for your app classes.

Sensible defaults for a new app class (used by the bundled templates):
- `CLASS zcl_my_app DEFINITION PUBLIC FINAL CREATE PUBLIC.` (`FINAL` is a good
  default; drop it only if you subclass). Some teams omit `FINAL`/`CREATE PUBLIC`
  — both are fine.
- All three sections present (`PUBLIC` / `PROTECTED` / `PRIVATE`), even if empty.
- Light naming: no prefix on scalars; `t_`/`s_` for tables/structures; `ty_s_`/
  `ty_t_` for local types. A single member `client TYPE REF TO z2ui5_if_client`.
- Backtick string literals; `NEW #( )` not `CREATE OBJECT`; `xsdbool( )` not
  `boolc( )`; `line_exists( )` not `READ TABLE`.

If your project mandates full Hungarian notation, `FINAL`, etc., apply it — the
templates are a starting point, not a constraint.

> The **samples** repo has its own stricter house style (lowercase class
> names, no `FINAL`/`CREATE PUBLIC`). Follow that **only** when contributing demos
> to that repo.
