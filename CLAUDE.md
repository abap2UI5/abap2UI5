# CLAUDE.md — AI Assistant Guide for abap2UI5

## Project Overview

abap2UI5 is a framework for building SAP UI5 applications purely in ABAP — no JavaScript, OData, or RAP required. It supports all ABAP releases from NW 7.02 to ABAP Cloud, running in both on-premise and cloud environments.

**Current version:** 1.142.0 (defined in `src/02/z2ui5_if_app.intf.abap`)
**License:** MIT
**Homepage:** https://abap2UI5.org

## Repository Structure

```
abap2UI5/
├── src/                           # ABAP source code (primary codebase)
│   ├── 00/                        # Layer 0: Utilities & Infrastructure
│   │   ├── 01/                    #   AJSON — JSON serialization/deserialization
│   │   ├── 02/                    #   S-RTTI — Runtime type information / reflection
│   │   └── 03/                    #   General utilities
│   │       ├── z2ui5_cl_util.clas.abap      # Main utility class
│   │       ├── z2ui5_cl_util_http.clas.abap # HTTP utilities
│   │       ├── z2ui5_cl_util_log.clas.abap  # Logging
│   │       ├── z2ui5_cl_util_msg.clas.abap  # Messaging
│   │       ├── z2ui5_cl_util_range.clas.abap # Range utilities
│   │       ├── z2ui5_cx_util_error.clas.abap # Error exception class
│   │       ├── 01/                 #   DB & extension utils (z2ui5_cl_util_db, z2ui5_cl_util_ext)
│   │       └── 02/                 #   API utils (z2ui5_cl_util_api, _api_c, _api_s)
│   ├── 01/                        # Layer 1: Core Framework Engine
│   │   ├── 01/                    #   Draft service (z2ui5_cl_core_srv_draft + z2ui5_t_01 table)
│   │   ├── 02/                    #   Core engine classes
│   │   │   ├── z2ui5_cl_core_handler.clas.abap  # Central request processor
│   │   │   ├── z2ui5_cl_core_client.clas.abap   # Implements z2ui5_if_client
│   │   │   ├── z2ui5_cl_core_action.clas.abap   # Event/action dispatcher
│   │   │   ├── z2ui5_cl_core_app.clas.abap      # App lifecycle management
│   │   │   ├── z2ui5_cl_core_srv_bind.clas.abap # Data binding engine
│   │   │   ├── z2ui5_cl_core_srv_event.clas.abap # Event service
│   │   │   ├── z2ui5_cl_core_srv_model.clas.abap # Model service
│   │   │   ├── z2ui5_cl_core_srv_util.clas.abap  # Core utility service
│   │   │   └── z2ui5_if_core_types.intf.abap     # Internal type definitions
│   │   └── 03/                    #   Embedded UI5 app resources (JS/XML as ABAP classes)
│   └── 02/                        # Layer 2: Public API
│       ├── z2ui5_if_app.intf.abap          # Main app interface (implement this)
│       ├── z2ui5_if_client.intf.abap       # Client methods for UI interaction
│       ├── z2ui5_if_types.intf.abap        # Shared type definitions
│       ├── z2ui5_if_exit.intf.abap         # Customization exit points
│       ├── z2ui5_cl_http_handler.clas.abap # HTTP entry point
│       ├── z2ui5_cl_exit.clas.abap         # Default exit implementation + user-exit support
│       ├── z2ui5_cl_xml_view.clas.abap     # Fluent XML view builder (largest file)
│       ├── z2ui5_cl_xml_view_cc.clas.abap  # Custom controls builder
│       ├── z2ui5_cl_app_startup.clas.abap  # Startup app with UI5 version selector
│       ├── z2ui5_cl_app_hello_world.clas.abap # Reference example
│       └── 01/                     # Built-in popup/dialog apps
│           ├── z2ui5_cl_pop_bal.clas.abap          # Application log popup
│           ├── z2ui5_cl_pop_data.clas.abap         # Data display popup
│           ├── z2ui5_cl_pop_error.clas.abap        # Error display popup
│           ├── z2ui5_cl_pop_file_dl.clas.abap      # File download popup
│           ├── z2ui5_cl_pop_file_ul.clas.abap      # File upload popup
│           ├── z2ui5_cl_pop_get_range.clas.abap    # Range selection popup
│           ├── z2ui5_cl_pop_get_range_m.clas.abap  # Multi range selection popup
│           ├── z2ui5_cl_pop_html.clas.abap         # HTML display popup
│           ├── z2ui5_cl_pop_image_editor.clas.abap # Image editor popup
│           ├── z2ui5_cl_pop_input_val.clas.abap    # Input validation popup
│           ├── z2ui5_cl_pop_js_loader.clas.abap    # JavaScript loader popup
│           ├── z2ui5_cl_pop_messages.clas.abap     # Messages display popup
│           ├── z2ui5_cl_pop_pdf.clas.abap          # PDF display popup
│           ├── z2ui5_cl_pop_table.clas.abap        # Table display popup
│           ├── z2ui5_cl_pop_textedit.clas.abap     # Text editor popup
│           ├── z2ui5_cl_pop_to_confirm.clas.abap   # Confirmation dialog
│           ├── z2ui5_cl_pop_to_inform.clas.abap    # Information dialog
│           └── z2ui5_cl_pop_to_select.clas.abap    # Selection dialog
├── app/                           # UI5 webapp (Fiori frontend)
│   └── webapp/
│       ├── controller/            # JS controllers (App, View1)
│       ├── view/                  # XML views (App, View1)
│       ├── cc/                    # Custom controls (DebugTool, Server.js)
│       ├── model/                 # UI5 data models
│       ├── css/                   # Custom stylesheets (style.css)
│       ├── Component.js           # UI5 component
│       ├── index.html             # App entry point
│       └── manifest.json          # App metadata
├── node/                          # Node.js transpilation & test setup
│   ├── srv/                       # Express.js server + ABAP HTTP handler shim
│   ├── tests/                     # Playwright browser tests
│   ├── setup/                     # Build/transpilation config
│   └── playwright.config.js       # Browser test configuration
├── .github/
│   ├── workflows/                 # 17 CI/CD GitHub Actions workflows
│   ├── abaplint/                  # Additional linter configs per target
│   ├── app2abap/                  # Script to convert app files to ABAP classes
│   └── cleaner-profile.cfj        # ABAP Cleaner formatting profile
├── abaplint.jsonc                 # Main linter configuration (v750 syntax)
├── package.json                   # Node.js dependencies & npm scripts
└── .abapgit.xml                   # abapGit repository configuration
```

