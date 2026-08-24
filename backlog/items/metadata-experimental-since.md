---
target: abap2ui5-linter
title: 'Read `@ui5-experimental-since` in generate-metadata.mjs — experimental members carry no version at all today'
summary: the snapshot parses only `@since`, so a member tagged `@ui5-experimental-since` lands in properties.json with no version and the property/scope gates pass it silently — a port can sit on a 1.142 API while declaring a 1.82 floor
priority: medium
state: filed
filed: https://github.com/abap2UI5/linter/tree/claude/samples-controls-review-u4g6cr
first_seen: 2026-08-24
upstream: abap2UI5/linter
evidence:
  - samples-controls app 432 (sap.m.sample.TokenizerMultiLine) binds Tokenizer.multiLine and showClearAll, both `@ui5-experimental-since 1.142`; both are absent from properties.json's since map, both passed every gate, and the sidecar declared a release floor of ">= 1.82" for two weeks
  - those two properties ARE the sample - on anything below 1.142 XMLTemplateProcessor ignores them and the port renders as a plain single-line Tokenizer with no Clear All
  - 6 files under node_modules/@openui5/*/src/sap/ carry the tag, so the blind spot is small but not empty
---

# Read `@ui5-experimental-since` in `generate-metadata.mjs`

> **Implemented 2026-08-24** in `abap2UI5/linter` - the shared SINCE_RE, the member-level parsing and the `experimental` flag - on branch `claude/samples-controls-review-u4g6cr`. The item stays here until that merges.

## Motivation

The corpus' whole release-scope discipline rests on `ui5/properties.json`
knowing when a member appeared. A member the snapshot has no version for is
treated as base version, i.e. as available on the 1.71 floor — and is therefore
passed by the property gate, by the scope gate, and by the `src/01` vs `src/02`
category split.

`@ui5-experimental-since` is a version tag like any other. UI5 uses it for
members that exist but whose API may still change; a port using one needs *at
least* that release, exactly as with `@since`.

## Current behaviour

`generate-metadata.mjs` matches one tag:

```js
const since = doc?.match(/@since\s+(?:version\s+)?([\d.]+)/i)?.[1];
if (since) entry.since = since;
```

`@ui5-experimental-since 1.142` does not match `@since\s+…` (the tag name does
not end there), so `entry.since` is never set. Verified against
`node_modules/@openui5/sap.m/src/sap/m/Tokenizer.js`: `multiLine` (:180-184) and
`showClearAll` (:186-190) both carry only that tag, and both appear in
`ui5/properties.json` with no `since` key.

## Proposed change

Match both spellings, and keep them distinguishable:

```js
const since = doc?.match(/@(?:ui5-experimental-)?since\s+(?:version\s+)?([\d.]+)/i)?.[1];
if (since) entry.since = since;
if (/@ui5-experimental-since/i.test(doc ?? '')) entry.experimental = true;
```

The `experimental` flag is worth carrying separately even though the version
alone fixes the gate: a consumer may reasonably want to warn that the API can
change under it, which is a different message from "too new for your floor".
abap2UI5/samples-controls already declares that distinction by hand — its
`sap.m.sample.OverflowToolbarTokenizer` port records the experimental tag in its
sidecar precisely because nothing checks it.

## What the change must NOT do

- It must not flag a member that carries **both** tags at different versions;
  `@since` is the one that governs availability there. Prefer `@since` when both
  are present.
- It must not turn every experimental member into a hard failure. The version is
  the gate; the flag is advisory. A corpus that declares a high enough floor is
  correct even while sitting on an experimental API.
- It must not change the meaning of an absent tag. A member with neither tag is
  still base version — that inference is what makes the snapshot usable at all.
