---
description: Explain an existing abap2UI5 app class - lifecycle, events, data binding and the view tree - for a developer who is new to abap2UI5.
argument-hint: <class name or path to the .clas.abap>
allowed-tools: Read, Grep, Glob, mcp__plugin_abap2ui5_abap2ui5__read_example, mcp__plugin_abap2ui5_abap2ui5__screenshot_view, mcp__plugin_abap2ui5_abap2ui5__api_reference, mcp__plugin_abap2ui5_abap2ui5__app_guide
---

Explain this abap2UI5 app class: **$ARGUMENTS**

Find the file: a path is used as given; a class name is looked up as
`**/<name lower-cased>.clas.abap` in the project. Not found locally and it
looks like a sample class (`Z2UI5_CL_SMP*`): MCP
`read_example { class }`. Nothing given: ask.

Read the whole class first. For the framework side, the guide is
`${CLAUDE_PLUGIN_ROOT}/docs/agents/building-apps.md` (MCP `app_guide`), and
`api_reference` documents every `z2ui5_if_client` method. Explain what
**this** class does - never describe a method it does not call.

Write for a developer who knows ABAP but not abap2UI5. Sections:

1. **What it is** - two sentences: what the user sees and can do.
2. **How abap2UI5 runs it** - one short paragraph: one class implementing
   `z2ui5_if_app`, `main( client )` runs on every roundtrip, the instance is
   serialized between roundtrips, so PUBLIC attributes are the state the
   browser sees.
3. **Lifecycle** - which branches `main` has (`check_on_init( )`,
   `check_on_navigated( )`, `check_on_event( )`), what each does here, and
   in which order they run on start, after an event, and after returning
   from a called app or popup. Point out a missing `check_on_navigated( )`
   display branch if there is one.
4. **State and binding** - a table: attribute, type, how it is bound
   (`_bind` = two-way, row-template fields as `{FIELD}` inside a bound
   table), and which control shows it. Name attributes that are PUBLIC but
   never bound (they travel to the browser for nothing).
5. **Events** - a table: event name, which control fires it
   (`_event( ... )` / `follow_up_action( ... )`), arguments, and what the
   handler does. Include frontend-only actions (`_event_client`).
6. **The view tree** - the `z2ui5_cl_ui5_view_builder` chain redrawn as an
   indented tree of controls (namespace prefix, the bindings and events on
   each), so the nesting is visible at a glance. Popups and popovers get a
   tree each. With the MCP server, `screenshot_view { abap_source }` shows
   what it looks like - mention what the picture shows.
7. **Navigation and popups** - `nav_app_call` / `nav_app_leave`, popups
   and value helps, if any.
8. **Worth knowing** - at most five points a newcomer would trip over in
   this class (a state pitfall, a binding subtlety, something that needs a
   newer UI5 than 1.71). No style review - `/abap2ui5:check` and the
   `abap2ui5-reviewer` agent do that.

Quote line numbers (`file:line`) when you refer to code.
