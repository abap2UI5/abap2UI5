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
| `bundle/AGENTS.md` | changing anything under `bundle/webapp/` — the frontend rules in full (loaded automatically below `bundle/`) |
| `REVIEW.md` | reviewing, auditing or proposing improvements — what is out of scope |
| `docs/agents/repository-map.md` | placing a change outside `src/`; related repositories, root files, reference files |
| `docs/agents/commands.md` | you need a command — the complete inventory, gated against `package.json` |
| `docs/agents/ci-workflows.md` | a check went red, or you touch a workflow |
| `docs/agents/architecture-seams.md` | touching the draft store, the serializer, the monitor, the language model seam or the exit lookup |
| `docs/agents/decisions.md` | you want to argue with a decision below, or need the history behind one |
| `RELEASING.md` | cutting a release (core, linter, ecosystem - in that order, each with a dry run), or removing anything public - **deprecate first, remove in a later release** (its "Deprecation policy") |
| `docs/agents/client-api.md` | you need a signature of `z2ui5_if_client` — the generated index (`npm run client-api`), never edited |
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
- **Related repositories** (samples, linter, mcp-server, the extension, abap-util, …): `docs/agents/repository-map.md`; which one pins
  what, how, and which are released with the core: `.github/ecosystem.json` (`npm run check:ecosystem`)

## Architecture

### How It Works — The Roundtrip

abap2UI5 is a **stateful SPA**. The browser loads a UI5 shell once via HTTP GET,
then talks to the ABAP backend exclusively via HTTP POST/JSON roundtrips:

```
Browser (UI5 SPA)                          ABAP Backend
       │──── HTTP GET ─────────────────────────→│  Returns HTML: the embed control, which
       │                                        │  loads the UI5 app (GET ?z2ui5-bundle)
       │←─── HTML page ─────────────────────────│
       │──── POST {S_FRONT, MODEL} ────────────→│  1. Parse JSON request
       │                                        │  2. Load draft (session) from DB
       │                                        │  3. Apply model changes (MODEL → ABAP vars)
       │                                        │  4. Call app->main(client)
       │                                        │  5. App builds view / handles events
       │                                        │  6. Save new draft to DB
       │←─ {S_FRONT: ID, APP, VIEWS, …; MODEL} ─│  7. Return JSON response
```

**Request JSON** carries `S_FRONT` (event name, draft ID, browser state) and
`MODEL` (view model changes as deltas). **Response JSON** carries a new draft
ID, the app class name, and three sections, each absent when it says nothing:
`VIEWS` (one entry per slot the roundtrip changes - a display with its view XML,
or a teardown), `NAV` (the URL intent) and `ACTIONS` (what the app asked the
frontend to do, messages included). `MODEL` travels only when something bound
changed.

**The wire carries its own version.** Every response stamps `S_FRONT.PROTOCOL`
from `z2ui5_if_ui5_types=>c_protocol`, and `bundle/webapp/core/Server.js` compares
it with its own `PROTOCOL`. It is not the product version: **raise both halves
in the change that breaks the wire** (reasoning at both sites).

**Inside the Fiori Launchpad** the POST body may arrive without its
`{ "value": … }` envelope (`z2ui5_cl_ui5_handler=>request_parse_body` handles
both), and the shell owns the front of the URL hash. Exactly two places know
that split — `bundle/webapp/core/Router.js` (`splitHash()`) and
`z2ui5_cl_ui5_handler` (`hash_get_shell_part`, for the links it composes). What a
hash asks an app start to restore is read by the router alone and travels parsed,
as `S_FRONT.ROUTE` (`Router.startRoute`). **Do not re-implement the split anywhere
else, do not parse a route out of `S_FRONT.HASH` on the backend, and do not
rebuild a URL from `location.href.split("#")[0]` plus an app hash** — write the
app hash through `Router.navTo()`.

### Layered Design

