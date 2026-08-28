---
target: abap2ui5
title: 'Positional shorthand for a short `t_arg` on `_event( )`'
summary: 274 of 399 `_event( )` calls that pass arguments wrap a SINGLE value in `VALUE #( ( … ) )` — optional `a1`/`a2`/`a3` parameters would take the table constructor out of the line every sample copies first
priority: low
state: open
first_seen: 2026-08-28
upstream: abap2UI5/abap2UI5
evidence:
  - abap2UI5/samples-controls, 637 port classes, measured 2026-08-28 — 1103 `_event( )` calls, 399 of them with `t_arg`, and the argument count is 274 × one, 62 × two, 24 × three, 39 × four or more
  - the one-argument form is the shape a reader meets first (a row key, a `${$source>/text}`, one event parameter), and it is also the shape that forces a two-line call at ordinary view-chain indentation
---

# Positional shorthand for a short `t_arg` on `_event( )`

## Motivation

Every backend event that carries data goes through one parameter, a
`string_table`. For the overwhelmingly common case — a single value — the
table constructor is longer than the value it wraps:

```abap
)->a( n = `senderPress` v = client->_event( val   = `PRESSED`
                                            t_arg = VALUE #( ( `${AUTHOR}` ) ) )
```

`VALUE #( ( … ) )` is four tokens of ceremony around one string, and at the
indentation an event wire usually sits at, it is also what pushes the call onto
a second line.

Measured over abap2UI5/samples-controls (637 ported demo-kit samples):

| `t_arg` elements | calls |
|---|---|
| 1 | **274** |
| 2 | 62 |
| 3 | 24 |
| 4 or more | 39 |
| (no `t_arg` at all) | 704 |

So two thirds of all argument-passing event wires in the corpus pass exactly
one value, and 84 % pass at most two.

## Current behaviour

`src/02/z2ui5_if_client.intf.abap`:

```abap
METHODS _event
  IMPORTING
    val           TYPE clike
    t_arg         TYPE string_table OPTIONAL
    …
  RETURNING
    VALUE(result) TYPE string.
```

There is no way to pass one argument without building a table for it, and
because `t_arg` is not the first optional parameter in the caller's mind, `val`
gets named as well — so the shortest possible one-argument event wire is

```abap
client->_event( val = `PRESSED` t_arg = VALUE #( ( `${AUTHOR}` ) ) )
```

## Proposed change

Add optional positional argument parameters that the method folds into `t_arg`
itself:

```abap
METHODS _event
  IMPORTING
    val           TYPE clike
    t_arg         TYPE string_table OPTIONAL
    a1            TYPE clike        OPTIONAL
    a2            TYPE clike        OPTIONAL
    a3            TYPE clike        OPTIONAL
    …
```

```abap
" today
client->_event( val = `PRESSED` t_arg = VALUE #( ( `${AUTHOR}` ) ) )
" proposed
client->_event( val = `PRESSED` a1 = `${AUTHOR}` )
```

The handler side is unchanged — `get_event_arg( 1 )` reads what `a1` supplied,
exactly as it reads the first row of a `t_arg` today.

**Scope — what it is not:**

- **Additive only, and mutually exclusive with `t_arg`.** Passing both must
  RAISE rather than silently pick one: a caller that does it means one of the
  two, and guessing would be the kind of silent wrong-argument defect this
  wire has produced before.
- **Same wire.** `a1…aN` are appended in order into the same `string_table`
  that is serialized today; a unit test asserting byte-identity with the
  hand-written `VALUE #( )` form is the contract.
- **How many.** Three covers 360 of the 399 argument-passing calls in the
  corpus; beyond that `t_arg` stays the right call, and the shorthand should
  stop rather than grow to `a14`.
- This is **not** a re-proposal of `frontend-action-named-api` (deferred
  2026-08-11). That item concerns the FRONTEND-ACTION wire
  (`follow_up_action` / `_event_client`), where the `t_arg` slots are a
  positional protocol — object, method, template, args — whose replacement is
  the planned action object. `_event( )` is the BACKEND event wire: its `t_arg`
  is a plain list of application values read back with `get_event_arg( )`,
  with no per-kind tuple order to design away. The ceremony here is the
  table constructor alone.
