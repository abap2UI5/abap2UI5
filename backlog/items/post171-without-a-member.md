---
target: abap2ui5-linter
title: 'Flag a POST_171 declaration with no post-1.71 member behind it'
summary: view-gates lets a POST_171 EXCUSE a version finding but never checks the excuse corresponds to a real one, so a wrong `@since` in a sidecar silently moves a port into the wrong category folder and nothing ever reports it
priority: medium
state: open
first_seen: 2026-08-24
upstream: abap2UI5/linter
evidence:
  - samples-controls app 443 declared "sap.m.Text.renderWhitespace is @since 1.89"; it is @since 1.51 (sap/m/Text.js, and ui5/properties.json agrees) - 1.89 is the @since of sap.m.Link.emptyIndicatorMode, a different member
  - on that unfounded declaration the port was filed under src/02/01 (post-1.71) instead of src/01/01 for two weeks; no gate reported anything, because the check only runs in the other direction
  - the sibling port 249 uses renderWhitespace on six Texts and correctly declares nothing, so the corpus contradicted itself with no signal
---

# Flag a POST_171 declaration with no post-1.71 member behind it

## Motivation

In `abap2UI5/samples-controls` a `POST_171` deviation is not prose: it is
load-bearing. It excuses a version finding, and per that repo's AGENTS §3 it
also decides which category folder the class lives in (`src/01/<lib>/` for
in-scope, `src/02/<lib>/` for post-1.71). A declaration is therefore a claim
that can be wrong in two directions, and only one of them is checked.

## Current behaviour

`scripts/view-gates.mjs` consults the sidecar when it *has* a finding: a
post-1.71 member is accepted when some `POST_171` deviation names it. The
reverse never happens — a `POST_171` naming a member that is not post-1.71, or
naming nothing the port actually uses, produces no output at all. The excuse is
consumed only if something needs excusing.

The failure is quiet in the worst way: the sidecar reads as verified, the port
sits in the wrong folder, and the stated runtime floor is wrong. App 443 claimed
`>= 1.89` for a port whose highest member is 1.34.

## Proposed change

After the version pass, walk the sidecar's `POST_171` deviations and report one
that has no support:

1. collect the member names each `POST_171` text mentions that the port's view
   actually uses;
2. look each up in the metadata snapshot;
3. report when **none** of them resolves to a version above the configured floor.

Message shape: `POST_171 names no member above the floor — renderWhitespace is
@since 1.51`.

The same walk answers the neighbouring question for free: a `POST_171` whose
named member the view does not use at all is either stale or a copy-paste from a
sibling port, which is how app 443's text arrived.

## What the rule must NOT do

- It must not require a one-to-one mapping between deviation and member. One
  `POST_171` legitimately covers several members, and its prose names them in
  running text, not in a list. **One** supported member is enough to make the
  declaration sound.
- It must not fire on a member the snapshot has no entry for. That is the
  metadata gap (see `metadata-experimental-since` and `linter-sapui5-metadata`),
  and treating "unknown" as "not post-1.71" would turn a blind spot into a false
  positive on exactly the ports that need the declaration most.
- It must not fire on a deviation that declares something other than a member
  version — a post-1.71 CONTROL, or an experimental API — as long as that is
  what the text says. Only a claim of the form "member X is @since Y" is
  checkable this way.