```
src/
├── 00/   Layer 0: Utilities
│   ├── 01/   AJSON (z2ui5_cl_ui5_ajs) — vendored, DO NOT MODIFY
│   ├── 02/   S-RTTI (z2ui5_cl_ui5_srt_*) — vendored, DO NOT MODIFY
│   └── 03/   z2ui5_cl_ui5_util_context (+ _http, _json_fl, z2ui5_cx_ui5_util_error) — see "Utilities"
├── 01/   Layer 1: Core engine
│   ├── 01/   Draft service (z2ui5_cl_ui5_srv_draft + table z2ui5_t_01)
│   ├── 02/   handler, client, action, frontend, app_cont, srv_bind/_event/_message/_model/_monitor, z2ui5_if_ui5_types
│   ├── 03/   Embedded UI5 frontend — GENERATED from bundle/webapp/, never edit (rule 2)
│   ├── 04/   Shipped apps + default exit (z2ui5_cl_ui5_app_start, _app_hi_world, _user_exit)
│   └── 05/   Language model providers behind z2ui5_if_ui5_llm (z2ui5_cl_ui5_llm_claude, _openai, _local, _http),
│             and z2ui5_cl_ui5_llm_guide — GENERATED from docs/agents/building-apps.md (`npm run guide-class`), never edit
├── 02/   Layer 2: Public API — the whole contract, ten objects (rule 5)
└── 03/   The service and the launchpad app — Standard ABAP only
    ├── 01/   ICF node /sap/bc/z2ui5 and its handler z2ui5_cl_ui5_icf_handler
    └── 02/   BSP Z2UI5 — GENERATED from app_source/webapp/, never edit (rule 2)
```

There is no `src/99` any more: the frozen legacy package left the core on 2026-11-17 (below).

- **Layer 0** — self-contained utilities. `noIssues` in `abaplint.jsonc` suppresses lint for all of `src/00`.
- **Layer 1** — the engine. `z2ui5_cl_ui5f_*` (**f**rontend) are the generated classes in `src/01/03`; the bare
  `z2ui5_cl_ui5_*` segment is everything hand-written. There is no `z2ui5_cl_app_*` object any more.
- **Layer 2** — `z2ui5_if_app`, `z2ui5_if_client`, `z2ui5_if_ui5_exit`, `z2ui5_if_ui5_monitor`,
  `z2ui5_cl_ui5_http_handler`, `z2ui5_cl_ui5_view_builder`, and the language model seam `z2ui5_if_ui5_llm`,
  `z2ui5_cx_ui5_llm`, `z2ui5_cl_ui5_llm`, and the app test harness `z2ui5_cl_ui5_test` (a global `FOR TESTING` class -
  test code only; it drives the real handler through `mo_app_start`, its one hook in Layer 1). Recorded symbol for symbol in
  `.github/api-snapshot.json`. **A type lives on the object that uses it** (`ty_s_get` on `z2ui5_if_client`,
  the HTTP-config types on the exit) — nothing in `src/00`–`src/02` resolves into the retired `z2ui5_if_types`.
- **`src/03` — what makes one pull a running installation**, and the one package that is not the same on every
  platform. On `main` it is Standard ABAP: the ICF node, its handler on `if_http_extension`, and the BSP for the
  launchpad. The branch `cloud` is generated from `main` with `cloud/src/03` in its place — an HTTP service, the
  same handler name on `if_http_service_extension`, the IAM objects — and `app_source/` as a Fiori project to
  deploy (`tools/build-cloud.mjs`, `auto-cloud.yaml`). The node, the BSP and the HTTP service carry the names
  installations have had since these objects shipped from abap2UI5/frontend (until 2026-11), and an ICF node or
  a launchpad target mapping names them: **do not rename an object of `src/03` or `cloud/src/03`.** (The handler
  was renamed once, with the move: `z2ui5_cl_lp_handler` became `z2ui5_cl_ui5_icf_handler`.) The handler has lint configs of its own (`npm run check:service`).
