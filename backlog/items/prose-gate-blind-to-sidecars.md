---
target: abap2ui5
title: 'The shared prose-name gate does not look at `meta/` sidecars, where most class names are actually written'
summary: a dead class name survived a corpus-wide sweep for a month because the gate that removed it everywhere else checks eight markdown files and no sidecar — and a sidecar deviation is prose, read by agents, and is where the corpus writes most of its class references
priority: low
state: open
first_seen: 2026-08-23
upstream: abap2UI5/abap2UI5
evidence:
  - samples-controls `meta/z2ui5_cl_smpc_app_038.json` cited `z2ui5_cl_demo_app_038`, a class in the retired `z2ui5_cl_demo_app_*` naming scheme that does not exist in any repository; found by reading the port on 2026-08-23
  - samples-controls STATUS.md records the 2026-08-21 sweep that resolved "36 class names across 8 prose files" and concluded the dead `z2ui5_cl_demo_app_<n>` citations were gone — the sidecars were never in scope, so one was not
  - the same sidecar text is baked verbatim into the generated in-system overview app (`src/z2ui5_cl_smpc_app_000.clas.abap`), so a dead name reaches a running SAP system
---

# The shared prose-name gate does not look at `meta/` sidecars

## Motivation

`check-prose-names.mjs` exists so that a class named in prose still exists. It
resolves names across the ecosystem — including foreign ones, which it looks up
in the owning repository's generated `SAMPLES.md` rather than exempting — and it
is shared, with abap2UI5's `.github/shared/check-prose-names.mjs` as the one
source.

Its scope is a list of eight markdown files:

```js
const PROSE = ['README.md', 'CONTRIBUTING.md', 'AGENTS.md', 'CLAUDE.md',
               'TRAINING.md', 'STATUS.md', 'CAPABILITIES.md', 'E2E.md'];
```

In `abap2UI5/samples-controls` that misses the place where class names are
written most often. Every port carries a `meta/<class>.json` sidecar whose
`deviations[].what`, `audit.note` and `checked.note` are long-form prose — the
corpus' own AGENTS.md calls a deviation "a log entry about a process" and puts
it there *because* it is prose. Those texts cite sibling ports constantly
("the same path app 284 uses", "same technique as app 007", "proven by …").

The consequence is not hypothetical. On 2026-08-21 that repository ran a sweep
to remove citations of the retired `z2ui5_cl_demo_app_*` scheme and recorded it
as finished: "36 class names across 8 prose files, every one of them existing".
On 2026-08-23 `meta/z2ui5_cl_smpc_app_038.json` still read

> Proven by the curated sample `z2ui5_cl_demo_app_038` (MessageView +
> MessageItem + MessagePopover over a bound table).

No such class exists anywhere. It survived because it was never looked at, and
it was found only by a human reading that one port against its original.

It also travels further than a sidecar suggests: `generate-overview.mjs` bakes
the deviation texts into the generated overview app, so the dead name is
compiled into ABAP that gets pulled into a customer system.

## Proposed change

Extend the shared gate to scan sidecar prose, as a second scope beside `PROSE`
rather than as more entries in it — the files are JSON, so the reader differs:

- add an optional `SIDECARS` scope (default `meta/*.json`), and for each file
  collect the string values of `deviations[].what`, `audit.note` and
  `checked.note`;
- run the existing name regex and the existing resolution over those strings
  unchanged — the whole value of doing this in the shared script is that the
  ecosystem-wide resolution (including the foreign-repository `SAMPLES.md`
  lookup) is the same one;
- report a hit as `meta/<class>.json` plus the deviation index, so the finding
  points at the sentence rather than at a 4 KB file;
- keep `prose-absent.json` per repository, as it is today.

A repository with no `meta/` directory simply contributes no files, so the
change is inert in the consumers that do not use sidecars.

## Scope — what it must NOT report

- **Not the sidecar's own `class` field**, which names the port the file
  belongs to. It resolves trivially and would double every port into the count.
- **Not a name inside a quoted upstream identifier** — the corpus quotes UI5
  class names (`sap.m.MenuWrapper`) and framework classes
  (`z2ui5_cl_ui5_view_builder`) constantly; the gate's existing regex already
  targets the `z2ui5_cl_*_app_<n>` sample shape, and it should stay that narrow
  here.
- **Not history.** `docs/history.md` is already excluded by the `HISTORY` rule
  for the reason that a journal records what a class was called at the time; a
  `checked.note` dated years back has the same character. If that turns out to
  bite, exclude `checked.note` rather than widening `prose-absent.json`, so the
  exemption stays a rule instead of a list.

## Why this is filed rather than done

The script is shared by three consumer repositories
(`samples`, `samples-controls`, `samples-stack`) and `npm run check:shared`
compares each copy against the source here. Changing the source and only one
copy is exactly the drift that gate exists to catch, and the change should land
in all four places in one go — which needs all three consumers checked out, not
one.
