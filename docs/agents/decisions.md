# Design decisions and known non-issues

> Extracted from `AGENTS.md`, which keeps a one-line prohibition per entry and
> points here for the reasoning — what was proposed, what was measured, why
> it was declined. An agent needs the prohibition before it proposes the same
> thing again, and the reasoning only when it wants to argue with it; AGENTS.md
> is loaded into every session. Every fact below was in that file unchanged.

The following items may look like gaps but are intentional design choices:

- **Draft table `Z2UI5_T_01` has no version column** — Drafts are session-scoped (deleted after a few hours). There is no long-lived state that needs schema migration. Versioning would add complexity with no benefit.
- **Draft cleanup (`z2ui5_cl_ui5_srv_draft=>cleanup`) is deliberately not throttled or debounced** — it runs a single `DELETE ... WHERE timestampl < ...` on each app cold-start (`factory_first_start`). A per-work-process throttle (a `CLASS-DATA` "last run" timestamp that skips a sweep if the previous one ran seconds ago) was considered and **rejected**: deployments are overwhelmingly **stateless ICF**, where such a static resets between requests and never takes effect — it would only help the rare long-lived / stateful work process, a too-narrow edge case not worth the state. A **secondary index on `TIMESTAMPL`** to make each sweep cheaper was also considered and **rejected**: the `DELETE` runs only **once per app cold-start**, never per roundtrip, so a rarely-executed scan does not justify the index-maintenance overhead paid on **every** draft write (`Z2UI5_T_01` takes one `INSERT` per roundtrip). Do not add a secondary index on `TIMESTAMPL`, and do not (re-)introduce a cleanup throttle.
- **No `componentPreload` declaration in `bundle/webapp/manifest.json` / `index.html`** — both production delivery paths already bundle all modules: the ABAP-served page inlines every `bundle/webapp` file via the generated `z2ui5_cl_ui5f_preload` (`sap.ui.require.preload` in the GET response), and the standalone build (`npm --prefix bundle run build`) emits a `Component-preload.js` through the standard `generateComponentPreload` task, which the async bootstrap loads by convention. Per-module requests only occur in dev flows (`fiori run`, `node/srv/express.mjs`), which is intentional.
- **No central app-start authorization hook — authorization is the app's responsibility, by design.** `app_start` is client-controlled (URL query / hash route) and lands in `CREATE OBJECT TYPE (app_start)` (`z2ui5_cl_ui5_action`), constrained only to classes implementing `z2ui5_if_app`. The framework deliberately performs **no** `AUTHORITY-CHECK` and exposes **no** `check_app_start_allowed` exit: like a SAP transaction or an ICF node, reachability is governed by the surrounding authorization concept (ICF node auth, `S_TCODE`/`S_SERVICE`/app-specific authorization objects), and any per-app access decision belongs **in the app implementation's `z2ui5_if_app~main`** — the app checks its own authorizations and, if denied, renders an error/leaves. This keeps authorization where the app author has the domain context, and matches how every other ABAP UI dispatches. A proposal to add a framework-level `check_app_start_allowed` exit or a central `AUTHORITY-CHECK` before instantiation is **rejected**: it would offer a false sense of central security (the meaningful check is always app-specific) while every app must still guard `main( )` anyway. Treat "any user who can reach the ICF node can instantiate any `z2ui5_if_app` class" as **by design** — the app, not the framework, owns the authority check. Nothing needs to be added here. What the framework does check is the **type**, not the user: `z2ui5_cl_ui5_action=>app_create` refuses a name whose class does not implement `z2ui5_if_app` from its RTTI descriptor (`rtti_check_class_impl_intf`) before anything is instantiated, so a URL cannot make the system load an arbitrary class pool — and the error says "does not implement" instead of "does not exist". That is a type check on the way to `CREATE OBJECT`, not an authorization hook, and it does not change the decision above.
- **Changelog** — The project maintains a `changelog.txt` in the repository root. A `CHANGELOG.md` is not needed separately.
- **The draft of a sticky app is committed on the paths that write it, and that stays so.** `set_session_stateful( )` pins the work process so an app can hold enqueue locks and uncommitted database work across roundtrips, and on an ordinary event roundtrip the framework leaves that LUW alone (no draft save, no rollback). On three paths it does not: when the URL carries the draft id (`cs_nav_mode-keep` routing, the app-state link) `main_end_save` writes the draft, and `z2ui5_cl_ui5_action=>prepare_app_stack` writes it on every `nav_app_call( )` / `nav_app_leave( )`; `z2ui5_cl_ui5_srv_draft` ends every write with `COMMIT WORK AND WAIT`, and `cleanup( )` on a first start (a restore included) with `COMMIT WORK`. Until 2026-10-22 the monitor interface, `architecture-seams.md` and a handler comment promised that a sticky app's LUW is "not touched on any path", which was false on exactly those paths. Reviewed then and **decided to document rather than change**: (1) the writes exist so the URL, Back/Forward and a hop to another app survive — a sticky app that asked for KEEP routing or app state asked for a bookmarkable draft, and a hop has to persist the caller; (2) writing the draft over a secondary database connection would move every store access, the collision path and the cleanup onto that connection and make the shipped store depend on a DBCON entry that ABAP Cloud and the transpiled runtime do not have; (3) the store is a seam (`z2ui5_if_ui5_draft_store`, `set_instance( )`), so an installation whose sticky apps must keep their LUW across hops can install a store of its own on a connection of its own, which is where that cost belongs. The contract is now stated where an app author reads it (`z2ui5_if_client=>set_session_stateful`), where a monitor author reads it (`z2ui5_if_ui5_monitor`), at the two save sites and here. Do not re-propose a secondary connection in the shipped store, and do not report the commit on those paths as a bug.
- **The pre-main model snapshot in `z2ui5_cl_ui5_handler=>main_process` is not dropped.** Every variant without it trades that pass for a full-model push over the wire on every edit roundtrip whose `main( )` changed nothing bound — do not re-propose dropping it as a performance bug. What the snapshot IS was revised in 2026-10: until then a digest of the serialized model (so a delta roundtrip serialized the whole model once before `main( )` and, with a display, once more for the response), since then a copy of the bound values (`z2ui5_cl_ui5_srv_model=>main_snapshot`), which table sharing makes free for every attribute `main( )` leaves alone, compared value against copy. Measured on the transpiled runtime at 4000 bound rows: the serialization and digest cost 70 ms per call, the copy 1 ms and the compare 9 ms — against a draft parse of 1,100 ms in the same roundtrip, which is why the end-to-end number barely moves there; on a kernel, where the asXML transformation is native and the serialization is interpreted ABAP, the share is larger. The reasoning lives in the comment at that code site.
- **The developer tools are split: the facade, the console capture and the
  roundtrip recorder stay in the preload; the rest is the devtools bundle,
  loaded on demand.** Until 2026-10-10 the whole of `devtools/` rode in the
  shell's inline script, and the decision recorded here said it could not be
  otherwise: on an ABAP system every frontend file arrived in ONE
  `sap.ui.require.preload` block inside the GET response, the bootstrap sets
  the resource root to the ICF node, which answers every GET with the shell
  page — so a module dropped from that block was fetched as `text/html`,
  never defined, and the tools simply did not open (rule 18 is the same
  constraint stated from the other side). The premise changed when the
  handler learned to serve a generated preload as a FILE under a URL
  parameter with an ETag (`?z2ui5-bundle`, for the embed control): that is
  the on-demand delivery path the old entry said was missing. The generator
  now emits a second bundle — `z2ui5_cl_ui5f_preload=>get_devtools( )`, the
  dialog, its fragment, the inspectors, the tabs, the picker, the live
  editor, the report — served on `?z2ui5-bundle=devtools`
  (`_http_get_devtools`, same headers and 304 as the embed bundle, a
  validator of its own in `devtools_hash`), and `devtools/DevTools.js` loads
  it with a `<script>` element the first time the tools are opened and
  reaches the dialog's class through `sap.ui.require( )` afterwards — a
  same-origin file under `script-src 'self'`, no inline script and no eval,
  so rule 13 holds, and the CSP hash of the shell is still taken over the
  inline script alone. What stays eager stays for the reason it always had:
  `Console` and `Recorder` collect BEFORE the problem, and `DevTools.js` is
  the facade the component installs. `trans2abap.js` decides the split
  (`DEVTOOLS_EAGER`) and refuses a shell module that names a bundled one as
  a `sap.ui.define` dependency — the failure the old entry described, caught
  at generation time. Measured 2026-10-10 against the transpiled backend:
  the GET shell went from 426,018 to 338,840 bytes uncompressed and from
  98,177 to 76,708 gzipped (the devtools bundle is 89,749 bytes, 22,494
  gzipped), see the changelog. A page without the
  tools opened never asks for the bundle (`devtools-bundle` e2e). The old
  numbers (2026-08-28: `devtools/` was 32.7% of the preload, 23.2% deferrable)
  were the measurement this change was made on.