## Architecture

### Request/Response Flow

```
HTTP Request → z2ui5_cl_http_handler (factory) → z2ui5_cl_core_handler
  → Parse JSON → Load/Create App → app->main(client) → Build View/Handle Events
  → JSON Response → Browser (UI5 SPA)
```

### Layered Design

- **Layer 0 (`src/00/`)** — Self-contained utility libraries. AJSON handles all JSON work; S-RTTI provides runtime type reflection. General utilities (`src/00/03/`) include HTTP, logging, messaging, range, DB, and API helpers. The `noIssues` flag in `abaplint.jsonc` suppresses lint warnings for this layer since it mirrors external projects.
- **Layer 1 (`src/01/`)** — Core engine. Handles HTTP processing, session drafts (`src/01/01/`), event routing, data binding, model management, and app lifecycle (`src/01/02/`). Also contains embedded UI5 frontend resources as ABAP string constants (`src/01/03/`).
- **Layer 2 (`src/02/`)** — Public API. The interfaces and classes that application developers use. This is the stable contract. Includes a collection of built-in popup/dialog helper apps (`src/02/01/`) and the exit/customization framework.

### Key Design Patterns

- **Factory Pattern:** `z2ui5_cl_http_handler=>factory()` / `factory_cloud()` for on-premise vs. cloud
- **Fluent Builder:** `z2ui5_cl_xml_view=>factory()->shell()->page()->...->stringify()` builds XML views
- **Two-way Data Binding:** `client->_bind_edit(val)` binds ABAP variables to UI controls; `client->_bind(val)` for read-only binding
- **Event Routing:** `client->_event('EVENT_ID')` registers events; `client->check_on_event('EVENT_ID')` checks them
- **Stateful Sessions:** Draft service persists app state between requests via `check_sticky`
- **Exit Pattern:** `z2ui5_cl_exit` provides default HTTP config; users can override via `z2ui5_if_exit` implementations for custom themes, CSP headers, etc.
- **App Navigation:** `client->nav_app_call(app)` pushes a new app onto the stack; `client->nav_app_leave()` returns to the previous app
- **Multi-View Support:** Main view, nested views (nest/nest2), popups, and popovers can be displayed simultaneously

