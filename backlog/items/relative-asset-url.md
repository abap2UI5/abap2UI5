---
target: abap2ui5-linter
title: 'Report a document-relative asset URL in a view — an abap2UI5 app has no document root to resolve it against'
summary: `src="./test-resources/…"` resolves against the demo kit's page but 404s from the ABAP ICF node, and no gate sees it — data-fidelity only rejects a non-OpenUI5 HOST, and a relative path has none
priority: medium
state: open
first_seen: 2026-08-24
upstream: abap2UI5/linter
evidence:
  - samples-controls apps 401, 402, 412 and 587 shipped ten such paths - two Avatars each on 402/412, an Avatar plus the LinkedIn and Twitter icons on 401, both icons on 587 - all rendering as placeholders
  - app 261 had the identical defect and was fixed on 2026-08-23; its sidecar records that both icons "rendered broken". The four ports above then justified keeping the relative form by citing 261 as precedent
  - the corpus was split 18 uxap ports absolutizing against 4 not, with 413 and 412 in the same batch on opposite sides
---

# Report a document-relative asset URL in a view

## Motivation

A UI5 demo-kit sample is served from the SDK page, so `./test-resources/sap/uxap/images/x.png`
resolves. An abap2UI5 app is served from the ABAP ICF node and has no such
document root: the request 404s and the control silently falls back to its
placeholder. The view renders, no error is logged where anyone looks, and the
port looks correct in every gate.

This is a porting mistake with one correct answer — absolutize onto the OpenUI5
host — which makes it exactly the shape a rule should carry rather than a
reviewer's memory. It has now been made at least five times in one corpus, twice
after the rule was known, and the second batch cited the first as precedent.

## Current behaviour

Nothing checks it:

- `data-fidelity` rejects an asset URL whose **host** is not OpenUI5. A relative
  path has no host, so the check does not apply.
- `structural-diff` does not compare literal attribute values unless the
  ORIGINAL's value is a simple `{path}` binding, and here both sides are
  literals.
- the e2e build serves no `test-resources` at all, so a smoke run cannot see the
  difference between a loaded and a missing image.

## Proposed change

Report any literal attribute value that is a document-relative URL pointing at a
UI5 resource tree — practically, a value matching `^\.{0,2}/` (or a bare
`test-resources/…`) on an attribute the metadata types as `sap.ui.core.URI`.

Message shape: `document-relative asset URL — an abap2UI5 app has no document
root; absolutize it onto the OpenUI5 host`.

Typing the attribute through `properties.json` rather than matching attribute
names keeps it honest: `src`, `icon`, `backgroundImage`, `objectImageURI` and
`fontURI` are all `URI`-typed and all reachable this way.

## What the rule must NOT do

- It must not touch a `sap-icon://` URI, a `data:` URI, an absolute `http(s)://`
  URL, or a protocol-relative `//host/…` one.
- It must not fire on a **binding** — `{IMAGE_URL}` is resolved at runtime from
  the model and the rule cannot know what it holds.
- It must not fire on a relative path that legitimately targets the app's own
  ICF resources, if a project ever serves such a tree. Scoping the match to
  paths containing `test-resources/` or `resources/sap/` keeps the rule to the
  demo-kit case that is actually wrong.
