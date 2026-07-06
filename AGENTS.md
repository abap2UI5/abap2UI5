# AGENTS.md — AI Assistant Guide for abap2UI5

> This file follows the cross-tool AGENTS.md convention. `CLAUDE.md` is a
> pointer to this file so Claude Code picks it up automatically.

## Project Overview

abap2UI5 is a framework for building SAP UI5 applications purely in ABAP — no JavaScript, OData, or RAP required. It supports all ABAP releases from NW 7.02 to ABAP Cloud, running in both on-premise and cloud environments.

**Current version:** 1.142.0 (defined in `src/02/z2ui5_if_app.intf.abap`)
**License:** MIT
**Homepage:** https://abap2UI5.org
**Language:** English — all code, comments, commit messages, PRs, issues, documentation, and communication must be in English.

### Related Repositories

| Repository | Purpose |
|---|---|
| [abap2UI5](https://github.com/abap2UI5/abap2UI5) | Core framework (this repo) |
| [samples](https://github.com/abap2UI5/samples) | Sample applications and usage examples |
| [docs](https://github.com/abap2UI5/docs) | Project documentation |

> **Building apps?** This file is the briefing for AI assistants working **on the framework itself**. For everything an AI needs to **build apps with** abap2UI5 — app template, client API, view-building patterns, lifecycle, deprecated controls — see the single canonical guide at <https://abap2ui5.github.io/docs/advanced/agent.html>.

## Architecture

### How It Works — The Roundtrip

abap2UI5 is a **stateful SPA** (Single Page Application). The browser loads a UI5 shell once via HTTP GET, then communicates with the ABAP backend exclusively via HTTP POST/JSON roundtrips:

```
Browser (UI5 SPA)                          ABAP Backend
       │                                        │
       │──── HTTP GET ─────────────────────────→│  Returns HTML + embedded UI5 app
       │←─── HTML page ────────────────────────│
       │                                        │
       │──── POST {S_FRONT, XX model} ────────→│  1. Parse JSON request
       │                                        │  2. Load draft (session) from DB
       │                                        │  3. Apply model changes (XX → ABAP vars)
       │                                        │  4. Call app->main(client)
       │                                        │  5. App builds view / handles events
       │                                        │  6. Save new draft to DB
       │←─── {S_FRONT, MODEL, VIEW XML} ──────│  7. Return JSON response
       │                                        │
       │  (UI5 renders XML view, binds model)   │
       │──── POST (next event) ───────────────→│  ... repeat
```

**Request JSON** contains `S_FRONT` (event name, draft ID, browser state) and `XX` (two-way binding changes as deltas).
**Response JSON** contains a new draft ID, view XML strings (if view changed), the full JSON model, messages, and follow-up actions.

#### Launchpad Special Case — Request Body Wrapping

The frontend always sends the POST body as `{ "value": <payload> }` (see `app/webapp/core/Server.js`). In standalone mode this envelope arrives intact and `request_parse_body` unwraps it via `slice('value')`.

When the app runs inside the **SAP Fiori Launchpad** (FLP), requests may be routed through the FLP shell or an SAP Gateway proxy. In certain configurations this infrastructure strips the `value` envelope before the request reaches the ABAP ICF handler, so the payload arrives as a plain object without the `value` key.

`request_parse_body` handles both cases defensively:
```abap
DATA(lo_ajson2) = lo_ajson->slice( `value` ).
IF lo_ajson2 IS BOUND.
  lo_ajson = lo_ajson2.   " standalone: unwrap the value envelope
ENDIF.
" launchpad/gateway: no value key → use lo_ajson as-is
```

The Launchpad context is detected afterwards from the parsed request fields:
```abap
result-s_control-check_launchpad = xsdbool(
    result-s_front-search   CS `scenario=LAUNCHPAD`
    OR result-s_front-pathname CS `/ui2/flp`
    OR result-s_front-pathname CS `test/flpSandbox` ).
```

Both scenarios are covered by unit tests in `z2ui5_cl_core_handler.clas.testclasses.abap` (`test_parse_body_with_wrapper` / `test_parse_body_without_wrapper`).

### Layered Design

```
src/
├── 00/   Layer 0: Utilities (AJSON, S-RTTI, general utils) — mirrored from external projects, DO NOT MODIFY
├── 01/   Layer 1: Core engine (handler, action, binding, model, events, draft service, embedded frontend)
└── 02/   Layer 2: Public API (interfaces, XML view builder, HTTP handler, exit framework, built-in popups)
```

- **Layer 0 (`src/00/`)** — Self-contained utility libraries. AJSON handles JSON; S-RTTI provides runtime type reflection. General utilities in `src/00/03/` (HTTP, logging, messaging, ranges, XML builder). The `noIssues` flag in `abaplint.jsonc` suppresses lint warnings here.
- **Layer 1 (`src/01/`)** — Core engine. Session drafts (`src/01/01/`), request processing, event routing, data binding, model management, app lifecycle (`src/01/02/`). Embedded UI5 frontend resources as ABAP string constants (`src/01/03/` — auto-generated, never manually edit).
- **Layer 2 (`src/02/`)** — Public API. The stable contract for app developers. Includes built-in popup/dialog apps (`src/02/01/`) and the exit/customization framework.

### Data Binding

The framework provides **transparent two-way data binding** between ABAP variables and UI5 controls:

| Method | Path Format | Direction | Use Case |
|---|---|---|---|
| `client->_bind_edit(var)` | `{/XX/attribute}` | ABAP ↔ UI (two-way) | Input fields, editable data |
| `client->_bind(var)` | `{/attribute}` | ABAP → UI (read-only) | Display fields, labels |

**How it works:**
1. When you call `_bind_edit(name)`, the framework discovers the ABAP attribute via RTTI and maps it to a UI5 model path `/XX/name`
2. On outbound (ABAP → browser): all bound attributes are serialized to JSON and sent as `MODEL`
3. On inbound (browser → ABAP): only `/XX/` prefixed attributes (two-way) are read back from the request and written into the ABAP variables
4. Table bindings use **delta updates** — only changed rows/cells are transferred

### Session Persistence (Draft Service)

App state is persisted between roundtrips via the draft service (`z2ui5_cl_core_srv_draft`):
- **Table `Z2UI5_T_01`** stores serialized app state (XML) keyed by UUID
- Each roundtrip: load draft → restore app → call `main()` → save new draft with new UUID
- Draft IDs chain via `id_prev` for back-navigation through the app stack
- In-memory buffer cache avoids repeated DB reads within one request

### Key Design Patterns

- **Factory:** `z2ui5_cl_http_handler=>factory()` / `factory_cloud()` for on-premise vs. cloud
- **Fluent Builder:** `z2ui5_cl_xml_view=>factory()->shell()->page()->...->stringify()` builds XML views
- **Generic XML Builder:** `z2ui5_cl_util_xml=>factory()` builds any XML view (see below)
- **Event Routing:** `client->_event('ID')` registers; `client->check_on_event('ID')` checks
- **App Navigation:** `client->nav_app_call(app)` pushes; `client->nav_app_leave()` pops (executed in a loop within one roundtrip)
- **Multi-View:** Main view, nested views (nest/nest2), popups, and popovers simultaneously
- **Exit Pattern:** `z2ui5_cl_exit` / `z2ui5_if_exit` for custom themes, CSP headers, etc.

### Building Apps

App-building guidance (view builder choice, deprecated controls, lifecycle patterns, canonical app template, client API) lives exclusively at <https://abap2ui5.github.io/docs/advanced/agent.html>. Do not duplicate it here.

## Repository Structure

```
src/
├── 00/                        # Layer 0: Utilities (DO NOT MODIFY)
│   ├── 01/                    #   AJSON — JSON serialization
│   ├── 02/                    #   S-RTTI — Runtime type information
│   └── 03/                    #   General utilities (z2ui5_cl_util, _http, _log, _msg, _range, _xml)
├── 01/                        # Layer 1: Core Engine
│   ├── 01/                    #   Draft service (z2ui5_cl_core_srv_draft + z2ui5_t_01)
│   ├── 02/                    #   Core classes (handler, client, action, app, srv_bind, srv_event, srv_model)
│   └── 03/                    #   Embedded UI5 frontend (auto-generated, DO NOT EDIT)
└── 02/                        # Layer 2: Public API
    ├── z2ui5_if_app.intf.abap          # Main app interface (version constant)
    ├── z2ui5_if_client.intf.abap       # Client interaction methods
    ├── z2ui5_if_types.intf.abap        # Shared type definitions
    ├── z2ui5_if_exit.intf.abap         # Customization exit points
    ├── z2ui5_cl_http_handler.clas.abap # HTTP entry point
    ├── z2ui5_cl_xml_view.clas.abap     # Fluent XML view builder (~511KB)
    ├── z2ui5_cl_xml_view_cc.clas.abap  # Custom controls builder
    ├── z2ui5_cl_exit.clas.abap         # Default exit implementation
    ├── z2ui5_cl_app_startup.clas.abap  # Default startup app
    ├── z2ui5_cl_app_hello_world.clas.abap # Hello world example app
    └── 01/                             # Built-in popups (z2ui5_cl_pop_*)
        # to_confirm, to_inform, to_select, file_dl, file_ul, table, textedit,
        # pdf, html, messages, error, bal, input_val, data, image_editor,
        # js_loader, get_range, get_range_m
```

### Additional Directories

| Directory | Purpose |
|---|---|
| `app/` | Frontend tooling (`package.json`, `ui5.yaml`, `eslint.config.mjs`, `.prettierrc`, `.editorconfig`) |
| `app/webapp/` | UI5 frontend source — `Component.js`, `index.html`, `manifest.json`, `controller/`, `view/`, `model/`, `css/`, `Util.js` (the **public** date helpers exposed as the `z2ui5.Util` global), `cc/` with one file per custom control (`Timer.js`, `Scrolling.js`, … — module IDs `z2ui5/cc/<Name>`, resolved from the `z2ui5` XML namespace which maps to `z2ui5.cc`), and `core/` with the internals: `Server.js` (the JSON POST client that wraps the body as `{ "value": <payload> }`), `AppState.js` (owner of the shared frontend state + the documented inventory of all `z2ui5.*` globals), `ViewSlots.js` (access layer for the five view slots — lookups, byId resolution and teardown), `Lib.js` (shared helper module), `FrontendAction.js` (the handlers behind the controller's `eF()` entry point), `Messages.js` (S_MSG_TOAST / S_MSG_BOX display), `ErrorView.js` (the fatal-error overlay) and `DebugTool` |
| `node/srv/` | `express.mjs` (dev server on port 3000), `zcl_sicf.clas.abap` (reference ICF handler impl — ~15 lines; real apps follow the same pattern) |
| `node/setup/` | `abap_transpile.json` (transpiler config), `setup.mjs` (SQLite bootstrap for Node unit tests) |
| `node/tests/` | Playwright tests — browser tests in `e2e/` (`example.spec.js` shell smoke test, `roundtrip.spec.js` POST/draft wire contract, `lib-sanitizer.spec.js` XSS regression tests for `Lib.sanitizeMessageDetails`, `error-view.spec.js` fatal-error overlay accessibility/focus/Retry tests; run via `node/playwright.config.js` against the dev server), plus unit specs (`buildDeltaFromPaths.spec.js`, `utilHelpers.spec.js`, `appState.spec.js`, `viewSlots.spec.js`, `uiTableExt.spec.js`, `messages.spec.js`, `util.spec.js`, `serverTimeout.spec.js`, `serverClosestElement.spec.js`) that load the **real** `app/webapp` modules via `loadModule.js` (stubbed `sap.ui.define`, stubbable dependencies); run them without a browser via `npx playwright test -c node/playwright-unit.config.js` (the unit config ignores `e2e/`) |
| `node/tests-examples/` | Playwright example specs and performance benchmarks (reference material, not run in CI) — `modelUpdate.bench.spec.js` measures the model-update strategies and documents its own setup; run via `node/playwright-bench.config.js` |
| `.github/workflows/` | 16 CI/CD workflows (see below) |
| `.github/scripts/` | `ui5lint-gate.mjs` — baseline gate for the UI5 linter (fails CI only when new errors are introduced; lower its `MAX_ERRORS` when findings are fixed) |
| `.github/abaplint/` | Target-specific abaplint configs: `abap_702.jsonc`, `abap_standard.jsonc`, `abap_cloud.jsonc`, `auto_abaplint_fix.jsonc`, `rename_test.jsonc` |
| `.github/app2abap/` | `trans2abap.js` — converts `app/webapp/*` files into embedded ABAP string constants in `src/01/03/` |
| `.github/cleaner-profile.cfj` | ABAP Cleaner profile (SAP ABAP Cleaner tool configuration for automated code cleanup) |

### Root Files

| File | Purpose |
|---|---|
| `README.md` | Project intro, badges, quick start, references |
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

Grouped by purpose:

| Group | Workflows | Purpose |
|---|---|---|
| **Compatibility checks** | `ABAP_702.yaml`, `ABAP_STANDARD.yaml`, `ABAP_CLOUD.yaml` | Lint against each ABAP target environment |
| **Frontend checks** | `UI5.yaml` | UI5 linter, gated on a fixed error baseline via `.github/scripts/ui5lint-gate.mjs` |
| **Tests** | `test_unit.yaml`, `test_node.yaml`, `test_browser.yaml`, `test_rename.yaml` | Unit tests, Node transpile tests, JS unit specs + Playwright browser tests, namespace-rename test |
| **Automation** | `auto_downport.yaml`, `auto_abaplint_fix.yaml`, `auto_abaplint_fix_pr.yaml` | Scheduled downporting and auto-formatting (open PRs) |
| **Generation** | `create_app2abap.yaml`, `create_frontend.yaml` | Regenerate `src/01/03/` from `app/webapp/` |
| **Mirroring** | `mirror_ajson.yaml`, `mirror_srtti.yaml` | Sync `src/00/01/` (AJSON) and `src/00/02/` (S-RTTI) from upstream repos |
| **Downstream sync** | `trigger_local.yaml` | On every push to `main`, dispatch the `update_input` workflow in [abap2UI5-local](https://github.com/abap2UI5/abap2UI5-local) so its `input/` copy and artifact branches follow this repo (needs secret `ACTION_TOKEN_LOCAL`); `create_frontend.yaml` covers [frontend](https://github.com/abap2UI5/frontend) the same way |

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
- **Exception handling:** Use `cx_root` as catch-all; re-raise as `z2ui5_cx_util_error`; use `##NO_HANDLER` when intentionally ignoring
  ```abap
  CATCH cx_root INTO DATA(x).
    RAISE EXCEPTION TYPE z2ui5_cx_util_error EXPORTING val = x.

  CATCH cx_root ##NO_HANDLER.
  ```
- **API parameter types:** Use `TYPE clike` for string/char input parameters in public API methods (allows both string and char literals without conversion)
- **Utility access:** Always call utilities via the facade `z2ui5_cl_util` — it inherits everything from `z2ui5_cl_util_api`. Never reference `z2ui5_cl_util_api` (or its environment-specific implementations `z2ui5_cl_util_api_s` / `z2ui5_cl_util_api_c`) directly outside `src/00/`
  ```abap
  " good
  z2ui5_cl_util=>bal_read( ... ).
  " bad
  z2ui5_cl_util_api=>bal_read( ... ).
  ```

### Naming (enforced by abaplint)

- Classes: `Z2UI5_CL_*` or `Z2UI5_CX_*`
- Interfaces: `Z2UI5_IF_*`
- Allowed object types: `CLAS`, `DEVC`, `INTF`, `TABL` only

### Style Rules

- Max 100 statements per method, max cyclomatic complexity 20, max nesting depth 5
- No aliases, no STATICS, no BREAK-POINT, no DEFINE macros
- `NEW #()` instead of `CREATE OBJECT`; `xsdbool()` for booleans (NEVER use `boolc()` — the downport pipeline converts `xsdbool` to `boolc` automatically); `line_exists()` instead of READ TABLE
- Backtick string literals (`` ` ``) preferred over single quotes
- `IS NOT` over `NOT ... IS`; `RETURNING` over `EXPORTING` for single outputs
- No `EXPORT TO MEMORY`/`DATABASE`; no test seams; `lines()` instead of `DESCRIBE LINES`
- No DB operations in loops; SQL uses `@` host variable escaping
- No Yoda conditions
- `forbidden_void_type` blocks SAP standard types — use `abap_bool`, `i`, `string` etc.

## Build & Validation

Install dependencies: `npm install`

### Validation sequence (run before every PR)

```bash
npx abaplint                  # Lint check (primary quality gate)
npm run auto_downport         # Downport for 7.02 compatibility
npm run auto_transpile        # Transpile ABAP → JS
npm run unit                  # Unit tests
```

### Other commands

| Command | Purpose |
|---|---|
| `npx abaplint .github/abaplint/auto_abaplint_fix.jsonc --fix` | Auto-fix formatting |
| `npm run express` | Start dev server on port 3000 |
| `npm run app2abap` | **Canonical** full regeneration pipeline: Prettier (`app` format) → generate → abaplint normalize. Use this after editing `app/webapp/` so only truly-changed `src/01/03/` files differ |
| `npm run auto_app2abap` | Generate ABAP string constants from `app/webapp/` (raw, **un-normalized** — prefer `npm run app2abap` instead) |
| `npm run auto_abaplint` | Run the auto-fix config directly |
| `npm run rename` | Test namespace-rename transformation via abaplint |
| `npm run syfixes` | Replace `RAISE EXCEPTION TYPE cx_sy_itab_line_not_found` with `ASSERT 1 = 0` (compatibility step for 7.02 downport) |
| `npm run abaplintpathfix` | Rewrite abaplint file globs in `abaplint.jsonc` after downport copy |

### Frontend Tooling (`app/`)

The `app/` folder has its own `package.json` (name `z2ui5`, `sapuxLayer: CUSTOMER_BASE`) with UI5-specific dev dependencies (`@ui5/cli`, `@ui5/linter`, `@sap/ui5-builder-webide-extension`, `@sap/ux-ui5-tooling`, `eslint`, `prettier`, `mbt`, `rimraf`). Key scripts:

| Script (run inside `app/`) | Purpose |
|---|---|
| `npm start` / `npm run start-local` | Run locally via Fiori tools with FLP sandbox |
| `npm run build` | UI5 production build |
| `npm run format` / `format:check` | Prettier |
| `npm run lint` | ESLint on `webapp/**/*.js` (eslint:recommended + `eqeqeq` "smart", `prefer-const`, `no-new-func`) |
| `npm run deploy` / `build:cf` / `build:mta` | Cloud Foundry / MTA deployment |

Config files: `eslint.config.mjs`, `.prettierrc`, `.editorconfig`, `ui5.yaml`, `ui5-local.yaml`, `ui5-mock.yaml`.

### Testing

- **Unit tests:** Embedded in source files as `.testclasses.abap` (46 files as of v1.142.0), run via abaplint transpiler in Node.js
- **Browser tests:** Playwright in `node/tests/e2e/` — Chromium, Firefox, WebKit against localhost:3000 (config: `node/playwright.config.js`; run in CI by `test_browser.yaml` after downport + transpile). Covers the POST/draft wire contract (`roundtrip.spec.js`), XSS regression tests for `Lib.sanitizeMessageDetails` in a real DOM (`lib-sanitizer.spec.js`), the fatal-error overlay (`error-view.spec.js` — accessibility semantics, focus management, Retry action) and the shell smoke test (`example.spec.js`). Note: the transpiled Node backend currently never returns backend-built view XML — interface attributes read through an interface-typed reference resolve to a missing JS property in the transpiler output, so `check_on_init( )` is always false there; extend the roundtrip tests with view-rendering assertions once that upstream `@abaplint/transpiler` issue is fixed
- **JS unit specs:** the specs under `node/tests/` load the **real** `app/webapp` modules through a stubbed `sap.ui.define` (`loadModule.js`, with stubbable module dependencies) — never test a copied function. Covered: `core/Lib.js` (`buildDeltaFromPaths.spec.js`, `utilHelpers.spec.js`), `core/AppState.js` (`appState.spec.js`), `core/ViewSlots.js` (`viewSlots.spec.js`), `cc/UITableExt.js` (`uiTableExt.spec.js`), `core/Messages.js` (`messages.spec.js`), `core/Server.js` timeout handling (`serverTimeout.spec.js`) and UI5-element resolution incl. the pre-1.106 fallback for scroll/focus capture (`serverClosestElement.spec.js`), the public `Util.js` date helpers (`util.spec.js`). Run without a browser: `npx playwright test -c node/playwright-unit.config.js`
- **Unit test metadata:** When a class has a `.testclasses.abap` file, its `.clas.xml` **must** contain `<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>`. When a class has no test file, this flag **must not** be present. Mismatches cause `local_testclass_consistency` lint errors.
- **Test SICF handler:** `node/srv/zcl_sicf.clas.abap` is copied into `node/downport/` during `auto_transpile` so the Node runtime has a minimal HTTP entry point.

## Key Files

**Must-know files (start here):**

| File | Why |
|---|---|
| `src/02/z2ui5_if_app.intf.abap` | Main app interface + version constant |
| `src/02/z2ui5_if_client.intf.abap` | All client methods (view, events, binding, navigation) |
| `src/02/z2ui5_cl_xml_view.clas.abap` | Fluent view builder (~511KB) — read only sections you need |
| `src/01/02/z2ui5_cl_core_handler.clas.abap` | Central request processor + main loop |
| `src/01/02/z2ui5_cl_core_client.clas.abap` | Implements z2ui5_if_client |
| `abaplint.jsonc` | Linter rules — source of truth for code standards |

**Reference files (consult as needed):**

| File | Why |
|---|---|
| `src/02/z2ui5_if_types.intf.abap` | Shared type definitions |
| `src/02/z2ui5_if_exit.intf.abap` | Customization exit points |
| `src/02/z2ui5_cl_exit.clas.abap` | Default exit + user-exit class support |
| `src/01/02/z2ui5_cl_core_action.clas.abap` | Event/action dispatcher |
| `src/01/02/z2ui5_cl_core_app.clas.abap` | App lifecycle (create, load, serialize) |
| `src/01/02/z2ui5_cl_core_srv_bind.clas.abap` | Data binding engine |
| `src/01/02/z2ui5_cl_core_srv_model.clas.abap` | JSON model management |
| `src/01/02/z2ui5_cl_core_srv_event.clas.abap` | Event registration and payload assembly |
| `src/01/01/z2ui5_cl_core_srv_draft.clas.abap` | Draft/session persistence |
| `src/00/03/z2ui5_cl_util.clas.abap` | General utility class |
| `src/00/03/z2ui5_cl_util_xml.clas.abap` | Generic XML builder (preferred for new code) |
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

## Important Rules for AI Assistants

These rules apply to AI assistants **modifying the framework** (this repo). For AI assistants **building apps**, see <https://abap2ui5.github.io/docs/advanced/agent.html> instead.

1. **Do not modify `src/00/`** — mirrored from external projects, synced by automated workflows.
2. **NEVER manually edit any ABAP file under `src/01/03/`.** These files are the embedded frontend (auto-generated from `app/webapp/` via the `app2abap` job — see `.github/app2abap/trans2abap.js` and the `create_app2abap.yaml` workflow). The **only** allowed way to update them is:
   - Change the source under `app/webapp/`
   - Run **`npm run app2abap`** locally (or trigger the `create_app2abap.yaml` workflow). This single command runs the full pipeline in the correct order — `npm --prefix app run format` (Prettier) → `npm run auto_app2abap` (generate) → `npm run auto_abaplint` (normalize) — exactly as CI does. Running `auto_app2abap` on its own produces **un-normalized** ABAP that differs from the committed form in *every* `src/01/03/` file (alignment/whitespace drift); the `auto_abaplint` step reverts that drift so only the files whose `app/webapp/` source actually changed remain modified.
   - Commit the regenerated `src/01/03/` files as the job produced them
   - The `sap.ui.require.preload` mapping is **also generated**: `trans2abap.js` emits `z2ui5_cl_app_preload`, which `z2ui5_cl_http_handler` consumes. New files under `app/webapp/` are picked up automatically — never reintroduce a manually maintained preload list in the HTTP handler.
   Direct edits to `src/01/03/*.abap` are forbidden — no manual tweaks, no "small fixes", no formatting changes, nothing. The job may be invoked, but the files must never be touched by hand or by any other means.
   - **Prettier governs all of `app/webapp/`** — do not add `// prettier-ignore` directives. Since every custom control lives in its own file, a header reflow only touches that control's small generated constant; just let `npm run app2abap` format and regenerate.
3. **Always run `npx abaplint`** before considering changes complete.
4. **Multi-environment compatibility** — code must work on NW 7.02, standard ABAP, and ABAP Cloud.
5. **The public API (`src/02/`) is a stable contract — never change or remove existing public attributes, methods, or constants.** This folder is consumed directly by thousands of downstream apps. Specifically:
   - Do not rename, remove, or change the signature of any method in `z2ui5_if_client`, `z2ui5_if_app`, `z2ui5_if_types`, or `z2ui5_if_exit`
   - Do not remove or rename public `DATA`, `CONSTANTS`, or `TYPES` in any `src/02/` class or interface
   - Do not change the type or default value of existing parameters in any public method
   - Additive changes are allowed (new methods, new optional parameters, new constants)
   - When in doubt, add rather than change
6. **String literals use backticks** (`` ` ``), not single quotes.
7. **The `z2ui5_cl_xml_view` class has a `method_overwrites_builtin` exception** — its fluent methods intentionally match UI5 control names.
8. **Frontend public contracts** — besides `src/02/`, the following frontend names are consumed by backend-generated views and existing apps and must not be renamed: the module IDs `z2ui5/cc/<Name>` of the custom controls (file location under `webapp/cc/` defines the ID; the `z2ui5` XML namespace maps to `z2ui5.cc` in `z2ui5_cl_xml_view`), their properties/events used by `z2ui5_cl_xml_view_cc`, the controller methods `eB`/`eF`, the `z2ui5/Util` module and the `z2ui5.Util` global (public date helpers). Additive changes only. Raw view XML written by apps must declare `xmlns:z2ui5="z2ui5.cc"` (changed from `"z2ui5"` when the controls moved into `cc/`).
9. **Shared frontend helpers live in `app/webapp/core/Lib.js`** — shared or pure/testable logic goes there (pure helpers are unit-tested in Node via `node/tests/loadLibModule.js`); helpers with a single consumer stay in that module. **Shared frontend state is owned by `app/webapp/core/AppState.js`** — it documents the complete inventory of the `z2ui5.*` globals (public contract vs. internal fields), provides the defaults for all internal fields and exposes them on the global via transitional accessors. Do not add new lazy `if (!z2ui5.x)` bootstrapping; add the field with its default to `AppState.createState()` instead.
10. **`npm run auto_downport` rewrites `src/` in place** (and overwrites `abaplint.jsonc`) — it is meant for throwaway CI checkouts. When running the validation sequence locally, commit your work first and restore afterwards with `git checkout -- src/ abaplint.jsonc`.

## Design Decisions & Known Non-Issues

The following items may look like gaps but are intentional design choices:

- **Draft table `Z2UI5_T_01` has no version column** — Drafts are session-scoped (deleted after a few hours). There is no long-lived state that needs schema migration. Versioning would add complexity with no benefit.
- **Changelog** — The project maintains a `changelog.txt` in the repository root. A `CHANGELOG.md` is not needed separately.
- **`z2ui5_cl_xml_view` size (~11K lines)** — This class is intentionally large: each method wraps one UI5 control for the fluent API. Both this builder and `z2ui5_cl_util_xml` are supported equally; do not add new wrapper methods.
