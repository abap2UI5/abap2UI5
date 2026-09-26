# AGENTS.md — AI Assistant Guide for abap2UI5

> **Building an app WITH abap2UI5? Stop reading here.** Everything an app
> needs — template, lifecycle, view builder, client API — is the
> self-contained guide **`docs/agents/building-apps.md`** (also wired as the
> `build-an-app` Claude Code skill; `llms.txt` indexes both audiences). The
> rest of this file is for changing the framework itself.

> This file follows the cross-tool AGENTS.md convention and is the single
> agent instruction file of this repository. `CLAUDE.md` exists next to it and
> is a pointer at this file, nothing more — CONVENTIONS §6 asks for one in
> every repository that has an AGENTS.md, and `check:conventions` now enforces
> it. This paragraph used to claim there was no CLAUDE.md, which made a
> convention this repository OWNS false in the repository that declares it.

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
| [playground](https://github.com/abap2UI5/playground) | The sample catalogue site, <https://abap2ui5.github.io/playground/samples/> — every sample of the three corpora, searchable by control and by UI5 release, most of them one click from running in the browser; `README.md` sends readers there and its `apps.json` index is what an agent fetches. A canary: it builds against a commit SHA of this repository (CONVENTIONS §9) |
| [abap2UI5-local](https://github.com/abap2UI5/abap2UI5-local) | The single-class build of the framework. `trigger_local.yaml` pushes `src/` into its `input/` on every push to `main` (deploy key `ACTION_KEY_LOCAL`, the refresh script pinned by hash in `.github/pins/`), and its own workflows fold the sources into one class per target — `z2ui5_cl_abap2ui5_local`, the name a user's SLIN run reports findings against (`abap-check` skill, §3) |
| [custom-controls](https://github.com/abap2UI5-addons/custom-controls) | Community custom controls in their own BSP — the reserved resourceRoot `z2ui5_cci` in `app/webapp/manifest.json` is what makes it findable |
| [customer-frontend-extension](https://github.com/abap2UI5/customer-frontend-extension) | Template for a customer's **own** frontend artefacts (reuse library, icon font, CSS) in their own BSP — same mechanism under the reserved resourceRoot `z2ui5_ccc`. Both roots exist so nobody has to patch `index.html` / `manifest.json`, which are generated here and overwritten downstream |

> **Building apps?** See the routing note at the very top of this file — the guide is `docs/agents/building-apps.md`. The rendered docs site is <https://abap2ui5.github.io/docs/> — unreachable from many sandboxes, which is why the guide lives in-repo.

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

#### Launchpad Special Cases — settled at the code sites

Two things differ inside the SAP Fiori Launchpad, and both are explained where
they are handled, not here:

- **The POST body may arrive without the `{ "value": … }` envelope** the
  frontend always sends (`app/webapp/core/Server.js`) — an FLP shell or a
  Gateway proxy can strip it. `z2ui5_cl_ui5_handler=>request_parse_body`
  computes the root prefix once and reads every container below it; the
  comment there says why nothing is sliced, and `test_parse_body_with_wrapper`
  / `test_parse_body_no_wrapper` pin both shapes.
- **The shell owns the front of the URL hash; only the remainder is the app
  hash.** Exactly two places know the split and mirror each other:
  `app/webapp/core/Router.js` (`splitHash()`, the only module that writes the
  hash) and `z2ui5_cl_ui5_handler` (`hash_get_app_part` /
  `hash_get_shell_part`). Both headers carry the hash layout and the
  reasoning; `node/tests/router.spec.js` and `test_hash_app_part` /
  `test_route_launchpad` / `test_app_state_hash` cover it. **Do not
  re-implement the split anywhere else, and do not rebuild a URL from
  `location.href.split("#")[0]` plus an app hash** — write the app hash
  through `Router.navTo()` and let the shell own the rest.

### Layered Design

```
src/
├── 00/   Layer 0: Utilities (AJSON, S-RTTI, framework context/HTTP abstractions)
├── 01/   Layer 1: Core engine (handler, action, binding, model, events, draft service, embedded frontend)
├── 02/   Layer 2: Public API (z2ui5_if_app / _client / _exit, z2ui5_cl_ui5_http_handler, z2ui5_cl_ui5_view_builder)
└── 99/   FROZEN legacy code. Legacy XML view builder (z2ui5_cl_xml_view / _cc), the deprecated z2ui5_cl_http_handler shim, retired z2ui5_cl_util* classes (99/01) and popups (99/02). Ships so existing downstream installations keep compiling. Its test classes are the exception: they run in CI and guard the layer
```

- **Layer 0 (`src/00/`)** — Self-contained utility libraries. AJSON (`src/00/01/`) handles JSON; S-RTTI (`src/00/02/`) provides runtime type reflection — both are mirrored from external projects, DO NOT MODIFY. `src/00/03/` holds the context/HTTP abstractions (`z2ui5_cl_ui5_util_context`, `z2ui5_cl_ui5_util_http`, `z2ui5_cl_ui5_util_json_fl`, `z2ui5_cx_ui5_util_error`), all but `_json_fl` vendored from abap-util (see "Utilities"). The `noIssues` flag in `abaplint.jsonc` suppresses lint warnings for all of `src/00`.
- **Layer 1 (`src/01/`)** — Core engine. Session drafts (`src/01/01/`), request processing, event routing, data binding, model management, app lifecycle (`src/01/02/`). Embedded UI5 frontend resources as ABAP string constants (`src/01/03/` — auto-generated, never manually edit). Those carry the `z2ui5_cl_ui5f_*` prefix (UI5 **f**rontend); the bare `z2ui5_cl_ui5_*` segment covers everything else the framework owns — hand-written ABAP-side helpers (`z2ui5_cl_ui5_view_builder`), the engine (`z2ui5_cl_ui5_handler`), and the shipped apps (`z2ui5_cl_ui5_app_start`, `z2ui5_cl_ui5_app_hi_world`). No `z2ui5_cl_app_*` object exists any more; that segment used to mean both a generated frontend artefact and a real ABAP app, which is what made it worth retiring.
- **Layer 2 (`src/02/`)** — Public API. The stable contract for app developers. Five objects: `z2ui5_if_app`, `z2ui5_if_client`, `z2ui5_if_ui5_exit`, `z2ui5_cl_ui5_http_handler` (the HTTP entry point) and the view builder `z2ui5_cl_ui5_view_builder`. `z2ui5_if_exit`, the **superseded** name of the exit interface, is retired to `src/99` — it still ships and is still called (see "Exit Pattern"), it is simply no longer part of the guarded contract. Recorded symbol for symbol in `.github/api-snapshot.json` (rule 5). **A type lives on the object that uses it** — `ty_s_get` and `ty_s_event_control` on `z2ui5_if_client` because `get( )` and `_event( )` are their only public appearance, the three HTTP-config types on `z2ui5_if_exit` for the same reason. The shared `z2ui5_if_types` that used to hold all of them is retired to `src/99`, unchanged and still shipping, so an app that names it keeps compiling; nothing in `src/00`–`src/02` resolves into it any more, which is what lets `abaplint.jsonc` leave the frozen package out of the strict ruleset.
- **Package `src/99/` — frozen legacy code.** Its production code has **zero consumers** anywhere in this repository — no framework code, no app, no tooling references it (what remains are comments naming the old classes). It ships solely so **existing downstream installations** keep compiling on upgrade. Its **test classes are live**, though: they lint and run in the transpiled unit suite (`npm run unit`), guarding the layer against regressions — which is why they, unlike the production code, may change (they assert against core internals such as `t_action_front` and follow them when those move):
  - **Package top level** — the legacy XML view builder (`z2ui5_cl_xml_view`, `z2ui5_cl_xml_view_cc`), superseded by `z2ui5_cl_ui5_view_builder` in `src/02/`, and the deprecated `z2ui5_cl_http_handler` shim that forwards to `z2ui5_cl_ui5_http_handler`. All builder work happens in `z2ui5_cl_ui5_view_builder`.
  - **`z2ui5_if_exit`** — the superseded name of `z2ui5_if_ui5_exit`. The one object here that is still **called**: `z2ui5_cl_ui5_user_exit` looks it up alongside the current interface so that no exit written against the old name breaks (see "Exit Pattern"), and `abaplint.jsonc` lists this one file in the strict ruleset for that reason. Both go together when the transition ends.
  - **`z2ui5_if_types`** — the shared type interface the public API used to name. Every type it holds now lives on the object that uses it (see Layer 2); this copy ships unchanged so a downstream app that names `z2ui5_if_types=>…` keeps compiling.
  - `src/99/01/` — the retired utility classes (see "Utilities").
  - `src/99/02/` — the obsolete built-in popup/dialog apps (`z2ui5_cl_pop_*`), replaced by the [popups addon](https://github.com/abap2UI5-addons/popups).

  **For AI assistants this means: never change the production code under `src/99/` or add consumers on it.** It is out of scope for reviews and audits. The `check_gates` workflow enforces the freeze; the `*.testclasses.abap` files and the abapGit `.clas.xml` sidecars are exempt from it, because the tests keep running in CI and must follow the core internals they assert on. Moving an object **out** of the package is also allowed — abapGit installs the repository, not the folder, so an object that relocates and keeps shipping breaks no downstream install. The gate refuses a deletion only when the object name exists nowhere else under `src/` afterwards **and** the object shipped in the latest release tag — an object added since that release has never reached an installation, so dropping it breaks nothing. Anything edited in place is refused either way.

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

  **One deletion is recorded as such a decision: `z2ui5_cl_pop_js_loader`**
  (maintainer decision 2026-09-22). The popup existed to load app JavaScript
  onto the `z2ui5` global and call it back through `cs_event-z2ui5`; the
  global and the event were removed in the same change, so the class had
  nothing left to talk to, and it was deleted rather than kept compiling
  against a runtime that no longer answers it. It is a released object, so
  an installation naming it stops compiling — the entry in `changelog.txt`
  and `docs/removal-plan.md` §0 says so. The deletion went through the
  popup pathspec above while it was open; it widened nothing else.

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
- **Symbols marked `FROZEN-ONLY`** in the class have no caller anywhere in `src/00`–`src/02`, and `npm run check:frozen-only` is what keeps that true. They exist only because the shipped `src/99` package still calls them on real systems, and they go when `src/99` goes — do not add new callers on them.

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
- There is deliberately NO read buffer: a second read after an overwrite sees the new row (`test_buffer` pins it)
- **Owner binding:** each draft stores its creator's `sy-uname` (column `UNAME`); `read`/`check_exists` only return a draft to that same user, so a leaked or guessed draft id (bookmark URLs carry it) cannot restore another user's serialized state. A mismatch fails closed with the same `NO_DRAFT_ENTRY...` exception as "not found", so a shared bookmark degrades to a fresh app start. Legacy rows written before the column existed carry a blank owner and stay readable during the upgrade transition (they expire within a few hours), so no active session breaks on upgrade.

**Both the store and the serializer are seams.** `z2ui5_if_ui5_draft_store`
is reached through `z2ui5_cl_ui5_srv_draft=>get_instance( )`,
`z2ui5_if_ui5_serializer` through `z2ui5_cl_ui5_app_cont=>get_serializer( )`,
and on an SAP system nothing changes: without `set_instance( )` /
`set_serializer( )` the shipped classes run statement for statement as before.
Who the seams are for (hosts that are not an SAP system), what an
implementation must keep and why each seam sits where it does is
**`docs/agents/architecture-seams.md`**; the contracts themselves are on the
two interfaces.

### The wire carries its own version (`c_protocol`)

Every response stamps `S_FRONT.PROTOCOL` from
`z2ui5_if_ui5_types=>c_protocol`, and `app/webapp/core/Server.js` compares it
against its own `PROTOCOL` before reading anything else. A mismatch is reported
to the user; a response *without* the field is let through, because a backend
older than the field cannot be told apart from one that is merely older.

It is not the product version and does not move with a release. It moves when a
response can no longer be read by a frontend written for the previous number —
the `S_ACTION` envelope replacing `S_FRONT.PARAMS` was such a change. **Raise
both halves in the change that breaks the wire.**

Why it exists: the two halves ship together *here*, and not everywhere. A port
of this framework, a pinned webapp, a third-party shell — each can pair a
backend and a frontend of different ages, and the failure mode was the worst
available: the frontend looked for a key the backend no longer wrote, read its
absence as "nothing to do", and rendered an empty page with no error anywhere.
A number on the wire turns that into a sentence somebody can read.

### Two things settled elsewhere

- **`@abap2ui5/runtime`.** `backend-prebuilt.yaml` packs the transpiled tree
  twice from one build: the release tarball (`npm run pack:backend`) and the
  npm package `@abap2ui5/runtime`, whose manifest is
  `node/setup/runtime.package.json` — **deliberately not `node/package.json`**
  (a `package.json` inside `node/` makes `npm run` stop there; the file's
  header says what broke). What each delivery is for and what the package
  promises is the `@abap2ui5/runtime` section of `docs/agents/ci-workflows.md`.
- **A missing codepage class must not take down the view.**
  `conv_get_string_by_xstring( )` chains both dynamic-call failures into
  `UNSUPPORTED_CODEPAGE_API`, and `z2ui5_cl_ui5_view_builder=>xml_escape( )`
  catches it and degrades (the control-character set stays empty; `&`, `<`,
  `>`, `"`, newline, CR and tab escape exactly as before). The reasoning is
  at both code sites and, with the seams above, in
  `docs/agents/architecture-seams.md`.

### Key Design Patterns

- **Factory:** `z2ui5_cl_ui5_http_handler=>factory()` / `factory_cloud()` for on-premise vs. cloud
- **Generic View Builder:** `z2ui5_cl_ui5_view_builder=>factory()` + `ele`/`tag`/`a`/`end`/`stringify` builds any UI5 XML view 1:1 (see `src/02/z2ui5_cl_ui5_view_builder.clas.abap`)
- **Event Routing:** `client->_event('ID')` registers; `client->check_on_event('ID')` checks
- **App Navigation:** `client->nav_app_call(app)` pushes; `client->nav_app_leave()` pops (executed in a loop within one roundtrip)
- **Multi-View:** Main view, nested views (nest/nest2), popups, and popovers simultaneously
- **Exit Pattern:** `z2ui5_if_ui5_exit` (the public extension point) implemented by `z2ui5_cl_ui5_user_exit` for custom themes, CSP headers, etc. **Two interfaces are honoured during the rename:** `z2ui5_if_exit` is the superseded name and carries the same two methods, its types being references to the ones on `z2ui5_if_ui5_exit` rather than copies. It lives in `src/99` and is the **one** object of that package `abaplint.jsonc` lists in the strict ruleset by name — a `src/01` class naming a type the strict parser cannot see is 37 unresolvable-type errors, so the line stays until the interface goes. `get_user_exit_class( )` looks the current interface up first and the superseded one only when that names nothing, so a class implementing both is found under the current name; `get_instance( )` casts to the current interface first, so such a class is called once, through `z2ui5_if_ui5_exit`. The shipped exit implements `z2ui5_if_ui5_exit` only — `gi_user_exit_dep`, the reference of the superseded type, holds nothing but a customer class written against that name. When `z2ui5_if_exit` goes, what goes with it is the second lookup, the second class-data reference and the two delegating methods — all in `z2ui5_cl_ui5_user_exit`.

### Building Apps

App-building guidance (view builder choice, lifecycle patterns, canonical app template, client API) lives in **`docs/agents/building-apps.md`** — the self-contained in-repo guide, also exposed as the `build-an-app` skill. Do not duplicate it here; the rendered docs site is <https://abap2ui5.github.io/docs/>.

## Repository Structure

```
src/
├── 00/                        # Layer 0: Utilities
│   ├── 01/                    #   AJSON — JSON serialization (mirrored, DO NOT MODIFY)
│   ├── 02/                    #   S-RTTI — Runtime type information (mirrored, DO NOT MODIFY)
│   └── 03/                    #   Context/HTTP abstractions (z2ui5_cl_ui5_util_context, _http, _json_fl, z2ui5_cx_ui5_util_error) — vendored copies from abap-util (except _json_fl)
├── 01/                        # Layer 1: Core Engine
│   ├── 01/                    #   Draft service (z2ui5_cl_ui5_srv_draft + z2ui5_t_01)
│   ├── 02/                    #   Core classes (handler, client, action, frontend, app_cont, srv_bind, srv_event, srv_model + z2ui5_if_ui5_types)
│   ├── 03/                    #   Embedded UI5 frontend (auto-generated, DO NOT EDIT)
│   └── 04/                    #   Shipped apps + default exit (z2ui5_cl_ui5_app_start, _app_hi_world, _user_exit)
├── 02/                        # Layer 2: Public API (the whole contract - 5 objects)
│   ├── z2ui5_if_app.intf.abap          # Main app interface (version constant)
│   ├── z2ui5_if_client.intf.abap       # Client interaction methods
│   ├── z2ui5_if_ui5_exit.intf.abap     # Customization exit points
│   ├── z2ui5_cl_ui5_http_handler.clas.abap  # HTTP entry point
│   └── z2ui5_cl_ui5_view_builder.clas.abap  # Generic XML view builder
└── 99/                        # HISTORY ONLY - ignore completely, zero in-repo consumers
    ├── z2ui5_if_types.intf.abap        # Retired shared types - every one of them now lives on its user
    ├── z2ui5_if_exit.intf.abap         # Superseded name of z2ui5_if_ui5_exit - still shipped, still looked up
    ├── z2ui5_cl_xml_view.clas.abap     # Legacy fluent view builder (~16K lines) - superseded by z2ui5_cl_ui5_view_builder
    ├── z2ui5_cl_xml_view_cc.clas.abap  # Legacy custom controls builder - superseded by z2ui5_cl_ui5_view_builder
    ├── z2ui5_cl_http_handler.clas.abap # Deprecated shim - forwards to z2ui5_cl_ui5_http_handler
    ├── 01/                    #   Retired z2ui5_cl_util* classes + z2ui5_t_91 (obsolete)
    └── 02/                    #   Built-in popups (z2ui5_cl_pop_*, formerly src/02/01/) (obsolete)
                               #   to_confirm, to_inform, to_select, file_dl, file_ul, table, textedit,
                               #   pdf, html, messages, error, input_val, data, demo_output,
                               #   image_editor, get_range, get_range_m
```

### Additional Directories

Everything outside `src/` — `app/` and its `webapp/` module inventory, `node/`,
`docs/`, `.claude/skills/`, `backlog/`, `tools/`, `frontend/`,
`.github/` and what each script and shared file in it is for — is
**`docs/agents/repository-map.md`**. It is a lookup: an agent needs it once it
knows it has to place a change, not before, and this file is loaded into every
session. Two of its rows were the two longest lines in this file.

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

What every workflow does, grouped by purpose, is
**`docs/agents/ci-workflows.md`** — same reason as the directory map above: it
is what a reader looks up when a check goes red, not what they have to know
before they can start.

What is worth carrying without looking it up:

- **The static gates are one job** (`check_gates.yaml`), one step per rule, each
  `if: ${{ !cancelled() }}` — so a pull request that trips three of them reports
  all three at once. `npm run gates` is the local half of the same behaviour.
- **`src/99` is frozen and `src/02` is a contract**, and both are machine-checked
  (rule 1, rule 5). A change that edits either fails the pull request.
- **`src/01/03/` is generated from `app/webapp/`** and its drift gate runs on
  the pull request, so a frontend change carries the regenerated tree with it
  (rule 2). The delivery trees are not committed at all — `frontend_check`
  builds them from the sources into the git-ignored `tools/out/`.
- **The gates run on `push: main` as well as on pull requests.** A merge is not a
  state any pull request tested, and `auto_downport`,
  `frontend_deploy` and `trigger_local` all rebuild or deploy from it.
- **Every job takes its toolchain from `.github/actions/setup`** — Node version,
  pinned action sha, the `npm ci` / `app` / `deps` installs.
- **A release also carries the prebuilt backend**: `backend-prebuilt.yaml`
  attaches `backend-<version>.tar.gz` (the downported and transpiled tree,
  `npm run pack:backend`) once `release.yaml` has published. The asset name
  and its `backend-manifest.json` are read by `abap2UI5/mcp-server` — renaming
  either is a change over there; the workflow's header has the reasoning.

Both downstream repositories are **generated, never edited**: the deploy writes
over their content, so a change made there survives only until the next push to
this `main` and then disappears without a trace. `app/webapp/` is edited here
and nowhere else. [frontend](https://github.com/abap2UI5/frontend) enforces this
with its `guard` workflow, which fails every manual pull request by default and
only lets through changes to the docs it genuinely owns after a maintainer
applies the `maintenance` label. Its `main` carries those docs plus the
machine-written `result/<branch>` trees this repository delivers, and every
published branch is fanned out from them by its `deliver` workflow — always
exactly one commit ahead of `main` there, never edited in place.

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
  The exception handed over as `val` is chained as `previous` automatically, so the whole cause chain survives up to the single top-level catch, which renders it into the 500 body via `z2ui5_cx_ui5_util_error=>get_text_full` (chain entries with class, source position, kernel id and exception attributes). **Never inline a cause into a message** (`val = |MY_ERROR: { x->get_text( ) }|`) — that flattens it to one line and drops everything below; pass the message as `val` and the cause as `previous`. Reasoning at `z2ui5_cx_ui5_util_error`, and `npm run check:cause` is the gate — the rule was prose only until five raises in `z2ui5_cl_ui5_frontend` had broken it.
- **API parameter types:** Use `TYPE clike` for string/char input parameters in public API methods (allows both string and char literals without conversion)
- **Utility access:** every system- and environment-specific call goes through `z2ui5_cl_ui5_util_context` — never directly to `cl_abap_*` or a function module. Full rules in "Utilities — the context class is the only door"
  ```abap
  z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
  ```
- **Prefer simple, transpile- and downport-friendly ABAP over clever constructs.** Every framework ABAP file is both **downported to 7.02** (`npm run auto_downport`) and **transpiled to JS** (`npm run auto_transpile`, for the Node unit and browser tests), so the plainest expression that does the job is the safest one — readability and pipeline-robustness win over brevity, and a little duplication is preferable to a hard-to-follow abstraction. In particular, avoid ref/deref gymnastics such as a helper that hands back `REF TO data` pointing into the caller's own structure (`REF #( <field-symbol> )` returned and dereferenced with `<ref>->*`): it compiles on every target but is hard to read and to reason about through the downport/transpile pipeline — prefer two straightforward `SPLIT` / `LOOP AT` / `ASSIGN COMPONENT` loops even if they overlap slightly. Rule of thumb: if `abaplint` and the transpiler pass but a reviewer would call the construct "clever", pick the plainer form.

### Naming (enforced by abaplint)

- Classes: `Z2UI5_CL_*` or `Z2UI5_CX_*`
- Interfaces: `Z2UI5_IF_*`
- Allowed object types: `CLAS`, `DEVC`, `INTF`, `TABL` only — and `TABL` is
  allowed, not encouraged (see below)

#### No new dictionary objects

**The framework is ABAP source. A dictionary object is a last resort, and
"released so an app can name it" is not a reason at all.**

A DDIC object costs what a class does not: it activates separately, it cannot
carry a test include, it has no visibility to hide behind, a field rename is a
runtime break for every caller that spelled the name dynamically, and on an
ABAP Cloud system it drags in a release contract that outlives the reason it
was added. A type an app needs is a `TYPES` in an interface; a constant is a
`CONSTANTS`; a lookup table is an internal table built in ABAP.

Two `TABL` objects remain, each because nothing else can do its job:

| Object | Why it cannot be ABAP |
|---|---|
| `z2ui5_t_01` (`src/01/01`) | the draft table — the framework's state **is** rows on the database between roundtrips |
| `z2ui5_t_91` (`src/99/01`) | the key/value store behind `z2ui5_cl_util_db`, frozen with the rest of `src/99` |

`z2ui5_t_02` used to be the third: a released `name`/`value` structure added
purely so a sample could write
`CREATE DATA … TYPE STANDARD TABLE OF ('Z2UI5_T_02')` without naming a
framework internal. **It was removed on 2026-09-22** — in a year nothing named
it, its only consumer was the unit test pinning its shape, and the app it was
written for went on naming a table of its own. A dynamic type names a type the
*system* has; supplying one from the framework was solving the wrong half of
the problem (`docs/agents/building-apps.md`, `docs/removal-plan.md` §5).

So: **do not add a `TABL`, a `DTEL`, a `DOMA`, a `DDLS` or a `BDEF`.** If one
looks unavoidable, the change needs a maintainer decision recorded here first,
naming what ABAP could not express.
- **Method names, convention only — no abaplint rule decides these.** `factory( )`
  builds and returns a new object **of its own class** (`z2ui5_cl_ui5_http_handler`,
  `z2ui5_cl_ui5_view_builder`, `z2ui5_cl_ui5_action=>factory_*`, …) and is a
  constructor replacement. An **interface** returned from a `get_*( )` with a
  `set_*( )` twin is the opposite thing — the one swappable implementation behind
  an extension point, not a new object per caller: `get_instance( )` where the
  class *is* that implementation (`z2ui5_cl_ui5_user_exit`,
  `z2ui5_cl_ui5_srv_draft`), `get_<role>( )` where it merely holds one
  (`z2ui5_cl_ui5_app_cont=>get_serializer( )`). Do not rename these to `factory` —
  they hand out the configured instance, which is what `factory` promises not to do.

### Style Rules

- Max 50 statements per method, max cyclomatic complexity 10, max nesting depth 5
- No aliases, no STATICS, no BREAK-POINT, no DEFINE macros
- `NEW #()` instead of `CREATE OBJECT`; `xsdbool()` for booleans (NEVER use `boolc()` — the downport pipeline converts `xsdbool` to `boolc` automatically); `line_exists()` instead of READ TABLE
- Backtick string literals (`` ` ``) preferred over single quotes
- An `abap_bool` is compared to `abap_true` / `abap_false` — never asked with `IS INITIAL` / `IS NOT INITIAL`, which is the question for a string. The app corpus goes one step further for the three `check_on_*( )` lifecycle methods and writes the predicative call itself (`IF client->check_on_init( ).`), a negative branch only as `= abap_false`; that rule and its reasons live in the `build-an-app` skill, and the apps under `node/srv` follow it like any other
- `IS NOT` over `NOT ... IS`; `RETURNING` over `EXPORTING` for single outputs
- No `EXPORT TO MEMORY`/`DATABASE`; no test seams; `lines()` instead of `DESCRIBE LINES`
- No DB operations in loops; SQL uses `@` host variable escaping
- No Yoda conditions
- `forbidden_void_type` blocks SAP standard types — use `abap_bool`, `i`, `string` etc.

### Extended-check (SLIN/ATC) pitfalls — not caught by abaplint

The sources are also run through the extended program check in real systems,
which flags things `npm run check` cannot see. `npm run check:atc` gates the
traps a script can decide; the complete catalogue — every trap with the case
that produced it, gated or not — is **section 3 of the `abap-check` skill**
(`.claude/skills/abap-check/SKILL.md`). Read it before finishing any change
under `src/`, and add the case there when a system reports a new one.

## Build & Validation

Three headline commands — all **non-destructive**, they never modify `src/`
or `abaplint.jsonc`:

```bash
npm run check        # Fast inner loop: abaplint only (seconds) — run while iterating
npm run gates        # Every static gate in one process (~4s), reporting EVERY failure
npm run verify       # The full pre-PR gate: all independent checks first, then
                     # downport -> transpile -> unit -> JS specs -> app2abap drift
                     # gate, matching CI (run verify:full when app/webapp/ changed)
```

**Never validate with `npm run auto_downport`** — it rewrites `src/` in
place and overwrites `abaplint.jsonc`; it exists only to build the `702`
branch in CI (rule 9). `npm run verify` runs the identical downport
non-destructively in `node/downport/`.

Everything else — the complete command inventory (held complete against
`package.json` by `npm run check:commands`), the frontend tooling under
`app/`, the testing setup and what the unit suite covers — is
**`docs/agents/commands.md`**: a lookup for when a task needs a command,
not something to know before starting.

## Key Files

**Must-know files (start here):**

| File | Why |
|---|---|
| `src/02/z2ui5_if_app.intf.abap` | Main app interface + version constant |
| `src/02/z2ui5_if_client.intf.abap` | All client methods (view, events, binding, navigation), and the types they return and take |
| `src/02/z2ui5_cl_ui5_view_builder.clas.abap` | Generic XML view builder — the standard for all apps |
| `src/01/02/z2ui5_cl_ui5_handler.clas.abap` | Central request processor + main loop |
| `src/01/02/z2ui5_cl_ui5_client.clas.abap` | Implements z2ui5_if_client |
| `abaplint.jsonc` | Linter rules — source of truth for code standards |

**Reference files (consult as needed):**

| File | Why |
|---|---|
| `src/02/z2ui5_if_ui5_exit.intf.abap` | Customization exit points (`z2ui5_if_exit` is its superseded name) |
| `src/01/04/z2ui5_cl_ui5_user_exit.clas.abap` | Default exit + user-exit class support |
| `src/01/02/z2ui5_cl_ui5_action.clas.abap` | Event/action dispatcher |
| `src/01/02/z2ui5_cl_ui5_frontend.clas.abap` | Frontend action queues + response serialization (T_SYSTEM/T_CUSTOM, ROUTER/nav intent) |
| `src/01/02/z2ui5_cl_ui5_app_cont.clas.abap` | App lifecycle (create, load, serialize) |
| `src/01/02/z2ui5_cl_ui5_srv_bind.clas.abap` | Data binding engine — a bound value to its client path, one service per render |
| `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap` | The attribute rows: dissolve, binding search, model out and in (row deltas), the draft save and restore of generic references |
| `src/01/02/z2ui5_cl_ui5_srv_event.clas.abap` | Event registration and payload assembly |
| `src/01/01/z2ui5_cl_ui5_srv_draft.clas.abap` | Draft/session persistence |
| `src/00/03/z2ui5_cl_ui5_util_context.clas.abap` | The single door to system/platform functionality — see "Utilities" |
| `app/webapp/core/Context.js` | One context per component: the state instance, the per-module records, and how a module finds it (`Context.of`) |
| `app/webapp/core/AppState.js` | The shape of a component's state (`createState()`) + its field inventory |
| `app/webapp/core/ViewSlots.js` | View-slot access layer (get/set/byId/destroy per slot) |
| `app/webapp/core/Lib.js` | Shared frontend helpers |
| `app/webapp/core/Env.js` | UI5-release compatibility layer (1.71 fallbacks) |
| `app/webapp/core/Server.js` | Roundtrip lifecycle + request/response wire format docs |

## Commits, pull requests, issues

The rule is **`.github/shared/CONVENTIONS.md` §7** — a subject in the
imperative describing the outcome, one topic per pull request, the PR title
becomes the squash subject — and `CONTRIBUTING.md` ("Submitting Changes")
carries the how-to for titles and issue replies. One prohibition an agent
cannot look up in time: **never close an issue somebody else reported, and
never let a merge close it** — no `Fixes #NNNN` / `Closes #NNNN` /
`Resolves #NNNN` in a title, body or commit message (GitHub acts on it at
merge time); write `Report: #NNNN` or `See #NNNN`. Only the reporter can
confirm the fix, on their system — #2664 was closed exactly this way.

## Important Rules for AI Assistants

These rules apply to AI assistants **modifying the framework** (this repo). For AI assistants **building apps**, read `docs/agents/building-apps.md` instead (rendered docs site: <https://abap2ui5.github.io/docs/>).

1. **Do not modify `src/00/01/` (AJSON) and `src/00/02/` (S-RTTI)** — mirrored from external projects, synced by automated workflows. `src/00/03/` is the opposite case: see "Utilities — the context class is the only door", which settles everything about utilities. **Ignore `src/99/` completely — the package is history only** (see "Layered Design"): never read it, change it, or add consumers on it. The view builder is `z2ui5_cl_ui5_view_builder` in `src/02/`; all builder work happens there.
2. **NEVER manually edit any ABAP file under `src/01/03/`.** These files are the embedded frontend (auto-generated from `app/webapp/` — see `tools/app2abap/trans2abap.js` and the `check_app2abap.yaml` drift gate). The **only** allowed way to update them is:
   - Change the source under `app/webapp/`
   - Run **`npm run app2abap`** locally (or comment `/fix app2abap` on the pull request). This single command runs the full pipeline in the correct order — `npm --prefix app run format` (Prettier) → `npm run auto_app2abap` (generate) → `npm run auto_abaplint` (normalize) — exactly as CI does. Running `auto_app2abap` on its own produces **un-normalized** ABAP that differs from the committed form in *every* `src/01/03/` file (alignment/whitespace drift); the `auto_abaplint` step reverts that drift so only the files whose `app/webapp/` source actually changed remain modified.
   - Commit the regenerated `src/01/03/` files as the job produced them
   - The `sap.ui.require.preload` mapping is **also generated**: `trans2abap.js` emits `z2ui5_cl_ui5f_preload`, whose `get( )` returns the complete text of the GET shell's one inline `<script>` and which `z2ui5_cl_ui5_http_handler` consumes, together with two constants taken over that exact text: `build_hash` (the GET shell's ETag carries it) and `script_hash` (the CSP hash that lets the script run without `'unsafe-inline'`, see rule 13). `get_bundle( )` returns the same entries as the script a GET with `?z2ui5-bundle` answers with (`_http_get_bundle`, for a page that embeds the component) - served as a file, so no hash is taken over it. New files under `app/webapp/` are picked up automatically — never reintroduce a manually maintained preload list in the HTTP handler, and never let a configurable value into that script text: the hash is fixed at generation time.
   - **The embedded `.js` copies are comment-stripped.** `trans2abap.js` cuts the comments out of the original text by position (acorn) and lets Prettier tidy the holes — no compress, no mangle, no reprint, and a terser re-parse proves the program is unchanged. The mirror is a delivery artefact: the comments live in `app/webapp/`, and stripping them roughly halves the ICF `GET` payload. Do not expect `src/01/03/` to carry a frontend comment; the special files (`.xml`/`.json`/`.html`/`.css`) go in untouched.
   Direct edits to `src/01/03/*.abap` are forbidden — no manual tweaks, no "small fixes", no formatting changes, nothing. The job may be invoked, but the files must never be touched by hand or by any other means.
   - **Prettier governs all of `app/webapp/`** — do not add `// prettier-ignore` directives. Since every custom control lives in its own file, a header reflow only touches that control's small generated constant; just let `npm run app2abap` format and regenerate.
   - **The delivery trees follow the same rule, one step further: they are not committed here at all.** `npm run frontend:build` builds them from `app/webapp/`, `frontend/` and `tools/` into the git-ignored `tools/out/`, `frontend_check` proves the build on every pull request, and `frontend_deploy` runs the same build on `main` and ships it into abap2UI5/frontend (`result/<branch>` on its `main`). Never edit a built tree — change the source; the only generated artefact a webapp change commits alongside it is `src/01/03/`.
3. **Always run `npx abaplint`** before considering changes complete.
4. **Multi-environment compatibility** — code must work on NW 7.02, standard ABAP, and ABAP Cloud.
5. **The public API (`src/02/`) is a stable contract — never change or remove existing public attributes, methods, or constants.** This folder is consumed directly by thousands of downstream apps. Specifically:
   - Do not rename, remove, or change the signature of any method in `z2ui5_if_client`, `z2ui5_if_app`, or `z2ui5_if_ui5_exit`
   - Do not remove or rename public `DATA`, `CONSTANTS`, or `TYPES` in any `src/02/` class or interface
   - Do not change the type or default value of existing parameters in any public method
   - Additive changes are allowed (new methods, new optional parameters, new constants)
   - When in doubt, add rather than change
   - **No public signature may name a Layer 1 type.** A `z2ui5_if_ui5_types=>…` in a `src/02` signature makes an internal a de-facto public contract and blocks renaming it. The public class declares its own type instead — see `z2ui5_cl_ui5_http_handler=>ty_s_http_res`, which is structurally identical to the core's and meets it once, in `_http_post( )`, via `MOVE-CORRESPONDING`
   - **Machine-enforced** by `check_gates.yaml`: every public `src/02` signature is recorded in `.github/api-snapshot.json`; a removed/changed signature fails the PR (revert it — never edit the snapshot to silence the gate), and an addition fails until you record it with `node .github/scripts/api-snapshot.mjs --write` and commit the snapshot alongside
   - The recorded exceptions — ten so far, all owner-approved, from the move to the `ui5` namespace to the exit-field removal of 2026-09-23 — are **`docs/agents/api-snapshot-exceptions.md`**. Not a precedent for editing the snapshot on any other finding; a new entry goes there AND into `docs/removal-plan.md` §0, so that list stays the complete record it claims to be
6. **String literals use backticks** (`` ` ``), not single quotes.
7. **Frontend public contracts** — besides `src/02/`, the following frontend names are consumed by backend-generated views and existing apps and must not be renamed: the module IDs `z2ui5/cc/<Name>` of the custom controls (file location under `webapp/cc/` defines the ID), their properties and events (bound by existing app views), the controller methods `eB`/`eF`, and the `z2ui5/model/formatter` module (reached from a view via `core:require`). Additive changes only. **There is no frontend global** — the `z2ui5` object on `window`, and with it the `z2ui5.Util` / `z2ui5.Formatter` globals and the `z2ui5/Util` module, was removed on 2026-09-22; do not bring one back. View XML using the custom controls must declare `xmlns:z2ui5="z2ui5.cc"` (changed from `"z2ui5"` when the controls moved into `cc/`).
8. **Shared frontend helpers live in `app/webapp/core/Lib.js`** — shared or pure/testable logic goes there (pure helpers are unit-tested in Node via `node/tests/loadLibModule.js`); helpers with a single consumer stay in that module. **Anything that differs between UI5 1.71 and the current release goes through `app/webapp/core/Env.js`** instead (element registry, messaging, theming, localization, the 1.71-1.82 fragment preload) — the one module allowed to call the deprecated fallbacks, so a raised floor removes code there and nowhere else (specs: `loadEnv` in the same helper). **The frontend state is per component: `app/webapp/core/Context.js` creates one context per `z2ui5.Component`** (`Component.init`), and `app/webapp/core/AppState.js` is only the SHAPE of its state — the complete field inventory and the defaults (`createState()`). There is no singleton: a module below the component takes the context as its first argument (`ctx.state`, plus the per-module records `ctx.server`, `ctx.session`, `ctx.router`, ...), an action handler reads it off the calling controller (`oController.ctx`), a custom control asks `Context.of(this)` — the views and fragments are built under the component as owner (`Context.runAsOwner` in `actions/Slots`), so UI5's own `getOwnerComponentFor` answers for every control inside them. Several components on one page share none of it since 2026-09-23; what stays page-wide by nature (the URL hash, the title, the global BusyIndicator, `Lib.logError`'s ring) is listed in the header of `Context.js`. Nothing is put on `window`: there is no `z2ui5` global and ui5lint's `no-project-globals` keeps it that way. Configuration from the backend GET page arrives as component data (`Component.init`). Do not add lazy `if (!state.x)` bootstrapping; add the field with its default to `AppState.createState()` instead, and a per-module record to `Context.create()`.
9. **Validate with `npm run verify`, never with `npm run auto_downport`.** `auto_downport` rewrites `src/` in place *and* overwrites `abaplint.jsonc`; it exists for exactly one purpose — producing the `702` branch in `auto_downport.yaml` — and will destroy uncommitted work if you run it to check your changes. `npm run downport` performs the identical downport into `node/downport/` and leaves the working tree untouched; `npm run verify` wraps it together with lint, transpile and unit tests.
10. **Custom controls (`app/webapp/cc/`) delegate, they never decide** — a control exposes bindable **properties** and **events** and lets the backend drive the UI; it must not surface its own popups/toasts/dialogs (the `Geolocation` control fires an `error` event with code/message instead of showing a `MessageBox`). Lifecycle (UI5 2.x is strict): `init` and other lifecycle listeners **must not return a value** — never make them `async` (an async function returns a Promise → `_enforceNoReturnValue` FUTURE FATAL; kick the async work off in a separate helper, see `CameraSelector._loadCameras`). After every `await`, bail out when the control was destroyed (`Lib.isDestroyed`). Read the DOM defensively (guard a 0-size canvas, a missing `videoWidth`, an absent element) and **log, never throw** (`Lib.logError`). Prefer reusing a standard control or a binding over writing a new custom control at all.
11. **Never "modernize" `WITH DEFAULT KEY` to `WITH EMPTY KEY` on a table that is passed to a classic function module** (or to any typed formal parameter) — the key is part of the table type, and an incompatible one makes the `CALL FUNCTION` fail at runtime, silently when it sits inside a `TRY … CATCH` / `EXCEPTIONS` guard. Reasoning and the concrete breakage: see the comment above `lt_impl` in `z2ui5_cl_ui5_util_context=>rtti_get_classes_intf_std`.
12. **A module that exists only in newer UI5 must never be a hard `sap.ui.define([...])` dependency.** abap2UI5 supports OpenUI5 down to **1.71**; a dep the old release lacks 404s and the *whole component* fails to load (blank app). Resolve version-specific modules **lazily** with `sap.ui.require("…")` at the point of use and handle `undefined` gracefully (see `Component.js` Theming/Messaging probing, and the `THEMING` target in `core/actions/ControlCall.js`). Known post-1.71 modules: `sap/ui/core/Theming` and `sap/ui/core/Messaging` (both since 1.118). Before adding any `sap/ui/core/*` dependency, check its "available since" — if it is newer than 1.71, lazy-require it.
13. **The default CSP has no `'unsafe-eval'`, and its `script-src` no `'unsafe-inline'` — nothing the framework ships may need either.** The GET shell's one inline script runs by its generated SHA-256 hash (`z2ui5_cl_ui5f_preload=>script_hash`, appended to every `script-src` by `z2ui5_cl_ui5_http_handler=>_csp_add_script_hash`); never add a second inline `<script>`, an inline event handler attribute or a `javascript:` URL to the page or to anything `app/webapp/` renders, and never put a configurable value between the script tags (`styles_css` is a `<style>` element of its own for that reason). `check:csp` holds the default, the `boots under the shipped CSP without a violation` e2e spec holds the running page. The default CSP (in `z2ui5_cl_ui5_user_exit`) leaves it out: follow-up actions are data (rule 19), and UI5 from **1.84** on runs without it when it loads asynchronously from its preload bundles. On **1.71 to 1.82** `Fragment.load` processes a popup/popover synchronously and the ui5loader evals every module it has to fetch — so `actions/Slots` awaits `Env.preloadFragmentModules( )` first, which requires the fragment's control classes asynchronously (a library counting as loaded is no guarantee: sap.m pulls sap.ui.layout in without its preload). A module the popup only names in a binding type or a `core:require` is still eval'd there (a view built by `XMLView.create` is not affected at all); an installation that hits it switches `'unsafe-eval'` on in its exit (the `REPLACE` documented on `z2ui5_if_ui5_exit=>ty_s_http_config-content_security_policy`). Never add a sync load, a `new Function` or an `eval` to `app/webapp/` — and keep `"async": true` on the manifest's `rootView`: 1.71 ignores `IAsyncContentCreation` (since 1.89), builds a rootView without the flag synchronously, loads its controller's dependencies one by one and evals them, so the shell would not even boot. UI5 **expression binding** (`{= … }`) is not one of the eval users: UI5 parses it with its own `sap/ui/base/ExpressionParser` (a Pratt parser — no `eval`/`new Function` in 1.71 through 1.120, checked in the npm sources and in a browser under a CSP without `'unsafe-eval'`), so it is fine in framework XML too. What does need `'unsafe-eval'` is a module arriving as a source string — synchronous loading, or a resource missing from the preload bundles.
14. **`app/webapp/` source must be 7-bit ASCII.** Every frontend file is embedded into an ABAP class under `src/01/03/` (`.js` comment-stripped, everything else verbatim — see rule 2), which abaplint checks with the `7bit_ascii` rule — a non-ASCII literal (`…`, `©`, `→`, a smart quote) breaks generation/lint. Use ASCII in source (`...` not `…`) and build any non-ASCII runtime string with `String.fromCharCode(...)` / entity decoding at run time, never as a literal.

15. **A generic aggregation-escape tag (`<ns:name>` — produced by `heading( ns )`, a literal `<footer>`, `_generic( name = … ns = … )`, …) must name an aggregation the parent actually has; otherwise UI5 resolves it as a *control class* and 404s** with `failed to load sap/<lib>/<name>.js` on any release lacking that control, killing the view. This is rule 12's failure mode for **controls/aggregations** rather than modules. Real 1.71 crashes fixed this way: `<footer>` on a `sap.m.Dialog` — the public `footer` aggregation only exists since **~1.110**, so use the **`buttons`** aggregation (since 1.21.1) for a Dialog footer (see `DeveloperTools.fragment.xml`); and (samples) `heading( `uxap` )` on a `sap.uxap.ObjectPageSection`, which has no `heading` aggregation. `heading( ns )` IS valid on a parent that has one (sap.f `DynamicPageTitle`); `sap.m.Page.footer` is fine. Before using an aggregation confirm the parent exposes it in the **oldest supported release (1.71)** — like modules, post-1.71 aggregations bite (Dialog `footer` ~1.110).
16. **`sap.m.MessageBox` always closes on Escape and gives no way to suppress it.** For a popup that must NOT be Escape-dismissable — the fatal-error overlay (`ErrorView.js`), which would otherwise let the user Escape back into a broken app — build a `sap.m.Dialog` with `escapeHandler: (oPromise) => oPromise.reject()` instead of a MessageBox (keep the raw-DOM overlay as the fallback for a broken core). Only the explicit actions (Details / Restart) may then close it.
17. **A dialog loaded from a fragment with a fixed `id` must be loaded once and reused across open/close — never destroyed on close and re-loaded on the next open.** On OpenUI5 1.71 the destroy races the dialog's close animation, so a fragment-scoped control id is still registered when the reload runs → `adding element with duplicate id 'z2ui5DeveloperTools--developerToolsEditor'` (the fragment id has been derived from the control instance since 2026-09-23, `<id>--tools`, the message reads accordingly). Pattern (see `DeveloperTools.js`): `show()` reuses an existing `this.oDialog` and only re-seeds the model; `close()` just closes it (and reuses it next time); `exit()` is the sole place that destroys it.
18. **Do not declare a physical resource in `manifest.json` that the ABAP deployment does not actually serve.** `sap.ui5/resources.css` made UI5 load `css/style.css` as a real `<link>`, which 404s on the ABAP system — frontend files are served through the module preload (`z2ui5_cl_ui5f_preload`), not as ICF resources at their raw URLs. The placeholder `style.css` contained only a placeholder comment, so the entry was removed. If a real stylesheet is ever needed, serve it through the preload / HTTP handler, not a bare manifest `<link>`.
19. **The frontend is a thin, data-driven executor — grow it through the declarative whitelists, not through new bespoke logic.** The backend drives frontend behavior by *data* (an event name plus positional args), and the action dispatch (`FrontendAction.js`, handlers in `core/actions/` — the whitelists live in `core/actions/ControlCall.js`, `BINDING_METHODS` in `core/actions/BindingCall.js`) turns that data into UI5 calls through three declarative whitelists: `CONTROL_METHODS` (imperative methods on a control resolved by id — `to`, `open`, `scrollToIndex`, `expandToLevel`, …), `GLOBAL_TARGETS` (whitelisted methods on a global object — `MessageToast`, `MessageBox`, `BusyIndicator`, `Theming`), and `BINDING_METHODS` (aggregation-binding ops — `filter`/`sort`, built from paths + whitelisted `FILTER_OPERATORS`, never from code). **When a new need is "call a UI5 control / global / binding method", add a whitelist entry** (method name + its arg *kinds*, cast via `castArg`) — do **not** add a new hand-written handler that re-implements the dispatch. Only add a new handler (in the matching `core/actions/` domain module, merged into the dispatch by `FrontendAction.js`) for a genuine *browser capability* that has no control-method equivalent (clipboard, history, download, storage, timer, focus/scroll/caret, audio, launchpad nav). Whichever you add, it stays a thin executor: resolve/cast args, guard the DOM, and `Lib.logError` on failure — **never** embed business decisions, thresholds, unit conversions, or app-specific branching — those belong in the backend model. This keeps the "delegate, never decide" contract (rule 10) at the action layer and keeps every payload data, not code — CSP-clean without `unsafe-eval` for the dispatch path.
    **The curated formatter module (`app/webapp/model/formatter.js`) is the same rule for values**, and the only place the framework ships JS an app's view calls on its data. It is a **marshalling layer, not a formatting toolbox**: a function may only live there when it (1) formats exactly the one value handed to it, (2) cannot be done in ABAP at all — a JS `Date` for an object-typed property, an icon-font glyph of the loaded theme, a browser locale/theme artefact — and (3) contains no domain vocabulary (no hardcoded ValueState, no icon URI, no business status). The criteria and the precedent (`weightState` and the stock/delivery status pack were shipped and **removed** again) are in the module header; criteria 2 and 3 are machine-enforced by `npm run check:formatter` / `check_gates.yaml`, criterion 1 is reviewer-enforced. Adding a function there is an architectural decision, not a convenience — if ABAP can produce the finished value, the app computes it and the view binds it.

20. **A green `npm run verify` does not prove the repository still round-trips through abapGit — `npm run check:abapgit` does.** abaplint parses ABAP and has no model of abapGit's file format, and its `global.files` never reaches `src/99` at all, so a `.clas.xml` with the terminating newline removed and CRLF line endings throughout produces **zero** findings while differing from the system's serialization on every single pull (`8e272492`, `54bce5b6`, `c7185c38` — three "fix abapgit diffs" commits, all repaired only after someone pulled). The BOM is the one byte-level rule abaplint has: `xml_bom`, new in 2.120.32 and on here in `abaplint.jsonc`, in the standard/cloud/702 target configs (which do reach `src/99`) and in the autofix config, where its quick fix inserts the BOM. It reads the one XML abapGit writes per object, so an `.abap` file carrying a BOM is still the gate's finding and nobody else's. The transpiler ignores visibility, so a `class_constructor` outside the **PUBLIC SECTION** keeps `npm run unit` green and fails activation in a real system (why `z2ui5_cl_ui5_frontend` fills `ct_box_type` lazily, #2547). **Never hand-edit a `.clas.xml`/`.intf.xml` to tidy it** — it is a serialization, not a config file; fix the object in a system and commit what abapGit writes. The full checklist, including the parts no gate can decide (`<DESCRIPTIONS>` following the components), is the `abap-check` skill in `.claude/skills/` — the catalogue for every ABAP problem a green CI misses, not just the abapGit ones.

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

Each of these was proposed, measured and declined; what was measured and why
is **`docs/agents/decisions.md`**. What stays here is the part an agent must
know before it proposes the same thing again:

- **`Z2UI5_T_01` has no version column, gets no secondary index on
  `TIMESTAMPL`, and draft cleanup is not throttled or debounced** — do not
  (re-)introduce any of the three.
- **No `componentPreload` declaration** in `app/webapp/manifest.json` /
  `index.html` — both production delivery paths already bundle every module.
- **No central app-start authorization hook.** Authorization belongs in the
  app's own `z2ui5_if_app~main`; the framework checks the *type*
  (`rtti_check_class_impl_intf`), not the user. Do not add an
  `AUTHORITY-CHECK` or a `check_app_start_allowed` exit, and do not report
  its absence as a vulnerability.
- **`changelog.txt`** is the changelog; no separate `CHANGELOG.md`.
- **The pre-main model snapshot in `z2ui5_cl_ui5_handler=>main_process`
  serializes a second time on delta roundtrips on purpose** — reasoning at
  the code site; do not re-propose it as a performance bug.
- **The developer tools stay in the preload and `devtools/DevTools.js` keeps
  its hard `sap.ui.define` dependencies** — reasoning in that file's header.
- **No app base class and no lifecycle hooks on `z2ui5_if_app`** (declined
  2026-08-11) — do not add either, and do not report the repeated
  dispatcher as duplication.
- **No named frontend-action wrappers on `z2ui5_if_client`** (reverted
  2026-08-11, parked for a future action object —
  `backlog/items/frontend-action-named-api.md`); `follow_up_action` stays the
  only API.
- **Embedding abap2UI5 as a reuse component is deferred** (2026-09-23,
  `backlog/items/embed-as-reuse-component.md`) — do not re-propose the rest
  as general cleanup.
- **`z2ui5_cl_xml_view` (src/99) is not extended, refactored or split**, and
  its size is not a finding.

### Scope Exclusions for Code Reviews, Security Audits & Improvement Work

When reviewing, auditing, or proposing improvements to this repository, treat the following as **out of scope** — do not report findings in them, refactor them, or otherwise invest in them:

- **The production code of `src/99/`.** It is **frozen legacy code** (see "Layered Design"): no in-repo consumers, kept solely so existing downstream installations keep compiling. Do **not** report, harden, refactor or extend it. For example, the unescaped single quote in the dynamic `WHERE` builders of `z2ui5_cl_util_ext` is a **non-issue** here, and the ~16K-line size of `z2ui5_cl_xml_view` is not a finding either. Only the `*.testclasses.abap` files under `src/99/` are maintained — they run in CI and may need adapting when core internals they assert on change.
- **The `_bind` / `_bind_edit` "mass assignment" question** — binding was **intentionally unified** (see "Data Binding" above): `_bind` and `_bind_edit` behave identically and every bound attribute is writable from the client `MODEL`. `_bind_edit` is a **compatibility-only alias of `_bind`** and is slated for **removal (~1 year out)**. A proposal to split them again — a separate "editable" flag so `_bind` becomes display-only while only `_bind_edit` writes back — is explicitly **rejected**: it would reintroduce exactly the distinction that was deliberately removed and break the many apps that rely on `_bind` round-tripping. Treat "an attribute exposed via `_bind` is writable from the client model" as **by design**, not a vulnerability.
- **A secondary index on `Z2UI5_T_01-TIMESTAMPL`** — see the draft-cleanup entry in `docs/agents/decisions.md`: rejected as not worth the per-write index-maintenance cost.
- **The "no app-start authorization" question** — see the app-start entry in `docs/agents/decisions.md`. That any authenticated user reaching the ICF node can instantiate any `z2ui5_if_app` class is **by design**: authorization lives in the app's own `z2ui5_if_app~main` (like a transaction guarding itself), not in a framework `AUTHORITY-CHECK` or a `check_app_start_allowed` exit. Do not report the missing central hook as a vulnerability, and do not add one.
