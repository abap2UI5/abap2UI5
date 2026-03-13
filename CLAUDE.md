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
- **Event Routing:** `client->_event('ID')` registers; `client->check_on_event('ID')` checks
- **App Navigation:** `client->nav_app_call(app)` pushes; `client->nav_app_leave()` pops (executed in a loop within one roundtrip)
- **Multi-View:** Main view, nested views (nest/nest2), popups, and popovers simultaneously
- **Exit Pattern:** `z2ui5_cl_exit` / `z2ui5_if_exit` for custom themes, CSP headers, etc.

## How Apps Work

Every abap2UI5 app implements `z2ui5_if_app` with a single `main()` method:

```abap
CLASS z2ui5_cl_my_app DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA name TYPE string.
ENDCLASS.

CLASS z2ui5_cl_my_app IMPLEMENTATION.
  METHOD z2ui5_if_app~main.
    CASE abap_true.
      WHEN client->check_on_init( ).
        client->view_display( z2ui5_cl_xml_view=>factory(
          )->shell( )->page( 'Title'
          )->input( client->_bind_edit( name )
          )->button( text = 'Send' press = client->_event( 'POST' )
          )->stringify( ) ).
      WHEN client->check_on_event( 'POST' ).
        client->message_box_display( |Hello { name }| ).
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
```

### Client API (`z2ui5_if_client`)

| Category | Methods | Purpose |
|---|---|---|
| Views | `view_display`, `view_destroy`, `view_model_update` | Main view lifecycle |
| Nested views | `nest_view_display/destroy/model_update`, `nest2_view_*` | Embedded sub-views |
| Popups | `popup_display`, `popup_destroy`, `popup_model_update` | Modal dialogs |
| Popovers | `popover_display`, `popover_destroy`, `popover_model_update` | Context popovers |
| Binding | `_bind(val)`, `_bind_edit(val)` | Read-only / two-way binding |
| Events | `_event(val)`, `_event_client(val)`, `check_on_event(val)` | Event registration and checking |
| Navigation | `nav_app_call(app)`, `nav_app_leave()`, `get_app_prev()` | App stack navigation |
| Lifecycle | `check_on_init()`, `check_on_navigated()`, `check_app_prev_stack()` | State checks |
| Messages | `message_box_display(text)`, `message_toast_display(text)` | User notifications |
| Session | `set_session_stateful(val)`, `set_app_state_active(val)` | Session management |
| Browser | `set_push_state(val)`, `set_nav_back(val)`, `follow_up_action(val)` | Browser interaction |
| Info | `get()`, `get_event_arg()`, `get_app(id)` | Request/context data |
| Constants | `cs_event`, `cs_view` | Predefined event IDs and view names |

## Common Tasks

### Adding a New UI5 Control to `z2ui5_cl_xml_view`

Every fluent method follows this pattern — add a new method to the class:

```abap
METHOD my_control.
  result = me.
  _generic( name   = `MyControl`
            ns     = ``
            t_prop = VALUE #( ( n = `text`    v = text )
                              ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                              ( n = `press`   v = press ) ) ).
ENDMETHOD.
```

Key rules:
- All parameters: `TYPE clike OPTIONAL`
- Return type: `REF TO z2ui5_cl_xml_view` (enables chaining)
- `_generic()` creates the XML node, adds it to the tree, returns the child for chaining
- Boolean properties: always convert via `z2ui5_cl_util=>boolean_abap_2_json()`
- `ns` parameter: empty for standard controls, specific namespace for others (e.g., `networkgraph`)

### Creating a New Popup App

Follow the pattern of `z2ui5_cl_pop_to_confirm`:

```abap
CLASS z2ui5_cl_pop_my_popup DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING i_text TYPE clike
      RETURNING VALUE(r_result) TYPE REF TO z2ui5_cl_pop_my_popup.

    METHODS result
      RETURNING VALUE(result) TYPE string.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    DATA mv_text TYPE string.
    METHODS view_display.
ENDCLASS.
```

Implementation essentials:
- `factory()` → creates instance, sets parameters, returns it
- `main()` → `check_on_init()` calls `view_display()`; event handlers call `client->popup_destroy()` then `client->nav_app_leave()`
- `view_display()` → uses `z2ui5_cl_xml_view=>factory_popup()` and ends with `client->popup_display( xml->stringify() )`
- Caller uses: `client->nav_app_call( z2ui5_cl_pop_my_popup=>factory( 'text' ) )`

### Adding Custom Controls to `z2ui5_cl_xml_view_cc`

Same as standard controls but:
- Always use namespace `z2ui5`: `mo_view->_generic( name = 'MyCC' ns = 'z2ui5' ... )`
- Methods return `REF TO z2ui5_cl_xml_view` (via `mo_view`)

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
        # confirm, inform, select, file_dl/ul, table, textedit, pdf, html,
        # messages, error, bal, input_val, data, image_editor, js_loader, get_range/_m
```

Additional directories:

| Directory | Purpose |
|---|---|
| `app/webapp/` | UI5 frontend (canonical source for JS/XML/CSS) |
| `node/` | Node.js transpilation, Express server, Playwright tests |
| `.github/workflows/` | 16 CI/CD workflows |
| `.github/abaplint/` | Linter configs per target environment |

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

- **Event routing:** Use `CASE abap_true / WHEN client->check_on_*()`  — not `IF/ELSEIF` chains
  ```abap
  CASE abap_true.
    WHEN client->check_on_init( ).
      " ...
    WHEN client->check_on_event( `BUTTON_POST` ).
      " ...
  ENDCASE.
  ```
- **Class definition:** Always add `FINAL` unless inheritance is explicitly needed
  ```abap
  CLASS z2ui5_cl_my_class DEFINITION PUBLIC FINAL CREATE PUBLIC.
  ```
- **Interface assignment:** Use `CAST` for interface-typed local variables
  ```abap
  DATA(li_client) = CAST z2ui5_if_client( NEW z2ui5_cl_core_client( mo_action ) ).
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
| `npm run auto_app2abap` | Convert `app/` frontend files into ABAP classes |

### Testing

- **Unit tests:** Embedded in source files as `.testclasses.abap` (~44 files), run via abaplint transpiler in Node.js
- **Browser tests:** Playwright in `node/tests/` — Chromium, Firefox, WebKit against localhost:3000
- **Unit test metadata:** When a class has a `.testclasses.abap` file, its `.clas.xml` **must** contain `<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>`. When a class has no test file, this flag **must not** be present. Mismatches cause `local_testclass_consistency` lint errors.

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
| `src/01/01/z2ui5_cl_core_srv_draft.clas.abap` | Draft/session persistence |
| `src/00/03/z2ui5_cl_util.clas.abap` | General utility class |

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
5. **The public API (`src/02/` interfaces) is a stable contract** — changes affect all downstream apps.
6. **String literals use backticks** (`` ` ``), not single quotes.
7. **The `z2ui5_cl_xml_view` class has a `method_overwrites_builtin` exception** — its fluent methods intentionally match UI5 control names.
8. **Use built-in popups** (`src/02/01/z2ui5_cl_pop_*`) rather than building custom ones.
9. **`z2ui5_if_client` constants**: `cs_event` has predefined client events (`popup_close`, `download_b64_file`, `location_reload`); `cs_view` has view type IDs.
