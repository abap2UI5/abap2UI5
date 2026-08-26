---
target: abap2ui5
title: '`control_by_id` `to` hands FlexibleColumnLayout a Control where it expects a page-id string, so the column swap is a silent no-op'
summary: the `to` whitelist entry casts its first argument with the `controlId` kind, which resolves to a Control; `sap.m.NavContainer.to` converts that to an id, but `sap.f.FlexibleColumnLayout.to` passes it straight into `getPage( )`, which compares ids as strings - so no column matches, the call falls through to the END column, and the begin-column page never appears
priority: medium
state: open
first_seen: 2026-08-26
upstream: abap2UI5/abap2UI5
evidence:
  - samples-controls app 578 (sap.f.sample.FlexibleColumnLayoutWithFullScreenPage) - measured on the transpiled backend, the browser logs "Navigation triggered to page with ID 'mainView--dynamicPageId', but this page is not known/aggregated by Element sap.m.NavContainer#mainView--fcl-endColumnNav", and the target page has no DOM node at all
  - sap.m.NavContainer.to converts a Control to its id at NavContainer.js:782 (`if (vPageIdOrControl instanceof Control) { vPageIdOrControl = vPageIdOrControl.getId(); }`), which is why every plain NavContainer port works and only the FCL ones do not
  - sap.f.FlexibleColumnLayout.to (FlexibleColumnLayout.js:2873) probes `this._getBeginColumn().getPage(sPageId)` and NavContainer.getPage compares `aPages[i].getId() == pageId` (NavContainer.js:485), so a Control never matches any column and the final `else` sends it to the end column
  - no gate can see it - the id in the ABAP is correct, so `frontend-action-unknown-id` passes; the CAST is what is wrong. App 578's own e2e module passed throughout because it asserted `productsTable.getItems()`, which an unrendered control still answers
  - `backToPage` is NOT affected by this cast and is NOT whitelisted at all (an earlier draft of this item said it was, which was wrong): `back`, `backDetail` and `backMaster` are the only back-navigation entries in CONTROL_METHODS and all three are zero-arg. A `backToPage` call therefore takes the unlisted-method path, where castArgAuto hands `NavContainer.backToPage( pageId )` the raw ABAP literal - unprefixed, where the rendered id carries the view prefix. Whether that misses is a separate, UNMEASURED question; samples-controls app 101 has the only two call sites
---

# `to` hands FlexibleColumnLayout a Control where it expects a page-id string

## Motivation

`CONTROL_METHODS` whitelists the navigation methods with

```js
to: ["controlId", "string"],   // target page + optional transitionName
```

The `controlId` argument kind resolves the id to the **Control instance**. That
is right for `sap.m.NavContainer`, which begins by converting a Control back to
its id, and it is the reason the idiom works everywhere else in the corpus.

`sap.f.FlexibleColumnLayout` does not convert. Its `to( )` asks each column
`getPage( sPageId )`, and `getPage` compares `aPages[i].getId() == pageId`. A
Control object never equals an id string, so the begin, mid and end probes all
miss and the trailing `else` navigates the **end** column - which does not own
the page either. The result is a silent no-op with a console warning and no
ABAP-side error.

The failure is invisible to every gate: the id in the port is correct, so no
unknown-id rule fires; the cast is what is wrong.

## Current behaviour

App 578's begin column never navigates. Its products page is never rendered
(`getDomRef()` is null) while the class believes it is displayed, and the port's
interaction module passed regardless because `getItems( )` answers on an
unrendered control.

## Proposed change

Two candidates, both one line; the first is preferred.

1. **Pass the resolved control's id.** Where the `controlId` kind is applied for
   these methods, hand over `control.getId()` rather than the control. This
   fixes FCL and changes nothing for `NavContainer`, which converts a Control to
   exactly that id on its own first line.
2. **Whitelist the column delegates.** Add
   `toBeginColumnPage`/`toMidColumnPage`/`toEndColumnPage` with the `controlId`
   kind - they accept a Control - and let FCL ports address a column explicitly.
   This is additive but leaves the broken `to` in place for the next reader.

## What the change must NOT do

- **It must not pass a raw, unprefixed id.** The view prefixes control ids, so
  resolving through `controlId` and then taking `.getId()` is required; sending
  the ABAP literal would break every existing `to`.
- **It must not change `NavContainer` behaviour.** Option 1 is only safe because
  `NavContainer.to` already normalises a Control to its id; the observable
  behaviour there must stay identical.
- **It must not silently swallow a miss.** Whatever is chosen, a `to` naming a
  page no column owns should say so - today it lands on the end column and
  reports nothing an app can see.

## Adjacent, not part of this item

`backToPage` is unlisted rather than mis-cast, so it is a different question and
is deliberately left out of scope here. Whoever picks this up should decide
whether the unlisted path handing over an unprefixed id is a second defect or
merely unused; do not fold it into this change without measuring it first.
