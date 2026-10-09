# AGENTS.md — abap2UI5

Single source of truth for agents working on the abap2UI5 framework.

> **Building an app WITH abap2UI5? Stop reading here.** Everything an app
> needs — template, lifecycle, view builder, client API — is the
> self-contained guide **`docs/agents/building-apps.md`** (also wired as the
> `build-an-app` Claude Code skill; `llms.txt` indexes both audiences). The
> rest of this file is for changing the framework itself.

### Where knowledge lives

This file is read at the start of **every** session (`CLAUDE.md` points Claude
Code at it), so what it costs is paid on every task. Keep it to what an agent must know *before* it can
know it needs to look something up. Everything else belongs closer to the code:

| Kind of knowledge | Where it belongs |
|---|---|
| A constraint on **one file or method** | A comment **at that code site**. This file may state the rule in one line and point there — it must not repeat the reasoning |
| A rule that can be **checked mechanically** | A lint rule or a CI gate. Prose is a request; a gate is a guarantee |
| A **procedure** or a **lookup** | A file that is read when the task comes up — see the list below |
| A rule bound to **one directory** | That directory's own `AGENTS.md` (with a `CLAUDE.md` importing it), loaded when work happens there |
| A **prohibition** an agent would otherwise violate unknowingly | Here, in one line — it has to be in context before the mistake |
| **History** — why something was removed, which exemption was opened and closed | `docs/agents/decisions.md`, never here |

When you fix something subtle, write the reasoning **into the code** and add at
most a pointer here. The comment ages with the code it guards; a paragraph in
this file does not.

Where the rest is:

| File | Read it when |
|---|---|
| `app/AGENTS.md` | changing anything under `app/webapp/` — the frontend rules in full (loaded automatically below `app/`) |
| `REVIEW.md` | reviewing, auditing or proposing improvements — what is out of scope |
| `docs/agents/repository-map.md` | placing a change outside `src/`; related repositories, root files, reference files |
| `docs/agents/commands.md` | you need a command — the complete inventory, gated against `package.json` |
| `docs/agents/ci-workflows.md` | a check went red, or you touch a workflow |
| `docs/agents/architecture-seams.md` | touching the draft store, the serializer, the monitor or the exit lookup |
| `docs/agents/decisions.md` | you want to argue with a decision below, or need the history behind one |
| `docs/agents/api-snapshot-exceptions.md` | rule 5 — the recorded exceptions to the public-API snapshot |
| `docs/agents/test-inventory.md` | which spec covers which module |
| `.claude/skills/abap-check` | before finishing any change under `src/` — what a green CI does not catch in ABAP |
| `.claude/skills/ui5-check` | before touching a view, fragment or frontend module — the same for UI5 and 1.71 |
| `.claude/skills/view-chain-layout` | writing or reformatting a view-builder chain |

## Project Overview

abap2UI5 is a framework for building SAP UI5 applications purely in ABAP — no
JavaScript, OData, or RAP required. It supports all ABAP releases from NW 7.02
to ABAP Cloud, on-premise and cloud.

- **Version:** the `version` constant in `src/02/z2ui5_if_app.intf.abap` — read it there, never repeat it here
- **License:** MIT · **Homepage:** https://abap2UI5.org
- **Language:** English — all code, comments, commit messages, PRs, issues, documentation, and communication
- **Related repositories** (samples, linter, mcp-server, frontend, abap-util, …): `docs/agents/repository-map.md`

## Architecture

### How It Works — The Roundtrip

abap2UI5 is a **stateful SPA**. The browser loads a UI5 shell once via HTTP GET,
then talks to the ABAP backend exclusively via HTTP POST/JSON roundtrips:

```
Browser (UI5 SPA)                          ABAP Backend
       │──── HTTP GET ─────────────────────────→│  Returns HTML + embedded UI5 app
       │←─── HTML page ─────────────────────────│
       │──── POST {S_FRONT, MODEL} ────────────→│  1. Parse JSON request
       │                                        │  2. Load draft (session) from DB
       │                                        │  3. Apply model changes (MODEL → ABAP vars)
       │                                        │  4. Call app->main(client)
       │                                        │  5. App builds view / handles events
       │                                        │  6. Save new draft to DB
       │←─ {S_FRONT: ID, APP, S_ACTION; MODEL} ─│  7. Return JSON response
```

