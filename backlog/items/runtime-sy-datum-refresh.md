---
target: open-abap
title: 'runtime: sy-datum / sy-uzeit are set once when ABAP( ) is constructed and only GET TIME refreshes them - a long-lived host answers yesterday''s date after midnight'
summary: 'the `ABAP` constructor calls `getTime( )` once; nothing else moves `sy-datum` and `sy-uzeit`, so a server or a browser tab that lives past UTC midnight reads the old date in every roundtrip until some code happens to run `GET TIME`; the playground calls `abap.statements.getTime()` before each roundtrip - a documented hook (`abap.context.beginDialogStep()`) or lazy getters would make that the runtime''s job'
priority: low
state: open
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'abap2UI5/playground `src/runtime/index.mjs:47-52` (2026-10): ''The runtime sets sy-datum and sy-uzeit only when it starts and as a side effect of GET TIME … a click after UTC midnight got yesterday''; the playground runs `abap.statements.getTime()` before every roundtrip'
  - 'read 2026-10-22 in abaplint/transpiler main 53a708f - `packages/runtime/src/index.ts` constructor calls `this.statements.getTime(…)` once; `sy` is a plain `Structure`'
  - 'abaplint/transpiler#690 ''Set sy-datum, uzeit, etc'' (closed 2022-05-01) introduced the one-time set; the long-lived host case was not part of it'
checked_upstream: 2026-10-22
---

# runtime: `sy-datum` and `sy-uzeit` for a long-lived process

## The problem

On a system `sy-datum`/`sy-uzeit` are set at the start of every dialog
step. In `@abaplint/runtime` they are set when `new ABAP()` runs and by
`GET TIME`. A Node server or a browser tab that serves requests for
days reads a stale date in every request that does not itself call
`GET TIME` - the playground saw yesterday's date after midnight and now
calls `abap.statements.getTime()` before each roundtrip.

## Proposed change

Either `abap.context.beginDialogStep()` (documented; sets `sy-datum`,
`sy-uzeit`, `sy-datlo`, `sy-timlo`, resets `GET RUN TIME`'s origin and
whatever else is per-step), which hosts call per request, or lazy
getters on those four `sy` fields that read the clock when accessed and
are frozen by `GET TIME` for the step. The first is the smaller change
and the clearer contract.

## How to file

An issue against abaplint/transpiler; cite #690 as the origin.

