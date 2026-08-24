---
target: abap2ui5-linter
title: 'A variable-valued attribute is dropped by the view reconstructor, so no property rule can ever fire on it'
summary: 'an attribute whose value is a COND #( ) or a local variable never reaches the reconstructed view, so member-too-new, icon-too-new and every other property gate are blind to it'
priority: high
state: open
first_seen: 2026-08-24
evidence:
  - samples-controls app 454 used `initialFocus` with a COND #( ) value. It is @since 1.117 on sap.m.SelectDialogBase, the snapshot carries that fact, and the port sat in src/01 claiming a 1.71 floor - view-gates reported pass, because the attribute was never in the document it judged
  - app 452 hides `colorSet` the same way; harmless only because its POST_171 happens to name both properties
  - both were found by hand. Nothing in the corpus can find the next one
---

## What happens

The reconstructor builds a view document from the `->a( n = … v = … )` chain. A
literal value reproduces; a `COND #( )`, a `SWITCH #( )` or a bare local
variable does not, and the attribute is **omitted from the document** rather
than carried with an unknown value.

Every property rule then judges a control that does not have the attribute at
all. It cannot fire, and there is no diagnostic saying it declined to look.

## Why this matters more than it sounds

The blind spot is not uniform — it selects for exactly the attributes worth
checking. An attribute is written as a `COND` because it is *conditional*, which
correlates with being newer, optional, or feature-gated. `initialFocus` is the
shape: a post-1.71 member, set conditionally, invisible.

## Proposed change

Two options, not exclusive:

1. **Carry the attribute with an unresolved marker.** The reconstructor emits
   the attribute with a sentinel value; version and existence rules (which only
   need the member NAME) then work unchanged, while value rules skip it
   explicitly.
2. **Report the omission.** A low-severity finding — "attribute `initialFocus`
   on `sap.m.TableSelectDialog` has a computed value and was not checked" — so
   the gap is visible in the run rather than silent.

Option 1 is the fix; option 2 is worth having anyway, because there will always
be a construct the reconstructor cannot resolve.

## What it must not report

- An attribute whose value is a `client->_bind( )` or `client->_event( )` call:
  those already reconstruct to a binding/handler and are judged today.
- A computed value on an attribute no rule would examine — reporting every
  `COND`-valued `text` would drown the signal. Scope option 2 to attributes that
  at least one active rule cares about.
