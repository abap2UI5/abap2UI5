---
target: abap2ui5
title: 'A `_bind_path( )` shorthand for `_bind( val = … path = abap_true )`'
summary: 345 of 3245 `_bind( )` calls carry `path = abap_true` and nothing else — a one-parameter alias removes a boolean flag from every one of them, in 167 of 637 ported apps
priority: low
state: open
first_seen: 2026-08-28
upstream: abap2UI5/abap2UI5
evidence:
  - 345 occurrences of `path = abap_true` in 167 of the 637 port classes of abap2UI5/samples-controls (measured 2026-08-28)
  - 2555 of 3245 `_bind( )` calls already use the terse one-argument form `client->_bind( val )`, so the flag is the only thing standing between the two shapes
  - the flag is required wherever a control needs the PATH rather than the value — bound aggregations, `binding_call` filters/sorts, `bindElement` — i.e. exactly the calls a sample reader meets first
---

# A `_bind_path( )` shorthand for `_bind( val = … path = abap_true )`

## Motivation

`z2ui5_if_client~_bind( )` does two different things depending on one boolean:
it returns either the bound VALUE or the model PATH of the same attribute. The
value form has a terse spelling and the path form does not:

```abap
client->_bind( t_products )                             " the value
client->_bind( val = t_products path = abap_true )      " the path
```

Both are equally common in ordinary app code — the path form is what a bound
aggregation, a `binding_call` filter/sort and `bind_element` need — but the
second spelling costs a named `val =` (which the first does not need) plus a
boolean flag whose name and value carry no meaning to a reader who does not
already know the method.

Measured over abap2UI5/samples-controls (637 ported demo-kit samples):

| | |
|---|---|
| `_bind( )` calls total | 3245 |
| of those in the terse one-argument form | 2555 |
| of those carrying `path = abap_true` | **345**, in 167 of 637 classes |

## Current behaviour

`src/02/z2ui5_if_client.intf.abap` (the `_bind` signature):

```abap
METHODS _bind
  IMPORTING
    val                  TYPE data
    path                 TYPE abap_bool DEFAULT abap_false
    …
  RETURNING
    VALUE(result)        TYPE string.
```

`path` is the first optional parameter, so the moment it is passed, `val` has
to be named too — the reason the two spellings differ by four tokens rather
than one.

## Proposed change

Add a delegating alias:

```abap
METHODS _bind_path
  IMPORTING
    val           TYPE data
  RETURNING
    VALUE(result) TYPE string.
```

with the body being exactly `result = _bind( val = val path = abap_true ).`

```abap
" today
)->a( n = `items` v = client->_bind( val = t_products path = abap_true )
" proposed
)->a( n = `items` v = client->_bind_path( t_products )
```

**Scope — what it is not:**

- **Additive only.** `path` stays on `_bind( )` and is not deprecated; every
  existing call keeps working, and callers that combine `path` with
  `omit_initial`, `json` or `switch_default_model` keep using the full form.
  The alias deliberately takes ONE parameter — the moment a second is needed,
  `_bind( )` is the right call.
- **No behaviour of its own.** It must emit byte-identical output to the call
  it delegates to; a unit test asserting that identity is the whole contract.
- This is not a re-proposal of `frontend-action-named-api` (deferred
  2026-08-11). That item is about the positional `t_arg` of the FRONTEND-ACTION
  wire and the action object that should replace it. `_bind( )` is neither: it
  is a model-binding helper with a named signature already, and the request
  here is one alias for its most common non-default flag.
