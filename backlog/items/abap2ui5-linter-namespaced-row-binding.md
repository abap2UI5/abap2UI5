---
target: abap2ui5-linter
title: 'Report a row binding that writes a namespaced column as an absolute path'
summary: 'a row template that binds a column like /CWM/XCWMAT as {/CWM/XCWMAT}, or builds the braces around a column name only known at run time without component_path( ), binds an absolute path - the cell is empty and an edit is lost, with no error anywhere'
priority: high
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
evidence:
  - 'abap2UI5 40e8a073 (2026-11-24): the model writes a namespaced column as a level of its row ("CWM":{"XCWMAT":...}) and z2ui5_cl_ui5_view_builder=>component_path( ) returns the row-relative path; before it, a row template''s {/CWM/XCWMAT} rendered an empty cell and an edit went nowhere - found on EWM apps over /SCWM/ tables in a consumer system'
  - 'abap2UI5/table-maintenance 880fc2d: the maintenance list (Z2UI5_CL_TM_001) built `|\{{ path }\}|` from the column name of a table it only knows at run time; now through component_path( )'
  - 'abap2UI5/layout-management 0ca56e3: the same shape in the layout XML builder (Z2UI5_CL_LAYO_XML_BUILDER), one binding per column of any table a layout is defined over'
  - 'a downstream app repository, review of 2026-11 - an inventory app has the same shape: a namespaced column bound in a row template'
  - 'docs/agents/building-apps.md section 4 documents the rule as prose; @abap2ui5/linter 0.11.0 has no rule for it (unknown-binding-path judges a path against the derived model, not the namespace shape); no issue in abap2UI5/linter (searched 2026-11-24)'
---

# Report a row binding that writes a namespaced column as an absolute path

## Motivation

A DDIC column whose name carries a namespace - `/CWM/XCWMAT`, the fields an
industry solution or a customer appends to a table - is written into the
model as a level of its row: `"CWM":{"XCWMAT":…}`. Its row-relative path is
`CWM/XCWMAT`. Written the obvious way, `{/CWM/XCWMAT}`, the leading slash
makes it an *absolute* path from the model root: the cell renders empty, a
user's edit is written somewhere nobody reads, and nothing logs anything.

The same happens one step removed in every generic app - a table
maintenance, a layout over any table, a report over a dynamic structure -
which builds the braces around a column name it only learns at run time:

```abap
)->a( n = `text` v = |\{{ comp-name }\}| )
```

That is right for `MATNR` and wrong for `/CWM/XCWMAT`, and the app's author
tests it with a table that has no namespaced column.

## Current behaviour

- abap2UI5 40e8a073 made the model write the namespace as a level and added
  `z2ui5_cl_ui5_view_builder=>component_path( name )`, which returns
  `CWM/XCWMAT` for a namespaced name and every other name as it is. A cell
  bound with `_bind( val = … tab = … tab_index = … )` gets the right path by
  itself.
- `docs/agents/building-apps.md` section 4 says to write `{CWM/XCWMAT}` or
  to call `component_path( )` - as prose.
- The linter judges `{/CWM/XCWMAT}` only through `unknown-binding-path`,
  which needs the model shape and does not know why the path is wrong; the
  dynamic form is not judged at all.

## Proposed rule

`namespaced-row-binding`, severity warning.

Inside a bound aggregation's template (the controls cloned per row,
including `Column.template` of a `sap.ui.table` table):

1. **Literal.** A binding whose path has the namespace shape `/SEG/NAME`
   (`^/[A-Z0-9_]+/[A-Z0-9_]+`) where `SEG` is not a public attribute of the
   class - so it cannot be an absolute path into the app's model. Message:
   write it relative, `{SEG/NAME}`. Fixable: drop the leading slash.
2. **Dynamic.** A string template that wraps one embedded expression in
   escaped braces (`|\{{ x }\}|`, also with a binding-info prefix
   `|\{path:'{ x }'…|`) where `x` is a variable or a component, not a call of
   `component_path( )`. Message: a namespaced column name binds an absolute
   path here; wrap the name in `z2ui5_cl_ui5_view_builder=>component_path( )`.

## What it must not report

- An absolute path whose first segment IS a public attribute (`{/MV_TITLE}`
  in a row template is the documented way to show a root value per row).
- The same shapes outside a bound aggregation - a root binding is absolute
  on purpose.
- `x` that is a literal, a constant, or a variable assigned only from
  literals in the method - the name is known and has no namespace (or it
  does, and then case 1 decides it).
- A path built by `_bind( val = … tab = … tab_index = … )` or by
  `client->_bind( )` / `_bind_path( )` - the framework writes those.
- An OData model path (the class switches its default model to an OData
  service); namespaced entity sets are absolute there by design.

## Example

```abap
LOOP AT lt_comp INTO DATA(comp).
  cells->tag( `Text`
      )->a( n = `text` v = |\{{ comp-name }\}| ).          " reported (2)
ENDLOOP.
cells->tag( `Text` )->a( n = `text` v = `{/CWM/XCWMAT}` ). " reported (1)

cells->tag( `Text`
    )->a( n = `text` v = |\{{ z2ui5_cl_ui5_view_builder=>component_path( comp-name ) }\}| ).  " not reported
cells->tag( `Text` )->a( n = `text` v = `{CWM/XCWMAT}` ). " not reported
```
