# Design decisions and known non-issues

> Extracted from `AGENTS.md`, which keeps a one-line prohibition per entry and
> points here for the reasoning — what was proposed, what was measured, why
> it was declined. An agent needs the prohibition before it proposes the same
> thing again, and the reasoning only when it wants to argue with it; AGENTS.md
> is loaded into every session. Every fact below was in that file unchanged.

The following items may look like gaps but are intentional design choices:

- **Draft table `Z2UI5_T_01` has no version column** — Drafts are session-scoped (deleted after a few hours). There is no long-lived state that needs schema migration. Versioning would add complexity with no benefit.
- **Draft cleanup (`z2ui5_cl_ui5_srv_draft=>cleanup`) is deliberately not throttled or debounced** — it runs a single `DELETE ... WHERE timestampl < ...` on each app cold-start (`factory_first_start`). A per-work-process throttle (a `CLASS-DATA` "last run" timestamp that skips a sweep if the previous one ran seconds ago) was considered and **rejected**: deployments are overwhelmingly **stateless ICF**, where such a static resets between requests and never takes effect — it would only help the rare long-lived / stateful work process, a too-narrow edge case not worth the state. A **secondary index on `TIMESTAMPL`** to make each sweep cheaper was also considered and **rejected**: the `DELETE` runs only **once per app cold-start**, never per roundtrip, so a rarely-executed scan does not justify the index-maintenance overhead paid on **every** draft write (`Z2UI5_T_01` takes one `INSERT` per roundtrip). Do not add a secondary index on `TIMESTAMPL`, and do not (re-)introduce a cleanup throttle.
- **No `componentPreload` declaration in `app/webapp/manifest.json` / `index.html`** — both production delivery paths already bundle all modules: the ABAP-served page inlines every `app/webapp` file via the generated `z2ui5_cl_ui5f_preload` (`sap.ui.require.preload` in the GET response), and the standalone build (`npm --prefix app run build`) emits a `Component-preload.js` through the standard `generateComponentPreload` task, which the async bootstrap loads by convention. Per-module requests only occur in dev flows (`fiori run`, `node/srv/express.mjs`), which is intentional.
- **No central app-start authorization hook — authorization is the app's responsibility, by design.** `app_start` is client-controlled (URL query / hash route) and lands in `CREATE OBJECT TYPE (app_start)` (`z2ui5_cl_ui5_action`), constrained only to classes implementing `z2ui5_if_app`. The framework deliberately performs **no** `AUTHORITY-CHECK` and exposes **no** `check_app_start_allowed` exit: like a SAP transaction or an ICF node, reachability is governed by the surrounding authorization concept (ICF node auth, `S_TCODE`/`S_SERVICE`/app-specific authorization objects), and any per-app access decision belongs **in the app implementation's `z2ui5_if_app~main`** — the app checks its own authorizations and, if denied, renders an error/leaves. This keeps authorization where the app author has the domain context, and matches how every other ABAP UI dispatches. A proposal to add a framework-level `check_app_start_allowed` exit or a central `AUTHORITY-CHECK` before instantiation is **rejected**: it would offer a false sense of central security (the meaningful check is always app-specific) while every app must still guard `main( )` anyway. Treat "any user who can reach the ICF node can instantiate any `z2ui5_if_app` class" as **by design** — the app, not the framework, owns the authority check. Nothing needs to be added here. What the framework does check is the **type**, not the user: `z2ui5_cl_ui5_action=>app_create` refuses a name whose class does not implement `z2ui5_if_app` from its RTTI descriptor (`rtti_check_class_impl_intf`) before anything is instantiated, so a URL cannot make the system load an arbitrary class pool — and the error says "does not implement" instead of "does not exist". That is a type check on the way to `CREATE OBJECT`, not an authorization hook, and it does not change the decision above.
- **Changelog** — The project maintains a `changelog.txt` in the repository root. A `CHANGELOG.md` is not needed separately.
- **The pre-main model snapshot in `z2ui5_cl_ui5_handler=>main_process` deliberately serializes a second time on delta roundtrips.** On a delta roundtrip it is the first of up to two full model serializations, and that is a decision, not an oversight: every variant that drops it trades that CPU pass for a full-model push over the wire. The full reasoning lives in the comment at that code site — do not re-propose it as a performance bug.
- **The developer tools cannot be lazy-loaded out of the preload, and the
  hard `sap.ui.define` dependencies in `devtools/DevTools.js` are deliberate.**
  On an ABAP system every frontend file arrives in ONE
  `sap.ui.require.preload` block inside the GET response
  (`z2ui5_cl_ui5f_preload`), and the bootstrap sets the resource root to the
  ICF node, which answers every GET with the shell page — so a module dropped
  from that block is fetched as `text/html`, never defines, and the tools
  simply do not open (rule 18 is the same constraint stated from the other
  side). Requiring lazily *without* dropping them from the preload moves only
  the factory execution, not the bytes; and `Console` and `Recorder` have to
  install eagerly anyway, because a history collected after the problem is
  worth nothing. Measured 2026-08-28: `devtools/` is 32.7% of the preload's
  bytes and at most 23.2% of it could ever be deferred. Making that real is an
  on-demand delivery path for a module the page did not receive — a design
  change to the HTTP handler, not an edit to `DevTools.js`. The full reasoning
  is in that file's header.
