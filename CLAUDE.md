# CLAUDE.md — AI Assistant Guide for abap2UI5

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
| [abap2UI5-samples](https://github.com/abap2UI5/abap2UI5-samples) | Sample applications and usage examples |
| [abap2UI5-documentation](https://github.com/abap2UI5/abap2UI5-documentation) | Project documentation |

> **Building apps?** See the [abap2UI5-samples](https://github.com/abap2UI5/abap2UI5-samples) repository — it contains the app development guide (CLAUDE.md), canonical app template, Client API reference, and 250+ example apps to learn from.

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

The frontend always sends the POST body as `{ "value": <payload> }` (see `app/webapp/cc/Server.js`). In standalone mode this envelope arrives intact and `request_parse_body` unwraps it via `slice('value')`.

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

### Building Views with the Full UI5 API — `z2ui5_cl_util_xml`

`z2ui5_cl_util_xml` (`src/00/03/`) is a generic XML builder. Because it takes any element name and attributes as strings, **the entire UI5 control library is immediately available** — no wrapper methods needed, no waiting for new releases.

**The pattern for AI assistants:** look up any control at https://ui5.sap.com/#/api, then translate the XML view example 1:1 to ABAP:

| UI5 XML view | ABAP with `z2ui5_cl_util_xml` |
|---|---|
| `<Button text="Send" />` | `->__( n=\`Button\` a=\`text\` v=\`Send\` )` |
| `press="onPress"` | `v = client->_event( \`BUTTON_POST\` )` |
| `value="{/name}"` | `v = client->_bind_edit( name )` |
| `<FeedInput><actions>...</actions></FeedInput>` | `->_( \`FeedInput\` )->_( \`actions\` )->__( ... )` |

**Builder methods:**
- `_( n=\`Name\` ns=\`ns\` a=\`attr\` v=\`val\` p=... )` — add child, **return child** (go deeper)
- `__( n=\`Name\` ... )` — add child, **return self** (stay at same level / leaf node)
- `p( n=\`attr\` v=\`val\` )` — add attribute to current node
- `n( \`Name\` )` / `n( )` — navigate to named ancestor / parent
- `stringify( indent=abap_true )` — serialize to XML string

**Important:** always pass `'true'` or `'false'` as string literals — never use `abap_true` or `abap_false` for XML attribute values. `abap_false` (space) is filtered out and the attribute would be silently dropped; `abap_true` ('X') is not converted and would produce an invalid attribute value.

**Complete example:**
```abap
METHOD z2ui5_if_app~main.
  CASE abap_true.
    WHEN client->check_on_init( ).
      DATA(lo_view) = z2ui5_cl_util_xml=>factory(
        )->_( n = `View`  ns = `mvc`
              p = VALUE #( ( n = `xmlns:mvc` v = `sap.ui.core.mvc` )
                           ( n = `xmlns`     v = `sap.m` ) )
        )->_( `Page`  a = `title`  v = `Hello`
        )->__( n = `Input`   a = `value` v = client->_bind_edit( name )
        )->__( n = `Button`
               p = VALUE #( ( n = `text`  v = `Send` )
                            ( n = `press` v = client->_event( `POST` ) ) ) ).
      client->view_display( lo_view->stringify( ) ).
    WHEN client->check_on_event( `POST` ).
      client->message_box_display( name ).
  ENDCASE.
ENDMETHOD.
```

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
| `app/webapp/` | UI5 frontend source — `Component.js`, `index.html`, `manifest.json`, `controller/`, `view/`, `model/`, `css/`, `cc/` (custom controls incl. `Server.js` — the JSON POST client that wraps the body as `{ "value": <payload> }`) |
| `node/srv/` | `express.mjs` (dev server on port 3000), `zcl_sicf.clas.abap` (reference ICF handler impl — ~15 lines; real apps follow the same pattern) |
| `node/setup/` | `abap_transpile.json` (transpiler config), `setup.mjs` (SQLite bootstrap for Node unit tests) |
| `node/tests/` | Playwright browser tests — `example.spec.js`, `buildDeltaFromPaths.spec.js` |
| `node/tests-examples/` | Playwright example specs (reference material, not run in CI) |
| `.github/workflows/` | 17 CI/CD workflows (see below) |
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
| **Frontend checks** | `UI5.yaml`, `check_app.yaml`, `check_frontend.yaml` | UI5 linter + frontend integrity checks |
| **Tests** | `test_unit.yaml`, `test_node.yaml`, `test_browser.yaml`, `test_rename.yaml` | Unit tests, Node transpile tests, Playwright browser tests, namespace-rename test |
| **Automation** | `auto_downport.yaml`, `auto_abaplint_fix.yaml`, `auto_abaplint_fix_pr.yaml` | Scheduled downporting and auto-formatting (open PRs) |
| **Generation** | `create_app2abap.yaml`, `create_frontend.yaml` | Regenerate `src/01/03/` from `app/webapp/` |
| **Mirroring** | `mirror_ajson.yaml`, `mirror_srtti.yaml` | Sync `src/00/01/` (AJSON) and `src/00/02/` (S-RTTI) from upstream repos |

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
- **Exception handling:** Use `cx_root` as catch-all; re-raise as `z2ui5_cx_util_error`; use `##NO_HANDLER` when intentionally ignoring
  ```abap
  CATCH cx_root INTO DATA(x).
    RAISE EXCEPTION TYPE z2ui5_cx_util_error EXPORTING val = x.

  CATCH cx_root ##NO_HANDLER.
  ```
- **API parameter types:** Use `TYPE clike` for string/char input parameters in public API methods (allows both string and char literals without conversion)

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
| `npm run auto_app2abap` | Convert `app/webapp/` frontend files into ABAP string constants in `src/01/03/` |
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
| `npm run lint` | ESLint on `webapp/**/*.js` |
| `npm run unit-tests` / `int-tests` | QUnit / OPA test runners |
| `npm run deploy` / `build:cf` / `build:mta` | Cloud Foundry / MTA deployment |

Config files: `eslint.config.mjs`, `.prettierrc`, `.editorconfig`, `ui5.yaml`, `ui5-local.yaml`, `ui5-mock.yaml`.

### Testing

- **Unit tests:** Embedded in source files as `.testclasses.abap` (46 files as of v1.142.0), run via abaplint transpiler in Node.js
- **Browser tests:** Playwright in `node/tests/` — Chromium, Firefox, WebKit against localhost:3000 (config: `node/playwright.config.js`; unit variant: `node/playwright-unit.config.js`)
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

## Commit Message Style

Concise, capitalized or lowercase first word. Conventional commits preferred:

```
feat: add new control method for FlexibleColumnLayout
fix: correct binding path for nested table structures
refactor: extract methods in core handler
test: add unit tests for utility class
```

## Important Rules for AI Assistants

1. **Do not modify `src/00/`** — mirrored from external projects, synced by automated workflows.
2. **Never manually edit `src/01/03/`** — auto-generated from `app/webapp/` via `auto_app2abap`.
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
8. **Use built-in popups** (`src/02/01/z2ui5_cl_pop_*`) rather than building custom ones.
9. **`z2ui5_if_client` constants**: `cs_event` has predefined client events (`popup_close`, `download_b64_file`, `location_reload`); `cs_view` has view type IDs.
10. **Building views — two APIs exist, use `z2ui5_cl_util_xml` for new code:**
    - **`z2ui5_cl_util_xml`** (`src/00/03/`) — generic XML builder, **preferred for all new code**. Accepts any element name and attributes as strings, giving immediate access to the full UI5 control library. See the "Building Views with the Full UI5 API" section above.
    - **`z2ui5_cl_xml_view`** (`src/02/`) — fluent builder with one ABAP method per UI5 control (~11K lines, ~446 methods). This is **legacy/maintenance-only**: do not add new wrapper methods. Existing apps using it continue to work; new code should use `z2ui5_cl_util_xml` instead.

## Design Decisions & Known Non-Issues

The following items may look like gaps but are intentional design choices:

- **Draft table `Z2UI5_T_01` has no version column** — Drafts are session-scoped (deleted after a few hours). There is no long-lived state that needs schema migration. Versioning would add complexity with no benefit.
- **Changelog** — The project maintains a `changelog.txt` in the repository root. A `CHANGELOG.md` is not needed separately.
- **`z2ui5_cl_xml_view` size (~11K lines)** — This class is intentionally large: each method wraps one UI5 control for the fluent API. It is in maintenance mode; new controls should be accessed via `z2ui5_cl_util_xml` instead.