**Request JSON** carries `S_FRONT` (event name, draft ID, browser state) and
`MODEL` (view model changes as deltas). **Response JSON** carries a new draft
ID, the app class name, and two action lists under `S_ACTION`: `T_SYSTEM`
view-lifecycle calls (which carry any view XML) and `T_CUSTOM` follow-up
actions (including messages). `MODEL` travels only when something bound changed.

**The wire carries its own version.** Every response stamps `S_FRONT.PROTOCOL`
from `z2ui5_if_ui5_types=>c_protocol`, and `app/webapp/core/Server.js` compares
it with its own `PROTOCOL`. It is not the product version: **raise both halves
in the change that breaks the wire** (reasoning at both sites).

**Inside the Fiori Launchpad** the POST body may arrive without its
`{ "value": … }` envelope (`z2ui5_cl_ui5_handler=>request_parse_body` handles
both), and the shell owns the front of the URL hash. Exactly two places know
that split — `app/webapp/core/Router.js` (`splitHash()`) and
`z2ui5_cl_ui5_handler` (`hash_get_app_part` / `hash_get_shell_part`). **Do not
re-implement the split anywhere else, and do not rebuild a URL from
`location.href.split("#")[0]` plus an app hash** — write the app hash through
`Router.navTo()`.

### Layered Design

```
src/
├── 00/   Layer 0: Utilities
│   ├── 01/   AJSON — mirrored, DO NOT MODIFY
│   ├── 02/   S-RTTI — mirrored, DO NOT MODIFY
│   └── 03/   z2ui5_cl_ui5_util_context (+ _http, _json_fl, z2ui5_cx_ui5_util_error) — see "Utilities"
├── 01/   Layer 1: Core engine
│   ├── 01/   Draft service (z2ui5_cl_ui5_srv_draft + table z2ui5_t_01)
│   ├── 02/   handler, client, action, frontend, app_cont, srv_bind/_event/_model/_monitor, z2ui5_if_ui5_types
│   ├── 03/   Embedded UI5 frontend — GENERATED from app/webapp/, never edit (rule 2)
│   └── 04/   Shipped apps + default exit (z2ui5_cl_ui5_app_start, _app_hi_world, _user_exit)
├── 02/   Layer 2: Public API — the whole contract, six objects (rule 5)
└── 99/   FROZEN legacy code — ships for downstream installations, zero in-repo consumers
```

- **Layer 0** — self-contained utilities. `noIssues` in `abaplint.jsonc` suppresses lint for all of `src/00`.
- **Layer 1** — the engine. `z2ui5_cl_ui5f_*` (**f**rontend) are the generated classes in `src/01/03`; the bare
  `z2ui5_cl_ui5_*` segment is everything hand-written. There is no `z2ui5_cl_app_*` object any more.
- **Layer 2** — `z2ui5_if_app`, `z2ui5_if_client`, `z2ui5_if_ui5_exit`, `z2ui5_if_ui5_monitor`,
  `z2ui5_cl_ui5_http_handler`, `z2ui5_cl_ui5_view_builder`. Recorded symbol for symbol in
  `.github/api-snapshot.json`. **A type lives on the object that uses it** (`ty_s_get` on `z2ui5_if_client`,
  the HTTP-config types on the exit) — nothing in `src/00`–`src/02` resolves into the retired `z2ui5_if_types`.