- **An app implements `z2ui5_if_app` — there is deliberately NO app base
  class, and the dispatcher boilerplate is accepted.** Every app hand-writes
  the same `main( )` lifecycle branching (`check_on_init` / `check_on_event`
  / `check_on_navigated`) plus its `client` member — measured 2026-08-11 in the
  samples-controls corpus as ~4.4k lines of identical ceremony across 366 classes
  (the corpus has grown since; the measurement is the one the decision was made on).
  A proposal for an optional abstract `z2ui5_cl_app` with
  `on_init`/`on_event`/`on_navigated` hooks (plain inheritance, 702-safe,
  purely additive) was made and **declined 2026-08-11**: it is too much
  overhead for the gain — the app contract stays ONE interface, with no
  inheritance chain, no base-class lifecycle to learn and no second way to
  write an app. Do not add a base class, do not add lifecycle hooks to
  `z2ui5_if_app`, and do not report the repeated dispatcher as duplication.
- **Named frontend-action wrappers belong in a future ACTION OBJECT, not on
  `z2ui5_if_client` — parked, do not re-add them to the interface.** A set of
  named convenience methods over the positional `t_arg` wire (`toast_client`,
  `control_call`/`control_call_client`, `binding_filter`/`binding_sort` +
  `_client` twins — thin delegations, unit-tested byte-identical to the
  generic `follow_up_action`/`_event_client` form) was implemented on
  2026-08-11 and deliberately **reverted the same day** (maintainer
  decision): instead of growing the already-large client interface method by
  method, these actions shall eventually be collected in **one dedicated
  action object** with a clean, designed surface (e.g. reachable from the
  client, grouping toast/control/binding/keyboard actions). The idea is being
  observed against real usage first; the design comes later. Until then the
  generic `follow_up_action` — as a statement to schedule an action, written
  where its result is consumed to wire one — remains the only API (its
  obsolete second name for the wired half is `_event_client`); do not
  re-introduce per-method wrappers on `z2ui5_if_client`. The reverted
  implementation (interface docs, delegations, byte-identity tests) is
  preserved in git history (`f1a1813`, reverted by `208b7ec`) and in the
  backlog item `backlog/items/frontend-action-named-api.md` as the reference for
  the future object; usage data there too (corpus 2026-08: 295 control_global
  wires / 137 control_by_id / 25 binding_call / 3 keyboard_shortcut).
- **Embedding abap2UI5 into other UI5 apps is deferred, not forgotten.** Running it as a reuse component (freestyle views, Fiori elements extensions), several instances per page, and a wrapping custom control were assessed on 2026-09-23 and deferred until there is real demand. The findings, the staged plan and why the page-wide listeners stay page-wide are in `backlog/items/embed-as-reuse-component.md`. The framework's own ids are already component-prefixed (`ViewSlots.ownId`). Do not re-propose the rest as general cleanup.
- **The `z2ui5_cl_xml_view` builder (src/99) is large because each method wraps one UI5 control for the fluent API.** It is **not** being extended or refactored here: the builder from [samples-controls](https://github.com/abap2UI5/samples-controls) replaces it and becomes the new standard. Do not add wrapper methods, controls or parameters, do not split the class, and do not report its size as a finding. The 1:1-with-the-UI5-SDK rule (method, property and event names match the SDK exactly, no invented convenience shortcuts) carries over to the replacement.
