---
target: open-abap
title: 'A JSON boolean event argument reaches transpiled ABAP as the string `true`, so `= abap_true` never matches'
summary: the framework's ajson path normalizes a JSON boolean `t_arg` to `X`/space on a real system; in open-abap the same argument lands verbatim as `'true'`/`'false'`, so the comparison fails, the flag never flips and the wire reads as dead while the port is correct
priority: medium
state: open
first_seen: 2026-08-25
upstream: open-abap/open-abap-core
evidence:
  - samples-controls app 421 (sap.m.sample.QuickViewCardScrollBar) hit it live during the 2026-08-22 e2e sweep - the afterNavigate `isTopPage` wire never flipped its flag under the transpiled backend, and the port had to transport the string tokens `top`/`sub` instead to be drivable on both runtimes
  - samples-controls app 099 still carries the latent form (`t_arg = VALUE #( ( `${$parameters>/isTopPage}` ) )`, src/.../z2ui5_cl_smpc_app_099.clas.abap:99), left as found because a real system reads it correctly
  - samples-controls app 108 (sap.m.sample.PlanningCalendarSingle) meets it again on 2026-08-25: its MessageBox says "selected"/"deselected" from `${...}.getSelected()`, so the e2e harness always reads "deselected" while a real system reads "selected" - the assertion had to be left out of the interaction module, because asserting the word either way would fail a correct port on one of the two runtimes
  - recorded in samples-controls' `.claude/skills/e2e-debugging/SKILL.md` since 2026-08-22 with the instruction to file it upstream "when touching this next"
---

# A JSON boolean event argument reaches transpiled ABAP as the string `true`

## Motivation

abap2UI5 event arguments travel as JSON. When an argument is a JSON **boolean**,
the framework's ajson path on a real SAP system normalizes it to the ABAP
convention — `X` for true, a space for false — so an app compares it the way
ABAP compares any flag:

```abap
IF client->get_event_arg( 2 ) = abap_true.
```

Under open-abap the same argument arrives **verbatim**, as the four-character
string `true`. The comparison is then false for every value the wire can carry,
including true. Nothing errors: the flag simply never flips, the response
carries no model delta, and the wire reads as dead.

That is the worst shape a divergence can take. It is invisible to every static
gate, it does not raise, and the app is *correct* — so the reader who meets it
first concludes the port is broken and rewrites working code.

## Current behaviour

Measured three times in `abap2UI5/samples-controls`, each time from the
opposite direction:

- **app 421** hit it live. Its `afterNavigate` wire transports
  `${$parameters>/isTopPage}`; under the transpiled backend the bound flag
  never moved. The port was changed to transport the string tokens `top` /
  `sub`, which both runtimes read identically — a workaround in the app for a
  difference in the runtime.
- **app 099** carries the identical construct and was deliberately left alone,
  because on a real system it is right. So the corpus now holds one port
  written against the divergence and one written against the specification.
- **app 108** meets it from the test side: the MessageBox text branches on
  `${...}.getSelected()`, so the e2e harness always renders the false branch.
  The interaction module cannot assert that sentence at all — asserting either
  word fails a correct port on one of the two runtimes — so a wire that works
  everywhere stays unverified everywhere.

## Proposed change

Normalize a JSON boolean node the way the ABAP side expects when it is read
into a character field: `true` → `X`, `false` → space, matching what ajson
produces on a real system. The comparison then holds on both runtimes and the
workaround in app 421 becomes unnecessary.

## What the change must NOT do

- **It must not touch a JSON string that happens to read `"true"`.** The
  divergence is about the boolean NODE TYPE; an app that deliberately
  transports the word must keep getting the word, or every port using the
  string-token workaround (421 today) breaks in the other direction.
- **It must not normalize into a non-character target.** Reading a boolean
  node into an integer or into a nested structure is a different question and
  is not what this asks for.
- **It must not change what a real system does.** The reference behaviour here
  is ajson's, and the point of the change is that open-abap matches it — a fix
  that makes the two agree on some third answer solves nothing.