- **`src/99` — frozen.** The legacy XML view builder (`z2ui5_cl_xml_view`, `_cc`), the `z2ui5_cl_http_handler`
  shim, `z2ui5_if_types`, `z2ui5_if_exit` (the superseded exit name — still looked up, see "Key Design Patterns"),
  the retired `z2ui5_cl_util*` classes (`99/01`) and the obsolete popups (`99/02`, successor:
  [abap2UI5-addons/popups](https://github.com/abap2UI5-addons/popups)).

**For AI assistants: never change the production code under `src/99/` or add
consumers on it.** The `check_gates` workflow enforces the freeze. Exempt are
the `*.testclasses.abap` files (they run in `npm run unit` and follow the core
internals they assert on) and the `.clas.xml` sidecars. Moving an object **out**
of the package is allowed; the gate refuses a deletion only when the object
name exists nowhere else under `src/` afterwards **and** it shipped in the
latest release tag. Any other change under `src/99` needs a maintainer decision
recorded in `docs/agents/decisions.md` first — the one exemption that was
opened (the popup port) has closed again and is **not** a precedent.

### Utilities — the context class is the only door

**This section is the single source of truth for how the framework reaches
system and platform functionality.**

**Rule: every system- and environment-specific function is called through a
method of `z2ui5_cl_ui5_util_context` (`src/00/03/`).** RTTI, conversions, UUID,
messages, XML/transformations, timestamps, base64, rollback, environment
detection — framework code never calls `cl_abap_*`, a function module, or an
environment-specific API directly. That keeps the framework portable across
NW 7.02 / Standard ABAP / ABAP Cloud and transpilable to JS; environment
branching happens inside the class (`check_abap_cloud( )`, dynamic calls).

**When the function you need is missing:**

1. **Look in [abap-util](https://github.com/abap-util/abap-util) first** — the master catalog.
2. **If it exists there, copy it into `z2ui5_cl_ui5_util_context`** with its private helpers, renamed to this namespace.
3. **If it does not, write it directly in `z2ui5_cl_ui5_util_context`.** No upstream-first step — this copy leads.
4. An AI periodically syncs additions and fixes back into abap-util ([its AGENTS.md](https://github.com/abap-util/abap-util/blob/main/AGENTS.md)).

So:

- **`z2ui5_cl_ui5_util_context` is not a read-only mirror — edit it freely**, and keep what you add **generic**
  (framework-specific logic belongs in the core `z2ui5_cl_ui5_*` classes).
- `z2ui5_cl_ui5_util_http` and `z2ui5_cx_ui5_util_error` are vendored too — change them only when a fix or a
  caller genuinely needs it. `z2ui5_cl_ui5_util_json_fl` is framework-owned.
- **Symbols marked `FROZEN-ONLY`** exist only for `src/99`; `npm run check:frozen-only` keeps them caller-free —
  do not add callers.
- **`src/99/01/z2ui5_cl_util*`, `z2ui5_cx_util_error`, `z2ui5_t_91` are legacy** — never use, call or change them.
- abap2UI5 does **not** depend on abap-util at install time (abapGit has no dependency management; "clone and
  go"), hence renamed copies.

### Data Binding

`client->_bind( var )` maps an ABAP attribute (found via RTTI) to the model path
`{/name}`; values travel out as `MODEL` and come back as row/cell deltas.
`_bind_edit` is an obsolete alias that behaves identically.

**Say "binding", never "one-way"/"two-way" binding** — there is only one kind
left, and it always carries values both ways. The one legitimate "one-way" is a
real UI5 one-way model that is not `_bind( )` (the `device>` JSONModel).

### Session Persistence (Draft Service)

`z2ui5_cl_ui5_srv_draft` stores the serialized app in table `Z2UI5_T_01`, keyed
by UUID; every roundtrip loads, runs `main( )` and saves under a new id, chained
by `id_prev`. There is deliberately **no read buffer** (`test_buffer`). **Owner
binding:** a draft is returned only to the `sy-uname` that wrote it, and a
mismatch fails closed exactly like "not found" — do not weaken either. The store
(`z2ui5_if_ui5_draft_store`) and the serializer (`z2ui5_if_ui5_serializer`) are
seams; see `docs/agents/architecture-seams.md`.

### Key Design Patterns

- **Factory:** `z2ui5_cl_ui5_http_handler=>factory()` / `factory_cloud()` for on-premise vs. cloud
- **Generic View Builder:** `z2ui5_cl_ui5_view_builder=>factory()` + `ele`/`tag`/`a`/`end`/`stringify` builds any UI5 XML view 1:1
- **Event Routing:** `client->_event('ID')` registers; `client->check_on_event('ID')` checks
- **App Navigation:** `client->nav_app_call(app)` pushes; `client->nav_app_leave()` pops
- **Multi-View:** main view, nested views (nest/nest2), popups and popovers at once
- **Exit Pattern:** `z2ui5_if_ui5_exit`, implemented by `z2ui5_cl_ui5_user_exit` (themes, CSP headers, …).
  The superseded `z2ui5_if_exit` (`src/99`) is still looked up and honoured during the rename — how, and what goes
  when it goes, is in `docs/agents/architecture-seams.md`. It is the one `src/99` object `abaplint.jsonc` lists in
  the strict ruleset.
- **Monitor seam:** `z2ui5_if_ui5_monitor`, called once per POST roundtrip. **It fails open, the exit fails
  closed** — a broken monitor must never break an app.
- **`@abap2ui5/node-runtime`:** the transpiled tree as an npm package; its manifest is
  `node/setup/npm.package.json`, **deliberately not `node/package.json`** (see `docs/agents/ci-workflows.md`).
- **A missing codepage class must not take down the view** — `xml_escape( )` degrades on
  `UNSUPPORTED_CODEPAGE_API` (reasoning at both code sites).

## CI/CD Workflows

What every workflow does is `docs/agents/ci-workflows.md`. Worth carrying:

- **The static gates are one job** (`check_gates.yaml`), one step per rule, each `if: ${{ !cancelled() }}`, so a
  pull request sees every failure at once. `npm run gates` is the local half.
- **`src/99` is frozen and `src/02` is a contract**, both machine-checked (rules 1, 5).
- **`src/01/03/` is generated from `app/webapp/`** and drift-gated (rule 2). The delivery trees are not committed:
  `frontend_check` builds them into the git-ignored `tools/out/`.
- **The gates also run on `push: main`** — a merge is a state no pull request tested.
- **Every job takes its toolchain from `.github/actions/setup`.**
- **A release carries the prebuilt backend** (`backend-prebuilt.yaml`); its asset name and `backend-manifest.json`
  are read by `abap2UI5/mcp-server` — renaming either is a change over there.
- **Downstream frontend repositories are generated, never edited** — `app/webapp/` is edited here and nowhere else.

## Language & Code Rules

**Primary language:** ABAP (v750 syntax target, downported to v702 via CI).
`abaplint.jsonc` is the source of truth for what is enforced; below is what it
does not say, or says in a way worth knowing in advance.

### Coding Style

[SAP Clean ABAP](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md), with deliberate exceptions:
Hungarian prefixes (`mv_`, `mo_`, `ms_`, `lo_`, `lv_`, `ls_`, `li_`, `lx_`), public `DATA` where the architecture
needs it, inline declarations used selectively (`prefer_inline: false`), no abapdoc (`abapdoc: false`).

- **Class definition:** `FINAL` unless inheritance is needed, and **always all three sections** — keep an empty
  `PROTECTED SECTION.` / `PRIVATE SECTION.`:
  ```abap
  CLASS z2ui5_cl_my_class DEFINITION PUBLIC FINAL CREATE PUBLIC.
    PUBLIC SECTION.
      METHODS do_something.
    PROTECTED SECTION.
    PRIVATE SECTION.
  ENDCLASS.
  ```
- **Exception handling:** catch `cx_root`, re-raise as `z2ui5_cx_ui5_util_error`, `##NO_HANDLER` when ignoring on
  purpose. **Never inline a cause into a message** (`val = |MY_ERROR: { x->get_text( ) }|`) — pass the message as
  `val` and the cause as `previous`, so the chain survives into the 500 body. `npm run check:cause` gates it.
  ```abap
  CATCH cx_root INTO DATA(x).
    RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error EXPORTING val = x.
  ```
- **API parameter types:** `TYPE clike` for string/char inputs of public methods.
- **Utility access:** only through `z2ui5_cl_ui5_util_context` — see "Utilities".
- **Prefer plain, transpile- and downport-friendly ABAP over clever constructs.** Every file is downported to 7.02
  and transpiled to JS. Avoid ref/deref gymnastics (a helper returning `REF TO data` into the caller's structure);
  a little duplication beats an abstraction that is hard to follow through the pipeline. If abaplint and the
  transpiler pass but a reviewer would call it "clever", pick the plainer form.
- **Method names:** `factory( )` returns a **new** object of its own class. A `get_*( )` with a `set_*( )` twin hands
  out the configured implementation behind an extension point (`get_instance( )`, `get_serializer( )`) — do not
  rename those to `factory`.

### Style Rules

- Max 50 statements per method, cyclomatic complexity 10, nesting depth 5
- No aliases, `STATICS`, `BREAK-POINT`, `DEFINE` macros, test seams, `EXPORT TO MEMORY`/`DATABASE`
- `NEW #()` not `CREATE OBJECT`; `xsdbool()` — **never `boolc()`** (the downport converts); `line_exists()` not
  `READ TABLE`; `lines()` not `DESCRIBE LINES`
- Backtick string literals; `IS NOT` over `NOT … IS`; `RETURNING` over `EXPORTING` for one output; no Yoda conditions
- An `abap_bool` is compared to `abap_true` / `abap_false`, never asked with `IS INITIAL` (the `check_on_*( )`
  predicative form is the `build-an-app` skill's rule)
- No DB operations in loops; SQL host variables escaped with `@`; `forbidden_void_type` — use `abap_bool`, `i`,
  `string`, …

### Naming and object types

- Classes `Z2UI5_CL_*` / `Z2UI5_CX_*`, interfaces `Z2UI5_IF_*`; object types `CLAS`, `DEVC`, `INTF`, `TABL` only.
- **No new dictionary objects** — no `TABL`, `DTEL`, `DOMA`, `DDLS` or `BDEF`. A type an app needs is a `TYPES` in
  an interface, a constant a `CONSTANTS`, a lookup table an internal table. The two remaining tables are
  `z2ui5_t_01` (the drafts) and the frozen `z2ui5_t_91`. A new one needs a maintainer decision first.

### Extended-check (SLIN/ATC) pitfalls — not caught by abaplint

Real systems run the extended program check, which flags what `npm run check`
cannot see. `npm run check:atc` gates what a script can decide; the complete
catalogue is **section 3 of the `abap-check` skill** — read it before finishing
any change under `src/`, and add the case there when a system reports a new one.

## Build & Validation

```bash
npm run check        # Fast inner loop: abaplint only (seconds)
npm run gates        # Every static gate in one process (~4s), reporting EVERY failure
npm run verify       # The full pre-PR gate: downport -> transpile -> unit -> JS specs -> app2abap drift,
                     # matching CI (run verify:full when app/webapp/ changed)
```

All three are non-destructive. **Never validate with `npm run auto_downport`** —
it rewrites `src/` in place and overwrites `abaplint.jsonc` (rule 9). Every other
command is in `docs/agents/commands.md`.

## Key Files

| File | Why |
|---|---|
| `src/02/z2ui5_if_app.intf.abap` | Main app interface + version constant |
| `src/02/z2ui5_if_client.intf.abap` | All client methods, and the types they take and return |
| `src/02/z2ui5_cl_ui5_view_builder.clas.abap` | Generic XML view builder — the standard for all apps |
| `src/01/02/z2ui5_cl_ui5_handler.clas.abap` | Central request processor + main loop |
| `src/01/02/z2ui5_cl_ui5_client.clas.abap` | Implements `z2ui5_if_client` |
| `src/00/03/z2ui5_cl_ui5_util_context.clas.abap` | The single door to system/platform functionality |
| `abaplint.jsonc` | Linter rules — source of truth for code standards |

The rest (action, frontend, app container, binding/model/event services, the
frontend core modules) is under "Reference files" in `docs/agents/repository-map.md`.

## Commits, pull requests, issues

The rule is **`.github/shared/CONVENTIONS.md` §7** (imperative subject describing
the outcome, one topic per pull request, the PR title becomes the squash
subject); `CONTRIBUTING.md` has the how-to. **Never close an issue somebody else
reported, and never let a merge close it** — no `Fixes #NNNN` / `Closes #NNNN` /
`Resolves #NNNN` in a title, body or commit message; write `Report: #NNNN` or
`See #NNNN`. Only the reporter can confirm the fix, on their system.

## Important Rules for AI Assistants

For **modifying the framework**. Code, tests and gates cite these by number —
keep the numbers. The frontend rules (2, 7, 8, 10, 12–19, 21) are written out in
full in **`app/AGENTS.md`**, under the same numbers.

1. **Do not modify `src/00/01/` (AJSON) or `src/00/02/` (S-RTTI)** — mirrored and synced by workflows.
   **Do not change the production code of `src/99/` or add consumers on it** (see "Layered Design").
   All builder work happens in `z2ui5_cl_ui5_view_builder`.
2. **NEVER edit any file under `src/01/03/` by hand** — it is generated from `app/webapp/`. Change the source there
   and run **`npm run app2abap`** (or comment `/fix app2abap`), then commit what it produced. Never reintroduce a
   hand-kept preload list, never edit a built delivery tree. Details: `app/AGENTS.md`, rule 2.
3. **Always run `npx abaplint`** (`npm run check`) before considering a change complete.
4. **Multi-environment compatibility** — code must work on NW 7.02, standard ABAP and ABAP Cloud.
5. **The public API (`src/02/`) is a stable contract.** Never rename, remove or change the signature of a method
   of `z2ui5_if_client`, `z2ui5_if_app`, `z2ui5_if_ui5_exit` or `z2ui5_if_ui5_monitor`; never remove or rename
   public `DATA`, `CONSTANTS` or `TYPES` in `src/02`; never change the type or default of an existing parameter.
   Additive changes are allowed — when in doubt, add rather than change. **No public signature may name a Layer 1
   type** (declare a structurally identical one on the public class, see `z2ui5_cl_ui5_http_handler=>ty_s_http_res`).
   Enforced by `.github/api-snapshot.json`: a removed/changed signature fails — revert it, **never edit the snapshot
   to silence the gate**; an addition fails until recorded with `node .github/scripts/api-snapshot.mjs --write`.
   The owner-approved exceptions are `docs/agents/api-snapshot-exceptions.md` — not a precedent; a new entry goes
   there **and** into `docs/removal-plan.md` §0.
6. **String literals use backticks** (`` ` ``), not single quotes.
7. **Frontend public contracts** — the custom-control module ids `z2ui5/cc/<Name>`, their properties and events,
   the controller methods `eB`/`eF`, `z2ui5/model/formatter` and `z2ui5/model/clipboard` must not be renamed.
   **There is no `z2ui5` frontend global** — do not bring one back.
8. **Shared frontend helpers live in `core/Lib.js`; anything that differs between UI5 1.71 and today goes through
   `core/Env.js`; state is per component** (`core/Context.js`, shape in `core/AppState.js`) — no singleton, nothing
   on `window`.
9. **Validate with `npm run verify`, never with `npm run auto_downport`** (see "Build & Validation").
10. **Custom controls (`app/webapp/cc/`) delegate, they never decide** — no popups/toasts of their own, no `async`
    lifecycle hooks, log never throw.
11. **Never "modernize" `WITH DEFAULT KEY` to `WITH EMPTY KEY` on a table passed to a classic function module** (or
    any typed formal parameter) — see the comment above `lt_impl` in
    `z2ui5_cl_ui5_util_context=>rtti_get_classes_intf_std`.
12. **A module newer than UI5 1.71 is never a hard `sap.ui.define` dependency** — lazy `sap.ui.require` at the
    point of use. Never run SAP's UI5 Modernization Plugin or an unreviewed `ui5lint --fix` over
    `app/webapp` — both target 1.136.
13. **Nothing the framework ships may need `'unsafe-eval'` or an inline-script `'unsafe-inline'`** — no second
    inline `<script>`, no inline handler, no `eval`/`new Function`/sync load, no configurable value inside the
    hashed GET script. `check:csp` gates the default.
14. **`app/webapp/` source is 7-bit ASCII** — every file is embedded into ABAP.
15. **A generic aggregation tag (`<ns:name>`, `heading( ns )`, `_generic( … )`) must name an aggregation the parent
    has in UI5 1.71** — otherwise UI5 loads it as a control class and the view dies (Dialog footer → `buttons`).
    This applies to views built in ABAP too.
16. **A popup that must not be Escape-dismissable is a `sap.m.Dialog`, never a `sap.m.MessageBox`.**
17. **A fragment dialog with a fixed id is loaded once and reused** — destroyed only in `exit()`.
18. **`manifest.json` declares no physical resource the ABAP deployment does not serve.**
19. **The frontend is a thin, data-driven executor** — grow it through the whitelists in `core/actions/`, not
    bespoke handlers; `model/formatter.js` admits a function only under its header's criteria (`check:formatter`).
20. **A green `npm run verify` does not prove the abapGit round trip — `npm run check:abapgit` does.** **Never
    hand-edit a `.clas.xml`/`.intf.xml`** — fix the object in a system and commit what abapGit writes. The
    transpiler ignores visibility, so a `class_constructor` outside the PUBLIC SECTION keeps `npm run unit` green and
    fails activation. The full checklist is the `abap-check` skill.
21. **An icon name must exist in the 1.71 icon font** (`npm run check:icons`; names are lower-case, `text-formatting`
    not `textFormatting`), **and a toolbar-only control (`ToolbarSpacer`/`ToolbarSeparator`) must not sit in a
    `sap.m.Bar`** — before 1.71's flex layout it cuts the bar's content off. Applies to ABAP-built views too.

**What a green CI proves:** rules 1 (`src/99` part), 2, 3, 4, 5, 14, 20, the icon
half of 21 and the formatter half of 19 are gated. The 1.71 cluster (12, 13, 15–18)
is only partly covered by the `ui5-1.71` Playwright leg — outside the shell and
roundtrip specs it is reviewer-enforced. Details: `app/AGENTS.md`, last section.

## Design Decisions & Known Non-Issues

Each was proposed, measured and declined — reasoning and history in
`docs/agents/decisions.md`, review scope in `REVIEW.md`. Do not propose these
again:

- **`Z2UI5_T_01` has no version column, no secondary index on `TIMESTAMPL`, and draft cleanup is not throttled.**
- **No `componentPreload` declaration** in `manifest.json` / `index.html` — both delivery paths already bundle.
- **No central app-start authorization hook.** Authorization belongs in the app's own `z2ui5_if_app~main`; the
  framework checks the *type*, not the user. Do not add one, and do not report its absence as a vulnerability.
- **`_bind` writing back from the client model is by design** — do not split `_bind` / `_bind_edit` again, and do not
  report it as mass assignment.
- **`changelog.txt`** is the changelog; no `CHANGELOG.md`.
- **The second model serialization in `z2ui5_cl_ui5_handler=>main_process`** on delta roundtrips is deliberate.
- **The developer tools stay in the preload** with their hard `sap.ui.define` dependencies.
- **No app base class and no lifecycle hooks on `z2ui5_if_app`**; the repeated dispatcher is not duplication.
- **No named frontend-action wrappers on `z2ui5_if_client`** — `follow_up_action` stays the only API.
- **Embedding as a reuse component goes as far as demand asked** — do not re-propose the rest as cleanup.
- **`z2ui5_cl_xml_view` is not extended, refactored or split**, and its size is not a finding.
