# AGENTS.md — AI Assistant Guide for abap2UI5

> This file follows the cross-tool AGENTS.md convention and is the single
> agent instruction file of this repository — there is no separate
> `CLAUDE.md`; Claude Code reads `AGENTS.md` natively.

### Where knowledge lives

This file is loaded into **every** session, so what it costs is paid on every
task. Keep it to what an agent must know *before* it can know it needs to look
something up. Everything else belongs closer to the code:

| Kind of knowledge | Where it belongs |
|---|---|
| A constraint on **one file or method** ("never change this key", "this dialog must not be Escape-dismissable") | A comment **at that code site**. AGENTS.md may state the rule in one line and point there — it must not repeat the reasoning |
| A rule that can be **checked mechanically** | A lint rule or a CI gate. Prose is a request; a gate is a guarantee |
| A **procedure** ("how to regenerate the frontend", "what is out of scope in a review") | A place that is read when the task comes up, not on every task |
| A **prohibition** an agent would otherwise violate unknowingly | Here — it has to be in context before the mistake, so it cannot be looked up on demand |

When you fix something subtle, write the reasoning **into the code** and add at
most a pointer here. The comment ages with the code it guards; a paragraph in
this file does not.

## Project Overview

abap2UI5 is a framework for building SAP UI5 applications purely in ABAP — no JavaScript, OData, or RAP required. It supports all ABAP releases from NW 7.02 to ABAP Cloud, running in both on-premise and cloud environments.

**Current version:** the `version` constant in `src/02/z2ui5_if_app.intf.abap` — read it there; a number repeated here is a number that goes stale (it did, at 1.142.0, and nothing caught it: `check:version` holds that constant to `package.json`, not to this file)
**License:** MIT
**Homepage:** https://abap2UI5.org
**Language:** English — all code, comments, commit messages, PRs, issues, documentation, and communication must be in English.

### Related Repositories