- **The custom controls are a bundle of their own, loaded when a view names
  one.** Until 2026-11-23 the 17 files of `bundle/webapp/cc/` rode in the
  frontend bundle of every page: 56 KB of its 247 KB as delivered (minified),
  14 of 70 KB gzipped, for controls that 19 of the 763 apps of
  abap2UI5/samples-controls and abap2UI5/samples-stack use (2.5%). They are
  the third generated text now — `z2ui5_cl_ui5f_cc`,
  `z2ui5_cl_ui5f_preload=>get_cc( )`, served on `?z2ui5-bundle=cc`
  (`_http_get_cc`, the headers and the 304 of the other bundles, a validator
  of its own in `cc_hash`) — and `core/CustomControls.js` loads it with a
  `<script>` element before the first view that needs it is built:
  `actions/Slots` awaits it at each of its three builds (MAIN, nested, the
  fragment of a popup or popover), which are the only places of the frontend
  that turn XML into controls. Measured 2026-11-23: the frontend bundle went
  from 246,555 to 191,411 bytes and from 69,892 to 55,621 gzipped; the
  controls bundle is 57,505 bytes, 15,447 gzipped. Three things were decided
  with it, and are not to be re-opened as cleanups:
  (1) **The trigger is the text of the view, and it is wider than the
  namespace.** In both sample repositories every app reaches a control the
  same way, `xmlns:z2ui5="z2ui5.cc"` on the view; the test also takes a
  module id (`z2ui5/cc/<Name>` in a `core:require` or in JavaScript the view
  carries) and the two sibling BSPs the frontend wires in (`z2ui5_cci`,
  `z2ui5_ccc`): their code is not ours to read, and a control there that is
  built on one of ours would send the loader to the node for it. Neither
  add-on repository does that today (checked 2026-11-23), so for their users
  the rule costs one cached request and buys nothing — narrow it only with
  that in mind. What no test of the view can see is a module in a namespace
  of its own that depends on a control; such a view declares the namespace.
  (2) **The bundle is asked for by its version, of the node the frontend
  came from.** The frontend bundle's tail carries the digest (`ccBundle`),
  the request names it (`z2ui5-version`), and the handler answers
  `immutable` for exactly that digest — an app with a control would
  otherwise revalidate the bundle on every page load, before its first view.
  The tail also remembers the URL its own script was loaded from
  (`bundleUrl`), and the controls are asked of that node rather than of the
  endpoint of the view's component (the developer tools ask the latter):
  they are a part of that frontend and call its `core/` modules, and on a
  page with apps of several backends the view's backend may be another
  release - one from before the split would answer with its whole frontend. The field is also how the frontend knows the controls have
  to be fetched at all: where its files are served one by one (the protocol
  conformance suite, a build of the classic app) there is no tail, nothing is
  loaded, and the UI5 loader finds `cc/<Name>.js` itself.
  (3) **A load that fails fails the view.** The bundle ends in a module of
  its own (`z2ui5/cc/bundle`), so a 200 that is not the bundle — a logon
  page — counts as a failure too; the build that waited rejects with the URL
  and surfaces in the error overlay, and the next view tries again. Going on
  without the bundle would end in a loader error about a file that was never
  there. `trans2abap.js` refuses a module that names a module of a deferred
  bundle it is not part of as a `sap.ui.define` dependency — a control from
  the shell, a developer tool from a control, either way.
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
  **`timer_set( )` / `timer_stop( )` (2026-11, maintainer-approved) are not
  such wrappers:** they do not emit an action, they DECLARE state the
  framework keeps with the app container and re-sends as `START_TIMER` /
  `STOP_TIMER` whenever the app gets or loses the screen
  (`z2ui5_cl_ui5_handler=>main_end_timer`) - a lifecycle no
  `follow_up_action( )` call can express. They do not open the door for
  named action wrappers. The title was solved the other way, without a
  method: `SET_TITLE` sets the launchpad shell title as well inside the
  launchpad.
