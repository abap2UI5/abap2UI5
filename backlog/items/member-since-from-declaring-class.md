---
target: abap2ui5-linter
title: 'A member with no own @since inherits its declaring class version, not the version of the control it is used on'
summary: 'cards.BaseHeader is @1.86 and its press event carries no member-level @since, so a press on the @1.64 cards.Header reads as base-version and passes at a 1.71 floor'
priority: medium
state: filed
filed: https://github.com/abap2UI5/linter/pull/61
first_seen: 2026-08-24
evidence:
  - samples-controls app 528 wired press on card:Header and sat in src/01/04 claiming a 1.71 floor. The event is declared on sap.f.cards.BaseHeader, which is @since 1.86 - below that the header renders but is not pressable, so the withAction card's navigation silently does nothing
  - app 168 had already hit this and declares it by hand, which is how the pattern was recognised at all
  - the same reading applies to sap.f.GridList.borderReached, whose direction parameter is typed with an @1.85 enum while the event itself carries no @since
---

## The rule as it stands

`sinceOf` walks the parent chain to find the member, then reads the member's own
`@since`. When the member has none, the result is "base version" — i.e. ≤ 1.71 —
regardless of where it was found.

That is right when the member was declared with its class at or before the
floor. It is wrong when the member was declared with a class introduced *after*
the floor: the member cannot predate the class that declares it.

## Proposed change

When a member carries no `@since`, fall back to the **`@since` of the class that
declares it**, not to base version. Concretely: `press` found on
`sap.f.cards.BaseHeader` (@1.86) is @1.86, even though it is used on
`sap.f.cards.Header` (@1.64).

## What it must not report

- A member with its own `@since` — that always wins, and is often *later* than
  the declaring class (the normal case: a property added to an old control).
- A member found on a class at or below the floor. The change only moves members
  whose declaring class is itself post-1.71, which is a small set.
- The reverse inference: a member on a post-1.71 class used by a port that
  already declares that class as POST_171 needs no second finding.

## Worth checking while implementing

Whether the snapshot records the declaring class per member at all. If it only
records the member and its `@since`, this needs a metadata change first — which
is the same generator that `metadata-experimental-since` touched.
