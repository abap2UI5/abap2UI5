---
target: abap2ui5-linter
title: 'Report _bind( ) of an attribute an interface declares'
summary: 'client->_bind( ) of an attribute the app gets from an interface (zif_x~attr, or ii_x->attr) raises BINDING_ERROR on the first roundtrip - the model only knows the public attributes of the app class itself'
priority: medium
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
evidence:
  - 'src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap, ltcl_07_intf_attr->intf_attribute_refused (abap2UI5 40e8a073): the class''s own attribute binds, an attribute of an interface raises BINDING_ERROR - "changing that is a decision, not a fix"'
  - 'docs/agents/building-apps.md section 4: "An attribute an interface declares ... is not bindable: _bind( ) raises BINDING_ERROR for it" - prose only'
  - '@abap2ui5/linter 0.11.0: binding-to-nonpublic and binding-to-local judge the section and the lifetime of the bound name, not where it is declared; no issue in abap2UI5/linter (searched 2026-11-24)'
---

# Report _bind( ) of an attribute an interface declares

## Motivation

`client->_bind( )` finds the bound variable by its address among the public
attributes of the app class, read through RTTI. An attribute that an
interface declares is written into the class by `INTERFACES`, but under the
name `LIF~ATTR`, and the search finds no row for it. The first roundtrip
answers `BINDING_ERROR`, naming no attribute the author recognises as
private or local - the attribute *is* public.

It is a natural thing to write in an app that implements a state interface
of its own, or that reaches its data through an interface reference:

```abap
client->_bind( zif_my_state~mv_value ).
client->_bind( mi_state->mv_value ).   " a reference to an interface, no alias
```

## Current behaviour

- `z2ui5_cl_ui5_srv_model` (bind service) refuses it; the test
  `ltcl_07_intf_attr->intf_attribute_refused` pins the behaviour as a
  decision.
- `docs/agents/building-apps.md` section 4 says it, as prose.
- `binding-to-nonpublic` and `binding-to-local` look at the visibility and
  the lifetime of the bound name; neither knows interface attributes.

## Proposed rule

`binding-to-interface-attribute`, severity error.

Report a `_bind( )` (also `_bind_path( )`, and `val =` of the cell form)
whose argument's root is

1. a name with the component selector `~` (`zif_x~attr`, `me->zif_x~attr`),
   or
2. an attribute read through a reference whose static type is an interface
   (`ii_x->attr`, `mi_state->attr`) - resolved from the declaration of the
   reference in the class.

Message: the model only carries the app class's own public attributes; copy
the value into one (or declare it in the class) and bind that.

## What it must not report

- An `ALIASES` name declared in the class for the interface attribute - it
  is still the interface's attribute, so it IS reported, but under the
  alias; the rule has to resolve the alias rather than skip it. (Listed here
  because the obvious implementation, a test for `~`, misses it.)
- A reference to another class (`mo_data->attr`) - that is
  `binding-to-reference`'s case, not this one.
- An interface method call (`zif_x~get( )`) passed to something other than
  `_bind( )`.
- An attribute of a structure or table that is itself the class's own
  attribute (`ms_state-value`).

## Example

```abap
CLASS zcl_my_app DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    INTERFACES zif_my_state.          " declares mv_value
    DATA mv_own TYPE string.
ENDCLASS.
" …
)->a( n = `value` v = client->_bind( zif_my_state~mv_value ) )   " reported
)->a( n = `value` v = client->_bind( mv_own ) )                  " not reported
```