| Repository | Purpose |
|---|---|
| [abap2UI5](https://github.com/abap2UI5/abap2UI5) | Core framework (this repo) |
| [samples](https://github.com/abap2UI5/samples) | Sample applications and usage examples — step 1 of the three sample catalogues |
| [samples-controls](https://github.com/abap2UI5/samples-controls) (formerly ai-demokit) | Step 2: the official UI5 demo kit rebuilt with abap2UI5, one port per sample, gate-verified. Also carries `CAPABILITIES.md` — what abap2UI5 can express, each claim naming the port that proves it |
| [samples-stack](https://github.com/abap2UI5/samples-stack) (formerly samples-ext) | Step 3: everything that needs more than an abap2UI5 installation — OData, RAP, WebSockets, the Fiori Launchpad. The dividing line against `samples` is that requirement, not the topic |
| [docs](https://github.com/abap2UI5/docs) | Project documentation — the prose for **people**; it generates its own `llms.txt` for agents. `llms.txt` here is the map of the CODE, and the two are deliberately different things |
| [linter](https://github.com/abap2UI5/linter) | `@abap2ui5/linter` — static + headless-render checks over an app class and the view its builder produces. A devDependency **here** (`abap2ui5lint.jsonc`, rule 21) and the destination of the `ui5-check` skill's `Linter:` lines |
| [mcp-server](https://github.com/abap2UI5/mcp-server) | MCP server giving an agent the loop without an SAP system: search the catalogues, validate a view, deploy, build, run headless, screenshot |
| [vscode-extension](https://github.com/abap2UI5/vscode-extension) | IDE support — lints while you type, `F9` runs a class against a real system, and registers the MCP servers into the editor |
| [abap-util](https://github.com/abap-util/abap-util) | Master catalog of the platform utilities — upstream of `src/00/03/` (see "Utilities") |
| [app-template](https://github.com/abap2UI5/app-template) | Starter repo for app projects — gates, CI and agent setup preconfigured |
| [custom-controls](https://github.com/abap2UI5-addons/custom-controls) | Community custom controls in their own BSP — the reserved resourceRoot `z2ui5_cci` in `app/webapp/manifest.json` is what makes it findable |
| [customer-frontend-extension](https://github.com/abap2UI5/customer-frontend-extension) | Template for a customer's **own** frontend artefacts (reuse library, icon font, CSS) in their own BSP — same mechanism under the reserved resourceRoot `z2ui5_ccc`. Both roots exist so nobody has to patch `index.html` / `manifest.json`, which are generated here and overwritten downstream |

> **Building apps?** This file is the briefing for AI assistants working **on the framework itself**. For everything an AI needs to **build apps with** abap2UI5 — app template, client API, view-building patterns, lifecycle — read the in-repo guide **`docs/agents/building-apps.md`** (also wired as the `build-an-app` Claude Code skill; `llms.txt` indexes both audiences). The rendered docs site is <https://abap2ui5.github.io/docs/> — unreachable from many sandboxes, which is why the guide lives in-repo.

## Architecture

### How It Works — The Roundtrip

abap2UI5 is a **stateful SPA** (Single Page Application). The browser loads a UI5 shell once via HTTP GET, then communicates with the ABAP backend exclusively via HTTP POST/JSON roundtrips:

```
Browser (UI5 SPA)                          ABAP Backend
       │                                        │
       │──── HTTP GET ─────────────────────────→│  Returns HTML + embedded UI5 app
       │←─── HTML page ─────────────────────────│
       │                                        │
       │──── POST {S_FRONT, MODEL} ────────────→│  1. Parse JSON request
       │                                        │  2. Load draft (session) from DB
       │                                        │  3. Apply model changes (MODEL → ABAP vars)
       │                                        │  4. Call app->main(client)
       │                                        │  5. App builds view / handles events
       │                                        │  6. Save new draft to DB
       │←─ {S_FRONT: ID, APP, S_ACTION; MODEL} ─│  7. Return JSON response
       │                                        │
       │  (UI5 renders XML view, binds model)   │
       │──── POST (next event) ────────────────→│  ... repeat
```

**Request JSON** contains `S_FRONT` (event name, draft ID, browser state) and `MODEL` (view model changes as deltas).
**Response JSON** contains a new draft ID, the app class name, and two action lists under `S_ACTION`: `T_SYSTEM` view-lifecycle calls (which carry any view XML) and `T_CUSTOM` follow-up actions (including messages). `MODEL` — the full JSON view model — travels only when something bound changed.

#### Launchpad Special Case — Request Body Wrapping

The frontend always sends the POST body as `{ "value": <payload> }` (see `app/webapp/core/Server.js`). In standalone mode this envelope arrives intact and `request_parse_body` reaches through it via a `/value` path prefix.

When the app runs inside the **SAP Fiori Launchpad** (FLP), requests may be routed through the FLP shell or an SAP Gateway proxy. In certain configurations this infrastructure strips the `value` envelope before the request reaches the ABAP ICF handler, so the payload arrives as a plain object without the `value` key.

`request_parse_body` handles both cases defensively by computing a root prefix once (a keyed `exists` check instead of slicing/copying the whole tree just to unwrap it), then slicing the sub-containers relative to it:
```abap
DATA(lv_root) = COND string( WHEN lo_ajson->exists( `/value` ) = abap_true
                             THEN `/value` ).
" standalone: lv_root = `/value`   launchpad/gateway: lv_root = `` (empty)
result-o_model = lo_ajson->slice( lv_root && `/MODEL` ).
lo_ajson       = lo_ajson->slice( lv_root && `/S_FRONT` ).
```

The Launchpad context is detected afterwards from the parsed request fields:
```abap
result-s_control-check_launchpad = xsdbool(
    result-s_front-search   CS `scenario=LAUNCHPAD`
    OR result-s_front-pathname CS `/ui2/flp`
    OR result-s_front-pathname CS `test/flpSandbox` ).
```

Both scenarios are covered by unit tests in `z2ui5_cl_ui5_handler.clas.testclasses.abap` (`test_parse_body_with_wrapper` / `test_parse_body_no_wrapper`).

#### Launchpad Special Case — The URL Hash

Inside the FLP the shell owns the front of the hash and only the remainder is the **app hash**. Exactly two places know this rule and they mirror each other — **do not re-implement the split anywhere else**, and do not rebuild a URL from `location.href.split("#")[0]` plus an app hash (use `Router.hrefFor()`):

| Side | Owner |
|---|---|
| Frontend | `app/webapp/core/Router.js` — `splitHash()`; the **only** module allowed to touch the hash |
| Backend | `z2ui5_cl_ui5_handler=>hash_get_app_part` — used by the route parser and the app-state parser |

Both modules carry the full explanation (hash layout, why the split keys off the leading `/` rather than the first `&/`, what breaks otherwise) in their header comments. Covered by `node/tests/router.spec.js` and the `test_hash_app_part` / `test_route_launchpad` / `test_app_state_hash` unit tests.

### Layered Design

```
src/
├── 00/   Layer 0: Utilities (AJSON, S-RTTI, framework context/HTTP abstractions)
├── 01/   Layer 1: Core engine (handler, action, binding, model, events, draft service, embedded frontend)
├── 02/   Layer 2: Public API (z2ui5_if_app / _client / _exit, z2ui5_cl_ui5_http_handler, z2ui5_cl_ui5_view_builder)
└── 99/   FROZEN legacy code. Legacy XML view builder (z2ui5_cl_xml_view / _cc), the deprecated z2ui5_cl_http_handler shim, retired z2ui5_cl_util* classes (99/01) and popups (99/02). Ships so existing downstream installations keep compiling. Its test classes are the exception: they run in CI and guard the layer
```

- **Layer 0 (`src/00/`)** — Self-contained utility libraries. AJSON (`src/00/01/`) handles JSON; S-RTTI (`src/00/02/`) provides runtime type reflection — both are mirrored from external projects, DO NOT MODIFY. `src/00/03/` holds the context/HTTP abstractions (`z2ui5_cl_ui5_util_context`, `z2ui5_cl_ui5_util_http`, `z2ui5_cl_ui5_util_json_fl`, `z2ui5_cx_ui5_util_error`), all but `_json_fltr` vendored from abap-util (see "Utilities"). The `noIssues` flag in `abaplint.jsonc` suppresses lint warnings for all of `src/00`.
- **Layer 1 (`src/01/`)** — Core engine. Session drafts (`src/01/01/`), request processing, event routing, data binding, model management, app lifecycle (`src/01/02/`). Embedded UI5 frontend resources as ABAP string constants (`src/01/03/` — auto-generated, never manually edit). Those carry the `z2ui5_cl_ui5f_*` prefix (UI5 **f**rontend); the bare `z2ui5_cl_ui5_*` segment covers everything else the framework owns — hand-written ABAP-side helpers (`z2ui5_cl_ui5_view_builder`), the engine (`z2ui5_cl_ui5_handler`), and the shipped apps (`z2ui5_cl_ui5_app_start`, `z2ui5_cl_ui5_app_hi_world`). No `z2ui5_cl_app_*` object exists any more; that segment used to mean both a generated frontend artefact and a real ABAP app, which is what made it worth retiring.
- **Layer 2 (`src/02/`)** — Public API. The stable contract for app developers. Six objects: `z2ui5_if_app`, `z2ui5_if_client`, `z2ui5_if_types`, `z2ui5_if_exit`, `z2ui5_cl_ui5_http_handler` (the HTTP entry point) and the view builder `z2ui5_cl_ui5_view_builder`. Recorded symbol for symbol in `.github/api-snapshot.json` (rule 5). `z2ui5_if_types` briefly sat in `src/99` after the `ui5` rename and was moved back: three public `src/02` signatures name its types, so an app could not call the API without resolving into the frozen package.
- **Package `src/99/` — frozen legacy code.** Its production code has **zero consumers** anywhere in this repository — no framework code, no app, no tooling references it (what remains are comments naming the old classes). It ships solely so **existing downstream installations** keep compiling on upgrade. Its **test classes are live**, though: they lint and run in the transpiled unit suite (`npm run unit`), guarding the layer against regressions — which is why they, unlike the production code, may change (they assert against core internals such as `t_action_front` and follow them when those move):
  - **Package top level** — the legacy XML view builder (`z2ui5_cl_xml_view`, `z2ui5_cl_xml_view_cc`), superseded by `z2ui5_cl_ui5_view_builder` in `src/02/`, and the deprecated `z2ui5_cl_http_handler` shim that forwards to `z2ui5_cl_ui5_http_handler`. All builder work happens in `z2ui5_cl_ui5_view_builder`.
  - `src/99/01/` — the retired utility classes (see "Utilities").
  - `src/99/02/` — the obsolete built-in popup/dialog apps (`z2ui5_cl_pop_*`), replaced by the [popups addon](https://github.com/abap2UI5-addons/popups).

  **For AI assistants this means: never change the production code under `src/99/` or add consumers on it.** It is out of scope for reviews and audits. The `check_gates` workflow enforces the freeze; the `*.testclasses.abap` files and the abapGit `.clas.xml` sidecars are exempt from it, because the tests keep running in CI and must follow the core internals they assert on. Moving an object **out** of the package is also allowed — abapGit installs the repository, not the folder, so an object that relocates and keeps shipping breaks no downstream install. The gate refuses a deletion only when the object name exists nowhere else under `src/` afterwards **and** the object shipped in the latest release tag — an object added since that release has never reached an installation, so dropping it breaks nothing. Anything edited in place is refused either way.

### Utilities — the context class is the only door

**This section is the single source of truth for how the framework reaches system and platform functionality. Everything about utilities is settled here; nowhere else in this file repeats it.**

**Rule: every system- and environment-specific function is called through a method of `z2ui5_cl_ui5_util_context` (`src/00/03/`).** RTTI, conversions, UUID, messages, XML/transformations, timestamps, base64, database rollback, environment detection — framework code never calls `cl_abap_*`, a function module, or an environment-specific API directly. The dependency on every SAP standard object lives in exactly one class, which is what makes the framework portable across NW 7.02 / Standard ABAP / ABAP Cloud and transpilable to JS. Environment branching happens inside that class via `check_abap_cloud( )` and dynamic calls, so the framework compiles on every target.

**When the function you need is missing, in this order:**

1. **Look in [abap-util](https://github.com/abap-util/abap-util) first.** It is the master catalog and holds all utility methods, unit-tested and linted for all three targets.
2. **If it exists there: copy it into `z2ui5_cl_ui5_util_context`** — with its private helper closure, renamed to this repo's namespace. Do not re-implement what the catalog already has.
3. **If it does not exist: write a new method** directly in `z2ui5_cl_ui5_util_context`. There is no upstream-first step and nothing to coordinate — this copy leads, abap-util follows.
4. **Separately and periodically, an AI syncs back:** it compares the context class against abap-util and merges what was added or fixed here into the catalog, so the master stays the superset for every other project. It diffs method *bodies*, not just names — see [abap-util's AGENTS.md](https://github.com/abap-util/abap-util/blob/main/AGENTS.md).

**Consequences of that process:**
- **`z2ui5_cl_ui5_util_context` is not a read-only mirror — edit it freely.** Add methods, change existing ones, extract helpers, refactor. (Only the AJSON/S-RTTI mirrors in `src/00/01` and `src/00/02` are off-limits.)
- **Keep what you add generic.** Framework-specific logic belongs in the core `z2ui5_cl_ui5_*` classes; the sync harvests this class into a catalog other projects consume.
- **Symbols marked `FROZEN-ONLY`** in the class have no caller anywhere in `src/00`–`src/02`. They exist only because the shipped `src/99` package still calls them on real systems, and they go when `src/99` goes — do not add new callers on them.

**What is vendored, and what is legacy:**

| Class | Status |
|---|---|
| `src/00/03/z2ui5_cl_ui5_util_context` | Vendored from `zabaputil_cl_util_context`, trimmed to the methods used here. **The one class to use and to extend** |
| `src/00/03/z2ui5_cl_ui5_util_http` | Vendored from `zabaputil_cl_util_http`, copied as-is — leave it alone unless a fix is genuinely needed |
| `src/00/03/z2ui5_cx_ui5_util_error` | Vendored from `zabaputil_cx_error`, copied as-is — same |
| `src/00/03/z2ui5_cl_ui5_util_json_fl` | Framework-owned, no abap-util master |
| `src/99/01/z2ui5_cl_util*`, `z2ui5_cx_util_error`, `z2ui5_t_91` | **Legacy.** Superseded by the classes above. They must stay so downstream apps keep compiling, but must never be used, called from new code, or changed |

abap2UI5 does **not** depend on abap-util at install time: abapGit has no dependency management, and abap2UI5 must stay "clone and go". Hence renamed copies instead of a dependency. The same principle applies in the other repos of the ecosystem — [abap2UI5-addons/popups](https://github.com/abap2UI5-addons/popups) has its own `z2ui5_cl_popup_context` with its own namespace and method subset, and is the designated successor of the obsolete built-in popups in `src/99/02/`.

### Data Binding

The framework provides **transparent data binding** between ABAP variables and UI5 controls:

| Method | Path Format | Direction | Use Case |
|---|---|---|---|
| `client->_bind(var)` | `{/attribute}` | ABAP ↔ UI | Any bound data — input, display, tables |
| `client->_bind_edit(var)` | `{/attribute}` | ABAP ↔ UI | Obsolete alias of `_bind`, kept for compatibility |

**How it works:**
1. When you call `_bind(name)`, the framework discovers the ABAP attribute via RTTI and maps it to a UI5 model path `/name`
2. On outbound (ABAP → browser): all bound attributes are serialized to JSON and sent as `MODEL`
3. On inbound (browser → ABAP): the edited model paths are read back from the request `MODEL` container and written into the ABAP variables
4. Table bindings use **delta updates** — only changed rows/cells are transferred

**Terminology: say "binding", never "one-way"/"two-way" binding.** There is only
one kind of binding left — `_bind( )` — and it always carries values in both
directions, so the qualifier distinguishes nothing and only suggests a second
mode that no longer exists. Write "bound attribute", "the binding writes the
value back", "the model delta". The one legitimate use of "one-way" is a real
UI5 one-way model that is not `_bind( )` (the `device>` JSONModel, for example).

> **Historical note:** writable data used to live under a dedicated `XX/` view-model
> node (`_bind_edit` → `/XX/name`) so the frontend knew which subtree to transport
> back, while `_bind` wrote read-only data to the root. Delta handling made that
> separation obsolete: everything is now written to the root model the same way and
> `_bind`/`_bind_edit` behave identically. That split is where the old
> "one-way/two-way" wording came from — it has no meaning in the current framework.

### Session Persistence (Draft Service)

App state is persisted between roundtrips via the draft service (`z2ui5_cl_ui5_srv_draft`):
- **Table `Z2UI5_T_01`** stores serialized app state (XML) keyed by UUID
- Each roundtrip: load draft → restore app → call `main()` → save new draft with new UUID
- Draft IDs chain via `id_prev` for back-navigation through the app stack
- In-memory buffer cache avoids repeated DB reads within one request
- **Owner binding:** each draft stores its creator's `sy-uname` (column `UNAME`); `read`/`check_exists` only return a draft to that same user, so a leaked or guessed draft id (bookmark URLs carry it) cannot restore another user's serialized state. A mismatch fails closed with the same `NO_DRAFT_ENTRY...` exception as "not found", so a shared bookmark degrades to a fresh app start. Legacy rows written before the column existed carry a blank owner and stay readable during the upgrade transition (they expire within a few hours), so no active session breaks on upgrade.

### Key Design Patterns

- **Factory:** `z2ui5_cl_ui5_http_handler=>factory()` / `factory_cloud()` for on-premise vs. cloud
- **Generic View Builder:** `z2ui5_cl_ui5_view_builder=>factory()` + `ele`/`tag`/`a`/`end`/`stringify` builds any UI5 XML view 1:1 (see `src/02/z2ui5_cl_ui5_view_builder.clas.abap`)
- **Event Routing:** `client->_event('ID')` registers; `client->check_on_event('ID')` checks
- **App Navigation:** `client->nav_app_call(app)` pushes; `client->nav_app_leave()` pops (executed in a loop within one roundtrip)
- **Multi-View:** Main view, nested views (nest/nest2), popups, and popovers simultaneously
- **Exit Pattern:** `z2ui5_if_exit` (the public extension point) implemented by `z2ui5_cl_ui5_user_exit` for custom themes, CSP headers, etc.

### Building Apps

App-building guidance (view builder choice, lifecycle patterns, canonical app template, client API) lives in **`docs/agents/building-apps.md`** — the self-contained in-repo guide, also exposed as the `build-an-app` skill. Do not duplicate it here; the rendered docs site is <https://abap2ui5.github.io/docs/>.

## Repository Structure

```
src/
├── 00/                        # Layer 0: Utilities
│   ├── 01/                    #   AJSON — JSON serialization (mirrored, DO NOT MODIFY)
│   ├── 02/                    #   S-RTTI — Runtime type information (mirrored, DO NOT MODIFY)
│   └── 03/                    #   Context/HTTP abstractions (z2ui5_cl_ui5_util_context, _http, _json_fltr, z2ui5_cx_ui5_util_error) — vendored copies from abap-util (except _json_fltr)
├── 01/                        # Layer 1: Core Engine
│   ├── 01/                    #   Draft service (z2ui5_cl_ui5_srv_draft + z2ui5_t_01)
│   ├── 02/                    #   Core classes (handler, client, action, action_front, app, srv_bind, srv_event, srv_model + z2ui5_if_ui5_types)
│   ├── 03/                    #   Embedded UI5 frontend (auto-generated, DO NOT EDIT)
│   └── 04/                    #   Shipped apps + default exit (z2ui5_cl_ui5_app_start, _app_hi_world, _user_exit)
├── 02/                        # Layer 2: Public API (the whole contract - 6 objects)
│   ├── z2ui5_if_app.intf.abap          # Main app interface (version constant)
│   ├── z2ui5_if_client.intf.abap       # Client interaction methods
│   ├── z2ui5_if_types.intf.abap        # Shared type definitions
│   ├── z2ui5_if_exit.intf.abap         # Customization exit points
│   ├── z2ui5_cl_ui5_http_handler.clas.abap  # HTTP entry point
│   └── z2ui5_cl_ui5_view_builder.clas.abap  # Generic XML view builder
└── 99/                        # HISTORY ONLY - ignore completely, zero in-repo consumers
    ├── z2ui5_cl_xml_view.clas.abap     # Legacy fluent view builder (~16K lines) - superseded by z2ui5_cl_ui5_view_builder
    ├── z2ui5_cl_xml_view_cc.clas.abap  # Legacy custom controls builder - superseded by z2ui5_cl_ui5_view_builder
    ├── z2ui5_cl_http_handler.clas.abap # Deprecated shim - forwards to z2ui5_cl_ui5_http_handler
    ├── 01/                    #   Retired z2ui5_cl_util* classes + z2ui5_t_91 (obsolete)
    └── 02/                    #   Built-in popups (z2ui5_cl_pop_*, formerly src/02/01/) (obsolete)
                               #   to_confirm, to_inform, to_select, file_dl, file_ul, table, textedit,
                               #   pdf, html, messages, error, input_val, data, demo_output,
                               #   image_editor, js_loader, get_range, get_range_m
```

### Additional Directories

| Directory | Purpose |
|---|---|
| `app/` | Frontend tooling (`package.json`, `ui5.yaml`, `eslint.config.mjs`, `.prettierrc`, `.editorconfig`) |
| `app/webapp/` | UI5 frontend source — `Component.js`, `index.html`, `manifest.json`, `controller/`, `view/`, `model/`, `css/`, `Util.js` (the **public** date helpers exposed as the `z2ui5.Util` global), `cc/` with one file per custom control (`Timer.js`, `Scrolling.js`, … — module IDs `z2ui5/cc/<Name>`, resolved from the `z2ui5` XML namespace which maps to `z2ui5.cc`), and `core/` with the internals: `Server.js` (the JSON POST client that wraps the body as `{ "value": <payload> }` — roundtrip, request sequencing, aborts), `Session.js` (the session-constant request block, sent once per page load, and the page-location send cadence), `ScrollFocus.js` (focus/caret + per-slot scroll capture for `S_FOCUS`/`S_SCROLL`), `AppState.js` (owner of the shared frontend state + the documented inventory of all `z2ui5.*` globals), `ViewSlots.js` (access layer for the five view slots — lookups, byId resolution and teardown), `Lib.js` (shared helper module), `FrontendAction.js` (the action registry/dispatcher behind the controller's `eF()` entry point and the response's action lists — the handlers live in `core/actions/`, one domain module each: `ControlCall.js` with the `CONTROL_GLOBAL`/`CONTROL_BY_ID`/`BINDING_CALL` whitelists and the message toast/box display hooks, `Slots.js` with the view-slot display machinery and model tracking, `Browser.js`, `Launchpad.js`, `Variants.js`, `Shortcuts.js`, `ViewOps.js`, and `LegacyCustomJs.js` with the legacy `eF()`-string parser), `Router.js` (hash routing — the only module allowed to touch the URL hash) and `ErrorView.js` (the fatal-error overlay); **`devtools/` is a SIBLING of `core/`, not a part of it** — it holds the **entire** in-app developer tools, which are deliberately **not** part of the framework, and the folder sits at the top level precisely because `core/` means framework: `DevTools.js` (the lifecycle facade and the framework's single entry point: shortcut, dialog instance, auto open, error-details provider), `DeveloperTools.js` + `.fragment.xml` (the dialog — six groups: Overview / Problems / Roundtrips / View & Data / System / Search, the last being the cross-tab search on a tab of its own), **`Tabs.js` (the tab registry — the ONE table that says what a tab is: its group, label, kind, producer, availability and export position; the tab strip, the search and the export are all driven from it, and adding a tab is one entry here)**, `Format.js` (the two value formatters, `toJson` / `prettifyXml`), `Report.js` (the bug report: the plain-text export, the GitHub-ready Markdown form and the downloads), `AbapSource.js` (the running app's ABAP class — the ADT source endpoint, the deep link at the line of the last event, the source cache), `Console.js` (in-app capture of UI5's log, uncaught errors/rejections and every `console.*` call, so the browser's own devtools do not have to be open), `Recorder.js` (roundtrip history behind the History / Model Diff / View Diff views; observes the framework only through the `onAfterRendering` callback array and the Resource Timing API), `Inspect.js` (the read-only reports behind the Overview / Log / Environment / Registry / Actions / Bindings views — the Log merges the framework error log, the console capture and the backend messages into one timeline), `Picker.js` (the control picker) and `LiveEdit.js` (roundtrip-free re-render of an edited view XML, through the same `actions/Slots.action` entry point the backend's `VIEW_SLOTS` action uses). The tab **keys** (`VIEW`, `HISTORY`, `POPUP_MODEL`, …) are a compatibility surface — `?z2ui5-devtools=<KEY>` and the remembered last tab in sessionStorage both store them, so a key may be added but never renamed. **No framework module carries developer-tools code, names a developer-tools module, or holds a developer-tools object — keep it that way:** `Component.js` calls `DevTools.install()` / `DevTools.exit()` and that is the whole footprint; `core/ErrorView.js` reaches the Details action through the generic `onErrorDetails` callback array (`AppState`) and hides the button when nothing registered, so deleting `devtools/` degrades the framework gracefully instead of breaking it; `model/models.js` holds the device model setup and `model/formatter.js` is the curated app-level formatter module (the `z2ui5.Formatter` global / `core:require` of `z2ui5/model/formatter`) that owns the date helpers and value formatters — `Util.js` is now a **deprecated** legacy alias re-exporting them |
| `node/srv/` | `express.mjs` (dev server on port 3000), `zcl_sicf.clas.abap` (reference ICF handler impl — ~15 lines; real apps follow the same pattern), plus the `zcl_tst_nav_*` test apps used by the browser navigation tests (copied into `node/downport/` during `auto_transpile`) |
| `node/setup/` | `abap_transpile.json` (transpiler config), `setup.mjs` (SQLite bootstrap for Node unit tests) |
| `node/tests/` | Playwright tests — browser tests in `e2e/` (`example.spec.js` shell smoke test, `roundtrip.spec.js` POST/draft wire contract, `lib-sanitizer.spec.js` XSS regression tests for `Lib.sanitizeMessageDetails`, `error-view.spec.js` fatal-error overlay accessibility/focus/Retry tests, `nav-back-forward.spec.js` browser history navigation, `focus-after-enable.spec.js` SET_FOCUS retry after a re-render; run via `node/playwright.config.js` against the dev server), plus JS unit specs (`*.spec.js` — see the spec-to-module mapping under "Testing" below) that load the **real** `app/webapp` modules via `loadModule.js` (stubbed `sap.ui.define`, stubbable dependencies); run them without a browser via `npx playwright test -c node/playwright-unit.config.js` (the unit config ignores `e2e/`) |
| `node/tests-examples/` | Playwright example specs and performance benchmarks (reference material, not run in CI) — `modelUpdate.bench.spec.js` measures the model-update strategies and documents its own setup; run via `node/playwright-bench.config.js` |
| `docs/agents/` | `building-apps.md` — the in-repo app-building guide (see "Building Apps"; gated by `npm run check:guide`) |
| `docs/` | `removal-plan.md` — the standing checklist of everything obsolete: what replaces it, what breaks, and what has to happen first. Read it before removing any compatibility symbol, and tick the box in the same PR |
| `.claude/skills/` | The four catalogues, by audience: `build-an-app` (how to write an app **with** abap2UI5 — the `docs/agents/building-apps.md` guide), `abap-check` (every **ABAP** problem a green CI misses — abapGit round trip, activation, extended check, downport, runtime), `ui5-check` (every **UI5** problem a green CI misses — post-1.71 names, version-sensitive layout, views that fail to load, CSP traps; also the staging area for the [abap2UI5 linter](https://github.com/abap2UI5/linter), so each entry says what a rule would need to decide it). `view-chain-layout` (the layout rules for a builder chain — one call per line, four spaces per level, the `end( )` column, which `factory( )` shape goes with which chain shape; the rules the abap2UI5-linter's `chain-house-layout` checks — `npm run check:abap2ui5`; the same file is in both sample repositories). Build with the first two, check with the other two |
| `backlog/` | The stock of things to file, in four backlogs by where they get filed: `OPEN-ABAP.md` (`open-abap/open-abap-core`, `abaplint/transpiler`), `ABAPLINT.md`, `ABAP2UI5-LINTER.md` and `ABAP2UI5.md` (this repository). All four are **generated** from `backlog/items/<id>.md` — `npm run backlog`, gated by `npm run check:backlog` — and each item is written to be pasted into an issue as it stands. A skill section names what it put in the stock with a `**Backlog:**` line, so the analysis stays next to the defect and the backlog fills itself; converting an item into an issue stays a human step, and a shipped one is **deleted** rather than kept as a row. Details in `backlog/README.md` |
| `tools/` | Everything that **generates** an artefact out of `app/webapp/`, in one place — `app2abap/` (→ the embedded ABAP constants in `src/01/03/`), `app2bsp/` (→ BSP pages plus the minified UI5 component preload bundle), `app2app_v2/` (the legacy-free UI5 2.x bootstrap patch), `bsp_rename/` (deployment identity for a parallel install), `build-branches.mjs` (drives them into one delivery branch — the four published ones into the committed `build/`, anything else into the git-ignored `tools/out/`), `branch-stamp.mjs` (the provenance a branch carries, `VERSION` and the README banner, written at deploy time because it names the commit being made), `check-pages.mjs` (BSP page invariants on the built artefact), `verify-branches.mjs` (byte-for-byte diff against the published branches), `check-v2-sdk.mjs`. Not to be confused with `.github/scripts/`, which are CI gates: they read the repository and answer yes or no, they do not produce deliverables. Details in `tools/README.md` |
| `build/` | The four delivery branches of [abap2UI5/frontend](https://github.com/abap2UI5/frontend) as trees — `cloud/`, `cloud_v2/`, `standard/`, `standard_v2/`, each the whole branch as abapGit pulls it. **Generated, never edited**: `npm run frontend:build` rebuilds them, `npm run check:frontend` is the gate, and they are committed with the change that caused them — the same contract `src/01/03/` has against `app/webapp/`. `frontend_deploy.yaml` ships these trees as they stand — stamped into `result/<branch>` folders on abap2UI5/frontend's `main`, fanned out into the branches by that repository's `deliver` workflow — so what reaches an installation is what the pull request reviewed. Renamed variants (`standard_<name>`) have no committed tree and are built on demand. Details in `build/README.md` |
| `frontend/` | The parts of the [abap2UI5/frontend](https://github.com/abap2UI5/frontend) delivery branches that are not generated from `app/webapp/` — data, not code: `abap/cloud/` + `abap/standard/` (the ICF/BSP ABAP artefacts each branch ships, with `abap/cloud/abaplint.jsonc` linting them in place and being copied into each branch with its glob turned to `/src/`) and `common/` (the files every generated branch inherits). The cloud branches ship `app/` from this repository directly — a second copy of the Fiori project is what let the two drift apart before. Details in `frontend/README.md` |
| `.github/workflows/` | CI/CD workflows (see below) |
| `.github/scripts/` | `ui5lint-gate.mjs` — runs the UI5 linter and fails on any error; design-accepted findings are suppressed at the source (inline `ui5lint-disable` comments, whole files in `app/ui5lint.config.mjs`); `testclass-visibility-gate.mjs` — fails when a local test class reads a PRIVATE/PROTECTED member of the class under test without `LOCAL FRIENDS`; `api-snapshot.mjs` — records/compares the `src/02` public-API snapshot (rule 5); `check-guide-api.mjs` — fails when `docs/agents/building-apps.md` names a client method or `cs_*` constant the API does not have; `object-naming-gate.mjs` — fails when an object outside the public API carries no `ui5`/`ui5f` segment (exemptions and the scheduled-but-not-done list live in the script, each with its reason); `dynamic-name-gate.mjs` — fails when a `Z2UI5_*` class or interface named by a string literal (dynamic lookup, `CREATE OBJECT TYPE (name)`) does not exist in `src/` (names owned by other repositories live in the script's `EXTERNAL` list, each with its reason); `ui5-icon-gate.mjs` — fails when a `sap-icon://` name in `src/` or `app/webapp/` is not in the UI5 1.71 icon font. The 655-name set is **derived** from `@abap2ui5/linter`'s generated `data/icons.json` (`since <= 1.71`, minus what the font removed by then), not hand-kept — it used to be a third copy of UI5 metadata in this ecosystem. `src/99` is exempt as frozen and its two wrong icons are printed on every run; `frontend-module-gate.mjs` — fails when a `sap.ui.define` dependency array in `app/webapp/` names a UI5 module outside the reviewed 1.71 list (a module the floor lacks 404s and the ui5loader drops the WHOLE component — a blank app naming nothing). A newer module belongs behind `sap.ui.require( )` at the point of use with an `undefined` branch, the way `Component.js` reaches for `sap/ui/core/Theming` (@since 1.118); `shared-file-gate.mjs` — fails when something this repository is the source of (see its `SHARED` list) differs from the copy in a sibling repository: today the `view-chain-layout` skill (whole file) and `.github/abaplint/app-rules.json`, the 187-rule abaplint set the three app repositories are judged by, compared as **parsed settings** against each one's `abaplint.jsonc` minus its own `object_naming`; and `docs/agents/building-apps.md` against the mirror of it in `app-template`'s `AGENTS.md`, compared as the SECTION from "## 1. The model in one paragraph" down, with the three sentences that name framework-only commands (`fmt:chains`, the autofix config, `check:formatter`) applied from the script's `GUIDE_DEVIATIONS` list first — a mirror that has to rewrite three sentences to stay true cannot also be byte-equal, so the rewrites are declared rather than tolerated, and a deviation whose upstream sentence was edited away fails too; `frontend/common/README.md` — the file the frontend build copies into every generated branch — against `abap2UI5/frontend`'s own `README.md` on `main`, whole file and byte-equal, no deviations: since `frontend_deploy` writes the finished trees into `result/` on that `main`, the `frontend_deploy` badge reports on exactly the page it fronts (the copies had drifted in five paragraphs, and both named the reserved resourceRoots `z2ui5cc`/`z2ui5ext` when `app/webapp/manifest.json` reserves `z2ui5_cci`/`z2ui5_ccc`); and `.github/shared/agents-metadata.md`, the metadata convention (what goes on the class, what goes in the `meta/` sidecar) that `samples`, `samples-controls` and `samples-stack` each carry inside their `AGENTS.md`, compared as the SECTION from "## Metadata: what goes on the class, and what goes beside it" down to the next `##`, with a consumer's own `###` subsection cut out first when the script's `METADATA_EXTENSIONS` declares it (samples-controls documents its `@keywords`/`@summary` generators there) — an addition is a decision, a reworded shared subsection is drift. Reads a local checkout or GitHub raw and says so when neither is reachable; `corpus-count-gate.mjs` — fails when a corpus size quoted in `llms.txt`, `docs/agents/building-apps.md` or the `build-an-app` skill disagrees with the owning repository's **generated** catalogue (`SAMPLES.md`'s header count, samples-controls' `STATUS.md` state block). Those numbers are the reason an agent goes and looks instead of writing from scratch, and they had drifted to ~280 while the corpus stood at 416. Declared claim by claim in the script's `CLAIMS` list, so citing a count is a decision; same checkout-then-raw-then-say-so resolution as `shared-file-gate` |
| `.github/abaplint/` | Target-specific abaplint configs: `abap_702.jsonc`, `abap_standard.jsonc`, `abap_cloud.jsonc`, `auto_abaplint_fix.jsonc`, `rename.jsonc` (namespace rename, used by both the `build_rename` workflow and the `abaplint` PR gate; placeholder `znamespace`) |
| `.github/shared/` | Files this repository is the SOURCE of for the whole ecosystem — `agents-metadata.md`, the metadata convention `samples`, `samples-controls` and `samples-stack` each carry inside their `AGENTS.md` (a shared file needs one owner and this is the repository the others already depend on; `shared-file-gate.mjs` is what notices when a copy stops matching), and `CONVENTIONS.md`, the rules every repository follows — repository roles, workflow and npm-script naming, toolchain versions, which documentation files exist, commit style and the ABAP naming segments. Unlike the rest of this folder, `CONVENTIONS.md` binds this repository too; it exists because the same job carried three names across sibling repositories and `npm run check` ran a different set of steps than CI in three of them |
| `tools/app2abap/` | `trans2abap.js` — converts `app/webapp/*` files into embedded ABAP string constants in `src/01/03/`, named `z2ui5_cl_ui5f_*` and capped at 25 characters (`MAX_CLASS_NAME_LENGTH`) so the rename workflow's 10-character namespace still fits the 30-character ABAP limit. A file whose basename does not fit needs an entry in `CLASS_NAME_STEMS`; generation fails otherwise rather than truncating |
| `.github/actions/` | `setup` — composite action every job starts from: the Node version, the pinned `actions/setup-node` sha and the `npm ci` / `npm --prefix app ci` / `npm run deps` installs, in one place instead of copied into every workflow (inputs `npm-ci`, `app-npm-ci`, `deps`, `cache`; `deps` implies `npm-ci`). Checkout stays with the caller — a local action needs the repository on disk first. `report-scheduled-failure` — opens/updates an issue when a scheduled workflow fails (used by `auto_abaplint_fix.yaml`, `vendor-mirror.yaml`, `check_v2_sdk.yaml` and `frontend_deploy.yaml`) |
| `.github/cleaner-profile.cfj` | ABAP Cleaner profile (SAP ABAP Cleaner tool configuration for automated code cleanup) |

### Root Files

| File | Purpose |
|---|---|
| `README.md` | Project intro, key features, quick start, references |
| `AGENTS.md` | This file — the agent briefing for working on the framework |
| `llms.txt` | Index of the agent entry points (framework work vs. app building) |
| `CONTRIBUTING.md` | Contribution workflow and setup instructions |
| `CODE_OF_CONDUCT.md` | Community code of conduct |
| `SECURITY.md` | Security reporting policy |
| `LICENSE` | MIT license |
| `changelog.txt` | Project changelog (lowercase by convention) |
| `abaplint.jsonc` | Active linter config (swapped by `auto_downport` to target 7.02) |
| `.abapgit.xml` | abapGit repo config — `STARTING_FOLDER=/src/`, `FOLDER_LOGIC=PREFIX`, `VERSION_CONSTANT=Z2UI5_IF_APP=>VERSION` |
| `.gitignore` | Excludes `downport/`, `node_modules/`, `output/`, `node/output/`, env/IDE files |
| `package.json` | Node tooling entry point (scripts + devDependencies) |

### CI/CD Workflows (`.github/workflows/`)

Grouped by purpose. Several groups below name the same workflow: the static
gates are one job (`check_gates.yaml`), one step per rule, because each of
them is a Node script that finishes in well under a second and nine separate
workflows spent about two minutes of CI on runner starts to run one second of
work. The steps are `if: ${{ !cancelled() }}`, so a pull request that trips
three of them reports all three at once instead of one per push. The groups
stay separate here because they are separate rules — the table describes what
is enforced, not how many runners enforce it. Every job takes its toolchain
from the composite action `.github/actions/setup` (Node version, pinned action
sha, the `npm ci` / `app` / `deps` installs).

| Group | Workflows | Purpose |
|---|---|---|
| **Frozen-path guard** | `check_gates.yaml` | Fails any PR that edits a file under `src/99/` in place, or deletes one whose object ships nowhere else under `src/` — the package is history only (see "Layered Design") |
| **API-contract guard** | `check_gates.yaml` | Fails any PR that removes or changes a public symbol of `src/02/` (rule 5); additions must be recorded in `.github/api-snapshot.json` via `node .github/scripts/api-snapshot.mjs --write` |
| **Compatibility checks** | `ABAP_702.yaml`, `abaplint.yaml` | Lint against each ABAP target environment. `abaplint.yaml` is the pull-request run (standard, cloud, test-class visibility, namespace rename); `ABAP_702.yaml` lints the downported 702 branch, which is why it stays separate — different ref, different trigger |
| **Frontend checks** | `UI5_2X.yaml` | UI5 linter via `.github/scripts/ui5lint-gate.mjs`, zero-error policy (accepted findings are suppressed at the source) |
| **Conventions** | `check_gates.yaml` | Every object name outside `src/02` (public contract) and `src/99` (frozen) carries the `ui5` segment — `z2ui5_cl_ui5_*` for the engine, `z2ui5_cl_ui5f_*` for the generated frontend. abaplint only checks the `z2ui5` prefix, so this is the gate that keeps a new segment from drifting in |
| **Dynamic names** | `check_gates.yaml` | Every `Z2UI5_*` object named by a string literal exists in `src/`. Nothing else resolves those names — the lookups behind them read SEOCLASS/XCO, which the transpiler does not have, so a literal naming nothing returns an empty result and the caller reads it as "not implemented" (how #2564 silently disabled every user exit) |
| **UI5 1.71 icons** | `check_gates.yaml` | Every `sap-icon://` name shipped under `src/` or `app/webapp/` exists in the 1.71 icon font. Nothing else checks an icon name: UI5 renders no icon for one it does not know and says nothing, so a post-1.71 glyph is invisible on the oldest supported release and green everywhere in CI (rule 21) |
| **Tests** | `test.yaml` | Unit tests, Node transpile tests, JS unit specs + Playwright browser tests, over one shared `transpile` job — all three used to run `downport` + `auto_transpile` themselves, which was the same work three times. The four Playwright projects are a matrix (`browser (chromium)` …); `test_browser` is the aggregate that stays requirable. The namespace-rename test lives in `abaplint.yaml`, which already had the toolchain it needs |
| **Assertions** | `check_gates.yaml` | Every `FOR TESTING` method asserts something. A test that only calls the code proves it does not dump, and nothing in a green report distinguishes it from one that proves a behaviour — `z2ui5_cl_ui5_app_start`'s `test_first` was `factory( )` into a `##NEEDED` variable for as long as the class existed. The check is deliberately shallow (does the body assert, raise, or delegate to a helper of its own test class); judging an assertion's quality is a review's job |
| **Automation** | `auto_downport.yaml`, `auto_abaplint_fix.yaml`, `autofix.yaml` | `auto_downport.yaml` rebuilds the `702` branch on every push to `main`; `auto_abaplint_fix.yaml` is the weekly `abaplint --fix` pull request. `autofix.yaml` is the on-demand one: a `/fix` comment on a pull request (or the `autofix` label) runs every generator the gates check — `npm run app2abap`, `auto_abaplint`, `fmt:chains`, `backlog`, `frontend:build` — and commits the result back to the branch, so a PR that trips four gates is one command from green instead of four local toolchains. `/fix chains backlog` limits it to a subset; `abaplint` is a scope of its own because reaching that same `abaplint --fix` through `app2abap` costs the Fiori `npm ci` and a full `src/01/03` regeneration first (asking for both folds into one run). It replaced a workflow that ran the same regeneration on *every* push to *every* pull request, whose bot commit kept landing while the author was still working. Fork pull requests are refused with the local command line rather than half-served: the `GITHUB_TOKEN` cannot push to a fork's branch. `auto_downport` and `api-snapshot --write` are deliberately not in the set — the first rewrites the branch under review, the second would turn the API gate into a formality |
| **Generation** | `create_app2abap.yaml`, `check_app2abap.yaml` | Regenerate `src/01/03/` from `app/webapp/` (`create_app2abap.yaml`); PR drift gate that fails when `app/webapp/` and `src/01/03/` are out of sync (`check_app2abap.yaml`) |
| **Renamed variants** | `build_rename.yaml` | On demand (`workflow_dispatch`): rename all artifacts to a chosen namespace (max. 10 characters) via `abaplint --rename` with `.github/abaplint/rename.jsonc` and push the renamed sources to the branch `rename_<name>` (re-running updates the branch; no push without content changes) |
| **Mirroring** | `vendor-mirror.yaml` | Sync `src/00/01/` (AJSON) and `src/00/02/` (S-RTTI) from their upstream mirror repos and open a PR with the diff — one monthly workflow, one matrix leg per mirror, so a third mirror is a line rather than a file |
| **Release** | `release.yaml` | One tag push cuts both releases: `X.Y.Z` from `main` and `X.Y.Z-702` from the downported branch. It re-checks the tag against `package.json`, `z2ui5_if_app=>version` and `changelog.txt`, runs the full `npm run verify` on the tagged commit, and uses the changelog section as the release notes so the two cannot disagree. Releases were cut by hand before, and the cost showed downstream rather than here: the newest tag predates the view builder every sample repository teaches, so `app-template` cannot pin the framework to a tag at all. `RELEASING.md` is the human half |
| **Downstream sync** | `trigger_local.yaml` | On every push to `main` it refreshes the `input/` copy in [abap2UI5-local](https://github.com/abap2UI5/abap2UI5-local) and pushes it to its `main` via deploy key (secret `ACTION_KEY_LOCAL`), which rebuilds its artifact branches |
| **Frontend delivery** | `frontend_check.yaml`, `frontend_deploy.yaml`, `check_v2_sdk.yaml` | `frontend_check.yaml` is the pre-merge gate the two-repository split made impossible: on every pull request touching `app/`, `frontend/`, `tools/` or `build/` it rebuilds the four committed delivery trees and fails on any difference (`npm run check:frontend`), builds a renamed variant on top, lints the generated ABAP and checks the BSP page invariants (`tools/check-pages.mjs`). `frontend_deploy.yaml` publishes into [frontend](https://github.com/abap2UI5/frontend) via deploy key (`ACTION_KEY_FRONTEND`) — the four committed trees as they stand, stamped and written as `result/<branch>` folders into ONE commit on that repository's `main`, on every push to `main` here that changes `build/`, plus a monthly safety-net cron; frontend's own `deliver` workflow then fans each folder out into its branch as one commit parented on that `main` commit, so every published branch is always exactly one commit ahead of `main` over there and `main`'s history tracks every delivered change. A renamed `standard_<name>` (no committed tree, built on the spot) is pushed onto its branch directly on dispatch, parented on that `main` too. The deploy stamps the provenance (`tools/branch-stamp.mjs`) and ships; it does not build what it ships. A run whose content matches what `result/` already carries pushes nothing — the candidate is stamped with the commit the published `VERSION` names, so a provenance-only difference is not a commit — and the commit that is written carries the subject of the `main` commit behind it. `check_v2_sdk.yaml` is the monthly guard on the CDN version the v2 branches bootstrap from (`tools/app2app_v2/patch-v2.mjs`) |

Both downstream repositories are **generated, never edited**: the deploy writes over their content, so a change made there survives only until the next push to this `main` and then disappears without a trace. `app/webapp/` is edited here and nowhere else. [frontend](https://github.com/abap2UI5/frontend) enforces this with its `guard` workflow, which fails every manual pull request by default and only lets through changes to the docs it genuinely owns after a maintainer applies the `maintenance` label. Its `main` carries those docs plus the machine-written `result/<branch>` trees this repository delivers, and every published branch is fanned out from them by its `deliver` workflow — always exactly one commit ahead of `main` there, never edited in place.

## Language & Code Rules

**Primary language:** ABAP (v750 syntax target, downported to v702 via CI)

### Coding Style

This project follows the [SAP Clean ABAP styleguide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md) with the following deliberate exceptions:

| Clean ABAP Recommendation | This Project | Reason |
|---|---|---|
| No Hungarian prefixes | Prefixes used throughout (`mv_`, `mo_`, `ms_`, `lo_`, `lv_`, `ls_`, `li_`, `lx_`) | Established project convention, enforced consistently |
| No public instance attributes | Public `DATA` used extensively | Framework architecture requires direct state access |
| Prefer inline declarations (`DATA(var)`) | Used selectively, not enforced | `prefer_inline: false` — clarity over brevity |
| abapdoc comments | Disabled (`abapdoc: false`) | Self-documenting code preferred |

**Project-specific patterns to follow:**

- **Class definition:** Always add `FINAL` unless inheritance is explicitly needed
  ```abap
  CLASS z2ui5_cl_my_class DEFINITION PUBLIC FINAL CREATE PUBLIC.
  ```
- **Class sections:** Always include all three section blocks (`PUBLIC SECTION.`, `PROTECTED SECTION.`, `PRIVATE SECTION.`) in every class definition, even when a block is empty. Do not omit empty `PROTECTED SECTION.` or `PRIVATE SECTION.` blocks.
  ```abap
  CLASS z2ui5_cl_my_class DEFINITION PUBLIC FINAL CREATE PUBLIC.
    PUBLIC SECTION.
      METHODS do_something.
    PROTECTED SECTION.
    PRIVATE SECTION.
  ENDCLASS.
  ```
- **Exception handling:** Use `cx_root` as catch-all; re-raise as `z2ui5_cx_ui5_util_error`; use `##NO_HANDLER` when intentionally ignoring
  ```abap
  CATCH cx_root INTO DATA(x).
    RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error EXPORTING val = x.

  CATCH cx_root ##NO_HANDLER.
  ```
  The exception handed over as `val` is chained as `previous` automatically, so the whole cause chain survives up to the single top-level catch, which renders it into the 500 body via `z2ui5_cx_ui5_util_error=>get_text_full` (chain entries with class, source position, kernel id and exception attributes). **Never inline a cause into a message** (`val = |MY_ERROR: { x->get_text( ) }|`) — that flattens it to one line and drops everything below; pass the message as `val` and the cause as `previous`. Reasoning at `z2ui5_cx_ui5_util_error`.
- **API parameter types:** Use `TYPE clike` for string/char input parameters in public API methods (allows both string and char literals without conversion)
- **Utility access:** every system- and environment-specific call goes through `z2ui5_cl_ui5_util_context` — never directly to `cl_abap_*` or a function module. Full rules in "Utilities — the context class is the only door"
  ```abap
  z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
  ```
- **Prefer simple, transpile- and downport-friendly ABAP over clever constructs.** Every framework ABAP file is both **downported to 7.02** (`npm run auto_downport`) and **transpiled to JS** (`npm run auto_transpile`, for the Node unit and browser tests), so the plainest expression that does the job is the safest one — readability and pipeline-robustness win over brevity, and a little duplication is preferable to a hard-to-follow abstraction. In particular, avoid ref/deref gymnastics such as a helper that hands back `REF TO data` pointing into the caller's own structure (`REF #( <field-symbol> )` returned and dereferenced with `<ref>->*`): it compiles on every target but is hard to read and to reason about through the downport/transpile pipeline — prefer two straightforward `SPLIT` / `LOOP AT` / `ASSIGN COMPONENT` loops even if they overlap slightly. Rule of thumb: if `abaplint` and the transpiler pass but a reviewer would call the construct "clever", pick the plainer form.

### Naming (enforced by abaplint)

- Classes: `Z2UI5_CL_*` or `Z2UI5_CX_*`
- Interfaces: `Z2UI5_IF_*`
- Allowed object types: `CLAS`, `DEVC`, `INTF`, `TABL` only

### Style Rules

- Max 50 statements per method, max cyclomatic complexity 10, max nesting depth 5
- No aliases, no STATICS, no BREAK-POINT, no DEFINE macros
- `NEW #()` instead of `CREATE OBJECT`; `xsdbool()` for booleans (NEVER use `boolc()` — the downport pipeline converts `xsdbool` to `boolc` automatically); `line_exists()` instead of READ TABLE
- Backtick string literals (`` ` ``) preferred over single quotes
- `IS NOT` over `NOT ... IS`; `RETURNING` over `EXPORTING` for single outputs
- No `EXPORT TO MEMORY`/`DATABASE`; no test seams; `lines()` instead of `DESCRIBE LINES`
- No DB operations in loops; SQL uses `@` host variable escaping
- No Yoda conditions
- `forbidden_void_type` blocks SAP standard types — use `abap_bool`, `i`, `string` etc.

### Extended-check (SLIN/ATC) pitfalls — not caught by abaplint

The sources are also run through the extended program check in real systems,
which flags things `npm run check` cannot see. The four traps a script can
decide are gated by `npm run check:atc` — `LOOP AT ... WHERE` over a standard
table (a sequential read, wants `"#EC CI_SORTSEQ` on the statement), an empty
`CATCH` block (wants `##NO_HANDLER`), POSIX regex (below) and a misplaced
ABAP Doc block (below). The rest need a reader. Known traps — avoid them up
front, a green abaplint does not prove their absence:

- **`SELECT` without a `WHERE` clause** wants `"#EC CI_NOWHERE` (bit us in
  `z2ui5_cl_ui5_srv_draft=>count_entries`).
- **`CREATE OBJECT ... TYPE (name)` into a generic reference followed by a
  `CAST`** is flagged as insecure object creation. Declare the typed reference
  and create into it directly:
  ```abap
  DATA li_app TYPE REF TO z2ui5_if_app.
  CREATE OBJECT li_app TYPE (lv_classname).
  ```
- **POSIX regex is deprecated.** `FIND/REPLACE ... REGEX` uses the POSIX
  standard; the PCRE replacement (`FIND PCRE`) only exists on >= 7.55 and this
  repo targets v750/7.02. Prefer plain string logic over regex where feasible;
  when a regex is genuinely needed, add the `##REGEX_POSIX` pragma to the
  statement (the established convention — the vendored AJSON code does the same).
- **No redundant conversions.** Do not wrap a value in `CONV string( ... )`
  (or `CONV #( ... )`) when the source already has the target type — assign it
  directly (bit us in `z2ui5_cl_ui5_action=>factory_first_start`, where
  `s_control-app_start` is already a `string`).
- **ABAP Doc (`"!`) position** — gated by `npm run check:atc` since it
  recurred a third time (five findings on samples-stack's overview app from a
  user's system, 2026-08-17): a doc comment must sit directly before the one
  declaration it documents. In a chained statement (`CONSTANTS: BEGIN OF ...`)
  that means *inside* the chain, directly before the element — a `"!` block
  before the chain keyword is "in the wrong position" (bit us on
  `z2ui5_if_client=>cs_nav_mode`).
- **Never `"!` inside a parameter list** (same gate). A single parameter of a
  `METHODS` statement is not a declaration of its own, so a `"!` block in
  front of it (anywhere between `IMPORTING` and the final `.`) is "in the
  wrong position". Document parameters in the method's own doc block, before
  the `METHODS` keyword, with `"! @parameter <name> | <text>` (see
  `z2ui5_cl_xml_view` for the house style; bit us on
  `z2ui5_if_client~_bind( omit_initial )`). A plain `"` comment inside the
  list stays legal — that is why the `"obsolete …` note on `path` has no `!`.
- **ABAP Doc is parsed as HTML:** a literal `<`/`>`/`&` must be escaped as
  `&lt;`/`&gt;`/`&amp;` — a placeholder like `#/app/<CLASS>` is otherwise read
  as an unsupported, unclosed HTML tag; write `#/app/&lt;CLASS&gt;`.

## Build & Validation

Install dependencies: `npm install` (frontend gates additionally need
`npm --prefix app ci` — `verify:full` runs that itself)

### Validation sequence

Three commands, all **non-destructive** — they never modify `src/` or
`abaplint.jsonc`. (One nuance: `verify`'s final app2abap drift gate re-runs
the `src/01/03/` generation in place — on an in-sync tree the output is
byte-identical, and a difference is exactly the drift the gate exists to
fail on.)

```bash
npm run check        # Fast inner loop: abaplint only (seconds) — run this while iterating
npm run gates        # The 17 sub-second static gates in one process (~4s). Reports
                     # EVERY failure, not just the first, and names the npm script
                     # that reruns each one - the local half of what
                     # check_gates.yaml's per-step `!cancelled()` does in CI
npm run verify       # Gate before every PR: abaplint -> npm run gates ->
                     # chain layout -> standard/cloud abaplint targets ->
                     # downport -> transpile -> unit -> JS unit specs ->
                     # app2abap drift gate (matches the PR gates in CI)
npm run verify:full  # verify + the frontend gates (ui5lint zero-error gate, eslint);
                     # installs app/node_modules itself. Run when app/webapp/ changed
```

`npm run verify` downports into `node/downport/` and runs the transpiled unit
tests from there, so the working tree stays exactly as you left it. Use
`npm run check` for the tight edit/validate loop and `npm run verify` before
opening a PR. Do **not** use `npm run auto_downport` for validation — see rule 9.
The app2abap drift gate needs the frontend toolchain and installs
`app/node_modules` itself when it is missing (only then — no reinstall on
every run).

**What `verify` still does not cover** (CI-only): the browser e2e tests
(`test.yaml`, the `browser` matrix — needs browsers + the UI5 CDN), the express
smoke test (`test.yaml`, `test_node`), and the namespace-rename test
(`abaplint.yaml`).

**Pinned git dependencies:** abaplint and the transpiler clone three upstream
repos (steampunk API intersection, open-abap-core, express-icf-shim). These
are pinned to fixed SHAs via `node node/setup/fetch-deps.mjs` (auto-run by
`check`/`downport`; materializes `node/deps/`, gitignored) so a build cannot
turn red because an upstream moved. Bump pins deliberately: `--print-latest`,
edit the SHAs in `fetch-deps.mjs`, `npm run verify`. Without network the tools
fall back to a floating HEAD clone — treat unexplained lint/transpile failures
in untouched code as a possible upstream move only in that fallback case.

### Other commands

| Command | Purpose |
|---|---|
| `npm run deps` | Fetch the three pinned git dependencies into `node/deps/` (auto-run by `check`/`downport`; `-- --print-latest` shows upstream HEADs for a pin bump) |
| `npm run check_visibility` | Fail when a local test class reads a PRIVATE/PROTECTED member of the class under test without `LOCAL FRIENDS` (part of `verify`, gated in `abaplint.yaml`; abaplint and the transpiler cannot see this) |
| `npm run check:abapgit` | The abapGit round-trip gate — byte format of every file under `src/` (BOM, LF, terminating newline, tabs, file-name case), sidecar/package completeness, `<CLSNAME>`/`<LANGU>`/`<WITH_UNIT_TESTS>` against the source, and `class_constructor` in the PUBLIC section. Covers `src/00` and `src/99`, which abaplint does not scan (part of `verify`, gated in `check_gates.yaml`; background in `.claude/skills/abap-check/SKILL.md`) |
| `npm run check:atc` | The extended-check (SLIN/ATC) gate — `LOOP AT … WHERE` without `"#EC CI_SORTSEQ`, an empty `CATCH` without `##NO_HANDLER`, `FIND`/`REPLACE … REGEX` without `##REGEX_POSIX`, and an ABAP Doc block that documents nothing (before a chain keyword, inside a parameter list, before a section end). Scoped to this repository's own ABAP (`src/00/01`, `src/00/02` are upstream mirrors, `src/99` is frozen). abaplint models none of these (part of `verify`, gated in `check_gates.yaml`; background in `.claude/skills/abap-check/SKILL.md`) |
| `npm run check:standard` / `check:cloud` | abaplint against the standard-ABAP / ABAP-Cloud target configs (part of `verify`) |
| `npm run check:js` | JS unit specs for the real `app/webapp` modules, no browser needed (part of `verify`) |
| `npm run check:frozen` | Fail when the branch touches the frozen `src/99/` (part of `verify`) |
| `npm run check:icons` | Fail when a `sap-icon://` name under `src/` or `app/webapp/` is not in the UI5 1.71 icon font (`.github/scripts/ui5-icon-gate.mjs`; part of `verify`, gated in `check_gates.yaml`; see rule 21) |
| `npm run check:ui5` | The ui5lint zero-error gate (`.github/scripts/ui5lint-gate.mjs`; part of `verify:full`, needs `app/node_modules`) |
| `npm run check:api` | The `src/02` public-API contract gate — compares against `.github/api-snapshot.json` (see rule 5; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:guide` | Fail when `docs/agents/building-apps.md` names a client method or `cs_*` constant the API does not have (part of `verify`) |
| `npm run check:asserts` | Fail when a `FOR TESTING` method asserts nothing — it proves only that the code does not dump, while the report counts it as a passing test (`.github/scripts/assertion-gate.mjs`; part of `verify`, gated in `check_gates.yaml`). Same scope as `check:atc`: `src/00/01`, `src/00/02` are upstream mirrors and `src/99` is frozen |
| `npm run check:release` | The release-readiness gate — the tag, `package.json`, `z2ui5_if_app=>version` and `changelog.txt` all name the same version (`.github/scripts/release-gate.mjs`; run by `release.yaml` before anything is published, and by hand before tagging). Not part of `verify`: a normal commit is not a release |
| `npm run blockers` | What still stands between this repository and `docs/removal-plan.md`, measured over sibling checkouts you point it at (`npm run blockers -- ../samples ../samples-controls ...`). Not a gate and not part of `verify` — the siblings are not checked out here. It exists because every blocker in that plan is a caller count in another repository, and a hand-measured count silently rots |
| `npm run coverage` | What `npm run unit` covers, **per ABAP file** — the transpiler's source maps point back at the `.clas.abap`, so a JS coverage tool measures ABAP lines with ABAP line numbers. Needs the transpiled tree (`npm run downport && npm run auto_transpile`). A report, not a gate, and not part of `verify` — see "What the suite covers" |
| `npm run check:abap2ui5` | The [abap2UI5-linter](https://github.com/abap2UI5/linter) over this repository's OWN app classes — the six under `src/01/04`/`src/02` plus the test-server apps in `node/srv`. They are what an app developer copies from, so the corpus shipped to be imitated is checked with the tool shipped for imitators. Its reason for being here is `chain-house-layout`, the builder-chain layout rule (one call per line, four spaces per level, the closing call in the column of the element it closes) — nothing else formats a chain, abaplint's `indentation` does not reach into one. `npm run fmt:chains` applies it. Config and the two rule decisions: `abap2ui5lint.jsonc` (part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:formatter` | The curated-formatter scope gate — the exports of `app/webapp/model/formatter.js` must match the gate's justified manifest and the module must hardcode no ValueState/icon URI (see rule 19; part of `verify`, gated in `check_gates.yaml`) |
| `npm run check:app2abap` | Regenerate `src/01/03/` from `app/webapp/` and fail on drift (mirrors `check_app2abap.yaml`; regenerates in place; installs `app/node_modules` when missing; part of `verify`) |
| `npm run downport` | Downport `src/` into `node/downport/` for 7.02 compatibility (non-destructive; the step `verify` runs) |
| `npm run auto_transpile` | Transpile the downported ABAP to JS into `node/output/` |
| `npm run unit` | Run the transpiled unit tests |
| `npx abaplint .github/abaplint/auto_abaplint_fix.jsonc --fix` | Auto-fix formatting |
| `npm run express` | Start dev server on port 3000 |
| `npm run app2abap` | **Canonical** full regeneration pipeline: Prettier (`app` format) → generate → abaplint normalize. Use this after editing `app/webapp/` so only truly-changed `src/01/03/` files differ |
| `npm run auto_app2abap` | Generate ABAP string constants from `app/webapp/` (raw, **un-normalized** — prefer `npm run app2abap` instead) |
| `npm run auto_abaplint` | Run the auto-fix config directly |
| `npm run rename` | Test namespace-rename transformation via abaplint |
| `npm run auto_downport` | **CI only** — destructive variant that rewrites `src/` in place to produce the `702` branch. Never run this to validate work (rule 9) |
| `npm run syfixes` | Replace `RAISE EXCEPTION TYPE cx_sy_itab_line_not_found` with `ASSERT 1 = 0` in `node/downport/` (compatibility step for 7.02 downport) |
| `npm run strip_trailing_ws` | Strip trailing whitespace from all `node/downport/**/*.abap` files (runs as part of `downport`) |
| `npm run downport_config` | Generate the gitignored `.github/abaplint/downport_run.jsonc` from `abap_702.jsonc` (same rules, retargeted at `node/downport/`) |
| `npm run abaplintpathfix` | Rewrite abaplint file globs in `abaplint.jsonc` after the `auto_downport` copy |

### Frontend Tooling (`app/`)

The `app/` folder has its own `package.json` (name `z2ui5`, `sapuxLayer: CUSTOMER_BASE`) with UI5-specific dev dependencies (`@ui5/cli`, `@ui5/linter`, `@sap/ux-ui5-tooling`, `eslint`, `prettier`). Key scripts:

| Script (run inside `app/`) | Purpose |
|---|---|
| `npm start` / `npm run start-local` | Run locally via Fiori tools with FLP sandbox |
| `npm run build` | UI5 production build |
| `npm run format` / `format:check` | Prettier |
| `npm run lint` | ESLint on `webapp/**/*.js` (eslint:recommended + `eqeqeq` "smart", `prefer-const`, `no-new-func`) |

Config files: `eslint.config.mjs`, `ui5lint.config.mjs`, `.prettierrc`, `.editorconfig`, `ui5.yaml`, `ui5-local.yaml`.

### Testing

- **Unit tests:** Embedded in source files as `.testclasses.abap`, run via abaplint transpiler in Node.js
- **Browser tests:** Playwright in `node/tests/e2e/` — Chromium, Firefox, WebKit against localhost:3000 (config: `node/playwright.config.js`; run in CI by the `browser` matrix in `test.yaml`, against the shared `transpile` job's output), plus the pinned `ui5-1.71` project (Chromium, smoke + roundtrip specs against pinned OpenUI5 1.71 via the bootstrap rewrite in `node/tests/e2e/fixtures.js` — the executable part of the 1.71 rules, see the enforcement-status note). Covers the POST/draft wire contract (`roundtrip.spec.js`), XSS regression tests for `Lib.sanitizeMessageDetails` in a real DOM (`lib-sanitizer.spec.js`), the fatal-error overlay (`error-view.spec.js` — accessibility semantics, focus management, Retry action), browser history navigation (`nav-back-forward.spec.js`) and the shell smoke test (`example.spec.js`). The transpiled Node backend renders backend-built view XML (the historical "check_on_init always false" transpiler limitation is gone since the interface-attribute access goes through a typed variable — see the comment in `z2ui5_cl_ui5_client`'s `z2ui5_if_client~check_on_init`); `roundtrip.spec.js` asserts the full cycle: initial view XML, an event roundtrip whose model delta is applied before `on_event`, and — browser-level — filling the hello-world input and asserting the rendered message box
- **JS unit specs:** the specs under `node/tests/` load the **real** `app/webapp` modules through a stubbed `sap.ui.define` (`loadModule.js`, with stubbable module dependencies) — never test a copied function. Covered: `core/Lib.js` (`buildDeltaFromPaths.spec.js`, `utilHelpers.spec.js`, `sizeLimit.spec.js`), `core/AppState.js` (`appState.spec.js`), `core/ViewSlots.js` (`viewSlots.spec.js`), `core/Router.js` (`router.spec.js`), `Component.js` unload wiring (`componentUnload.spec.js`), `cc/UITableExt.js` (`uiTableExt.spec.js`), `cc/Focus.js` (`focus.spec.js`), `cc/Dirty.js` (`dirty.spec.js`), `cc/MessageManager.js` (`messageManager.spec.js`), `cc/Websocket.js` (`websocket.spec.js`), `cc/Geolocation.js` (`geolocation.spec.js`), `cc/CameraSelector.js` (`cameraSelector.spec.js`), `cc/CameraPicture.js` (`cameraPicture.spec.js`), `cc/FileUploader.js` (`fileUploader.spec.js`), `cc/UploadSetExt.js` (`uploadSetExt.spec.js`), `cc/MultiInputExt.js` (`multiInputExt.spec.js`), `cc/SmartMultiInputExt.js` (`smartMultiInputExt.spec.js`), `cc/Scrolling.js` (`scrolling.spec.js`), `cc/LPTitle.js` (`lpTitle.spec.js`), `controller/App.controller.js` startup wiring (`appController.spec.js`), the message toast/box display hooks in `core/actions/ControlCall.js` (`messages.spec.js`), `devtools/DeveloperTools.js` (`developerTools.spec.js` — the dialog, composed with the REAL registry rather than a stub), `devtools/Tabs.js` (`devtoolsTabs.spec.js`), `devtools/Format.js` (`devtoolsFormat.spec.js`), `devtools/Report.js` (`devtoolsReport.spec.js`), `devtools/AbapSource.js` (`devtoolsAbapSource.spec.js`), `devtools/DevTools.js` (`devtoolsFacade.spec.js`), `devtools/Recorder.js` (`devtoolsRecorder.spec.js`), `devtools/Console.js` (`devtoolsConsole.spec.js`), `devtools/Inspect.js` (`devtoolsInspect.spec.js`), `devtools/Picker.js` (`devtoolsPicker.spec.js`), `devtools/LiveEdit.js` (`devtoolsLiveEdit.spec.js`), `core/ErrorView.js` (`errorView.spec.js`), `core/FrontendAction.js` incl. the composed `core/actions/` dispatch (`frontendAction.spec.js`), the action runners and the legacy `eF()`-string parsing in `core/actions/LegacyCustomJs.js` (`actionRunner.spec.js`), `controller/View1.controller.js` event handling, the after-render phase (model push by MODEL presence, per-response router sync) and the `core/actions/Slots.js` model fan-out (`view1Events.spec.js`), `core/Server.js` timeout handling (`serverTimeout.spec.js`), request sequencing (`serverRequestSeq.spec.js`) and the session-constant location cadence (`serverLocation.spec.js`), `core/Session.js` (`session.spec.js`), `core/ScrollFocus.js` focus-info capture (`focusInfo.spec.js`) and UI5-element resolution incl. the pre-1.106 fallback for scroll/focus capture (`scrollFocus.spec.js`), `model/formatter.js` (`formatter.spec.js`), `model/models.js` device-model wiring (`deviceModel.spec.js`), `core/Lib.js` event-argument normalization (`eventArgs.spec.js`), `cc/Storage.js` (`storage.spec.js`), the public `Util.js` date helpers (`util.spec.js`). Run without a browser: `npx playwright test -c node/playwright-unit.config.js`
- **Unit test metadata:** When a class has a `.testclasses.abap` file, its `.clas.xml` **must** contain `<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>`. When a class has no test file, this flag **must not** be present. Mismatches cause `local_testclass_consistency` lint errors.
- **Never skip a test with `IF sy-sysid = ` + backtick-`ABC`.** `ABC` is the system ID of the Node runtime, so such a guard makes the method a silent no-op in `npm run unit` while it still runs in a real system — CI stays green over assertions nobody executes. A test that genuinely cannot run under the transpiler belongs in the `skip` list of `node/setup/abap_transpile.json` **with a note naming the missing runtime capability**; the runner then prints it as skipped instead of pretending it passed.
- **A test class touching PRIVATE/PROTECTED members of the class under test needs `CLASS <global> DEFINITION LOCAL FRIENDS <ltcl>.`** Neither abaplint nor the transpiler enforces visibility, so the class pool compiles here and fails on activation in a real system. Gated by `npm run check_visibility` (`.github/scripts/testclass-visibility-gate.mjs`).
- **Test SICF handler:** `node/srv/zcl_sicf.clas.abap` is copied into `node/downport/` during `auto_transpile` so the Node runtime has a minimal HTTP entry point.
- **Every `FOR TESTING` method has to assert something** — `npm run check:asserts`. A method that only calls the code proves it does not dump, and a green report cannot tell that apart from a proved behaviour. `z2ui5_cl_ui5_app_start`'s `test_first` was `factory( )` into a `##NEEDED` variable for as long as the class existed; it is now four tests over the model the first request renders. Judging an assertion's *quality* stays a review's job — the gate only asks whether one is there.

#### What the suite covers

`npm run coverage` answers it per ABAP file: the transpiler emits source maps back to the `.clas.abap`, so a JavaScript coverage tool measures ABAP lines with ABAP line numbers. Scoped to the engine — `src/00/01` and `src/00/02` are upstream mirrors, `src/99` is frozen, and the `src/01/03` frontend carriers are one method returning a JS/XML literal each, 100% by construction and two thirds of the line count, which would flatter the number without saying anything about the engine.

**72.4% of the engine at the time of writing** (8,324 of 11,493 lines, 19 files). It is a report and not a gate on purpose: a threshold is a number a build starts optimising for, while the useful question is always *which* file is low and whether that matters. Three are, and only one of them is a gap:

| File | Lines | Why |
|---|---|---|
| `src/00/03/z2ui5_cl_ui5_util_context.clas.abap` | 35% of 3,174 | **The real gap** — 2,055 uncovered lines, more than the rest of the engine's misses together. It is the door to everything utility-shaped (§ "Utilities"), and most of what it offers is called by *apps*, not by the engine the suite drives |
| `src/02/z2ui5_cl_ui5_http_handler.clas.abap` | 28% of 598, **of the downported copy** | The ICF entry point. The transpiled suite comes in through `z2ui5_cl_ui5_handler` (94%) because there is no ICF request to make; the browser tests drive the rest through `zcl_sicf`. **The "`_http_get( )` is never executed" reading was an artefact, and it is now explained** — see below. Read the 28% as coverage of `node/downport/02/…`, never as a per-line statement about `src/02/…` |
| `src/01/04/z2ui5_cl_ui5_app_hi_world.clas.abap` | 29% of 56 | A demo app. Its view is exercised by the browser tests, not by the unit suite |

**Coverage line numbers are the DOWNPORT's, not `src/`'s.** This cost a while
to see, because the two files share a basename and the report prints the
`src/` path:

```
node/output/z2ui5_cl_ui5_http_handler.clas.mjs.map
  sources: [ "../downport/02/z2ui5_cl_ui5_http_handler.clas.abap" ]
```

`c8` instruments the transpiled JS and maps back through that file — and the
downporter rewrites the source on the way. One `DATA(ls_config) = …` becomes
seven `DATA` declarations plus an assignment, `COND` becomes an `IF`, a string
template becomes a concatenation. The measurable numbers:

| | `src/02/…` | `node/downport/02/…` |
|---|---:|---:|
| the file | 529 lines | **598** lines |
| `_http_get( )` starts at | 275 | **297** |
| `_http_get( )` is | 75 lines | **91** lines |

The 598 in the table above is the downported count — it never was `src/`'s.
So the covered ranges are real, and reading them against `src/` shifts them by
20-odd lines and growing: `_http_get( )` looked stone cold because the lines
that ran are the *downport's* 297-387, which land somewhere else entirely in
the source. The tests were fine all along.

What this does **not** settle is whether 170/598 is the right statement
coverage of the downported file; that needs a run, and the figure is only ever
about that file. `npm run coverage -- --detail <file>` prints the cold ranges
against `node/downport/<rest>` and says so, which is why it reads that copy
rather than the source.

## Key Files

**Must-know files (start here):**

| File | Why |
|---|---|
| `src/02/z2ui5_if_app.intf.abap` | Main app interface + version constant |
| `src/02/z2ui5_if_client.intf.abap` | All client methods (view, events, binding, navigation) |
| `src/02/z2ui5_cl_ui5_view_builder.clas.abap` | Generic XML view builder — the standard for all apps |
| `src/01/02/z2ui5_cl_ui5_handler.clas.abap` | Central request processor + main loop |
| `src/01/02/z2ui5_cl_ui5_client.clas.abap` | Implements z2ui5_if_client |
| `abaplint.jsonc` | Linter rules — source of truth for code standards |

**Reference files (consult as needed):**

| File | Why |
|---|---|
| `src/02/z2ui5_if_types.intf.abap` | Shared type definitions |
| `src/02/z2ui5_if_exit.intf.abap` | Customization exit points |
| `src/01/04/z2ui5_cl_ui5_user_exit.clas.abap` | Default exit + user-exit class support |
| `src/01/02/z2ui5_cl_ui5_action.clas.abap` | Event/action dispatcher |
| `src/01/02/z2ui5_cl_ui5_frontend.clas.abap` | Frontend action queues + response serialization (T_SYSTEM/T_CUSTOM, ROUTER/nav intent) |
| `src/01/02/z2ui5_cl_ui5_app_cont.clas.abap` | App lifecycle (create, load, serialize) |
| `src/01/02/z2ui5_cl_ui5_srv_bind.clas.abap` | Data binding engine |
| `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap` | JSON model management |
| `src/01/02/z2ui5_cl_ui5_srv_event.clas.abap` | Event registration and payload assembly |
| `src/01/01/z2ui5_cl_ui5_srv_draft.clas.abap` | Draft/session persistence |
| `src/00/03/z2ui5_cl_ui5_util_context.clas.abap` | The single door to system/platform functionality — see "Utilities" |
| `app/webapp/core/AppState.js` | Owner of the shared frontend state + `z2ui5.*` globals inventory |
| `app/webapp/core/ViewSlots.js` | View-slot access layer (get/set/byId/destroy per slot) |
| `app/webapp/core/Lib.js` | Shared frontend helpers |
| `app/webapp/core/Server.js` | Roundtrip lifecycle + request/response wire format docs |

## Commit Message Style

Concise, capitalized or lowercase first word. Conventional commits preferred:

```
feat: add new control method for FlexibleColumnLayout
fix: correct binding path for nested table structures
refactor: extract methods in core handler
test: add unit tests for utility class
```

### Pull request titles

- **The PR title becomes the squash-merge commit subject — make it describe
  the change.** Before merging, replace any auto-generated title (e.g. a
  branch name like `Claude/...-abc123`) with a short descriptive title that
  states what actually changed.
- **One topic per PR.** A structural change (moving classes between packages,
  renaming, restructuring) must not ride along in a PR titled for an
  unrelated fix — split it into its own PR so the history stays searchable.

## Important Rules for AI Assistants

These rules apply to AI assistants **modifying the framework** (this repo). For AI assistants **building apps**, read `docs/agents/building-apps.md` instead (rendered docs site: <https://abap2ui5.github.io/docs/>).

1. **Do not modify `src/00/01/` (AJSON) and `src/00/02/` (S-RTTI)** — mirrored from external projects, synced by automated workflows. `src/00/03/` is the opposite case: see "Utilities — the context class is the only door", which settles everything about utilities. **Ignore `src/99/` completely — the package is history only** (see "Layered Design"): never read it, change it, or add consumers on it. The view builder is `z2ui5_cl_ui5_view_builder` in `src/02/`; all builder work happens there.
2. **NEVER manually edit any ABAP file under `src/01/03/`.** These files are the embedded frontend (auto-generated from `app/webapp/` via the `app2abap` job — see `tools/app2abap/trans2abap.js` and the `create_app2abap.yaml` workflow). The **only** allowed way to update them is:
   - Change the source under `app/webapp/`
   - Run **`npm run app2abap`** locally (or trigger the `create_app2abap.yaml` workflow). This single command runs the full pipeline in the correct order — `npm --prefix app run format` (Prettier) → `npm run auto_app2abap` (generate) → `npm run auto_abaplint` (normalize) — exactly as CI does. Running `auto_app2abap` on its own produces **un-normalized** ABAP that differs from the committed form in *every* `src/01/03/` file (alignment/whitespace drift); the `auto_abaplint` step reverts that drift so only the files whose `app/webapp/` source actually changed remain modified.
   - Commit the regenerated `src/01/03/` files as the job produced them
   - The `sap.ui.require.preload` mapping is **also generated**: `trans2abap.js` emits `z2ui5_cl_ui5f_preload`, which `z2ui5_cl_ui5_http_handler` consumes. New files under `app/webapp/` are picked up automatically — never reintroduce a manually maintained preload list in the HTTP handler.
   Direct edits to `src/01/03/*.abap` are forbidden — no manual tweaks, no "small fixes", no formatting changes, nothing. The job may be invoked, but the files must never be touched by hand or by any other means.
   - **Prettier governs all of `app/webapp/`** — do not add `// prettier-ignore` directives. Since every custom control lives in its own file, a header reflow only touches that control's small generated constant; just let `npm run app2abap` format and regenerate.
   - **`build/` follows the same rule for the delivery branches.** The four trees under `build/` are generated from `app/webapp/`, `frontend/` and `tools/` by `npm run frontend:build`, and `frontend_deploy` pushes them into abap2UI5/frontend unchanged. Never edit anything below `build/` by hand — change the source, rebuild, and commit the rebuilt trees with the change (`npm run check:frontend` is the gate that fails otherwise). A change under `app/webapp/` therefore regenerates two things, `src/01/03/` and `build/`, and both belong in the same commit.
3. **Always run `npx abaplint`** before considering changes complete.
4. **Multi-environment compatibility** — code must work on NW 7.02, standard ABAP, and ABAP Cloud.
5. **The public API (`src/02/`) is a stable contract — never change or remove existing public attributes, methods, or constants.** This folder is consumed directly by thousands of downstream apps. Specifically:
   - Do not rename, remove, or change the signature of any method in `z2ui5_if_client`, `z2ui5_if_app`, `z2ui5_if_types`, or `z2ui5_if_exit`
   - Do not remove or rename public `DATA`, `CONSTANTS`, or `TYPES` in any `src/02/` class or interface
   - Do not change the type or default value of existing parameters in any public method
   - Additive changes are allowed (new methods, new optional parameters, new constants)
   - When in doubt, add rather than change
   - **No public signature may name a Layer 1 type.** A `z2ui5_if_ui5_types=>…` in a `src/02` signature makes an internal a de-facto public contract and blocks renaming it. The public class declares its own type instead — see `z2ui5_cl_ui5_http_handler=>ty_s_http_res`, which is structurally identical to the core's and meets it once, in `_http_post( )`, via `MOVE-CORRESPONDING`
   - **Machine-enforced** by `check_gates.yaml`: every public `src/02` signature is recorded in `.github/api-snapshot.json`; a removed/changed signature fails the PR (revert it — never edit the snapshot to silence the gate), and an addition fails until you record it with `node .github/scripts/api-snapshot.mjs --write` and commit the snapshot alongside
   - The recorded exceptions, all owner-approved, all from the move to the `ui5` namespace. Not a precedent for editing the snapshot on any other finding — 1 and 2 are `CHANGED`, 3 is the far heavier `REMOVED`:
     1. `_http_post`/`_http_get`/`_main` moved from `z2ui5_if_core_types=>ty_s_http_res` to the handler's own `ty_s_http_res` when the core layer became `z2ui5_if_ui5_types`. The underscore methods had no caller outside the class's own test class
     2. `_http_post`/`_main`/`get_request` and `z2ui5_cl_exit=>init_context` moved from `z2ui5_cl_a2ui5_http=>ty_s_http_req` to `z2ui5_if_types=>ty_s_http_req` when `src/00/03` became `z2ui5_cl_ui5_*`. Structure unchanged field for field, and `get_request`/`init_context` never assigned the whole record anyway (`CORRESPONDING #( )` and field-wise writes)
     3. `z2ui5_cl_app_startup` → `z2ui5_cl_ui5_app_start` and `z2ui5_cl_app_hello_world` → `z2ui5_cl_ui5_app_hi_world` retired 17 public symbols under their old names. Unlike 1 and 2 this is a **name** change, not a type reference: a bookmarked `?app_start=z2ui5_cl_app_hello_world`, a launchpad tile pointing at either class, or downstream code naming them stops working with no fallback. Shipped deliberately without compatibility shims — if that turns out to be too sharp, the repo's own precedent is the `class` / `class_old` pair in `z2ui5_cl_ui5_app_start=>render_samples( )`
     4. The `ui5`-rename restructuring itself, recorded in a change of its own so the blast radius is the whole diff rather than a footnote. The snapshot went from 100 keys to **70**, then to **80** once `z2ui5_if_types` came back into `src/02` (see "Layered Design"). Against the 100: 44 `REMOVED`, 14 unrecorded additions, 1 `CHANGED`. **38 of the 44 removals are relocations, not deletions** — the object still ships and downstream code still compiles, it simply left the folder the snapshot scans: `z2ui5_cl_http_handler` (10, now a deprecated shim forwarding to `z2ui5_cl_ui5_http_handler`) to `src/99`; `z2ui5_cl_ui5_app_start` (15) and `z2ui5_cl_ui5_app_hi_world` (2) to `src/01/04`; `z2ui5_if_types` (11) to `src/99` and back again, so of the 38 only 27 are still outside the snapshot. The other **6 are real**: `z2ui5_cl_exit` (4) became `src/01/04/z2ui5_cl_ui5_user_exit`, with no shim — apps extend the still-public `z2ui5_if_exit`, so only code naming the *class* breaks; and `z2ui5_if_app~check_initialized` / `~check_sticky` (2) were dropped as dead lifecycle mirrors (use `client->check_on_init( )` / `client->set_session_stateful( )`), which fails at compile time rather than at runtime. The 14 additions are `z2ui5_cl_ui5_http_handler` under its new name (11) plus `cs_device` / `ty_s_name_value` / `ty_t_name_value`, which `z2ui5_if_client` now owns. The 1 `CHANGED` is `z2ui5_if_client=>cs_event` and is a **false positive**: the constants were reordered, none added or removed — the gate compares a block byte for byte, and for a set of independently named constants the order carries no contract. Left as-is because the regeneration absorbs it; if a reorder ever fails a PR again, teach the gate to compare constants blocks as a set rather than editing the snapshot around it
6. **String literals use backticks** (`` ` ``), not single quotes.
7. **Frontend public contracts** — besides `src/02/`, the following frontend names are consumed by backend-generated views and existing apps and must not be renamed: the module IDs `z2ui5/cc/<Name>` of the custom controls (file location under `webapp/cc/` defines the ID), their properties and events (bound by existing app views), the controller methods `eB`/`eF`, the `z2ui5/Util` module and the `z2ui5.Util` global (public date helpers — **deprecated**, kept as a backward-compatible alias; new code and new helpers go through `z2ui5/model/formatter` / the `z2ui5.Formatter` global, which re-exports them). Additive changes only. View XML using the custom controls must declare `xmlns:z2ui5="z2ui5.cc"` (changed from `"z2ui5"` when the controls moved into `cc/`).
8. **Shared frontend helpers live in `app/webapp/core/Lib.js`** — shared or pure/testable logic goes there (pure helpers are unit-tested in Node via `node/tests/loadLibModule.js`); helpers with a single consumer stay in that module. **Shared frontend state is owned by `app/webapp/core/AppState.js`** — it documents the complete inventory of the `z2ui5.*` globals (public contract vs. internal fields) and provides the defaults for all internal fields. Framework modules must not reference the `z2ui5` global directly (ui5lint `no-project-globals`): internal fields are accessed via the `AppState.state` module export, public-contract fields via `AppState.getGlobal()/setGlobal()`. AppState itself is the only module that touches the global — it exposes the internal fields there via accessors so external consumers (apps via the js_loader popup, backend-generated HTML) keep working. Do not add new lazy `if (!z2ui5.x)` bootstrapping; add the field with its default to `AppState.createState()` instead.
9. **Validate with `npm run verify`, never with `npm run auto_downport`.** `auto_downport` rewrites `src/` in place *and* overwrites `abaplint.jsonc`; it exists for exactly one purpose — producing the `702` branch in `auto_downport.yaml` — and will destroy uncommitted work if you run it to check your changes. `npm run downport` performs the identical downport into `node/downport/` and leaves the working tree untouched; `npm run verify` wraps it together with lint, transpile and unit tests.
10. **Custom controls (`app/webapp/cc/`) delegate, they never decide** — a control exposes bindable **properties** and **events** and lets the backend drive the UI; it must not surface its own popups/toasts/dialogs (the `Geolocation` control fires an `error` event with code/message instead of showing a `MessageBox`). Lifecycle (UI5 2.x is strict): `init` and other lifecycle listeners **must not return a value** — never make them `async` (an async function returns a Promise → `_enforceNoReturnValue` FUTURE FATAL; kick the async work off in a separate helper, see `CameraSelector._loadCameras`). After every `await`, bail out when the control was destroyed (`Lib.isDestroyed`). Read the DOM defensively (guard a 0-size canvas, a missing `videoWidth`, an absent element) and **log, never throw** (`Lib.logError`). Prefer reusing a standard control or a binding over writing a new custom control at all.
11. **Never "modernize" `WITH DEFAULT KEY` to `WITH EMPTY KEY` on a table that is passed to a classic function module** (or to any typed formal parameter) — the key is part of the table type, and an incompatible one makes the `CALL FUNCTION` fail at runtime, silently when it sits inside a `TRY … CATCH` / `EXCEPTIONS` guard. Reasoning and the concrete breakage: see the comment above `lt_impl` in `z2ui5_cl_ui5_util_context=>rtti_get_classes_intf_std`.
12. **A module that exists only in newer UI5 must never be a hard `sap.ui.define([...])` dependency.** abap2UI5 supports OpenUI5 down to **1.71**; a dep the old release lacks 404s and the *whole component* fails to load (blank app). Resolve version-specific modules **lazily** with `sap.ui.require("…")` at the point of use and handle `undefined` gracefully (see `Component.js` Theming/Messaging probing, and the `THEMING` target in `core/actions/ControlCall.js`). Known post-1.71 modules: `sap/ui/core/Theming` and `sap/ui/core/Messaging` (both since 1.118). Before adding any `sap/ui/core/*` dependency, check its "available since" — if it is newer than 1.71, lazy-require it.
13. **The app runs under a CSP without `'unsafe-eval'`-free assumptions — keep it eval-capable and avoid eval-only UI5 features.** The default CSP (in `z2ui5_cl_ui5_user_exit`) keeps `'unsafe-eval'` because the OpenUI5 **1.71** ui5loader evals module source; removing it breaks the 1.71 bootstrap with a CSP `EvalError`. Also do **not** use UI5 **expression binding** (`{= … }`) in framework-controlled XML/fragments — it is compiled with `eval`/`new Function`, so it fails wherever a stricter CSP applies; drive such state from a plain model property instead (see the DeveloperTools `closeEnabled` boolean).
14. **`app/webapp/` source must be 7-bit ASCII.** Every frontend file is embedded verbatim into an ABAP class under `src/01/03/`, which abaplint checks with the `7bit_ascii` rule — a non-ASCII literal (`…`, `©`, `→`, a smart quote) breaks generation/lint. Use ASCII in source (`...` not `…`) and build any non-ASCII runtime string with `String.fromCharCode(...)` / entity decoding at run time, never as a literal.

15. **A generic aggregation-escape tag (`<ns:name>` — produced by `heading( ns )`, a literal `<footer>`, `_generic( name = … ns = … )`, …) must name an aggregation the parent actually has; otherwise UI5 resolves it as a *control class* and 404s** with `failed to load sap/<lib>/<name>.js` on any release lacking that control, killing the view. This is rule 12's failure mode for **controls/aggregations** rather than modules. Real 1.71 crashes fixed this way: `<footer>` on a `sap.m.Dialog` — the public `footer` aggregation only exists since **~1.110**, so use the **`buttons`** aggregation (since 1.21.1) for a Dialog footer (see `DeveloperTools.fragment.xml`); and (samples) `heading( `uxap` )` on a `sap.uxap.ObjectPageSection`, which has no `heading` aggregation. `heading( ns )` IS valid on a parent that has one (sap.f `DynamicPageTitle`); `sap.m.Page.footer` is fine. Before using an aggregation confirm the parent exposes it in the **oldest supported release (1.71)** — like modules, post-1.71 aggregations bite (Dialog `footer` ~1.110).
16. **`sap.m.MessageBox` always closes on Escape and gives no way to suppress it.** For a popup that must NOT be Escape-dismissable — the fatal-error overlay (`ErrorView.js`), which would otherwise let the user Escape back into a broken app — build a `sap.m.Dialog` with `escapeHandler: (oPromise) => oPromise.reject()` instead of a MessageBox (keep the raw-DOM overlay as the fallback for a broken core). Only the explicit actions (Details / Restart) may then close it.
17. **A dialog loaded from a fragment with a fixed `id` must be loaded once and reused across open/close — never destroyed on close and re-loaded on the next open.** On OpenUI5 1.71 the destroy races the dialog's close animation, so a fragment-scoped control id is still registered when the reload runs → `adding element with duplicate id 'z2ui5DeveloperTools--developerToolsEditor'`. Pattern (see `DeveloperTools.js`): `show()` reuses an existing `this.oDialog` and only re-seeds the model; `close()` just closes it (and reuses it next time); `exit()` is the sole place that destroys it.
18. **Do not declare a physical resource in `manifest.json` that the ABAP deployment does not actually serve.** `sap.ui5/resources.css` made UI5 load `css/style.css` as a real `<link>`, which 404s on the ABAP system — frontend files are served through the module preload (`z2ui5_cl_ui5f_preload`), not as ICF resources at their raw URLs. The placeholder `style.css` contained only a placeholder comment, so the entry was removed. If a real stylesheet is ever needed, serve it through the preload / HTTP handler, not a bare manifest `<link>`.
19. **The frontend is a thin, data-driven executor — grow it through the declarative whitelists, not through new bespoke logic.** The backend drives frontend behavior by *data* (an event name plus positional args), and the action dispatch (`FrontendAction.js`, handlers in `core/actions/` — the whitelists live in `core/actions/ControlCall.js`) turns that data into UI5 calls through three declarative whitelists: `CONTROL_METHODS` (imperative methods on a control resolved by id — `to`, `open`, `scrollToIndex`, `expandToLevel`, …), `GLOBAL_TARGETS` (whitelisted methods on a global object — `MessageToast`, `MessageBox`, `BusyIndicator`, `Theming`), and `BINDING_METHODS` (aggregation-binding ops — `filter`/`sort`, built from paths + whitelisted `FILTER_OPERATORS`, never from code). **When a new need is "call a UI5 control / global / binding method", add a whitelist entry** (method name + its arg *kinds*, cast via `castArg`) — do **not** add a new hand-written handler that re-implements the dispatch. Only add a new handler (in the matching `core/actions/` domain module, merged into the dispatch by `FrontendAction.js`) for a genuine *browser capability* that has no control-method equivalent (clipboard, history, download, storage, timer, focus/scroll/caret, audio, launchpad nav). Whichever you add, it stays a thin executor: resolve/cast args, guard the DOM, and `Lib.logError` on failure — **never** embed business decisions, thresholds, unit conversions, or app-specific branching — those belong in the backend model. This keeps the "delegate, never decide" contract (rule 10) at the action layer and keeps every payload data, not code — CSP-clean without `unsafe-eval` for the dispatch path.
    **The curated formatter module (`app/webapp/model/formatter.js`) is the same rule for values**, and the only place the framework ships JS an app's view calls on its data. It is a **marshalling layer, not a formatting toolbox**: a function may only live there when it (1) formats exactly the one value handed to it, (2) cannot be done in ABAP at all — a JS `Date` for an object-typed property, an icon-font glyph of the loaded theme, a browser locale/theme artefact — and (3) contains no domain vocabulary (no hardcoded ValueState, no icon URI, no business status). The criteria and the precedent (`weightState` and the stock/delivery status pack were shipped and **removed** again) are in the module header; criteria 2 and 3 are machine-enforced by `npm run check:formatter` / `check_gates.yaml`, criterion 1 is reviewer-enforced. Adding a function there is an architectural decision, not a convenience — if ABAP can produce the finished value, the app computes it and the view binds it.

20. **A green `npm run verify` does not prove the repository still round-trips through abapGit — `npm run check:abapgit` does.** abaplint parses ABAP and has no model of abapGit's file format, and its `global.files` never reaches `src/99` at all, so a `.clas.xml` with the UTF-8 BOM stripped, the terminating newline removed and CRLF line endings throughout produces **zero** findings while differing from the system's serialization on every single pull (`8e272492`, `54bce5b6`, `c7185c38` — three "fix abapgit diffs" commits, all repaired only after someone pulled). The transpiler ignores visibility, so a `class_constructor` outside the **PUBLIC SECTION** keeps `npm run unit` green and fails activation in a real system (why `z2ui5_cl_ui5_frontend` fills `ct_box_type` lazily, #2547). **Never hand-edit a `.clas.xml`/`.intf.xml` to tidy it** — it is a serialization, not a config file; fix the object in a system and commit what abapGit writes. The full checklist, including the parts no gate can decide (`<DESCRIPTIONS>` following the components), is the `abap-check` skill in `.claude/skills/` — the catalogue for every ABAP problem a green CI misses, not just the abapGit ones.

21. **An icon name must exist in the 1.71 icon font, and a control that only lays out inside a flex container must not sit in a `sap.m.Bar`.** Two silent 1.71 failures that look identical from the outside — the icon is simply not there, with nothing in abaplint, ui5lint or the browser console. (a) **Icon names:** an unknown `sap-icon://` name is not an error, `IconPool` finds nothing and the control renders without an icon. `sap-icon://information` — added to the font *after* 1.71 — left the developer tools' help button blank on the oldest supported release. Gated by `npm run check:icons` / `check_gates.yaml` against a snapshot of the 1.71 registry. Names resolve through `URI.parse( )`, which lower-cases the host part, so a camelCase name renders nothing in **every** release (`textFormatting` → the name is `text-formatting`). (b) **Toolbar-only controls in a bar:** `sap.m.ToolbarSpacer` and `sap.m.ToolbarSeparator` render a `<div>` and are laid out as intended only inside a `sap.m.Toolbar`. `sap.m.Bar` — what `Page.headerContent` (forwarded to `contentRight`) and `customHeader` end up as — became a flex container only after 1.71; before that a block-level child starts a **new line** and everything from there on is cut away by the container's `overflow:hidden` at the bar's 3rem. That swallowed two of the four header icons of the start page on 1.71 while newer releases showed all of them. Put only inline controls in a bar and group them with a margin class (reasoning at `z2ui5_cl_ui5_app_start=>render_header_toolbar`).

> **Enforcement status — know which rules a green CI actually proves.** Rules
> 1 (`src/99` part), 2, 3, 4, 5, 14, 20 and rule 21's icon half are backed by CI gates, and rule 19's
> curated-formatter half by `check_gates.yaml` (its criteria 2 and
> 3 — "one value only" still needs a reader). **The OpenUI5-1.71
> compatibility cluster — rules 12, 13, 15, 16, 17, 18 — now has a partial
> executable gate**: the `ui5-1.71` Playwright project (a `browser` matrix leg in `test.yaml`,
> pinned build in `node/playwright.config.js`, bootstrap rewrite in
> `node/tests/e2e/fixtures.js`) boots the shell and runs the smoke +
> roundtrip specs against pinned OpenUI5 1.71, so a hard 1.71 breakage on
> that path — a post-1.71 `sap.ui.define` dependency in a core module (rule
> 12), an eval-hostile bootstrap (rule 13), a bad aggregation in the shell
> views (rule 15) — fails the PR. It only exercises what those specs render:
> everything outside that path (popups, fragments, the other custom
> controls; rules 16, 17, 18 in particular) is **still reviewer-enforced**,
> and `manifest.json` (where `minUI5Version: 1.71` lives) is excluded from
> ui5lint. So keep checking "available since" of every module, aggregation
> and control against 1.71 on every frontend change the gate does not reach.
> **The whole cluster is written out — with the evidence, and with how to
> check a fact against 1.71 from the `@openui5/*` npm packages, without a
> system or a CDN — in the `ui5-check` skill in `.claude/skills/`.** Read it
> before touching a view; add the case there when you find a new one.


## Design Decisions & Known Non-Issues

The following items may look like gaps but are intentional design choices:

- **Draft table `Z2UI5_T_01` has no version column** — Drafts are session-scoped (deleted after a few hours). There is no long-lived state that needs schema migration. Versioning would add complexity with no benefit.
- **Draft cleanup (`z2ui5_cl_ui5_srv_draft=>cleanup`) is deliberately not throttled or debounced** — it runs a single `DELETE ... WHERE timestampl < ...` on each app cold-start (`factory_first_start`). A per-work-process throttle (a `CLASS-DATA` "last run" timestamp that skips a sweep if the previous one ran seconds ago) was considered and **rejected**: deployments are overwhelmingly **stateless ICF**, where such a static resets between requests and never takes effect — it would only help the rare long-lived / stateful work process, a too-narrow edge case not worth the state. A **secondary index on `TIMESTAMPL`** to make each sweep cheaper was also considered and **rejected**: the `DELETE` runs only **once per app cold-start**, never per roundtrip, so a rarely-executed scan does not justify the index-maintenance overhead paid on **every** draft write (`Z2UI5_T_01` is `MODIFY`-ed on every roundtrip). Do not add a secondary index on `TIMESTAMPL`, and do not (re-)introduce a cleanup throttle.
- **No `componentPreload` declaration in `app/webapp/manifest.json` / `index.html`** — both production delivery paths already bundle all modules: the ABAP-served page inlines every `app/webapp` file via the generated `z2ui5_cl_ui5f_preload` (`sap.ui.require.preload` in the GET response), and the standalone build (`npm run build`) emits a `Component-preload.js` through the standard `generateComponentPreload` task, which the async bootstrap loads by convention. Per-module requests only occur in dev flows (`fiori run`, `node/srv/express.mjs`), which is intentional.
- **No central app-start authorization hook — authorization is the app's responsibility, by design.** `app_start` is client-controlled (URL query / hash route) and lands in `CREATE OBJECT TYPE (app_start)` (`z2ui5_cl_ui5_action`), constrained only to classes implementing `z2ui5_if_app`. The framework deliberately performs **no** `AUTHORITY-CHECK` and exposes **no** `check_app_start_allowed` exit: like a SAP transaction or an ICF node, reachability is governed by the surrounding authorization concept (ICF node auth, `S_TCODE`/`S_SERVICE`/app-specific authorization objects), and any per-app access decision belongs **in the app implementation's `z2ui5_if_app~main`** — the app checks its own authorizations and, if denied, renders an error/leaves. This keeps authorization where the app author has the domain context, and matches how every other ABAP UI dispatches. A proposal to add a framework-level `check_app_start_allowed` exit or a central `AUTHORITY-CHECK` before instantiation is **rejected**: it would offer a false sense of central security (the meaningful check is always app-specific) while every app must still guard `main( )` anyway. Treat "any user who can reach the ICF node can instantiate any `z2ui5_if_app` class" as **by design** — the app, not the framework, owns the authority check. Nothing needs to be added here.
- **Changelog** — The project maintains a `changelog.txt` in the repository root. A `CHANGELOG.md` is not needed separately.
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
  samples-controls request `pr/frontend-action-named-api` as the reference for the
  future object; usage data there too (corpus 2026-08: 295 control_global
  wires / 137 control_by_id / 25 binding_call / 3 keyboard_shortcut).
- **The `z2ui5_cl_xml_view` builder (src/99) is large because each method wraps one UI5 control for the fluent API.** It is **not** being extended or refactored here: the builder from [samples-controls](https://github.com/abap2UI5/samples-controls) replaces it and becomes the new standard. Do not add wrapper methods, controls or parameters, do not split the class, and do not report its size as a finding. The 1:1-with-the-UI5-SDK rule (method, property and event names match the SDK exactly, no invented convenience shortcuts) carries over to the replacement.

### Scope Exclusions for Code Reviews, Security Audits & Improvement Work

When reviewing, auditing, or proposing improvements to this repository, treat the following as **out of scope** — do not report findings in them, refactor them, or otherwise invest in them:

- **The production code of `src/99/`.** It is **frozen legacy code** (see "Layered Design"): no in-repo consumers, kept solely so existing downstream installations keep compiling. Do **not** report, harden, refactor or extend it. For example, the unescaped single quote in the dynamic `WHERE` builders of `z2ui5_cl_util_ext` is a **non-issue** here, and the ~16K-line size of `z2ui5_cl_xml_view` is not a finding either. Only the `*.testclasses.abap` files under `src/99/` are maintained — they run in CI and may need adapting when core internals they assert on change.
- **The `_bind` / `_bind_edit` "mass assignment" question** — binding was **intentionally unified** (see "Data Binding" above): `_bind` and `_bind_edit` behave identically and every bound attribute is writable from the client `MODEL`. `_bind_edit` is a **compatibility-only alias of `_bind`** and is slated for **removal (~1 year out)**. A proposal to split them again — a separate "editable" flag so `_bind` becomes display-only while only `_bind_edit` writes back — is explicitly **rejected**: it would reintroduce exactly the distinction that was deliberately removed and break the many apps that rely on `_bind` round-tripping. Treat "an attribute exposed via `_bind` is writable from the client model" as **by design**, not a vulnerability.
- **A secondary index on `Z2UI5_T_01-TIMESTAMPL`** — see the draft-cleanup entry above: rejected as not worth the per-write index-maintenance cost.
- **The "no app-start authorization" question** — see the app-start entry under "Design Decisions" above. That any authenticated user reaching the ICF node can instantiate any `z2ui5_if_app` class is **by design**: authorization lives in the app's own `z2ui5_if_app~main` (like a transaction guarding itself), not in a framework `AUTHORITY-CHECK` or a `check_app_start_allowed` exit. Do not report the missing central hook as a vulnerability, and do not add one.
