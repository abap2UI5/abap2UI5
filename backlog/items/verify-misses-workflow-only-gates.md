---
target: abap2ui5
title: '`npm run verify` cannot fail on a gate that only check_gates.yaml runs'
summary: two gates are steps in `check_gates.yaml` but absent from `run-gates.mjs`, so a change can be green through the whole local `verify` chain and still turn CI red on the gate nobody can run by accident
priority: medium
state: open
first_seen: 2026-08-27
upstream: abap2UI5/abap2UI5
evidence:
  - '`check:mirrors` (`linter-mirror-gate.mjs`) and `check:conventions` (`conventions-gate.mjs`) are `npm run` steps in `check_gates.yaml` and are not in `run-gates.mjs`''s `GATES` — 22 entries where the workflow has 24'
  - 'measured 2026-08-27 on branch `claude/samples-controls-review-u4g6cr`: `npm run verify` exits 0 end to end (`gates: 22 checked - all OK`) while `check_gates` is red, and has been since `977474af`, on `check:mirrors` alone'
  - 'both implementing agents were legitimately green locally before pushing; the gate that would have caught it was not reachable from any command they ran'
  - 'both are plain Node over the working tree and cost 0.2s and 0.4s — they meet `run-gates.mjs`''s own stated inclusion rule ("a gate belongs here when it is plain Node over the working tree") and were simply left out'
  - 'nothing holds the two lists together: `scripts-gate.mjs` deliberately checks only that `check` and `test` exist, and says so — "a gate that tried to compare a script body against a workflow would be guessing"'
---

# `npm run verify` cannot fail on a gate that only check_gates.yaml runs

## What happens

`check_gates.yaml` runs 24 `npm run check…` steps. `run-gates.mjs` — the
local half of the same behaviour, and what `npm run verify` reaches through
`npm run gates` — carries 22. The two missing ones are `check:mirrors` and
`check:conventions`.

So the local run and CI disagree about *which* gates exist, not just about
how failures are reported. A contributor can run `npm run verify` to
completion, see `gates: 22 checked in 10.5s - all OK`, push, and watch
`check_gates` go red on a step no local command runs.

This is not hypothetical. It is how `977474af` reached CI red on
`check:mirrors` and stayed red through `6fce3ae2`: the drift it reports is
real and correct, and `verify` had no way to say so.

## Why it is not caught

`run-gates.mjs`'s header states the inclusion rule — *"A gate belongs here
when it is plain Node over the working tree. The ones that shell out to
abaplint (check:standard, check:cloud, check:abap2ui5) stay in `verify` as
their own commands."* Both missing gates satisfy it: `conventions-gate.mjs`
and `linter-mirror-gate.mjs` are plain Node, and cost 0.2s and 0.4s.

They were left out, and nothing notices, because the rule lives in a comment.
`scripts-gate.mjs` is the gate that could have held the lists together and
explicitly declines to — for a good reason, stated in its own header: it
compares script *existence*, because comparing a script body against a
workflow "would be guessing, and it would go red on every unrelated CI edit".

That reasoning does not extend to this case. `package.json` is a better source
than the workflow: every `check…` script whose body is a single
`node .github/scripts/<x>.mjs [args]` run is decidably a plain-Node gate, and
can be required to appear in `GATES` — with an exemption map for the ones that
should stay out, so staying out becomes a decision with a written reason
rather than an omission.

## What to change

1. Add `check:mirrors` and `check:conventions` to `GATES`.
2. Make `run-gates.mjs` assert its own completeness against `package.json`:
   every `check…` script that is one plain-Node run over the working tree is
   either in `GATES` or in an exemption map that names why. On today's tree
   the exemptions would be `check:ui5` (shells out to the UI5 linter — the
   same reason the header already gives for the abaplint gates) and
   `check:release` (release-time only), and `check:app2abap` falls out on its
   own because it chains two commands.

## Related, not the same

`check:mirrors` **passes silently** when the installed `@abap2ui5/linter` is
too old to ship `scripts/check-upstream.mjs` — it prints "does not ship
scripts/check-upstream.mjs — SKIPPED, not verified" and exits 0. Observed on
this container with a stale `node_modules` at 0.2.2 while `package-lock.json`
pinned 0.4.1. It says what it did, which is the honest half; whether a
consumer's own pin being too old to check should pass is a separate question
from this item.
