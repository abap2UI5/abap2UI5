# backlog — the stock of things to file

Four backlogs, one per place a finding gets filed:

| | Filed against | |
|---|---|---|
| [**OPEN-ABAP.md**](OPEN-ABAP.md) | `open-abap/open-abap-core`, `abaplint/transpiler` | the compiler stack the transpiled build runs on |
| [**ABAPLINT.md**](ABAPLINT.md) | `abaplint/abaplint` | rules about ABAP as a language |
| [**ABAP2UI5-LINTER.md**](ABAP2UI5-LINTER.md) | `abap2UI5/linter` | rules about an abap2UI5 app and its view |
| [**ABAP2UI5.md**](ABAP2UI5.md) | this repository | the framework itself |

All four are **generated** from `items/*.md` — `npm run backlog`, gated by
`npm run check:backlog`. Do not edit them.

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
first_seen: 2026-08-17        # when it entered the stock — this is what ages
evidence:                     # required — at least one
  - what happened, where, when
checked_upstream: 2026-08-17  # when somebody last searched the upstream
                              # tracker, so we do not file a duplicate.
                              # REQUIRED once an `open` item is more than 30
                              # days old (see below)
---
```

The body is written to be **pasted into an issue as it stands**: motivation,
current behaviour with source references, the proposed change, an example. A
rule proposal also says what the rule must *not* report — that scope is usually
the hard half, and an item without it is a wish.

`evidence:` is required because an item without a case that happened is
speculation, and a backlog of speculation is one nobody reads twice.

`checked_upstream:` is required once an **open** item is more than 30 days
old, and `npm run backlog` fails without it. It used to be optional, and not
one item in the stock carried it — an instruction nothing asks for is an
instruction nobody follows. It stays optional for a fresh item, because the
first days of an item go into writing it rather than filing it and a search
done then is stale by the time anyone acts on it; past that age the item is a
standing claim that nothing exists upstream, and a claim nobody has re-checked
in a month is one this stock cannot make. Recording a search that found
nothing is the point — the field says *when somebody looked*, not *what they
found*.

### States

- **open** — nothing exists upstream. This is the stock.
- **filed** — an issue or PR exists; `filed:` names it. The item stays visible
  until the change merges. `npm run backlog:filed` asks GitHub what happened to
  each one, because the backlog cannot see when a claim about another
  repository stops being true: `event-auto-model-update` said "pending merge"
  for six days after abap2UI5#2545 had merged, at the first filed item the
  stock ever had.
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
**Backlog:** abaplint · abaplint-delete-index-in-loop, abaplint-subrc-after-assign
**Backlog:** open-abap · TODO: the ixml parser drops the position of a parse error
```

The first form has to resolve to an item of that target, so a renamed or
deleted item is reported instead of leaving the skill pointing at nothing. The
second is the raw form: a candidate somebody saw and did not work out. It is
listed in the backlog under **Raw stock** — visible, and not pretending to be
ready.

The generated pages cite the skill section back, so a row always leads to the
analysis and the analysis always leads to the row.

**The second source needs nobody at all.** `npm run backlog:mine` reads
`abap2UI5/samples-controls`' `meta/` sidecars, where every port records what
its rebuild could NOT do 1:1 (an `IMPROVISED` deviation), takes that
repository's own classification of them and keeps the two verdicts that mean
"possibly a framework gap" — `GAP` and `PROBE`. Families that already have an
item, or that already name a filed request, drop out. What is left is raw
stock, found without anybody deciding to look.

It answers nothing today, and that is the honest state rather than a
disappointment: the 2026-08 gap harvest filed six requests and all six shipped,
so the mine is drained. The value is that it is now a standing watch — the next
porting batch fills it again, and nobody has to remember to check. (The count
itself is deliberately not written down here — `npm run backlog` prints it, and
a number in prose is a number that goes stale, which this sentence proved by
claiming one candidate long after the last one was cleared.)

## Measuring a proposed rule — `npm run backlog:probe`

A rule proposal asks a maintainer to believe two things: that the defect is
real, and that the rule can be written without drowning everyone in false
positives. The second is what kills proposals — and it is the one this
ecosystem can simply **answer**, because abap2UI5, samples, samples-controls
and samples-stack are ~630 working apps plus a framework, all in ABAP, all
sitting next to each other on disk.

So an item may ship a detector next to it, `items/<id>.probe.mjs`:

```js
export const describe = 'one line: what this looks for'
export function run(roots) {
  return {
    sites: [...],      // where the rule would fire
    negatives: [...],  // where it must NOT, and looks identical
    notes: [...],      // where the detector approximates the rule
  }
}
```

**`negatives` is the important half.** "Fires 8 times" is a statistic; "fires 8
times, and here are the 3 places that look identical and are correct" is the
scope argument, which is what the proposal actually has to make.

The result is written into the item between markers — so the paste-ready body
carries the evidence — and cached in `probes.json` so the pages can show the
count. It is **not** re-run by `check:backlog`: the sibling checkouts do not
exist in CI, and a probe silently answering 0 because a repository is missing
would be worse than no probe. Each result records when it ran and against
which checkouts.

A detector is a throwaway approximation, not the rule. Where it over- or
under-counts, `notes` has to say so. The first cut of
`transpiler-reserved-js-identifiers` reported six words; four were structure
components and constants, which the transpiler emits as object keys where a
reserved word is legal — and the corpus transpiles green with all four. It was
narrowed to one rather than explained away, because an inflated number a
maintainer disproves in ten minutes costs more than no number at all.

## Does the stock actually drain?

`npm run backlog` prints it: the count per state, and the oldest open item. An
open item older than **90 days** is listed by name — not as a failure, since
waiting is what a backlog is for, but because an item nobody has filed in three
months is either not important (delete it) or blocked (say by what). This is
exactly what `pr/` lacked: five requests sat in it for weeks and nothing ever
said so.

Age is deliberately not rendered into the pages. It would change every day, so
every page would go stale overnight and `check:backlog` would fail on a tree
nobody touched. The **date** is stable and goes on the page; the aging goes to
the console, where it can be as current as it likes.

## How it empties

By hand, and that is deliberate.

Filing is the step where somebody decides this is worth another maintainer's
time, in another repository, under their own name. Nothing here opens an issue,
and nothing should: the stock is assembled automatically so that no finding is
lost, and drained by a person so that nothing is filed that nobody stands
behind.

To convert one:

1. Read the item. It is the issue body.
2. **Search the upstream tracker first** and record the date in
   `checked_upstream:`. Filing a duplicate costs a maintainer more than not
   filing at all, and this stock inherited one item whose "filed upstream"
   claim carries no link and could not be verified.
3. Open it against the `upstream` in its row.
4. Set `state: filed` and `filed: <url>`, run `npm run backlog`, commit.
5. When it merges, **delete the item** and run `npm run backlog` again.

**Issue or pull request?** It depends on the target, and it is worth deciding
before writing: for `abaplint` and `abap2UI5/linter` we can write the rule and
its tests ourselves, and a PR lands far more reliably than a request. For
`open-abap` and the transpiler an issue with a minimal repro is the realistic
ask. For the framework it is our own repository, so it is a PR.