### How Apps Work

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
        " Build and display the view
        client->view_display( z2ui5_cl_xml_view=>factory(
          )->shell( )->page( 'Title'
          )->input( client->_bind_edit( name )
          )->button( text = 'Send' press = client->_event( 'POST' )
          )->stringify( ) ).
      WHEN client->check_on_event( 'POST' ).
        " Handle the event
        client->message_box_display( |Hello { name }| ).
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
```

### Client API Overview (`z2ui5_if_client`)

The client interface provides these method groups:

| Category | Methods | Purpose |
|---|---|---|
| View display | `view_display`, `view_destroy`, `view_model_update` | Main view lifecycle |
| Nested views | `nest_view_display/destroy/model_update`, `nest2_view_*` | Embedded sub-views |
| Popups | `popup_display`, `popup_destroy`, `popup_model_update` | Modal dialogs |
| Popovers | `popover_display`, `popover_destroy`, `popover_model_update` | Context popovers |
| Data binding | `_bind(val)`, `_bind_edit(val)` | Read-only and two-way binding |
| Events | `_event(val)`, `_event_client(val)`, `check_on_event(val)` | Event registration and checking |
| Navigation | `nav_app_call(app)`, `nav_app_leave()`, `get_app_prev()` | App stack navigation |
| Lifecycle | `check_on_init()`, `check_on_navigated()`, `check_app_prev_stack()` | State checks |
| Messages | `message_box_display(text)`, `message_toast_display(text)` | User notifications |
| Session | `set_session_stateful(val)`, `set_app_state_active(val)` | Session management |
| Browser | `set_push_state(val)`, `set_nav_back(val)`, `follow_up_action(val)` | Browser interaction |
| Info | `get()`, `get_event_arg()`, `get_app(id)` | Request/context data |

### Built-in Popup Apps (`src/02/01/`)

The framework ships with ready-to-use popup apps that can be called via `nav_app_call`:

| Class | Purpose |
|---|---|
| `z2ui5_cl_pop_to_confirm` | Confirmation dialog (yes/no) |
| `z2ui5_cl_pop_to_inform` | Information dialog |
| `z2ui5_cl_pop_to_select` | Selection dialog from a list |
| `z2ui5_cl_pop_get_range` / `_m` | Range/filter selection (single/multi) |
| `z2ui5_cl_pop_file_dl` / `_ul` | File download / upload |
| `z2ui5_cl_pop_table` | Table data display |
| `z2ui5_cl_pop_textedit` | Multi-line text editor |
| `z2ui5_cl_pop_pdf` | PDF viewer |
| `z2ui5_cl_pop_html` | HTML content display |
| `z2ui5_cl_pop_messages` | Message log display |
| `z2ui5_cl_pop_error` | Error detail display |
| `z2ui5_cl_pop_bal` | Application log display |
| `z2ui5_cl_pop_input_val` | Input with validation |
| `z2ui5_cl_pop_data` | Data inspector |
| `z2ui5_cl_pop_image_editor` | Image editing |
| `z2ui5_cl_pop_js_loader` | JavaScript library loader |

### Exit / Customization Framework

The exit interface (`z2ui5_if_exit`) allows customizing HTTP responses:

- `set_config_http_get` — Configure the initial HTML page (UI5 source URL, theme, CSP, title, custom JS/CSS, security headers)
- `set_config_http_post` — Configure POST behavior (draft expiration time)

`z2ui5_cl_exit` provides the default implementation and supports user-exit classes that can override these settings.

## Language & Naming Conventions

**Primary language:** ABAP (v750 syntax target, downported to v702 via CI)

### Naming Rules (enforced by abaplint)

| Object Type | Pattern | Example |
|---|---|---|
| Classes | `Z2UI5_CL_*` or `Z2UI5_CX_*` | `z2ui5_cl_core_handler` |
| Interfaces | `Z2UI5_IF_*` | `z2ui5_if_client` |
| Programs/Tables/etc. | `Z*` | — |

### ABAP Style Rules

- **Max method length:** 100 statements (test classes excluded)
- **Max cyclomatic complexity:** 20
- **Max nesting depth:** 5
- No aliases, no external form calls, no DEFINE macros
- No STATICS, no BREAK/BREAK-POINT
- Use class-based exceptions only
- Use `NEW #()` instead of `CREATE OBJECT`
- Use `xsdbool()` for boolean expressions
- Use `line_exists()` instead of READ TABLE checking sy-subrc
- Backtick string literals (`` ` ``) preferred over single quotes for string values
- No Yoda conditions
- Prefer `IS NOT` over `NOT ... IS`
- Prefer `RETURNING` over `EXPORTING` for single outputs
- SQL: use `@` host variable escaping, strict SQL mode
- No `EXPORT TO MEMORY`/`EXPORT TO DATABASE` (avoid_use rule)
- No test seams, no `DESCRIBE LINES` (use `lines()` instead)

### Allowed Object Types

Only these ABAP object types are permitted: `CLAS`, `DEVC`, `INTF`, `TABL`.

## Build & Development Commands

All commands run from the repository root. Install dependencies first with `npm install`.

| Command | Purpose |
|---|---|
| `npx abaplint` | Run ABAP static analysis (main rules) |
| `npx abaplint .github/abaplint/auto_abaplint_fix.jsonc --fix` | Auto-fix formatting issues |
| `npm run auto_downport` | Downport code to ABAP 7.02 syntax |
| `npm run auto_transpile` | Transpile ABAP to JavaScript |
| `npm run unit` | Run unit tests (requires prior transpile) |
| `npm run express` | Start Express.js dev server on port 3000 |
| `npm run auto_abaplint` | Run abaplint auto-fix profile |
| `npm run auto_app2abap` | Convert `app/` frontend files into ABAP classes |
| `npm run rename` | Test namespace renaming |

### Typical validation sequence

```bash
npx abaplint                          # Check for lint errors
npm run auto_downport                 # Downport for 7.02 compat
npm run auto_transpile                # Transpile ABAP → JS
npm run unit                          # Run unit tests
```

## CI/CD Workflows

### Testing Workflows
- **`test_unit.yaml`** — Transpiles ABAP to JS, runs unit tests
- **`test_node.yaml`** — Starts Express server, verifies it responds
- **`test_browser.yaml`** — Playwright end-to-end tests (Chromium, Firefox, WebKit)
- **`test_rename.yaml`** — Validates namespace renaming works

### Compatibility Workflows
- **`ABAP_702.yaml`** — Verifies compatibility with NW 7.02
- **`ABAP_STANDARD.yaml`** — Standard ABAP environment checks
- **`ABAP_CLOUD.yaml`** — ABAP Cloud environment checks
- **`UI5.yaml`** — UI5 framework integration tests

### Automation Workflows
- **`auto_downport.yaml`** — Automatic downporting to 7.02 syntax
- **`auto_transpile.yaml`** — Automatic ABAP-to-JS transpilation
- **`auto_abaplint_fix.yaml`** — Automatic code cleanup
- **`auto_abaplint_fix_pr.yaml`** — Automatic code cleanup via PR
- **`create_app2abap.yaml`** — Converts frontend files to ABAP classes
- **`create_frontend.yaml`** — Generates frontend artifacts

### Verification Workflows
- **`check_app.yaml`** — App integrity checks (skips bot commits, flags manual changes to `src/01/03`)

### Mirror Workflows
- **`mirror_ajson.yaml`** / **`mirror_srtti.yaml`** — Sync upstream library changes

## Testing

### ABAP Unit Tests
Test classes are embedded alongside source files with the `.testclasses.abap` suffix (about 42 files across all layers). They run via the abaplint transpiler in Node.js.

### Browser Tests
Playwright tests live in `node/tests/`. They test the full UI5 app in Chromium, Firefox, and WebKit against the Express dev server at `http://localhost:3000`.

## Key Files to Know

| File | Why It Matters |
|---|---|
| `src/02/z2ui5_if_app.intf.abap` | Main app interface — version constant lives here |
| `src/02/z2ui5_if_client.intf.abap` | All client interaction methods (view, events, binding, navigation) |
| `src/02/z2ui5_if_types.intf.abap` | Shared type definitions (HTTP config, draft, events, get result) |
| `src/02/z2ui5_if_exit.intf.abap` | Customization exit points (HTTP GET/POST config) |
| `src/02/z2ui5_cl_exit.clas.abap` | Default exit implementation + user-exit class support |
| `src/02/z2ui5_cl_xml_view.clas.abap` | Fluent view builder — largest file (~511KB), maps to UI5 controls |
| `src/02/z2ui5_cl_xml_view_cc.clas.abap` | Custom controls builder (~24KB) |
| `src/02/z2ui5_cl_http_handler.clas.abap` | HTTP entry point — factory methods for on-prem and cloud |
| `src/02/z2ui5_cl_app_startup.clas.abap` | Startup app with UI5 version selector |
| `src/01/02/z2ui5_cl_core_handler.clas.abap` | Central request processor |
| `src/01/02/z2ui5_cl_core_client.clas.abap` | Implements z2ui5_if_client |
| `src/01/02/z2ui5_cl_core_action.clas.abap` | Event/action dispatcher |
| `src/01/02/z2ui5_cl_core_app.clas.abap` | App lifecycle (create, load, serialize) |
| `src/01/02/z2ui5_cl_core_srv_bind.clas.abap` | Data binding engine |
| `src/01/02/z2ui5_cl_core_srv_event.clas.abap` | Event processing service |
| `src/01/02/z2ui5_cl_core_srv_model.clas.abap` | JSON model management |
| `src/01/02/z2ui5_cl_core_srv_util.clas.abap` | Core utility functions |
| `src/01/02/z2ui5_if_core_types.intf.abap` | Internal type definitions for core engine |
| `src/01/01/z2ui5_cl_core_srv_draft.clas.abap` | Draft/session persistence |
| `src/00/01/z2ui5_cl_ajson.clas.abap` | JSON handling (mirrored from external project) |
| `src/00/03/z2ui5_cl_util.clas.abap` | General utility class |
| `abaplint.jsonc` | Linter rules — source of truth for code standards |

## Commit Message Style

The project uses a concise style with capitalized or lowercase first word. Examples from recent history:

```
Refactor code for improved readability and maintainability (#2130)
add unit tests (#2129)
improve code clarity (#2127)
fix downport+unit test (#2128)
Add comprehensive unit tests for utility and UI5 classes (#2126)
Refactor: Extract methods and optimize service initialization (#2125)
Refactor frontend for improved maintainability (#2124)
fix ushell error in console (#2120)
perf: optimize table lookups in z2ui5_cl_core_srv_model (#2110)
```

When following conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, `perf:`.

## Important Considerations for AI Assistants

1. **Do not modify `src/00/`** unless explicitly asked. Layer 0 (AJSON, S-RTTI) is mirrored from external projects and synced by automated workflows.

2. **The `z2ui5_cl_xml_view` class is very large** (~511KB). It contains a fluent method for nearly every UI5 control. Read only the sections you need.

3. **Multi-environment compatibility matters.** Code must work across NW 7.02, standard ABAP, and ABAP Cloud. The `downport` rule in abaplint enforces this. Avoid syntax that only exists in newer ABAP releases unless it can be downported.

4. **abaplint is the primary quality gate.** Always validate changes with `npx abaplint` before considering them complete.

5. **Frontend files in `app/` are converted to ABAP classes** in `src/01/03/` via the `auto_app2abap` script. If you modify frontend behavior, the canonical source is `app/webapp/`, not the generated ABAP classes. Never manually edit files in `src/01/03/`.

6. **The public API is in `src/02/`.** The four interfaces (`z2ui5_if_app`, `z2ui5_if_client`, `z2ui5_if_types`, `z2ui5_if_exit`) form the stable contract. Changes here affect all downstream applications.

7. **String literals use backticks.** The project prefers `` `string` `` over `'string'` for ABAP string values.

8. **No database operations in loops.** The `db_operation_in_loop` rule is enforced.

9. **All ABAP objects use the `Z2UI5_` namespace prefix.** Follow the naming patterns defined in `abaplint.jsonc`.

10. **The popup library (`src/02/01/`) provides reusable UI components.** Use these built-in popups (confirm, inform, select, file upload/download, etc.) rather than building custom ones. They follow the same `z2ui5_if_app` pattern and are called via `nav_app_call`.

11. **The `z2ui5_cl_xml_view` class has a `method_overwrites_builtin` exception** in abaplint because many of its fluent methods intentionally match UI5 control names that may collide with ABAP built-in names.

12. **The `forbidden_void_type` rule blocks many SAP standard types.** If you need types like `flag`, `int4`, `char10`, `abap_boolean`, `stringtab`, etc., use ABAP built-in equivalents instead (e.g., `abap_bool`, `i`, `string`).
