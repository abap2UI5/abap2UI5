---
target: abap2ui5-linter
title: 'unknown-builder-method reports z2ui5_cl_ui5_view_builder=>component_path( )'
summary: 'the linter''s list of builder statics knows only factory( ) and escape_literal( ), so the new public component_path( ) - the API building-apps recommends for a namespaced column - is reported as an error and has to be suppressed'
priority: high
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
evidence:
  - 'abap2UI5 40e8a073 (2026-11-24) added CLASS-METHODS component_path to z2ui5_cl_ui5_view_builder (src/02), the documented way to bind a column whose name is only known at run time (docs/agents/building-apps.md section 4)'
  - '@abap2ui5/linter 0.11.0, lib/builders.mjs: VIEW_BUILDER.statics = [''factory'', ''escape_literal''] - "what unknown-builder-method accepts beside the verbs and stringify( )"'
  - 'abap2UI5/table-maintenance 880fc2d: Z2UI5_CL_TM_001 suppresses the error with `" abap2ui5lint-disable-next-line unknown-builder-method -- component_path( ) is a static of the builder since abap2UI5 40e8a073, the linter 0.11 does not know it yet`'
  - 'abap2UI5/linter#196 (open) reports drift of the hand-maintained mirrors checked by scripts/check-upstream.mjs (formatters, frontend actions, released API, companion controls); the builder statics are not among the mirrors it checks (searched 2026-11-24)'
---

# unknown-builder-method reports z2ui5_cl_ui5_view_builder=>component_path( )

## Current behaviour

`lib/builders.mjs` describes the view builder with a hand-written list of
its class methods:

```js
// the class's other public methods (CLASS-METHODS of its PUBLIC SECTION):
// what unknown-builder-method accepts beside the verbs and stringify( )
statics: ['factory', 'escape_literal'],
```

abap2UI5 40e8a073 added a third, `component_path( )`, which returns the
row-relative binding path of a column (`/CWM/XCWMAT` becomes `CWM/XCWMAT`)
and is what `building-apps` section 4 tells an app to use. Every call of it
is reported by `unknown-builder-method` as an error:

```abap
DATA(path) = z2ui5_cl_ui5_view_builder=>component_path( layout->fname ).   " unknown-builder-method
```

The first consumer, abap2UI5/table-maintenance 880fc2d, had to suppress it
with a disable comment. A false positive on the API the documentation
recommends teaches people to suppress the rule.

## Proposed change

1. **Now:** add `component_path` to `VIEW_BUILDER.statics`.
2. **So it does not happen again:** take the list from abap2UI5 instead of
   writing it by hand. abap2UI5 already publishes
   `.github/shared/linter-manifest.json`, generated from its sources, and
   `scripts/check-upstream.mjs` compares the linter's mirrors against it.
   The public `CLASS-METHODS` of `z2ui5_cl_ui5_view_builder` can be one more
   entry of that manifest (a `builderStatics` list), so the next static is
   reported as drift by the linter's own check rather than as an error in a
   consumer's CI. The manifest side is an abap2UI5 change; the linter side
   is reading it and comparing.

## What must still be reported

- An instance method that does not exist (`view->tagg( )`) - the rule's
  purpose.
- A static that does not exist (`z2ui5_cl_ui5_view_builder=>escape( )`).
- `component_path( )` called on the frozen builder (`z2ui5_cl_xml_view`),
  which does not have it.