- **Embedding abap2UI5 into other UI5 apps is built as far as demand asked, not further.** Running it as a reuse component (freestyle views, Fiori elements extensions), several instances per page, and a wrapping custom control were assessed on 2026-09-23 and deferred until there is real demand. Since then several instances per page (stage 2), the `?z2ui5-bundle` and a wrapping control (abap2UI5-addons/embed-ui5-control) exist, on 2026-09-28 the embedded flag that hands the URL to the host (`state.embedded`), which a Fiori elements custom section needed, on 2026-10-10 the opt-in that hands the hash back to a component that is the host's whole page (`state.ownsHash`, the abap2UI5/frontend branches `standard_new` and `cloud_new`), and on 2026-10-12, asked for by the maintainer, `state.ownsPage`: the same opt-in for everything page-wide - the hash, the title, the favicon, the global busy indicator, the "leave page?" prompt - which an embedded component without it now leaves to the host (`ownsHash` is its older name and hands back the same). The findings, the staged plan and why the other page-wide listeners stay page-wide are in `backlog/items/embed-as-reuse-component.md`. The framework's own ids are already component-prefixed (`ViewSlots.ownId`). Do not re-propose the rest as general cleanup.
- **The `z2ui5_cl_xml_view` builder (src/99) is large because each method wraps one UI5 control for the fluent API.** It is **not** being extended or refactored here: the builder from [samples-controls](https://github.com/abap2UI5/samples-controls) replaces it and becomes the new standard. Do not add wrapper methods, controls or parameters, do not split the class, and do not report its size as a finding. The 1:1-with-the-UI5-SDK rule (method, property and event names match the SDK exactly, no invented convenience shortcuts) carries over to the replacement.
- **Deprecate first, remove in a later release (decided 2026-11-26).** The rule is
  `RELEASING.md`, "Deprecation policy": anything an installation can use is marked
  obsolete in the code, listed on the docs Deprecations page and in
  `docs/removal-plan.md`, and announced in a GitHub issue that names the replacement
  and says the previous release tag is where an installation can stay until it has
  migrated; it is removed in a LATER release, under a `BREAKING:` changelog line that
  links that issue (the changelog section is the release notes). Why it is written
  down now: 1.151.0 removed `_bind_edit( )` and the five `*_model_update( )` no-ops
  (#3036), moved the legacy objects to abap2UI5-ext (#3045) and merged
  abap2UI5/frontend into the core (#3023). All three went through an issue naming the
  replacement, and the deletion of the client methods carried a `BREAKING:` line - but #3036 was opened on 2026-11-22, the day the
  methods were deleted, so the warning and the removal shipped in one release, and none of
  the changelog lines linked its issue. The retrospective's answer was this rule, together
  with the tags of every `with-core` repository (`npm run release:ecosystem`) that make
  "stay on the previous release" something a user can actually do, and the nightly
  `ecosystem-canary.yaml`, which shows which consumers a removal on `main` breaks
  before a release carries it. Do not remove a public symbol in the release that
  first announces it.

## History that used to sit in AGENTS.md

Moved here unchanged when AGENTS.md was cut down to what an agent needs
before it starts. The prohibitions these explain are still there, one line each.

### The `src/99` exemptions

**One exemption was opened and has closed again: the popup apps**
(`src/99/02/z2ui5_cl_pop_*.clas.abap`) were ported off `z2ui5_cl_xml_view`
onto `z2ui5_cl_ui5_view_builder` (maintainer decision 2026-09-22), so that
the retired builder has zero consumers anywhere and can go. The port is
complete — none of the 17 classes names the retired builder any more — and
the named pathspec that allowed it came out of
`.github/scripts/frozen-paths-gate.mjs` on 2026-09-25, so `src/99/02` is
frozen again like the rest of the package. It was defensible because the
freeze exists so an installation that upgrades keeps **compiling**, and
the port changed no class name, no method and no signature — only how each
class assembles the XML string it already produced, which the popup tests
pin with `CS` assertions on the displayed XML. It covered nothing else and
it is **not** a precedent — any other change under `src/99` still needs its
own maintainer decision recorded here.

**A second exemption is open for one change: the two dynamic WHERE
builders** (maintainer decision 2026-10-12). `z2ui5_cl_util_ext=>tab_get_where_by_dfies`
put the values of a row into `LIKE '%…%'` literals as they were - a quote
typed into a value help ended the literal and appended SQL of its own - and
`z2ui5_cl_util=>filter_get_sql_where` put each filter's `name` into the
WHERE clause unchecked, while the filters of a selection screen are bound
to the view and come back from the browser. Nothing in this repository
calls either, but the addons do (popups, selection-screen), and an
installation that still has them calls the frozen copies. The fix is the
one popups (abap2UI5-addons/popups#43) and se16n (abap2UI5-addons/se16n#29)
made in their own copies: the quotes doubled, `#` and `_` escaped and
`ESCAPE '#'` always given; and only a plain field name (`[A-Z0-9_/]+`) is
taken, any other filter is skipped. No name, no signature and no result for
a well-formed input changes, so an installation that upgrades keeps
compiling - the reason the freeze exists. The two class files are named in
`.github/scripts/frozen-paths-gate.mjs` for that change only and come out
again right after it; like the popup port it is **not** a precedent.

**One deletion is recorded as such a decision: `z2ui5_cl_pop_js_loader`**
(maintainer decision 2026-09-22). The popup existed to load app JavaScript
onto the `z2ui5` global and call it back through `cs_event-z2ui5`; the
global and the event were removed in the same change, so the class had
nothing left to talk to, and it was deleted rather than kept compiling
against a runtime that no longer answers it. It is a released object, so
an installation naming it stops compiling — the entry in `changelog.txt`
and `docs/removal-plan.md` §0 says so. The deletion went through the
popup pathspec above while it was open; it widened nothing else.

**The package left the core** (maintainer decision
2026-11-17). `z2ui5_cl_xml_view`, `z2ui5_cl_xml_view_cc`, `z2ui5_if_types`
and the seventeen `z2ui5_cl_pop_*` popups moved, unchanged, out of the core -
first to abap2UI5/frontend, which stopped being a delivery repository in the
same step (next entry), and on 2026-11-25 with everything else of the former
`src/99` to [abap2UI5-ext](https://github.com/abap2UI5/abap2UI5-ext);
abap2UI5/frontend is retired. The reasoning is the one behind `src/99/01` two
weeks earlier: an installation that still names one of them installs that
repository next to abap2UI5 and keeps compiling, and a core that does not
ship thirty thousand lines of frozen code stops paying for them in every
downport, transpile and lint. Each file is named in `MOVED_OUT` of
`.github/scripts/frozen-paths-gate.mjs`.

One thing did **not** move, and it is deliberate: **the `FROZEN-ONLY`
symbols of `z2ui5_cl_ui5_util_context` stay.** The moved classes call them
and are compiled against a release of this repository. They go when the
extension stops calling them - which means a change over there first.

One object moved nowhere: **`z2ui5_cl_http_handler` was deleted.** It was
an empty subclass of `z2ui5_cl_ui5_http_handler` that kept the former name
of the HTTP entry point resolving, and the one object of the package a
customer names rather than calls - in an ICF node, or in a handler class of
their own. The node and the handler this repository delivers do not name it
(`z2ui5_cl_ui5_icf_handler` calls `z2ui5_cl_ui5_http_handler`, in a release since
1.148.0), so nothing shipped depends on it; an installation that still does
changes that one name. It is a released object, so this is a break - the
changelog says so.

**`z2ui5_if_exit` was deleted as well**, the same day, and `src/99` with
it. It was first kept - `z2ui5_cl_ui5_user_exit` was typed on it, and the
exit fails closed - and then removed for the reason the package left: the
core is not to carry a second way of doing one thing, and it is not to
depend on anything outside itself. The second lookup, `gi_user_exit_dep`
and the two delegating branches went with it. This one is not free: an
installation whose exit class still implements the old name has a class
that no longer compiles after the update, and with it no exit at all - the
shipped Content-Security-Policy, theme and bootstrap instead of its own -
until the class implements `z2ui5_if_ui5_exit`. The changelog names the
one-line fix first.

What the move costs: the test classes of the moved objects no longer run in
`npm run unit` (the extension lints, it does not transpile).

### The ICF node, the BSP and the cloud service are part of this repository

Maintainer decision 2026-11-17, with the question put to the community
first. abap2UI5 started on the BTP ABAP trial, where it ran through a plain
HTTP handler; BSP support for on-premise launchpads came later, as a second
repository (abap2UI5/frontend) whose branches were built here and pushed
there with a deploy key. By 2026 nearly every installation pulled both, and
they had to match.

So the objects came home:

- `src/03/01` - the ICF node `/sap/bc/z2ui5` and `z2ui5_cl_ui5_icf_handler`,
  `src/03/02` - the BSP `Z2UI5`, generated from `app_source/webapp/`. One
  pull of `main` is a running installation on Standard ABAP.
- The branch `cloud` is generated from `main` (`tools/build-cloud.mjs`,
  `auto-cloud.yaml`) with `cloud/src/03` in place of `src/03`. It is the
  third generated flavour next to `main` and `702`, not a branch anybody
  maintains.
- The node, the BSP and the HTTP service carry the names the frontend
  repository's branches delivered, so an installation keeps its node, its
  BSP and its launchpad target mapping. The handler class is the exception:
  `z2ui5_cl_lp_handler` became `z2ui5_cl_ui5_icf_handler` with the move -
  "lp" said launchpad, and the class is the handler of the node, whatever
  starts the app. The node this repository delivers names the new class;
  the old one stays behind in the package of the removed repository until
  somebody deletes it.

Declined on the way: keeping the handler out of `src/` because it is the one
class that is not portable (it would have left "one pull" a two-step
installation again), and resolving it against a wider dependency in the
existing lint configs (the released-API intersection those configs check
against is the guarantee rule 4 rests on - the handler has configs of its
own instead, `npm run check:service`).

### `z2ui5_t_02` and the dictionary objects

`z2ui5_t_02` used to be the third: a released `name`/`value` structure added
purely so a sample could write
`CREATE DATA … TYPE STANDARD TABLE OF ('Z2UI5_T_02')` without naming a
framework internal. **It was removed on 2026-09-22** — in a year nothing named
it, its only consumer was the unit test pinning its shape, and the app it was
written for went on naming a table of its own. A dynamic type names a type the
*system* has; supplying one from the framework was solving the wrong half of
the problem (`docs/agents/building-apps.md`, `docs/removal-plan.md` §5).

### Why the binding used to be called one-way and two-way

> **Historical note:** writable data used to live under a dedicated `XX/` view-model
> node (`_bind_edit` → `/XX/name`) so the frontend knew which subtree to transport
> back, while `_bind` wrote read-only data to the root. Delta handling made that
> separation obsolete: everything is now written to the root model the same way and
> `_bind`/`_bind_edit` behaved identically, until `_bind_edit` was removed on
> 2026-11-22. That split is where the old
> "one-way/two-way" wording came from — it has no meaning in the current framework.

### The vendored utility classes

What each class under `src/00/03` is, and the one addition the vendored HTTP class carries
(the rule itself is `AGENTS.md`, "Utilities"):

| Class | Status |
|---|---|
| `src/00/03/z2ui5_cl_ui5_util_context` | Vendored from `zabaputil_cl_util_context`, trimmed to the methods used here. **The one class to use and to extend** |
| `src/00/03/z2ui5_cl_ui5_util_http` | Vendored from `zabaputil_cl_util_http` — leave it alone unless a fix or a caller genuinely needs it. The one addition so far is the raw query (`get_query`, the `query` of `get_req_info` and `client_call`) for the two connector addons, which read and forward their requests through this class (maintainer decision 2026-09-30); the second is `client_request` - header fields, a timeout and the ABAP Cloud client (`CL_WEB_HTTP_CLIENT_MANAGER`, by name) - for the language model providers in `src/01/05`, which `client_call` now wraps (2026-10-15). The sync carries both back to abap-util |
| `src/00/03/z2ui5_cx_ui5_util_error` | Vendored from `zabaputil_cx_error`, copied as-is — same |
| `src/00/03/z2ui5_cl_ui5_util_json_fl` | Framework-owned, no abap-util master |
| `z2ui5_cl_util*`, `z2ui5_cx_util_error`, `z2ui5_t_91` | **Moved out** (formerly `src/99/01`; to abap2UI5-ext on 2026-11-02) - they ship from [abap2UI5-ext](https://github.com/abap2UI5/abap2UI5-ext) (2026-11-17 to 2026-11-25 from abap2UI5/frontend, now retired), which a system still using them installs next to abap2UI5. Superseded by the classes above |
