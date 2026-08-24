---
target: abap2ui5-linter
title: 'Report a bound aggregation seeded with more rows than the model size limit'
summary: JSONModel caps a bound aggregation at 100 entries unless the app raises it, so a table seeded with more rows renders truncated with no error anywhere — the sample whose whole subject is the row count then demonstrates the wrong number
priority: medium
state: open
first_seen: 2026-08-24
upstream: abap2UI5/linter
evidence:
  - samples-controls app 444 (sap.m.sample.MaxNumberOfNotificationsReached) seeds 400 notifications and binds them; 100 rendered. The sample exists to show what 400 notifications look like
  - its e2e module asserted only that some .sapMNLI rendered, which a 100-row render passes just as happily, and the sidecar's "Same 400 rows" was true of the ABAP table but not of the view
  - the corpus already carries the idiom in apps 252 and 094 (cs_event-set_size_limit), so the fix is known - it is the detection that is missing
---

# Report a bound aggregation seeded with more rows than the model size limit

## Motivation

`sap.ui.model.Model`'s constructor sets `iSizeLimit = 100`, and abap2UI5 leaves
it there unless the app sends `cs_event-set_size_limit`. Every list bound to a
model table therefore stops at 100 entries — silently, because a size limit is
not an error condition: the binding simply returns fewer contexts.

The original samples usually do not meet this limit, and often for a reason that
makes the port's exposure invisible: app 444's controller never uses a model at
all, it calls `addItem( )` 400 times with real control instances, and a size
limit applies to a bound aggregation, not to added children. So the upstream
sample is correct, the port is a faithful transcription of its data, and the
result is still wrong.

## Current behaviour

Nothing reports it. The port compiles, the view renders, `structural-diff` and
`data-fidelity` both compare the ABAP table (which really does hold 400 rows),
and an e2e assertion of the "some rows are present" shape passes.

## Proposed change

The linter already reconstructs the view and can see both halves. Report when

1. an aggregation is bound to a model table via `_bind( )`, and
2. the seeding code for that table can be shown to produce more than 100 rows,
   and
3. the class issues no `cs_event-set_size_limit` for the slot.

Condition 2 is the interesting one and does not need dataflow in the general
case: the corpus seeds tables either as a `VALUE #( ( … ) ( … ) )` literal whose
rows are countable, or in a `DO n TIMES` loop whose bound is a literal. Both are
syntactically decidable, and together they cover every case in the corpus today.

Message shape: `bound aggregation seeded with 400 rows but the model size limit
is 100 — raise it with cs_event-set_size_limit`.

## What the rule must NOT do

- It must not fire when a `set_size_limit` for that slot exists anywhere in the
  class, even if the rule cannot prove the value is large enough. Proving the
  number is a second question and a wrong second guess would be worse than
  silence.
- It must not fire on a table whose row count it cannot determine — a loop over
  another table, a SELECT, anything computed. An unknown count is not evidence
  of a large one, and this rule is only worth having if it never cries wolf on a
  legitimately small list.
- It must not fire on a table that is bound to something other than an
  aggregation (a property, a `binding` attribute), where no size limit applies.
