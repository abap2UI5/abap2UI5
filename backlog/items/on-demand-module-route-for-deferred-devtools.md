---
target: abap2ui5
title: 'An on-demand delivery route for one embedded frontend module, so the deferrable devtools bytes can leave the preload'
summary: 'The handler answers every GET with the shell, so a module dropped from the preload is unfetchable - deferring the ~23% of preload bytes the devtools could give up needs a whitelisted single-module GET route plus a frontend loader path, and the whitelist has to be GENERATED or it violates the no-manual-preload-list rule'
priority: low
state: open
first_seen: 2026-09-01
evidence:
  - 'app/webapp/devtools/DevTools.js:23-52 documents the blocker: on an ABAP system every frontend file arrives in ONE sap.ui.require.preload block, the bootstrap resource root is the ICF node, and the node answers every GET with the shell page - a module not in the block is fetched as text/html and never defines'
  - 'measured 2026-08-28 (same header): devtools/ is 32.7% of the preload bytes, at most 23.2% deferrable - Console, Recorder and DevTools.js itself must stay eager because a history collected after the problem is worth nothing'
  - 'investigated 2026-09-01 while landing the GET-shell cache/ETag work: the route alone is not safely landable without generator support, see the body'
---

# An on-demand module route for the deferrable devtools bytes

## The blocker, restated from the code

`z2ui5_cl_ui5_http_handler` answers every GET with the assembled shell page.
The bootstrap sets `resourceroots {"z2ui5": "./"}` - the ICF node itself - so
any module the ui5loader would fetch lazily comes back as `text/html`, the
`define` never runs, and the requiring code waits forever. That is why every
`devtools/` module is a hard `sap.ui.define` dependency today
(`DevTools.js` header), and why deferral is a **handler design change**, not
a frontend edit.

## What a sound implementation needs (found by attempting it)

1. **A generated whitelist, not a hand-written one.** Serving ONE module by
   name needs a module-id -> `z2ui5_cl_ui5f_*` dispatch in ABAP. AGENTS.md
   rule 2 says "never reintroduce a manually maintained preload list in the
   HTTP handler" - the sync between `app/webapp/` and the handler is exactly
   what `z2ui5_cl_ui5f_preload` exists to guarantee. So
   `tools/app2abap/trans2abap.js` has to emit a second accessor (a
   `get_module( name )` CASE over the same generated entries, static calls
   only - never `CREATE OBJECT` from request input), and the route validates
   the request against that generated closed set. `.js` entries hold the raw
   module source (the preload wraps them in `function(){...}` at assembly
   time), so a single `.js` module can be served as `application/javascript`
   verbatim; the non-JS entries (`.xml`/`.json`/`.css`) need their own
   content types if they are ever served at all - restricting the route to
   `.js` is the smaller surface.

2. **Per-module conditional GET.** The shell's ETag lives in one
   per-work-process field (`sv_get_etag`) that `set_response` compares
   against If-None-Match for the 200-GET case. A module response wants the
   same `private, no-cache` + ETag treatment, but per module - reusing the
   shell field would poison the shell's validator. That is new response
   state, not a reuse.

3. **A frontend loader path.** Either the loader fetches real sub-paths of
   the ICF node (`./devtools/Inspect.js` - the handler then routes on the
   `~path` suffix, which varies per deployment shape and needs the launchpad
   cases checked), or the frontend fetches through a query marker and feeds
   `sap.ui.require.preload` with the text - which leans on the eval-capable
   CSP (AGENTS.md rule 13) and must stay out of the action dispatch's
   "payload is data, not code" contract (rule 19).

4. **A consumer in the same change.** A route nothing calls is a widened
   HTTP surface with no producer to prove it - the same shape
   `t_model_skipped` shipped in and paid for (its first consumer found two
   gaps the day it was written). The deferral - DevTools switching its
   deferrable deps to `sap.ui.require` with an async open path, the preload
   emission dropping exactly those modules, the 1.71 Playwright leg still
   green - belongs in the change that adds the route.

## Proposal

One change, generator-first: `trans2abap.js` emits the single-module
accessor next to the preload class; the handler adds the GET route
(whitelist-validated, `application/javascript`, per-module ETag/304, the
no-store trio for everything refused); `DevTools.js` defers exactly the
modules its own header names as deferrable and keeps Console/Recorder eager;
the preload drops what is deferred. Measured payoff cap: 23.2% of the
preload's bytes - worth one designed change, not four incremental ones.