- **`src/99`, the frozen legacy package, is gone** (2026-11-17). The legacy XML view builder
  (`z2ui5_cl_xml_view`, `_cc`), `z2ui5_if_types` and the obsolete popups (`z2ui5_cl_pop_*`, successor:
  [abap2UI5-addons/popups](https://github.com/abap2UI5-addons/popups)) ship from
  [abap2UI5-ext](https://github.com/abap2UI5/abap2UI5-ext), together with the retired `z2ui5_cl_util*` classes,
  `z2ui5_cx_util_error` and `z2ui5_t_91` (2026-11-17 to 2026-11-25 they lived in abap2UI5/frontend, which is
  retired). A system whose code still uses one of them installs that repository
  next to abap2UI5. **Two names were deleted and ship nowhere:** `z2ui5_cl_http_handler` (what named it names
  `z2ui5_cl_ui5_http_handler`) and `z2ui5_if_exit` (an exit class implements `z2ui5_if_ui5_exit`).

**For AI assistants: never bring one of these objects back, and never add a file under `src/99/`.** The core
does not depend on the extension — the dependency runs the other way, and `check:frozen` in the `check_gates`
workflow refuses a new `src/99` and records in `MOVED_OUT` what went where. A decision to change that is the
maintainer's, recorded in `docs/agents/decisions.md` first.

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
- **Symbols marked `FROZEN-ONLY`** exist only for the legacy classes of abap2UI5-ext, which are
  compiled against this class; `npm run check:frozen-only` keeps them caller-free here — do not add callers, and
  do not remove one without that repository.
- **`z2ui5_cl_util*`, `z2ui5_cx_util_error`, `z2ui5_t_91` are no longer part of the core** — they ship from the
  extension repository. Never use or reintroduce them here.
- abap2UI5 does **not** depend on abap-util at install time (abapGit has no dependency management; "clone and
  go"), hence renamed copies.

### Data Binding

`client->_bind( var )` maps an ABAP attribute (found via RTTI) to the model path
`{/name}`; values travel out as `MODEL` and come back as row/cell deltas.
Its former alias `_bind_edit` and the `*_model_update( )` no-ops were removed on 2026-11-22.

**Say "binding", never "one-way"/"two-way" binding** — there is only one kind
left, and it always carries values both ways. The one legitimate "one-way" is a
real UI5 one-way model that is not `_bind( )` (the `device>` JSONModel).

### Session Persistence (Draft Service)

`z2ui5_cl_ui5_srv_draft` stores the serialized app in table `Z2UI5_T_01`, keyed
by UUID; every roundtrip loads, runs `main( )` and saves under a new id, chained
by `id_prev` - except a START_TIMER tick that changed nothing, which answers the id
it continued; the chain is pruned to 2 by default (`draft_keep_per_chain`, minimum 2, 0 = off). Both
in `docs/agents/architecture-seams.md`. There is deliberately **no read buffer** (`test_buffer`). **Owner
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
  It is the one exit interface: its former name `z2ui5_if_exit` and the second lookup that honoured it were
  deleted on 2026-11-17 (`docs/agents/architecture-seams.md`).
- **Monitor seam:** `z2ui5_if_ui5_monitor`, called once per POST roundtrip. **It fails open, the exit fails
  closed** — a broken monitor must never break an app.
- **`@abap2ui5/node-runtime`:** the transpiled tree as an npm package; its manifest is
  `node/setup/npm.package.json`, **deliberately not `node/package.json`** (see `docs/agents/ci-workflows.md`).
- **A missing codepage class must not take down the view** — `z2ui5_cl_ui5_util_context=>c_escape_xml( )` degrades on
  `UNSUPPORTED_CODEPAGE_API` (reasoning at both code sites).

## CI/CD Workflows

What every workflow does is `docs/agents/ci-workflows.md`. Worth carrying:

- **The static gates are one job** (`check_gates.yaml`), one step per rule, each `if: ${{ !cancelled() }}`, so a
  pull request sees every failure at once. `npm run gates` is the local half.
- **`src/02` is a contract and `src/99` stays gone**, both machine-checked (rules 1, 5).
- **`src/01/03/` is generated from `bundle/webapp/`** - plus `app_source/webapp/`, the minimal app with the embed control
  that the GET page itself carries - **and `src/03/02/` from `app_source/webapp/`**, the same app as a BSP; both are
  written by `npm run app2abap` and drift-gated (rule 2).
- **The branches `702` and `cloud` are generated from `main`** (`auto_downport.yaml`, `auto-cloud.yaml`; `702` without the
  BSP, `cloud` with `cloud/src/03` in place of `src/03`) — nobody
  commits to them. Both are the whole tree of `main`, rewritten in place, one commit on top of it. What `cloud`
  rewrites is not committed here: `delivery-check` builds it into the git-ignored `tools/out/`.
- **The gates also run on `push: main`** — a merge is a state no pull request tested.
- **Every job takes its toolchain from `.github/actions/setup`.**
- **A release carries the prebuilt backend** (`backend-prebuilt.yaml`); its asset name and `backend-manifest.json`
  are read by `abap2UI5/mcp-server` — renaming either is a change over there.
- **Nothing is delivered into another repository any more.** Until 2026-11 the ICF node, the BSP and the cloud
  service were built here and pushed into branches of abap2UI5/frontend; they are `src/03` and the branch `cloud`
  now, and that repository is the extension.

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
- `NEW #()` not `CREATE OBJECT` (only a dynamic `CREATE OBJECT x TYPE (name)` remains); `xsdbool()` — **never
  `boolc()`** (the downport converts); `lines()` not `DESCRIBE LINES`
- `forbidden_statement` (abaplint.jsonc) refuses `READ TABLE` (→ `line_exists()`, `ASSIGN itab[ … ] TO <fs>` +
  `IS ASSIGNED`; never `REF #( itab[ … ] OPTIONAL )`, the 7.02 downport drops the OPTIONAL), `APPEND` (→ `INSERT …
  INTO TABLE`), `CHECK` (→ `IF … RETURN`/`CONTINUE`), `CONCATENATE`/`CONDENSE`/`FIND`/`REPLACE`/`SHIFT`/`TRANSLATE`
  (→ `&&`, `condense()`, `find()`, `replace()`, `shift_left()`, `to_upper()`), `GET REFERENCE` (→ `REF #()`) and the
  obsolete ones listed there. The keyed hot-path `READ TABLE … WITH TABLE KEY` of four core classes is excluded
  (reason at the exclude); `MOVE-CORRESPONDING` stays allowed for generically typed operands only
- Backtick string literals; `IS NOT` over `NOT … IS`; `RETURNING` over `EXPORTING` for one output; no Yoda conditions
- An `abap_bool` is compared to `abap_true` / `abap_false`, never asked with `IS INITIAL` (the `check_on_*( )`
  predicative form is the `build-an-app` skill's rule)
- No DB operations in loops; SQL host variables escaped with `@`; `forbidden_void_type` — use `abap_bool`, `i`,
  `string`, …

### Naming and object types

- Classes `Z2UI5_CL_*` / `Z2UI5_CX_*`, interfaces `Z2UI5_IF_*`; object types `CLAS`, `DEVC`, `INTF`, `TABL` only —
  plus the `SICF` nodes and the `WAPA` (BSP) of `src/03`, which are that package's whole point and stay there.
- **No new dictionary objects** — no `TABL`, `DTEL`, `DOMA`, `DDLS` or `BDEF`. A type an app needs is a `TYPES` in
  an interface, a constant a `CONSTANTS`, a lookup table an internal table. The one remaining table is
  `z2ui5_t_01` (the drafts); `z2ui5_t_91` ships from abap2UI5-ext. A new one needs a maintainer decision first.
  The numbers `z2ui5_t_05` - `_06` and `_11` - `_33` belong to the abap2UI5-addons (one numbering all addons
  share, decided 2026-11) - never reuse one of them here. Which repository owns which number is the `tables` of
  its entry in `.github/ecosystem.json`; `npm run check:ecosystem` refuses a number listed twice and names the
  next free one. `_02` was released once and removed again (2026-09-22); `_03`/`_04` and `_07` - `_10` are left free.

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
                     # matching CI (run verify:full when bundle/webapp/ changed)
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

**Pull requests to other repositories** (abaplint, open-abap, the transpiler):
open them against the upstream repository itself, never against a fork's
`main`, and with "Allow edits by maintainers" switched on, so the maintainer
can update the branch. **No customer information** in a PR title or body, a
commit message, a test or an issue: no customer namespaces or object names, no
code copied from a customer system, no business details of the case. Write a
neutral reproducer (`ztab`, SFLIGHT fields, a generic `lv_where`) and describe
the evidence generically ("an activation on S/4HANA, 2026-11").

## Important Rules for AI Assistants

For **modifying the framework**. Code, tests and gates cite these by number —
keep the numbers. The frontend rules (2, 7, 8, 10, 12–19, 21) are written out in
full in **`bundle/AGENTS.md`**, under the same numbers.

1. **Do not modify `src/00/01/` (AJSON) or `src/00/02/` (S-RTTI)** — copied from `abap-util/mirror-ajson` and
   `abap-util/mirror-srtti` and renamed by `.github/scripts/vendor-mirror.mjs` (names: `.github/vendor-mirror.json`); a change belongs in the mirror.
   **Do not bring back an object of the former `src/99/`** (see "Layered Design").
   All builder work happens in `z2ui5_cl_ui5_view_builder`.
2. **NEVER edit any file under `src/01/03/` or `src/03/02/` by hand** — they are generated from `bundle/webapp/`
   and `app_source/webapp/`. Change the source there and run **`npm run app2abap`** (or comment `/fix app2abap`),
   then commit what it produced. Never reintroduce a hand-kept preload list, never edit a generated branch.
   Details: `bundle/AGENTS.md`, rule 2.
3. **Always run `npx abaplint`** (`npm run check`) before considering a change complete.
4. **Multi-environment compatibility** — code must work on NW 7.02, standard ABAP and ABAP Cloud. The one
   exception is `src/03`, which the branch `cloud` replaces (see "Layered Design") — nothing else may follow it.
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
10. **Custom controls (`bundle/webapp/cc/`) delegate, they never decide** — no popups/toasts of their own, no `async`
    lifecycle hooks, log never throw.
11. **Never "modernize" `WITH DEFAULT KEY` to `WITH EMPTY KEY` on a table passed to a classic function module** (or
    any typed formal parameter) — see the comment above `lt_impl` in
    `z2ui5_cl_ui5_util_context=>rtti_get_classes_intf_std`.
12. **A module newer than UI5 1.71 is never a hard `sap.ui.define` dependency** — lazy `sap.ui.require` at the
    point of use. Never run SAP's UI5 Modernization Plugin or an unreviewed `ui5lint --fix` over
    `bundle/webapp` — both target 1.136.
13. **Nothing the framework ships may need `'unsafe-eval'` or an inline-script `'unsafe-inline'`** — no second
    inline `<script>`, no inline handler, no `eval`/`new Function`/sync load, no configurable value inside the
    hashed GET script. `check:csp` gates the default.
14. **`bundle/webapp/` source is 7-bit ASCII** — every file is embedded into ABAP.
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
roundtrip specs it is reviewer-enforced. Details: `bundle/AGENTS.md`, last section.

## Design Decisions & Known Non-Issues

Each was proposed, measured and declined — reasoning and history in
`docs/agents/decisions.md`, review scope in `REVIEW.md`. Do not propose these
again:

- **`Z2UI5_T_01` has no version column, no secondary index on `TIMESTAMPL`, and draft cleanup is not throttled.**
- **No `componentPreload` declaration** in `manifest.json` / `index.html` — both delivery paths already bundle.
- **No central app-start authorization hook.** Authorization belongs in the app's own `z2ui5_if_app~main`; the
  framework checks the *type*, not the user. Do not add one, and do not report its absence as a vulnerability.
- **`_bind` writing back from the client model is by design** — do not bring back a display-only / editable split
  (the former `_bind_edit`), and do not report it as mass assignment.
- **`changelog.txt`** is the changelog; no `CHANGELOG.md`.
- **A sticky app's draft is committed where it is written** (KEEP routing, app state, every nav hop, the first-start
  cleanup) — stated at the sites and on `set_session_stateful`; the shipped store gets no secondary DB connection.
- **The second model serialization in `z2ui5_cl_ui5_handler=>main_process`** on delta roundtrips is deliberate.
- **The developer tools are split** — the facade, the console capture and the recorder in the preload, the rest in
  the devtools bundle (`?z2ui5-bundle=devtools`, loaded on the first Ctrl+F12); do not move a module across that line
  without `tools/app2abap/trans2abap.js` (`DEVTOOLS_EAGER`), which refuses a shell module depending on a bundled one.
  How a developer starts the tools (Ctrl+F12, `?z2ui5-devtools=1`, `?z2ui5-devtools=<KEY>`, "Open on Error") is
  section 10 of `docs/agents/building-apps.md`.
- **The custom controls are a bundle of their own** (`?z2ui5-bundle=cc`, loaded by `core/CustomControls.js` before
  the first view that names one is built) — nothing outside `bundle/webapp/cc/` may name a control as a
  `sap.ui.define` dependency (`trans2abap.js` refuses it), and no control moves back into the frontend bundle
  because one app needs it at start. Details: `bundle/AGENTS.md`, rule 2.
- **No app base class and no lifecycle hooks on `z2ui5_if_app`**; the repeated dispatcher is not duplication.
- **No named frontend-action wrappers on `z2ui5_if_client`** — `follow_up_action` stays the only API.
- **Embedding as a reuse component goes as far as demand asked** — do not re-propose the rest as cleanup.
- **`z2ui5_cl_xml_view` is not extended, refactored or split**, and its size is not a finding — it is frozen, and
  since 2026-11-17 it is not in this repository at all.
