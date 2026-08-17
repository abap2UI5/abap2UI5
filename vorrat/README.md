# vorrat — the stock of things to file

Four backlogs, one per place a finding gets filed:

| | Filed against | |
|---|---|---|
| [**OPEN-ABAP.md**](OPEN-ABAP.md) | `open-abap/open-abap-core`, `abaplint/transpiler` | the compiler stack the transpiled build runs on |
| [**ABAPLINT.md**](ABAPLINT.md) | `abaplint/abaplint` | rules about ABAP as a language |
| [**ABAP2UI5-LINTER.md**](ABAP2UI5-LINTER.md) | `abap2UI5/linter` | rules about an abap2UI5 app and its view |
| [**ABAP2UI5.md**](ABAP2UI5.md) | this repository | the framework itself |

All four are **generated** from `items/*.md` — `npm run vorrat`, gated by
`npm run check:vorrat`. Do not edit them.

## Why this exists

Findings outlive the change they came from, and for a long time each one went
wherever its author happened to be: an upstream compiler bug into
`samples-controls/STATUS.md`, a linter rule candidate into a skill's prose, a
framework request into `samples-controls/pr/`. Three shapes, three
repositories, and no way to answer *"what is there to file against abaplint"*
without reading all of them — which meant, in practice, that nobody asked.

## An item

One file, `items/<id>.md`, front matter plus the body:

```yaml
---
target: abaplint              # which of the four backlogs
title: 'Report …'             # the issue title
summary: …                    # one sentence — the row in the index
priority: high|medium|low
state: open|filed|deferred
upstream: abaplint/abaplint   # optional, when it differs from the target's default
filed: <url>                  # required when state is `filed`
evidence:                     # required — at least one
  - what happened, where, when
---
```

The body is written to be **pasted into an issue as it stands**: motivation,
current behaviour with source references, the proposed change, an example. A
rule proposal also says what the rule must *not* report — that scope is usually
the hard half, and an item without it is a wish.

`evidence:` is required because an item without a case that happened is
speculation, and a backlog of speculation is one nobody reads twice.

### States

- **open** — nothing exists upstream. This is the stock.
- **filed** — an issue or PR exists; `filed:` names it. The item stays visible
  until the change merges.
- **deferred** — a decision was made not to do this now. The body says why, so
  it is not re-proposed.

There is no `implemented`. A request whose change is live has its item
**deleted** in that same change — the details then live upstream, in the
release notes and in the code. Keeping a shipped item as a row is how an index
turns into a changelog nobody trusts.

## How it fills itself

The skills under `.claude/skills/` stay where a finding is first written down —
they are the staging area `skill-rule-gate.mjs` describes, and the analysis
belongs next to the defect that produced it. A skill section names what it put
in the stock with a line of its own, alongside its `**Linter:**` and
`**Gate:**` lines:

```
**Vorrat:** abaplint · abaplint-delete-index-in-loop, abaplint-subrc-after-assign
**Vorrat:** open-abap · TODO: the ixml parser drops the position of a parse error
```

The first form has to resolve to an item of that target, so a renamed or
deleted item is reported instead of leaving the skill pointing at nothing. The
second is the raw form: a candidate somebody saw and did not work out. It is
listed in the backlog under **Raw stock** — visible, and not pretending to be
ready.

The generated pages cite the skill section back, so a row always leads to the
analysis and the analysis always leads to the row.

## How it empties

By hand, and that is deliberate.

Filing is the step where somebody decides this is worth another maintainer's
time, in another repository, under their own name. Nothing here opens an issue,
and nothing should: the stock is assembled automatically so that no finding is
lost, and drained by a person so that nothing is filed that nobody stands
behind.

To convert one:

1. Read the item. It is the issue body.
2. Open it against the `upstream` in its row.
3. Set `state: filed` and `filed: <url>`, run `npm run vorrat`, commit.
4. When it merges, **delete the item** and run `npm run vorrat` again.
